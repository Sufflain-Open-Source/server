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

(require "keys.rkt"
         "const.rkt"
         racket/function
         mock
         json)

(provide (all-defined-out))

(define EXAMPLE-API-KEY "XhfT4ih0k7!")
(define EXAMPLE-JSEXPR/STRING
  (string-append "{\"apiKey\" : \"" EXAMPLE-API-KEY "\"}"))
(define EXAMPLE-JSEXPR
  (string->jsexpr EXAMPLE-JSEXPR/STRING))

(define EXAMPLE-TBODY
  '(tbody
    "\r\n"
    "\t\t"
    (tr
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:64px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (strong "время "))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:132px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (strong "Э11-20 ауд.319"))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (strong "Ф11-20 ауд.505"))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (strong (& nbsp) (& nbsp) (& nbsp) (& nbsp) (& nbsp) (& nbsp) " Б11-20 ауд.501"))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (strong "ИБ11-20 ауд.305"))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (strong "ИБ12-20 ауд.202"))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (strong "СА11-20 ауд.302"))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (strong "СА12-20 ауд."))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:151px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (strong "БА11-20 ауд.301"))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:34px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (strong "БА12-20 ауд.312"))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t")
    "\r\n"
    "\t\t"
    (tr
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:64px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp))
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "09.00 " (& ndash) " 10.30" (& nbsp))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:132px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Естествознание")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Астрономия")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "ОБЖ")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Родной язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Химия")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Человек и общество")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "История")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Вебинар.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:151px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Иностранный язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Физическая культура")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Спорт.зал")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t")
    "\r\n"
    "\t\t"
    (tr
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:64px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "11.00 " (& ndash) " 12.30" (& nbsp))
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:132px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Литература")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Экономика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Естествознание")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Химия")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Родной язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Информатика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.404")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Математика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Вебинар.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:151px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Математика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Иностранный язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t")
    "\r\n"
    "\t\t"
    (tr
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:64px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp) "12.50 " (& ndash) " 14.20")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:132px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Иностран.язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Сверчкова А.В Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Родной язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Иностранный язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Математика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Русский язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Математика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Физика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp) "Вебинар.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:151px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Информатика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.404")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:32px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Химия")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t")
    "\r\n"
    "\t\t"
    (tr
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:64px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp) "14.30 " (& ndash) " 16.00")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:132px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Литература")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Информатика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.404")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Физика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:160px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Физика")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Родной язык")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Вебинар.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:151px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) (& nbsp))
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t\t"
     (td
      (@ (style "width:161px;height:39px;"))
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Литература")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Фамилия И. О.")
      "\r\n"
      "\r\n"
      "\t\t\t"
      (p (@ (align "center")) "Ауд.")
      "\r\n"
      "\t\t\t")
     "\r\n"
     "\t\t")
    "\r\n"
    "\t"))

;; Scraped from the college site.
(define EXAMPLE-TABLE
  `(table
    (@ (border "1") (cellpadding "0") (cellspacing "0") (width "1472"))
    "\r\n"
    "\t"
    ,EXAMPLE-TBODY
    "\r\n"))

;; Scraped from the college site.
(define EXAMPLE-TIMETABLE-PAGE
  `(div
    (@ (class "kris-post-item-txt"))
    (p
     (div
      "\r\n"
      (table
       (@ (border "0") (cellpadding "0") (cellspacing "0") (style "width:1393px;") (width "1394"))
       "\r\n"
       "\t"
       (tbody
        "\r\n"
        "\t\t"
        (tr
         "\r\n"
         "\t\t\t"
         (td
          (@ (style "width:577px;"))
          "\r\n"
          "\t\t\t"
          (p (@ (align "center")) "Государственное бюджетное профессиональное")
          "\r\n"
          "\r\n"
          "\t\t\t"
          (p (@ (align "center")) "образовательное учреждение" (& nbsp) " города Москвы")
          "\r\n"
          "\r\n"
          "\t\t\t"
          (p
           (@ (align "center"))
           (strong (& laquo) "МОСКОВСКИЙ КОЛЛЕДЖ БИЗНЕС " (& ndash) " ТЕХНОЛОГИЙ" (& raquo)))
          "\r\n"
          "\r\n"
          "\t\t\t"
          (p (@ (align "center")) "(ГБПОУ КБТ)")
          "\r\n"
          "\t\t\t")
         "\r\n"
         "\t\t\t"
         (td (@ (style "width:321px;")) "\r\n" "\t\t\t" (p (& nbsp)) "\r\n" "\t\t\t")
         "\r\n"
         "\t\t\t"
         (td
          (@ (style "width:496px;"))
          "\r\n"
          "\t\t\t"
          (p (@ (align "center")) "Изменения в расписании")
          "\r\n"
          "\r\n"
          "\t\t\t"
          (p (@ (align "center")) "на четверг, 29 апреля" (& nbsp) " 2021 г.")
          "\r\n"
          "\r\n"
          "\t\t\t"
          (p (@ (align "center")) "(верхняя неделя)")
          "\r\n"
          "\t\t\t")
         "\r\n"
         "\t\t")
        "\r\n"
        "\t")
       "\r\n")
      "\r\n"
      "\r\n"
      (p (& nbsp))
      "\r\n"
      "\r\n"
      (p (& nbsp))
      "\r\n"
      "\r\n"))
    ,EXAMPLE-TABLE
    "\r\n"
    "\r\n"
    (p (& nbsp))
    "\r\n"
    "\r\n"))

(define GET-CONFIG-MOCK 
  (mock #:behavior 
        (const
         (make-immutable-hasheq 
          `((,CONFIG-IDENTITY-TOOLKIT-KEY
             .
             ,(make-immutable-hasheq `((,CONFIG-IDENTITY-TOOLKIT-URL-KEY . "https://identity.url"))))
            (,CONFIG-DATABASE-KEY
             .
             ,(make-immutable-hasheq `((,CONFIG-DATABASE-URL-KEY            . "https://ourdb.app")
                                       (,CONFIG-DATABASE-API-KEY            . "uioy568y7")
                                       (,CONFIG-DATABASE-GROUPS-PATH-KEY    . "/g")
                                       (,CONFIG-DATABASE-TIMETABLE-PATH-KEY . "/t"))))
            (,CONFIG-USER-KEY
             .
             ,(make-immutable-hasheq `((,CONFIG-USER-EMAIL-KEY    . "bruhmail@yeah.lol")
                                       (,CONFIG-USER-PASSWORD-KEY . "8543873487"))))
            (,CONFIG-COLLEGE-SITE-KEY
             .
             ,(make-immutable-hasheq `((,CONFIG-COLLEGE-SITE-URL-KEY       . "https://college.site")
                                       (,CONFIG-COLLEGE-SITE-BLOG-PATH-KEY . "/blog")))))))))