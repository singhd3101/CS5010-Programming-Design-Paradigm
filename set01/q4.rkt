;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q4) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Program: Calculate speed of microprocessor in FLOPS

(require rackunit)
(require "extras.rkt")
(check-location "01" "q4.rkt")

(provide flopy)

;; DATA DEFINITIONS:
;; A NoOfFLops is represented as a Real
;; A NoOfOps is represented as a Real

;; flopy : NoOfFLops -> NoOfOps
;; GIVEN : NoOfFLops is the speed of microprocessor in FLOPS
;; RETURNS : NoOfOps is the number of operations performed by microprocessor.
;; EXAMPLES :
;; (flopy 19) = 599184000
;; (flopy 5) = 157680000
;; DESIGN STRATEGY : Transcribe formula
;; No of Floating point operations = F * total no of seconds in a year.

(define (flopy f)
  (* f 365 24 60 60))

;; TESTS:

(begin-for-test
  (check-equal? (flopy 19) 599184000)
  (check-equal? (flopy 5) 157680000))