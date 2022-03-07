#|
    Copyright (C) 2021  Timofey Chuchkanov

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
|#

#lang racket/base

(require "blog-scraper.rkt"
         "scraper.rkt"
         "database.rkt"
         "config.rkt"
         "requests.rkt"
         "teachers-timetable-builder.rkt"
         sxml
         openssl/md5)

(provide track)

;; hashes is one of:
;;   - null
;;   - (cons string? string?)
;; It holds hashes for a blog-post and for a list of <tbody>s.

;; post is a structure.
;; It contains a blog post link and title, its data and hashes.
;; (post blog-post? (listof xexpr) pair?)
(struct post [blogpt data hashes])

;; track: xexpr group-list (listof teacher?) jsexpr? string? -> void?
;; Find changes in the blog page and timetables, add to the DB.
(define (track blog-page groups teachers config token
               #:track-update-mock [track-and-update track-and-update]
               #:remove-redundant-mock [remove-redundant remove-redundant])
  (let*
      ([BLOG-POSTS   (select-blog-posts blog-page config)]
       [POSTS        (map (lambda (bpost)
                            (let*
                                ([TIMETABLE-PAGE (get-page (blog-post-link bpost))]
                                 [TBODYS         (select-tbodys TIMETABLE-PAGE)]
                                 [BLOG-POST-HASH (string->symbol (blog-post-hash bpost))]
                                 [TBODYS-HASH    (tbodys-hash TBODYS)]
                                 [HASHES         (cons BLOG-POST-HASH TBODYS-HASH)])
                              (post bpost TBODYS HASHES))) BLOG-POSTS)]
       [POSTS-HASHES (make-immutable-hasheq (map post-hashes POSTS))])
    (for ([POST POSTS])
      (add-post-order (get-database-info config)
                      (car (post-hashes POST)) (blog-post-order (post-blogpt POST)) token))
    (track-and-update POSTS teachers config token)
    (remove-redundant POSTS-HASHES groups teachers config token)))

;; track-and-update: (listof post?) (listof teacher?) jsexpr? string? -> void?
;; Track timetable changes and add to the DB.
(define (track-and-update posts teachers config token)
  (let* ([DB-HASHES          (get-hashes/safe config token)]
         [get-db-vhash       (lambda (post-khash)
                               (hash-ref DB-HASHES post-khash))]
         [add-or-update-data (lambda (data-adder db-info blog-post-title post-khash post-vhash timetables)
                               (define KHASH-STRING (symbol->string post-khash))
                               (data-adder db-info
                                           blog-post-title
                                           KHASH-STRING
                                           token
                                           timetables))])
    (unless (null? posts)
      (let ([DB-INFO (get-database-info config)])
        (for ([post posts])
          (let* ([POST-KHASH          (car (post-hashes post))]
                 [POST-VHASH          (cdr (post-hashes post))]
                 [BPOST               (post-blogpt post)]
                 [BPOST-TITLE         (blog-post-title BPOST)]
                 [TIMETABLES          (select-all-groups-timetables (post-data post))]
                 [TEACHERS-TIMETABLES (select-all-teachers-timetables teachers TIMETABLES)])
            (unless (if (hash-has-key? DB-HASHES POST-KHASH)
                        (if (equal? (get-db-vhash POST-KHASH) POST-VHASH)
                            #t
                            #f)
                        #f)
              (add-hash DB-INFO (symbol->string POST-KHASH) POST-VHASH token)
              (add-or-update-data add-all-groups-timetables
                                  DB-INFO BPOST-TITLE POST-KHASH POST-VHASH TIMETABLES)
              (add-or-update-data add-all-teachers-timetables
                                  DB-INFO BPOST-TITLE POST-KHASH POST-VHASH TEACHERS-TIMETABLES))))))))

;; remove-redundant: (listof hashes) group-list (listof teacher?) jsexpr? string? -> void?
;; Remove redundant timetables for each group.
(define (remove-redundant hashes groups teachers config token)
  (let ([DB-HASHES (get-hashes/safe config token)]
        [DB-INFO   (get-database-info config)])
    (unless (hash-empty? DB-HASHES)
      (if (hash-empty? hashes)
          ((lambda ()
             (hash-for-each DB-HASHES
                            (lambda (key val)
                              (delete-timetables groups teachers key DB-INFO token)))
             (delete-all-hash-pairs DB-INFO token)))
          (hash-for-each DB-HASHES
                         (lambda (key val)
                           (unless (hash-has-key? hashes key)
                             (delete-timetables groups teachers key DB-INFO token)
                             (delete-hash-pair key DB-INFO token)
                             (remove-post-order DB-INFO key token))))))))

;; remove-post-order: jsexpr? symbol? string? -> jsexpr?
;; Remove the blog post order from the database.
(define (remove-post-order db-info khash token)
  (define ORDERS-PATH (database-order-path db-info))
  (http-delete (string-append (database-url db-info)
                              ORDERS-PATH "/" (symbol->string khash) ".json" "?auth=" token)))

;; add-post-order: jsexpr? symbol? number? string? -> jsexpr?
;; Add a number that represents a post order on the blog page.
(define (add-post-order db-info khash order token)
  (define ORDERS-PATH (database-order-path db-info))
  (add db-info (number->string order) (string-append ORDERS-PATH "/" (symbol->string khash)) token))

;; get-hashes/safe: jsexpr? string? -> hash?
;; Get hashes from the DB.
(define (get-hashes/safe config token)
  (define h (get-hashes config token))
  (if (equal? h 'null)
      #hasheq()
      h))

;; delete-timetables: group-list (listof teacher?) string? jsexpr? string? -> void?
;; Locate a timetable by khash and delete for each group.
(define (delete-timetables groups teachers khash db token)
  (let*
      ([URL                    (database-url db)]
       [TIMETABLE-PATH         (database-timetable-path db)]
       [make-timetable-del-url (lambda (location)
                                 (string-append URL TIMETABLE-PATH "/" location "/"
                                                (symbol->string khash) ".json" "?auth=" token))])
    (for ([GROUP groups])
      (http-delete (make-timetable-del-url GROUP)))
    (for ([TEACHER teachers])
      (http-delete (make-timetable-del-url (teacher-hash TEACHER))))))

;; delete-all-hash-pairs: jsexpr string? -> jsexpr?
;; Delete all hash pairs from the DB.
(define (delete-all-hash-pairs db token)
  (let*
      ([URL         (database-url db)]
       [HASHES-PATH (database-hashes-path db)])
    (http-delete (string-append URL HASHES-PATH ".json" "?auth=" token))))

;; delete-hash-pair: symbol? jsexpr? string? -> jsexpr?
;; Locate a pair of hashes by khash and delete it.
(define (delete-hash-pair khash db token)
  (let*
      ([URL          (database-url db)]
       [HASHES-PATH  (database-hashes-path db)]
       [HASH-DEL-URL (string-append URL HASHES-PATH "/" (symbol->string khash) ".json" "?auth=" token)])
    (http-delete HASH-DEL-URL)))

;; tbodys-hash: (listof xexpr) -> string?
;; Compute MD5 hash for a list of <tbody>s.
(define (tbodys-hash lotb)
  (define TBODYS-STRING (listof-tbody->string lotb))
  (md5 (open-input-string TBODYS-STRING)))

;; listof-tbody->string: (listof xexpr) -> string?
;; Represent timetables <tbody>s as a string to compute hash later.
(define (listof-tbody->string lot)
  (define LIST-OF-TBODY-STRING (map srl:sxml->html lot))
  (foldr string-append "" LIST-OF-TBODY-STRING))

;; blog-post-string-hash: blog-post?
;; Compute MD5 hash of the given blog-post.
(define (blog-post-hash bpost)
  (define BLOG-POST-STRING (blog-post->stirng bpost))
  (md5 (open-input-string BLOG-POST-STRING)))

;; blog-post->string: blog-post? -> string?
;; Represent blog-post as a string of the following form:
;;   "<title>@<link>"
(define (blog-post->stirng bpost)
  (let
      ([TITLE (blog-post-title bpost)]
       [LINK  (blog-post-link bpost)])
    (string-append TITLE "@" LINK)))

(module+ test
  (require rackunit)

  (define EXAMPLE-BLOG-POST (blog-post "title" "link" 0))

  (check-equal? (tbodys-hash '((*TOP* (tbody)) (*TOP* (tbody))))
                (md5 (open-input-string "<tbody /><tbody />")))

  (check-equal? (blog-post-hash (blog-post "Расписание занятий на ..."
                                           "/some/path"
                                           0))
                (md5 (open-input-string "Расписание занятий на ...@/some/path")))

  (check-equal? (blog-post->stirng EXAMPLE-BLOG-POST)
                "title@link")

  (check-equal? (listof-tbody->string  '((tbody) (tbody)))
                "<tbody /><tbody />"))