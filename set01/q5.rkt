;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "01" "q5.rkt")

(provide years-to-test)

(define (years-to-test f)
  (inexact->exact (/ (expt 2 128) (* f 365 24 60 60))))

(begin-for-test
  (check-equal? (years-to-test 2048) 1298074214633706907132624082305024/246375)
  (check-equal? (years-to-test 100) 664613997892457936451903530140172288/6159375))
