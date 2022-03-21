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

(require "config.rkt"
         "blog-scraper.rkt"
         "requests.rkt"
         "teachers-timetable-builder.rkt"
         "util.rkt"
         "auth.rkt"
         json
         openssl/md5
         racket/hash)

(provide (all-defined-out))

;; remove-redundant: (listof hashes) group-list (listof teacher?) jsexpr? -> void?
;; Remove redundant timetables for each group.
(define (remove-redundant hashes groups teachers config)
  (let ([DB-HASHES (get-hashes config)]
        [DB-INFO   (get-database-info config)])
    (unless (hash-empty? DB-HASHES)
      (if (hash-empty? hashes)
          ((lambda ()
             (hash-for-each DB-HASHES
                            (lambda (key val)
                              (delete-timetables groups teachers key DB-INFO config)))
             (delete-all-hash-pairs DB-INFO config)))
          (hash-for-each DB-HASHES
                         (lambda (key val)
                           (unless (hash-has-key? hashes key)
                             (delete-timetables groups teachers key DB-INFO config)
                             (delete-hash-pair key DB-INFO config)
                             (remove-post-order DB-INFO key config))))))))

;; remove-post-order: jsexpr? symbol? jsexpr? -> jsexpr?
;; Remove the blog post order from the database.
(define (remove-post-order db-info khash config)
  (let*
      ([ORDERS-PATH     (database-order-path db-info)]
       [ORDERS          (get/safe database-order-path config)])
    (add db-info
         (jsexpr->string (hash-remove ORDERS khash))
         ORDERS-PATH
         config)))

;; add-post-order: jsexpr? symbol? number? jsexpr? -> jsexpr?
;; Add a number that represents a post order on the blog page.
(define (add-post-order db-info khash order config)
  (let*
      ([ORDERS-PATH     (database-order-path db-info)]
       [ORDERS          (get/safe database-order-path config)])
    (add db-info
         (jsexpr->string (hash-set ORDERS khash order))
         ORDERS-PATH
         config)))

