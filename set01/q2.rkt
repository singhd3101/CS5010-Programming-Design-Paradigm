;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "01" "q2.rkt")

(provide furlongs-to-barleycorns)

(define (furlongs-to-barleycorns f)
  (* f 10 4 33/2 12 3))

(begin-for-test
  (check-equal? (furlongs-to-barleycorns 10) 23.66))
