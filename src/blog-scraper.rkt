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
         sxml)

(define BLOG-LIST-ELEMENT-XPATH
  "//div[@class=\"kris-blogitem-all\"]/ol/li//div[@class=\"item-body-h\"]//a")
(define TITLE-XPATH "/text()")
(define LINK-XPATH "/@href/text()")

;; blog-post is a structure.
;; It contains a title and a link of the blog post.
;; (blog-post string? string?)
(struct blog-post [title link])

;; select-blog-posts: xexpr -> (listof blog-post)
;; Select blog posts from the blog page SXML.
(define (select-blog-posts blog-page 
                           #:get-college-site-info-mock [get-college-site-info get-college-site-info])
  (let
      ([BLOG-POSTS    ((txpath BLOG-LIST-ELEMENT-XPATH) blog-page)]
       [get-by-xpath  (lambda (xpath element)
                        (car 
                         ((txpath xpath) element)))])
    (for/list ([element BLOG-POSTS])
      (let*
          ([TITLE         (get-by-xpath TITLE-XPATH element)]
           [RELATIVE-LINK (get-by-xpath LINK-XPATH element)]
           [FULL-LINK     (string-append
                           (college-site-url (get-college-site-info)) RELATIVE-LINK)])
        (blog-post TITLE FULL-LINK)))))

(module+ test
  (require rackunit
           mock
           racket/function)
  
  (define COLLEGE-SITE-INFO-MOCK
    (mock #:behavior 
          (const
           (college-site "https://example.url" "" "" ""))))
  
  ;; Scraped from the blog page
  (define BLOG-MOCK
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
  
  (test-case "select-blog-posts"
             (define EXAMPLE-BLOG-POST
               (blog-post "Расписание занятий на 2 июля 2021 г."
                          "https://example.url/elektronnye_servisy/blog/\
uchchast/raspisanie-zanyatiy-na-2-iyulya-2021-g"))
             
             (check-pred null? (select-blog-posts null 
                                                  #:get-college-site-info-mock COLLEGE-SITE-INFO-MOCK))
             (check-equal? (blog-post-title 
                            (car 
                             (select-blog-posts BLOG-MOCK
                                                #:get-college-site-info-mock COLLEGE-SITE-INFO-MOCK)))
                           (blog-post-title EXAMPLE-BLOG-POST))
             (check-equal? (blog-post-link 
                            (car 
                             (select-blog-posts BLOG-MOCK
                                                #:get-college-site-info-mock COLLEGE-SITE-INFO-MOCK)))
                           (blog-post-link EXAMPLE-BLOG-POST))))