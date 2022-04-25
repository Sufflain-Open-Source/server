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
         racket/string
         racket/list
         percs)

(provide (all-defined-out))

;; teacher:
;; (teacher string? string?)
(struct teacher [hash name])

;; teacher-timetable:
;; (teacher-timetable teacher? (listof group-timetable?))
(struct teacher-timetable [teacher group-timetables])

;; select-all-teachers-timetables: (listof string?) (listof group-timetable?) -> (listof teacher-timetable?)
;; Select timetables for all teachers.
(define (select-all-teachers-timetables teachers timetables)
  (filter (lambda (item)
            (not (empty? (teacher-timetable-group-timetables item))))
          (for/list
              ([TEACHER teachers])
            (teacher-timetable TEACHER (select-all-teacher-timetables (teacher-name TEACHER) timetables)))))

;; select-all-teacher-timetables: string? (listof group-timetable?) -> (listof group-timetable?)
;; Selects timetables only with the teacher's name.
(define (select-all-teacher-timetables teacher timetables)
  (define TEACHER-TIMETABLES
    (for/list ([TIMETABLE timetables])
      (let
          ([FILTERED-LESSONS (timetable:select-teacher-lessons teacher (group-timetable-lessons TIMETABLE))])
        (if (cons? FILTERED-LESSONS)
            (group-timetable (group-timetable-title TIMETABLE) FILTERED-LESSONS)
            #f))))
  (filter (lambda (item) ; Keep only timetables, remove all booleans.
            (not (boolean? item))) TEACHER-TIMETABLES))

;; timetable:select-teacher-lessons: string? (listof lesson?)
;; Select only lessons with the teacher's name.
(define (timetable:select-teacher-lessons teacher lessons)
  (filter (lambda (lesson)
            (string? (find-name-in-lesson-data teacher (lesson-data lesson)))) lessons))

;; find-name-in-lesson-data: string? (listof string?) -> (or/c string? boolean?)
;; Find a teacher's name in lesson's data.
;; It can find a name even if it is written with a small amount of typos.
;; Returns #f if the name's not found.
(define (find-name-in-lesson-data name lesson-data)
  (let*
      ([NAME-SPLITTED            (string-split name " ")]
       [LAST-NAME                (car NAME-SPLITTED)]
       [INITIALS                 (string-append (cadr NAME-SPLITTED)
                                                " "
                                                (caddr NAME-SPLITTED))]
       [LAST-NAME-OPTIONAL-CHARS (make-regex-case-insensitive
                                  (make-each-name-char-optional LAST-NAME))]
       [INITIALS-OPTIONAL-CHARS  (make-regex-case-insensitive
                                  (make-initials-chars-optional INITIALS))]
       [FILTERED-DATA (filter (lambda (item)
                                (define LAST-NAME-MATCH
                                  (remove-empty-matches
                                   (regexp-match* (pregexp LAST-NAME-OPTIONAL-CHARS)
                                                  (regexp-replace (pregexp INITIALS-OPTIONAL-CHARS) item ""))))
                                (define INITIALS-MATCH
                                  (remove-empty-matches
                                   (regexp-match* (pregexp INITIALS-OPTIONAL-CHARS)
                                                  (regexp-replace (pregexp LAST-NAME-OPTIONAL-CHARS) item ""))))
                                (define TEACHER-NAME-MATCH (string-append LAST-NAME-MATCH
                                                                          " "
                                                                          INITIALS-MATCH))
                                (define (make-empty-str-if-bool x)
                                  (if (boolean? x)
                                      ""
                                      (car x)))
                                (define TEACHER-NAME
                                  (make-empty-str-if-bool
                                   (regexp-match (pregexp (string-append "(?i:" LAST-NAME ")"))
                                                 TEACHER-NAME-MATCH)))
                                ; (displayln LAST-NAME-OPTIONAL-CHARS)
                                ; (displayln INITIALS-OPTIONAL-CHARS)
                                ; (display "LAST NAME:")
                                ; (displayln LAST-NAME-MATCH)
                                ; (display "INITIALS: ")
                                ; (displayln INITIALS-MATCH)
                                ; (display "NAME MATCH: ")
                                ; (displayln TEACHER-NAME-MATCH)
                                ; (display "NAME: ")
                                ; (displayln TEACHER-NAME)
                                (if (>= (strings-equality-percentage name
                                                                     (string-append TEACHER-NAME
                                                                                    " "
                                                                                    INITIALS-MATCH)) 80)
                                    #t
                                    #f))
                              lesson-data)]
       [RESULT        (if (cons? FILTERED-DATA)
                          (car FILTERED-DATA)
                          #f)])
    ; (display "RESULT: ")
    ; (displayln RESULT)
    (if (string? RESULT)
        (string-normalize-spaces RESULT)
        RESULT)))

(define (remove-empty-matches ml)
  (foldr string-append
         ""
         (filter (lambda (i) (not (equal? "" i))) ml)))

(define (make-regex-case-insensitive regstr)
  (string-append "(?i:" regstr ")"))

(define (make-initials-chars-optional initials)
  (define INITIALS (regexp-match* #px"\\p{L&}{1}\\.{1}" initials))
  (define MODIFIED (map (lambda (item)
                          (define EXPLODED-ITEM (explode item))
                          (string-append (car EXPLODED-ITEM)
                                         "\\"
                                         (cadr EXPLODED-ITEM)
                                         "?")) INITIALS))
  (string-append (car MODIFIED) " *" (cadr MODIFIED)))

;; make-each-name-char-optional: string? -> string?
;; Append "?" after each character. If the character is ".", also prepend "\\".
(define (make-each-name-char-optional str)
  (implode
   (map (lambda (1str)
          (string-append 1str "?"))
        (explode str))))

;; implode: (listof string?) -> string?
;; Combine all 1strings in a list into a string.
(define (implode lostr)
  (foldr string-append "" lostr))

;; explode: string? -> (listof string?)
;; Create a list of strings with each character represented as a string.
(define (explode str)
  (map (lambda (char) (make-string 1 char)) (string->list str)))