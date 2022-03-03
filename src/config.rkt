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

(require "shared/keys.rkt"
         json
         racket/function
         racket/port)

(provide identity-toolkit
         identity-toolkit?
         identity-toolkit-url
         user
         user?
         user-email
         user-password
         database
         database?
         app-props
         app-props-sleep-time
         app-props?
         get-app-props
         database-url
         database-api-key
         database-groups-path
         database-timetable-path
         database-hashes-path
         database-order-path
         database-teachers-names-path
         database-teachers-timetable-path
         college-site
         college-site?
         college-site-url
         college-site-blog-path
         get-identity-toolkit
         get-user-credentials
         get-database-info
         get-college-site-info
         get-config)

(define CONFIG-DIR-PATH
  (string-append
   (path->string
    (find-system-path 'home-dir))
   "/.config"))
(define CONFIG-PATH
  (string-append CONFIG-DIR-PATH "/sufflain-config.json"))

;; identity-toolkit is a structure.
;; It contains Google's Identity Toolkit url.
;; (identity-toolkit string?)
(struct identity-toolkit [url])

;; user is a structure.
;; It contatins user's email and password that are used for authentication.
;; (user string? string?)
(struct user [email password])

;; database is a structure.
;; It contains a URL of the database and an API key.
;; (database string? string? string? string? string? string? string? string?)
(struct database [url
                  api-key
                  groups-path
                  timetable-path
                  hashes-path
                  order-path
                  teachers-names-path
                  teachers-timetable-path])

;; college-site is a structure.
;; It contains a site URL and a blog path.
;; (college-site string? string?)
(struct college-site [url blog-path])

;; sleep-time is a structure.
;; It contains server app properties such as sleep time.
;; (app-props number?)
(struct app-props [sleep-time])

;; get-app-props: jsexpr? -> app-props?
;; Read app properties from the config file.
(define (get-app-props config)
  (let*
      ([APP-PROPS            (hash-ref config    CONFIG-APP-PROPS-KEY)]
       [APP-PROPS-SLEEP-TIME (hash-ref APP-PROPS CONFIG-APP-PROPS-SLEEP-TIME-KEY)])
    (app-props APP-PROPS-SLEEP-TIME)))

;; get-identity-toolit: jsexpr? -> identity-toolkit?
;; Read identity toolkit info from the config file.
(define (get-identity-toolkit config)
  (let*
      ([IDENTITY-TOOLKIT     (hash-ref config           CONFIG-IDENTITY-TOOLKIT-KEY)]
       [IDENTITY-TOOLKIT-URL (hash-ref IDENTITY-TOOLKIT CONFIG-IDENTITY-TOOLKIT-URL-KEY)])
    (identity-toolkit IDENTITY-TOOLKIT-URL)))

;; get-user-credentials: jsexpr? -> user?
;; Read user credentials from the config file.
(define (get-user-credentials config)
  (let*
      ([USER     (hash-ref config CONFIG-USER-KEY)]
       [EMAIL    (hash-ref USER   CONFIG-USER-EMAIL-KEY)]
       [PASSWORD (hash-ref USER   CONFIG-USER-PASSWORD-KEY)])
    (user EMAIL PASSWORD)))

;; get-database-info: jsexpr? -> database?
;; Read necessary info about the database from the config file.
(define (get-database-info config)
  (let*
      ([DATABASE                (hash-ref config   CONFIG-DATABASE-KEY)]
       [URL                     (hash-ref DATABASE CONFIG-DATABASE-URL-KEY)]
       [API-KEY                 (hash-ref DATABASE CONFIG-DATABASE-API-KEY)]
       [GROUPS-PATH             (hash-ref DATABASE CONFIG-DATABASE-GROUPS-PATH-KEY)]
       [TIMETABLE-PATH          (hash-ref DATABASE CONFIG-DATABASE-TIMETABLE-PATH-KEY)]
       [HASHES-PATH             (hash-ref DATABASE CONFIG-DATABASE-HASHES-PATH-KEY)]
       [ORDER-PATH              (hash-ref DATABASE CONFIG-DATABASE-ORDER-PATH-KEY)]
       [NAMES-PATH              (hash-ref DATABASE CONFIG-DATABASE-NAMES-PATH-KEY)]
       [TEACHERS-TIMETABLE-PATH (hash-ref DATABASE CONFIG-DATABASE-TEACHERS-TIMETABLE-PATH-KEY)])
    (database URL API-KEY GROUPS-PATH TIMETABLE-PATH HASHES-PATH ORDER-PATH NAMES-PATH TEACHERS-TIMETABLE-PATH)))

;; get-college-site-info: jsexpr? -> college-site?
;; Read college site info from the config site.
(define (get-college-site-info config)
  (let*
      ([COLLEGE-SITE (hash-ref config       CONFIG-COLLEGE-SITE-KEY)]
       [URL          (hash-ref COLLEGE-SITE CONFIG-COLLEGE-SITE-URL-KEY)]
       [BLOG-PATH    (hash-ref COLLEGE-SITE CONFIG-COLLEGE-SITE-BLOG-PATH-KEY)])
    (college-site URL BLOG-PATH)))

;; get-config: nothing -> jsexpr
;; Read data from the config file.
(define (get-config #:config-exists-mock [config-exists? config-exists?]
                    #:file-reader-mock   [port->string   port->string])
  (define FILE-PORT (if (config-exists?)
                        (open-input-file CONFIG-PATH)
                        #f))
  (if (boolean? FILE-PORT)
      (raise exn:fail:filesystem)
      (read-json FILE-PORT)))

;; config-exists?: nothing -> boolean?
;; Check if the config file is present.
(define (config-exists? #:dir-check-mock  [directory-exists? directory-exists?]
                        #:file-check-mock [file-exists?      file-exists?])
  (let*
      ([CONFIG-DIR-EXISTS? (directory-exists? CONFIG-DIR-PATH)]
       [CONFIG-FILE-EXISTS (if CONFIG-DIR-EXISTS?
                               (file-exists? CONFIG-PATH)
                               #f)])
    CONFIG-FILE-EXISTS))

(module+ test
  (require "shared/mocks.rkt"
           mock
           rackunit)

  (define DIR-OR-FILE-EXISTS-MOCK/TRUE  (mock #:behavior (const #t)))
  (define DIR-OR-FILE-EXISTS-MOCK/FALSE (mock #:behavior (const #f)))
  (define STRING-PORT-MOCK              (mock #:behavior (const EXAMPLE-JSEXPR/STRING)))
  (define EXAMPLE-CONFIG (GET-CONFIG-MOCK))

  (check-pred identity-toolkit? (get-identity-toolkit EXAMPLE-CONFIG))
  (check-pred user?             (get-user-credentials EXAMPLE-CONFIG))
  (check-pred database?         (get-database-info EXAMPLE-CONFIG))
  (check-pred college-site?     (get-college-site-info EXAMPLE-CONFIG))
  (check-pred app-props?        (get-app-props EXAMPLE-CONFIG))

  (check-pred jsexpr? (get-config #:config-exists-mock DIR-OR-FILE-EXISTS-MOCK/TRUE
                                  #:file-reader-mock   STRING-PORT-MOCK))

  (test-case "config-exists?"
             (check-true  (config-exists? #:dir-check-mock  DIR-OR-FILE-EXISTS-MOCK/TRUE
                                          #:file-check-mock DIR-OR-FILE-EXISTS-MOCK/TRUE))
             (check-false (config-exists? #:dir-check-mock  DIR-OR-FILE-EXISTS-MOCK/FALSE
                                          #:file-check-mock DIR-OR-FILE-EXISTS-MOCK/FALSE))
             (check-false (config-exists? #:dir-check-mock  DIR-OR-FILE-EXISTS-MOCK/TRUE
                                          #:file-check-mock DIR-OR-FILE-EXISTS-MOCK/FALSE))))