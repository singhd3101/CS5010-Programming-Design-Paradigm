;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "01" "q3.rkt")

(provide kelvin-to-fahrenheit)

(define (kelvin-to-fahrenheit k)
  (+ (* 9/5 (- k 273) 32)))

(begin-for-test
  (check-equal? (kelvin-to-fahrenheit 0) -459))