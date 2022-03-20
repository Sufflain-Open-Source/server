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

;; track: xexpr group-list (listof teacher?) jsexpr? -> void?
;; Find changes in the blog page and timetables, add to the DB.
(define (track blog-page groups teachers config
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
                      (car (post-hashes POST)) (blog-post-order (post-blogpt POST))
                      config))
    (track-and-update POSTS teachers config)
    (remove-redundant POSTS-HASHES groups teachers config)))

;; track-and-update: (listof post?) (listof teacher?) jsexpr? -> void?
;; Track timetable changes and add to the DB.
(define (track-and-update posts teachers config)
  (let* ([DB-HASHES          (get-hashes config)]
         [get-db-vhash       (lambda (post-khash)
                               (hash-ref DB-HASHES post-khash))]
         [add-or-update-data (lambda (data-adder db-info blog-post-title post-khash post-vhash timetables config)
                               (define KHASH-STRING (symbol->string post-khash))
                               (data-adder db-info
                                           blog-post-title
                                           KHASH-STRING
                                           timetables
                                           config))])
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
              (add-hash DB-INFO (symbol->string POST-KHASH) POST-VHASH config)
              (add-or-update-data add-all-groups-timetables
                                  DB-INFO BPOST-TITLE POST-KHASH POST-VHASH TIMETABLES config)
              (add-or-update-data add-all-teachers-timetables
                                  DB-INFO BPOST-TITLE POST-KHASH POST-VHASH TEACHERS-TIMETABLES config))))))))

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