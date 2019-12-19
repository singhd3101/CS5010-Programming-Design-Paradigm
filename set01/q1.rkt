;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "01" "q1.rkt")

(provide pyramid-volume)

(define (pyramid-volume x h)
  (* 1/3 h (* x x)))

(begin-for-test
  (check-equal? pyramid-volume 10 30) 3000
     "Volume of pyramid in cubic meters")
   (check-equal? (pyramid-volume 25 15 ) 3125
     "Volume of pyramid in cubic meters")
   (check-equal? (pyramid-volume 17 12) 1156
     "Volume of pyramid in cubic meters")