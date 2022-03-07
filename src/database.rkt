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
         json
         openssl/md5)

(provide add-all-teachers-timetables
         add-all-groups-timetables
         add-hash
         get-hashes
         get-groups
         get-names
         add-groups
         add-names
         add)

;; add-names: (listof string?) string? jsexpr? -> jsexpr?
;; Add teachers' names.
(define (add-names names auth-token config)
  (let*
      ([DB           (get-database-info config)]
       [NAMES-PATH   (database-teachers-names-path DB)]
       [NAMES-HASHES (for/list
                         ([NAME names])
                       `(,(string->symbol (md5 (open-input-string NAME))) . ,NAME))]
       [NAMES/JSON   (jsexpr->string (make-immutable-hasheq NAMES-HASHES))])
    (add DB NAMES/JSON NAMES-PATH auth-token)))

;; add-all-teachers-timetables: jsexpr? string? string? string? (listof teacher-timetable?) -> jsepxr?
;; Add timetables for all teachers.
(define (add-all-teachers-timetables db-info link-title khash token timetables)
  (for ([TABLE timetables])
    (let* ([TEACHER              (teacher-timetable-teacher TABLE)]
           [TIMETABLES           (teacher-timetable-group-timetables TABLE)]
           [NUMBER-OF-TIMETABLES (length TIMETABLES)]
           [TABLES               (for/list ([GROUP-TIMETABLE TIMETABLES]
                                            [i               NUMBER-OF-TIMETABLES])
                                   (let*
                                       ([TITLE            (group-timetable-title GROUP-TIMETABLE)]
                                        [GROUP-ID         (select-group-from-title TITLE)]
                                        [TIMETABLE-JSEXPR (group-timetable-as-jsexpr "" GROUP-TIMETABLE)])
                                     TIMETABLE-JSEXPR))])
      (add db-info
           (jsexpr->string (make-immutable-hasheq `((linkTitle . ,link-title)
                                                    (data . ,TABLES))))
           (string-append (database-teachers-timetable-path db-info) "/"
                          (teacher-hash TEACHER) "/"
                          khash "/")
           token))))

;; add-all-groups-timetables: jsexpr? string? string? string? (listof group-timetable?) -> jsexpr?
;; Add timetables for all groups.
(define (add-all-groups-timetables db-info link-title khash token timetables)
  (for ([TABLE timetables])
    (let* ([TITLE          (group-timetable-title TABLE)]
           [GROUP-ID       (select-group-from-title TITLE)]
           [TIMETABLE-JSON (jsexpr->string
                            (group-timetable-as-jsexpr link-title TABLE))])
      (add db-info
           TIMETABLE-JSON
           (string-append (database-timetable-path db-info) "/" GROUP-ID "/" khash)
           token))))

;; add-hash: jsexpr? string? string? string? -> jsexpr?
;; Add a pair of hashes to the DB.
(define (add-hash db-info khash vhash token)
  (define HASHES-PATH (database-hashes-path db-info))
  (add db-info (jsexpr->string vhash) (string-append HASHES-PATH "/" khash) token))

;; get-names: jsexpr? string? -> (listof teacher?)
;; Get teachers names.
(define (get-names config token)
  (define NAMES/LIST (get database-teachers-names-path config token))
  (if (eq? NAMES/LIST 'null)
      null
      (for/list
          ([ENTRY (hash->list NAMES/LIST)])
        (teacher (symbol->string (car ENTRY)) (cdr ENTRY)))))

;; get-hashes: jsexpr? string? -> jsexpr?
;; Get hashes from the DB.
(define (get-hashes config token)
  (get database-hashes-path config token))

;; get-groups: jsexpr? string? -> (listof string?)
;; Get groups from the DB.
(define (get-groups config token)
  (get database-groups-path config token))

;; add-groups: string? string? jsexpr? -> string?
;; Add groups to the database. If they are already present, replace them.
(define (add-groups groups auth-token config)
  (let*
      ([DB          (get-database-info config)]
       [GROUPS-PATH (database-groups-path DB)])
    (add DB groups GROUPS-PATH auth-token)))

;; get: procedure? jsexpr? string? -> any/c
(define (get get-db-path-proc config token)
  (let*
      ([DB          (get-database-info config)]
       [DB-URL      (database-url DB)]
       [PATH        (get-db-path-proc DB)]
       [REQUEST-URL (string-append DB-URL PATH ".json" "?auth=" token)])
    (http-get REQUEST-URL)))

;; add: database? string? string? string? -> jsepxr?
(define (add db-info payload path auth-token
             #:get-database-info-mock [get-database-info     get-database-info]
             #:with-json-payload-mock [with-json-payload/put with-json-payload/put])
  (let*
      ([DB-URL      (database-url db-info)]
       [REQUEST-URL (string-append DB-URL path ".json" "?auth=" auth-token)])
    (with-json-payload/put REQUEST-URL payload)))

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

  (check-equal? (add (GET-DATABASE-INFO-MOCK) "[\"СА21-19\"]" "" ""
                     #:get-database-info-mock GET-DATABASE-INFO-MOCK
                     #:with-json-payload-mock WITH-JSON-PAYLOAD-MOCK) "[\"СА21-19\"]"))
