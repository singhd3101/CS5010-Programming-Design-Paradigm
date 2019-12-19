;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(check-location "02" "q2.rkt")

(provide
   initial-state
   next-state
   is-red?
   is-green?)

;; CONSTANTS

;; the interval between color changes
(define COLOR-CHANGE-INTERVAL 30)

;; DATA DEFINITIONS

;; Countdown Timer

;; A TimerState is represented a PosInt
;; WHERE: 0 < t <= COLOR-CHANGE-INTERVAL
;; INTERPRETATION: number of seconds until the next color change.
;; If t = 1, then the color should change at the next second.

;; A ChineseTrafficSignal ctSignal is represented as a struct
;; (make-ctSignal color cycle-num time-left)
;; with the fields
;; color : Color    represents the color of the traffic signal
;; time-left : TimerState   represents the current state of the timer
;; cyclenum : PosInt   is the cycle num and is represend as one
;; of the following - {1,2,3,4,5}

(define-struct ctSignal(color cycle-num time-left))

;; CONSTRUCTOR TEMPLATE
;; (make-ctSignal Color TimerState)

;; OBSERVER TEMPLATE
;; ctSignal-fn : ChineseTrafficSignal -> ?
;;(define (ctSignal-fn l)
;;  (...
;;  (ctSignal-color l)
;;  (ctSignal-cyclenum l)
;;  (ctSignal-time-left l)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTION DEFINITIONS

;; initial-state : intTime -> ctSignal
;; GIVEN :
;; intTime : PosInt   represents input value of time in seconds
;; greater than 3
;; RETURNS : representation of a ChineseTrafficSignal
;;     at the beginning of its red state, which will last
;;     for intTime seconds
;; DESIGN STRATEGY: Use constructor template for ChineseTrafficSignal
;; (define (initial-state n)
;;          (nake-ctSignal color cyclenum time-left)
;; EXAMPLES :
;; (next-state (make-ctSignal "red" 1 2)) => (make-ctSignal "red" 1 1)

(define (initial-state n)
         (make-ctSignal "red" 1 n))

;; TESTS

(begin-for-test
 (check-equal? (make-ctSignal "red" 1 5) (make-ctSignal "red" 1 5)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; next-state : ctSignal -> ctSignal
;; GIVEN :
;; ctSignal : ChineseTrafficSignal   a representation of a traffic signal
;;      in some state
;; RETURNS : representation of a Chinese traffic signal
;;      the state that traffic signal should have one
;;      second later
;; DESIGN STRATEGY : Cases on color cyclenum and time left of the state of
;;      ChineseTrafficSignal
;; (define (next-state s)
;;          (cond
;;           (string=? s.color "red"
;;            (cond
;;             (= c.time-left 1)
;;              (make-s ("green" 2 (- interval 3))
;;            (else make-s "red" cyclenum (- timeleft 1)))
;;          (else
;;            (cond
;;              (string? s.coor "green")
;;               (cond
;;                 [(= s.cyclenum 2) (make-s "blank" 3 1)]
;;                 [(= s.cyclenum 4) (make-s "blank" 5 1)])]
;;             [else
;;                 (make-s "green" s.cyclenum (- s.timeleft 1))])]
;;           [else
;;             (cond
;;               [(= s.cyclenum 3) (make-s "green" 4 1)]
;;               [(= s.cyclenum 5) (make-s "red" 1 internal)])])]))
;; EXAMPLES :
;; (next-state (make-ctSignal "red" 1 1)) = (make-ctSignal "green" 2 27)
;; (next-state (make-ctSignal "red" 1 2)) = (make-ctSignal "red" 1 1)

(define (next-state ctSignal)
            (cond
              [(string=? (ctSignal-color ctSignal) "red")
               (cond
                 [(= 1 (ctSignal-time-left ctSignal))
                  (make-ctSignal "green" 2 (- COLOR-CHANGE-INTERVAL 3))]
               [else (make-ctSignal "red" (ctSignal-cycle-num ctSignal) (- (ctSignal-time-left ctSignal) 1))])]
            [else
                (cond
                  [(string=? (ctSignal-color ctSignal) "green")
                    (cond
                      [(= 1 (ctSignal-time-left ctSignal))
                       (cond
                         [(= (ctSignal-cycle-num ctSignal) 2)(make-ctSignal "blank" 3 1)]
                         [(= (ctSignal-cycle-num ctSignal) 4)(make-ctSignal "blank" 5 1)])]
                    [else
                     (make-ctSignal "green" (ctSignal-cycle-num ctSignal) (- (ctSignal-time-left ctSignal) 1))])]
                [else
                    (cond
                      [(= (ctSignal-cycle-num ctSignal) 3)(make-ctSignal "green" 4 1)]
                      [(= (ctSignal-cycle-num ctSignal) 5)(make-ctSignal "red" 1 COLOR-CHANGE-INTERVAL)])])]))

;; TESTS :

(begin-for-test
  (check-equal? (next-state (make-ctSignal "red" 1 2)) (make-ctSignal "red" 1 1))
  (check-equal? (next-state (make-ctSignal "red" 1 1)) (make-ctSignal "green" 2 27))
  (check-equal? (next-state (make-ctSignal "green" 2 27)) (make-ctSignal "green" 2 26))
  (check-equal? (next-state (make-ctSignal "green" 2 1)) (make-ctSignal "blank" 3 1))
  (check-equal? (next-state (make-ctSignal "blank" 3 1)) (make-ctSignal "green" 4 1))
  (check-equal? (next-state (make-ctSignal "green" 4 1)) (make-ctSignal "blank" 5 1))
  (check-equal? (next-state (make-ctSignal "blank" 5 1)) (make-ctSignal "red" 1 30)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; is-red? : ctSignal -> redFlag
;; GIVEN :
;; ctSignal : ChineseTrafficSignal   a representation of a traffic signal
;;      in some state
;; RETURNS :
;; redFlag : Boolean   returns true if and only if the signal is red
;; DESIGN STRATEGY : Cases on color c of the state of ChineseTrafficSignal
;;   (define (is-red? s)
;;         (cond
;;            [(string=? s.color "red") true]
;;         [else false]))
;; EXAMPLES :
;; (is-red? (next-state (initial-state 4)))  =>  true
;; (is-red?
;;      (next-state
;;       (next-state
;;        (next-state (initial-state 4)))))  =>  true

(define (is-red? ctSignal)
         (cond
            [(string=? (ctSignal-color ctSignal) "red") true]
         [else false]))

;; TESTS :

(begin-for-test
  (check-equal? (is-red? (initial-state 4)) true)
  (check-equal? (is-red?
                (next-state
                 (next-state
                  (next-state (initial-state 4))))) true)
  (check-equal? (is-red?
                (next-state
                 (next-state
                  (next-state
                   (next-state (initial-state 4)))))) false)
  (check-equal? (is-red?
                (next-state
                 (next-state
                  (next-state
                   (next-state
                    (next-state (initial-state 4))))))) false))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; is-green? : ctSignal -> greenFlag
;; GIVEN :
;; ctSignal : ChineseTrafficSignal   a representation of a traffic signal
;;      in some state
;; RETURNS :
;; greenFlag : Boolean   returnstrue if and only if the signal is green
;; DESIGN STRATEGY : Cases on color c of the state of ChineseTrafficSignal
;;   (define (is-green? s)
;;         (cond
;;            [(string=? s.color "green") true]
;;         [else false]))
;; EXAMPLES :
;; (is-green?
;;      (next-state
;;       (next-state
;;        (next-state
;;         (next-state (initial-state 4))))))  =>  true

(define (is-green? ctSignal)
         (cond
            [(string=? (ctSignal-color ctSignal) "green") true]
  [else false]))

;; TESTS :

(begin-for-test
  (check-equal? (is-green?
                (next-state
                 (next-state
                  (next-state
                   (next-state (initial-state 4))))))   true)
  (check-equal? (is-green?
                 (next-state
                   (next-state
                    (next-state (initial-state 4))))) false))