;; delete-timetables: group-list (listof teacher?) symbol? jsexpr? jsexpr? -> void?
;; Locate a timetable by khash and delete for each group.
(define (delete-timetables groups teachers khash db config)
  (let*
      ([URL                        (database-url db)]
       [TIMETABLE-PATH             (database-timetable-path db)]
       [TEACHERS-TIMETABLE-PATH    (database-teachers-timetable-path db)]
       [add-data                   (lambda (jsexpr path)
                                     (add db (jsexpr->string jsexpr) path config))]
       [remove-selected-entry-from (lambda (tables)
                                     (hash-remove tables khash))]
       [select-tables-by           (lambda (key from)
                                     (hash-ref from (string->symbol key) #hasheq()))]
       [add-table-for              (lambda (target)
                                     (let*
                                         ([GET-PATH-PROC          (if (string? target)
                                                                      database-timetable-path
                                                                      database-teachers-timetable-path)]
                                          [ALL-TABLES             (get/safe GET-PATH-PROC
                                                                            config)]
                                          [TARGET-TABLES          (select-tables-by (if (string? target)
                                                                                        target
                                                                                        (teacher-hash target)) ALL-TABLES)]
                                          [WITHOUT-SELECTED-ENTRY (remove-selected-entry-from TARGET-TABLES)])
                                       (add-data (hash-set ALL-TABLES (string->symbol (if (string? target)
                                                                                          target
                                                                                          (teacher-hash target)))
                                                           WITHOUT-SELECTED-ENTRY)
                                                 (GET-PATH-PROC db))))])
    (display "\nDELETING TIMETABLES ...\n")
    (for ([GROUP groups])
      (display (string-append "FOR GROUP: [" GROUP "] ...\r"))
      (add-table-for GROUP))
    (display "\n")
    (for ([TEACHER teachers])
      (display (string-append "FOR TEACHER: [" (teacher-name TEACHER) "] ...\r"))
      (add-table-for TEACHER))))

;; delete-all-hash-pairs: jsexpr jsexpr -> jsexpr?
;; Delete all hash pairs from the DB.
(define (delete-all-hash-pairs db config)
  (let*
      ([URL         (database-url db)]
       [HASHES-PATH (database-hashes-path db)]
       [HASHES-REV  (get-doc-rev database-hashes-path config)])
    (display "\nDELETING ALL HASH PAIRS ...")
    (add db
         (set-rev-if-needed (jsexpr->string #hasheq()) HASHES-REV)
         HASHES-PATH
         config)))

;; delete-hash-pair: symbol? jsexpr? jsexpr? -> jsexpr?
;; Locate a pair of hashes by khash and delete it.
(define (delete-hash-pair khash db config)
  (let*
      ([HASHES-PATH (database-hashes-path db)]
       [HASHES      (get/safe database-hashes-path config)])
    (display (string-append "\nDELETING HASH PAIR: " (symbol->string khash) " ..."))
    (add db
         (jsexpr->string (hash-remove HASHES khash))
         HASHES-PATH
         config)))

;; add-names: (listof string?) jsexpr? -> jsexpr?
;; Add teachers' names.
(define (add-names names config)
  (let*
      ([DB           (get-database-info config)]
       [NAMES-PATH   (database-teachers-names-path DB)]
       [NAMES-HASHES (for/list
                         ([NAME names])
                       `(,(string->symbol (md5 (open-input-string NAME))) . ,NAME))]
       [NAMES/JSON   (jsexpr->string (make-immutable-hasheq
                                      (list
                                       (cons
                                        'data (make-immutable-hasheq NAMES-HASHES)))))]
       [NAMES-REV    (get-doc-rev database-teachers-names-path config)])
    (display (string-append "\nADDING NAMES (" (length names) ") ..."))
    (add DB
         (set-rev-if-needed NAMES/JSON NAMES-REV)
         NAMES-PATH
         config)))

;; add-all-teachers-timetables: jsexpr? string? string? (listof teacher-timetable?) jsexpr? -> jsepxr?
;; Add timetables for all teachers.
(define (add-all-teachers-timetables db-info link-title khash timetables config)
  (display "\nADDING TEACHERS TIMETABLES ...\n")
  (for ([TABLE timetables])
    (let* ([TEACHER                (teacher-timetable-teacher TABLE)]
           [TIMETABLES             (teacher-timetable-group-timetables TABLE)]
           [NUMBER-OF-TIMETABLES   (length TIMETABLES)]
           [TABLES                 (for/list ([GROUP-TIMETABLE TIMETABLES]
                                              [i               NUMBER-OF-TIMETABLES])
                                     (group-timetable-as-jsexpr "" GROUP-TIMETABLE))]
           [ALL-TIMETABLES         (get/safe database-teachers-timetable-path config)]
           [ALL-TEACHER-TIMETABLES (hash-ref ALL-TIMETABLES (string->symbol (teacher-hash TEACHER)) #hasheq())]
           [TEACHER-TIMETABLES     (make-immutable-hasheq
                                    `((linkTitle . ,link-title)
                                      (data      . ,TABLES)))])
      (display (string-append "FOR TEACHER: [" (teacher-name TEACHER) "] ...\r"))
      (add db-info
           (jsexpr->string (hash-set ALL-TIMETABLES (string->symbol (teacher-hash TEACHER))
                                     ;; We need to use hash-union/safe to avoid a confilct
                                     ;; if both hash tables have entries with the same key.
                                     ;; Same as in the add-all-groups-timetables.
                                     (hash-union/safe (make-immutable-hasheq (list (cons (string->symbol khash)
                                                                                         TEACHER-TIMETABLES)))
                                                      ALL-TEACHER-TIMETABLES)))
           (database-teachers-timetable-path db-info)
           config))))

;; add-all-groups-timetables: jsexpr? string? string? (listof group-timetable?) jsexpr? -> jsexpr?
;; Add timetables for all groups.
(define (add-all-groups-timetables db-info link-title khash timetables config)
  (display "\nADDING TIMETABLES ...\n")
  (for ([TABLE timetables])
    (let* ([TITLE            (group-timetable-title TABLE)]
           [GROUP-ID         (select-group-from-title TITLE)]
           [TIMETABLE-JSEXPR (make-immutable-hasheq (list (cons (string->symbol khash)
                                                                (group-timetable-as-jsexpr link-title TABLE))))]
           [ALL-TIMETABLES   (get/safe database-timetable-path config)]
           [GROUP-TIMETABLES (hash-ref ALL-TIMETABLES (string->symbol GROUP-ID) #hasheq())])
      (display (string-append "FOR GROUP: [" GROUP-ID "] ...\r"))
      (add db-info
           (jsexpr->string (hash-set ALL-TIMETABLES (string->symbol GROUP-ID)
                                     ;; Same as in the add-all-teachers-timetables.
                                     (hash-union/safe TIMETABLE-JSEXPR
                                                      GROUP-TIMETABLES)))
           (database-timetable-path db-info)
           config))))

;; hash-union/safe: hash? hash? -> hash?
;; Create a hash union. If both hashes contain entries with the same key, the value will be replaced by {pri}'s value.
(define (hash-union/safe pri sec)
  (hash-union pri
              sec
              #:combine (lambda (new exs) new)))

;; add-hash: jsexpr? string? string? jsexpr? -> jsexpr?
;; Add a pair of hashes to the DB.
(define (add-hash db-info khash vhash config)
  (let*
      ([HASHES-PATH (database-hashes-path db-info)]
       [HASHES      (get-hashes config)])
    (add db-info (jsexpr->string (hash-set HASHES (string->symbol khash) vhash)) HASHES-PATH config)))

;; get-names: jsexpr? -> (listof teacher?)
;; Get teachers names.
(define (get-names config)
  (define NAMES (hash-ref (get/safe database-teachers-names-path config) 'data null))
  (if (hash? NAMES)
      (for/list
          ([ENTRY (hash->list NAMES)])
        (teacher (symbol->string (car ENTRY)) (cdr ENTRY)))
      NAMES))

;; get-hashes: jsexpr? -> jsexpr?
;; Get hashes from the DB.
(define (get-hashes config)
  (hash-remove (hash-remove (get/safe database-hashes-path config) '_rev) '_id))

;; get-groups: jsexpr? -> (listof string?)
;; Get groups from the DB.
(define (get-groups config)
  (hash-ref (get/safe database-groups-path config)
            'data
            null))

;; add-groups: string? jsexpr? -> string?
;; Add groups to the database. If they are already present, replace them.
(define (add-groups groups config)
  (let*
      ([DB          (get-database-info config)]
       [GROUPS-PATH (database-groups-path DB)]
       [GROUPS-REV  (get-doc-rev database-groups-path config)])
    (display (string-append "\nADDING GROUPS (" (length groups) ")..."))
    (add DB
         (set-rev-if-needed groups GROUPS-REV)
         GROUPS-PATH config)))

;; set-rev-if-needed: string? string?
;; Set _rev if an update is necessary.
(define (set-rev-if-needed json rev)
  (if (>= (string-length rev) 1)
      (jsexpr->string (hash-set (string->jsexpr json) '_rev rev))
      json))

;; get/safe: procedure? jsexpr? -> any/c
;; Returns an empty list if there is an error.
(define (get/safe get-db-path-proc config)
  (define RESULT (get get-db-path-proc config))
  (if (has-error? RESULT)
      #hasheq()
      RESULT))

;; get-doc-rev: procedure? jsexpr? -> string?
;; Get document revision.
(define (get-doc-rev get-db-path-proc config)
  (define DOC (get/safe get-db-path-proc config))
  (define REV-KEY '_rev)
  (if (hash-has-key? DOC REV-KEY)
      (hash-ref DOC REV-KEY)
      ""))

;; get: procedure? jsexpr? -> any/c
(define (get get-db-path-proc config)
  (let*
      ([DB          (get-database-info config)]
       [DB-URL      (database-url DB)]
       [PATH        (get-db-path-proc DB)]
       [REQUEST-URL (string-append DB-URL PATH)])
    (http-get REQUEST-URL #:header (make-auth-header config))))

;; add: database? string? string? jsexpr? -> jsepxr?
(define (add db-info payload path config
             #:with-json-payload-mock [with-json-payload/put with-json-payload/put])
  (let*
      ([DB-URL      (database-url db-info)]
       [REQUEST-URL (string-append DB-URL path)])
    (with-json-payload/put REQUEST-URL payload #:header (make-auth-header config))))

;; has-error?: hash? -> boolean?
;; Returns true if the hash contains an 'error key.
(define (has-error? hash)
  (hash-has-key? hash 'error))

(module+ test
  (require "shared/mocks.rkt"
           rackunit
           racket/function
           mock)

  (define GET-DATABASE-INFO-MOCK (mock
                                  #:behavior (const
                                              (get-database-info (GET-CONFIG-MOCK)))))
  (define WITH-JSON-PAYLOAD-MOCK (mock
                                  #:behavior (const "[\"СА21-19\"]")))

  (check-equal? (add (GET-DATABASE-INFO-MOCK) "[\"СА21-19\"]" ""
                     (GET-CONFIG-MOCK)
                     #:with-json-payload-mock WITH-JSON-PAYLOAD-MOCK) "[\"СА21-19\"]"))
