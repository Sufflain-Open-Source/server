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

(require "scraper.rkt"
         "config.rkt"
         "shared/const.rkt"
         sxml
         racket/string)

(provide blog-post
         blog-post-title
         blog-post-link
         lesson
         lesson-time
         lesson-data
         group-timetable
         group-timetable-title
         group-timetable-lessons
         group-timetable-as-jsexpr
         select-all-groups-timetables
         select-tbodys
         select-blog-posts)

(define BLOG-LIST-ELEMENT-XPATH
  "//div[@class=\"kris-blogitem-all\"]/ol/li//div[@class=\"item-body-h\"]//a")
(define TITLE-XPATH "/text()")
(define LINK-XPATH "/@href/text()")

;; blog-post is a structure.
;; It contains a title, link of the blog post.
;; (blog-post string? string? number?)
(struct blog-post [title link])

;; lesson is a structure.
;; It contains info about lesson.
;; (lesson string? (listof string?))
(struct lesson [time data])

;; group-timetable is a structure.
;; It contains a title with the group id and data about lessons for a specific day.
;; (timetable string? (listof lesson?))
(struct group-timetable [title lessons])

;; group-timetable-as-jsexpr: string? (listof lesson?)
;; Make a jsexpr with timetable contents.
(define (group-timetable-as-jsexpr link-title gtimetable)
  (let*
      ([TITLE          (group-timetable-title gtimetable)]
       [LESSONS        (group-timetable-lessons gtimetable)]
       [LESSONS/JSEXPR (map lesson->jsexpr LESSONS)])
    (make-immutable-hasheq `((title     . ,TITLE)
                             (linkTitle . ,link-title)
                             (lessons   . ,LESSONS/JSEXPR)))))

;; lesson->jsexpr: lesson? -> jsexpr
;; Make a jsexpr with a lesson info.
(define (lesson->jsexpr lesson)
  (make-immutable-hasheq `((time . ,(lesson-time lesson))
                           (data . ,(lesson-data lesson)))))

;; select-all-groups-timetables: (listof xexpr) -> (listof group-timetable?)
;; Select all timetabes on page.
(define (select-all-groups-timetables tbodys)
  (define GROUPED-TIMETABLES (map (lambda (tbody)
                                    (select-groups-timetables tbody)) tbodys))
  (foldr append null GROUPED-TIMETABLES))

;; select-groups-timetables: xexpr -> (listof group-timetable?)
;; Select timetables for each group.
(define (select-groups-timetables tbody)
  (let*
      ([TITLES            (select-titles tbody)]
       [TIME              (select-time tbody)]
       [LESSONS-DATA      (select-lessons-data tbody)]
       [not-null?         (lambda (val)
                            (not (null? val)))]
       [LESSONS-DATA-RAW  (map (lambda (ld)
                                 (filter not-null?
                                         (map (lambda (element)
                                                (map string-trim 
                                                     ((sxpath "//p/text()") element))) ld))) 
                               LESSONS-DATA)]
       [LESSONS-WITH-TIME (map (lambda (lessons)
                                 (for/list ([lesson-data lessons]
                                            [lesson-time TIME])
                                   (lesson lesson-time lesson-data))) LESSONS-DATA-RAW)]
       [GROUPS-TIMETABLES (for/list ([group-lessons LESSONS-WITH-TIME]
                                     [title         TITLES])
                            (group-timetable title group-lessons))])
    GROUPS-TIMETABLES))

;; select-lessons-data: xexpr -> (listof (listof xexpr?))
;; Select info about each lesson. The result is a list of <td>s.
(define (select-lessons-data tbody)
  (if (null? tbody)
      null
      (let*
          ([NO-TITLES    ((sxml:modify (list "//tr[1]" 'delete)) tbody)]
           [NO-TIME      (map (lambda (element) ; Remove the first cell—which contains time—from each row.
                                ((sxml:modify (list "//td[1]" 'delete)) element)) NO-TITLES)]
           [LESSONS-DATA ((sxpath '(// tr)) NO-TIME)]
           [NO-TR        (for/list ([row LESSONS-DATA])
                           ((sxpath '(// td)) row))])
        (compose NO-TR))))

;; compose: (listof list?) -> (listof list?)
;; Create a list of lists where each element of the Nth list is the first element of each initial list.
;; IMPORTANT: Inner lists must have an equal number of elements.
(define (compose lst)
  (if (null? lst)
      null
      (let ([ANY-INNER-LIST-NULL? (andmap null? lst)])
        (if ANY-INNER-LIST-NULL?
            null
            (letrec ([compose-first-elements
                      (lambda (lst)
                        (if (null? lst)
                            null
                            (cons (car (car lst)) (compose-first-elements (cdr lst)))))]
                     [FIRST-ELEMENTS/LIST    (compose-first-elements lst)]
                     [REDUCED-LISTS          (map cdr lst)])
              (cons FIRST-ELEMENTS/LIST
                    (compose REDUCED-LISTS)))))))

;; select-titles: xexpr -> title-list
;; Select timetable titles with groups.
;; Titles on the site are formatted inconsistently.
;; All of them have one thing in common — a group id.
(define (select-titles tbody)
  (select-from-tbody tbody GROUP-TIMETABLE-TITLE-XPATH (string-append GROUPS-REGEX ".*")))

;; select-time: xexpr -> time-list
;; Select the time when classes start and end.
;; Time is formatted as hh \u2013 mm.
(define (select-time tbody)
  (select-from-tbody tbody "//tr/td[1]/p" TIME-REGEX))

;; select-from-tbody: xexpr string? string? -> (listof string?)
;; Select data from the provided <tbody>.
(define (select-from-tbody tbody xpath regex)
  (let*
      ([SELECTED-BY-XPATH                ((sxpath xpath) tbody)]
       [SELECTED-BY-XPATH/LIST-OF-STRING (for/list ([element SELECTED-BY-XPATH])
                                           (srl:sxml->html element))])
    (map string-trim (regex-select SELECTED-BY-XPATH/LIST-OF-STRING regex))))

;; select-tbodys: xexpr -> (listof xexpr)
;; Select <tbody>s from the timetable page.
(define (select-tbodys page)
  ((sxpath TIMETABLE-TBODY-XPATH) page))

;; select-blog-posts: xexpr -> (listof blog-post)
;; Select blog posts from the blog page SXML.
(define (select-blog-posts blog-page config
                           #:get-college-site-info-mock [get-college-site-info get-college-site-info])
  (let*
      ([BLOG-POSTS        ((sxpath BLOG-LIST-ELEMENT-XPATH) blog-page)]
       [BLOG-POSTS-LENGTH (length BLOG-POSTS)]
       [get-by-xpath  (lambda (xpath element)
                        (car 
                         ((sxpath xpath) element)))])
    (for/list ([element BLOG-POSTS]
               [index   (build-list BLOG-POSTS-LENGTH values)])
      (let*
          ([TITLE         (get-by-xpath TITLE-XPATH element)]
           [RELATIVE-LINK (get-by-xpath LINK-XPATH element)]
           [SITE-INFO     (get-college-site-info config)]
           [FULL-LINK     (string-append
                           (college-site-url SITE-INFO)
                           RELATIVE-LINK
                           "/")])
        (blog-post TITLE FULL-LINK index)))))

(module+ test
  (require "shared/mocks.rkt"
           rackunit
           mock
           racket/function)
  
  (define COLLEGE-SITE-INFO-MOCK
    (mock #:behavior 
          (const
           (college-site "https://example.url" ""))))
  
  ;; Scraped from the blog page
  (define EXAMPLE-BLOG
    '(div 
      (@ (class "kris-blogitem-tabs"))
      (div
       (@ (class "kris-blogitem-all"))
       (ol
        "\n"
        "                                                        "
        (li
         (@ (style "width:100%;"))
         (div
          (@ (class "item-body"))
          "\n"
          "                                    "
          (div
           (@ (class "item-body-titline"))
           "\n"
           "                                        "
           (div
            (@ (class "item-body-h"))
            (div
             (@ (class "h2"))
             (a
              (@
               (href
                "/elektronnye_servisy/blog/uchchast/raspisanie-zanyatiy-na-2-iyulya-2021-g"))
              "Расписание занятий на 2 июля 2021 г."))))))))))
  
  (define EXAMPLE-TABLE
    '(*TOP* 
      (tbody
       (tr
        (td "СА21-19, ауд. 304б"))
       (tr
        (td (p "10.00 " (&ndash) " 11.00"))
        (td (p "Lesson data")))
       (tr
        (td (p "11.15 " (&ndash) " 12.30"))
        (td (p "Lesson data"))))))
  
  (define EXAMPLE-LESSON (lesson "10.00 &ndash; 11.00" '("КС")))
  (define EXAMPLE-LESSON/JSEXPR (lesson->jsexpr EXAMPLE-LESSON))
  
  (check-equal? (group-timetable-as-jsexpr "Расписание на ... дату" 
                                           (group-timetable "СА21-19 ауд.304" 
                                                            `(,EXAMPLE-LESSON)))
                (make-immutable-hasheq 
                 `((title     . "СА21-19 ауд.304")
                   (linkTitle . "Расписание на ... дату")
                   (lessons   . (,EXAMPLE-LESSON/JSEXPR)))))
  
  (check-equal? (lesson->jsexpr (lesson "11.15 &ndash; 12.30" '("Предмет")))
                #hasheq((time . "11.15 &ndash; 12.30")
                        (data . ("Предмет"))))
  
  (check-pred (lambda (result)
                (andmap group-timetable? result)) 
              (select-all-groups-timetables (cdr
                                             (select-tbodys EXAMPLE-TIMETABLE-PAGE))))
  
  (test-case "select-groups-timetables"
             (check-equal? (select-groups-timetables null) null)
             (check-equal? (lesson-time (cadr 
                                         (group-timetable-lessons 
                                          (cadr
                                           (select-groups-timetables EXAMPLE-TBODY)))))
                           "11.00 &ndash; 12.30")
             (check-equal? (group-timetable-title (cadddr (select-groups-timetables EXAMPLE-TBODY)))
                           "ИБ11-20 ауд.305")
             (check-equal? (car
                            (lesson-data (cadr 
                                          (group-timetable-lessons 
                                           (cadddr 
                                            (select-groups-timetables EXAMPLE-TBODY))))))
                           "Химия"))
  
  (test-case "select-lessons-data"
             (check-equal? (select-lessons-data null) null)
             (check-equal? (select-lessons-data EXAMPLE-TABLE) '(((td (p "Lesson data"))
                                                                  (td (p "Lesson data"))))))
  
  (test-case "compose"
             (check-equal? (compose (list (list 1 2 3) (list 1 2 3) (list 1 2 3)))
                           (list (list 1 1 1) (list 2 2 2) (list 3 3 3)))
             (check-equal? (compose null) null)
             (check-equal? (compose (list null null null null)) null)
             (check-equal? (compose (list (list "a" "c") (list "b" "d")))
                           (list (list "a" "b") (list "c" "d"))))
  
  (check-equal? (select-titles EXAMPLE-TBODY) '("Э11-20 ауд.319"
                                                "Ф11-20 ауд.505"
                                                "Б11-20 ауд.501"
                                                "ИБ11-20 ауд.305"
                                                "ИБ12-20 ауд.202"
                                                "СА11-20 ауд.302"
                                                "СА12-20 ауд."
                                                "БА11-20 ауд.301"
                                                "БА12-20 ауд.312"))
  
  (check-equal? (select-time EXAMPLE-TBODY) '("09.00 &ndash; 10.30"
                                              "11.00 &ndash; 12.30"
                                              "12.50 &ndash; 14.20"
                                              "14.30 &ndash; 16.00"))
  
  (check-equal? (select-tbodys EXAMPLE-TIMETABLE-PAGE) `(,EXAMPLE-TBODY))
  
  (test-case "select-blog-posts"
             (define EXAMPLE-BLOG-POST
               (blog-post "Расписание занятий на 2 июля 2021 г."
                          "https://example.url/elektronnye_servisy/blog/\
uchchast/raspisanie-zanyatiy-na-2-iyulya-2021-g/"
                          0))
             
             (check-pred null? (select-blog-posts null (GET-CONFIG-MOCK)
                                                  #:get-college-site-info-mock COLLEGE-SITE-INFO-MOCK))
             (check-equal? (blog-post-title 
                            (car 
                             (select-blog-posts EXAMPLE-BLOG (GET-CONFIG-MOCK)
                                                #:get-college-site-info-mock COLLEGE-SITE-INFO-MOCK)))
                           (blog-post-title EXAMPLE-BLOG-POST))
             (check-equal? (blog-post-link 
                            (car 
                             (select-blog-posts EXAMPLE-BLOG (GET-CONFIG-MOCK)
                                                #:get-college-site-info-mock COLLEGE-SITE-INFO-MOCK)))
                           (blog-post-link EXAMPLE-BLOG-POST))))
             