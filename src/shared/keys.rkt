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

(provide (all-defined-out))

(define CONFIG-IDENTITY-TOOLKIT-KEY     'identityToolkit)
(define CONFIG-IDENTITY-TOOLKIT-URL-KEY 'url)

(define CONFIG-USER-KEY          'user)
(define CONFIG-USER-EMAIL-KEY    'email)
(define CONFIG-USER-PASSWORD-KEY 'password)

(define CONFIG-DATABASE-KEY                'database)
(define CONFIG-DATABASE-URL-KEY            'url)
(define CONFIG-DATABASE-API-KEY            'apiKey)
(define CONFIG-DATABASE-GROUPS-PATH-KEY    'groupsPath)
(define CONFIG-DATABASE-TIMETABLE-PATH-KEY 'timetablePath)

(define CONFIG-COLLEGE-SITE-KEY              'collegeSite)
(define CONFIG-COLLEGE-SITE-BLOG-URL-KEY     'blogUrl)
(define CONFIG-COLLEGE-SITE-GROUPS-XPATH-KEY 'groupsXpath)
(define CONFIG-COLLEGE-SITE-GROUPS-REGEX-KEY 'groupsRegex)