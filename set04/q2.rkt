;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; SIMULATION FOR SQUASH PRACTICE (SquashPractice3) 
;; A player practicing without an opponent with point sized ball and racket
;; moving within a rectangular court

;; start with (simulation 1/24)

(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(check-location "04" "q2.rkt")
         
(provide
 simulation
 initial-world
 world-ready-to-serve?
 world-after-tick
 world-after-key-event
; world-ball
 world-racket
 ball-x
 ball-y
 racket-x
 racket-y
 ball-vx
 ball-vy
 racket-vx
 racket-vy
 world-after-mouse-event
 racket-after-mouse-event
 racket-selected?
 world-balls)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; MAIN FUNCTION.

;; simulation : PosReal -> World
;; GIVEN: the speed of the simulation, in seconds per tick
;;     (so larger numbers run slower)
;; EFFECT: runs the simulation, starting with the initial world
;; RETURNS: the final state of the world
;; DESIGN SRATEGY : 
;; EXAMPLES :
;;     (simulation 1) runs in super slow motion
;;     (simulation 1/24) runs at a more realistic speed 

(define (simulation ticks)
  (big-bang (initial-world ticks)
            (on-tick world-after-tick ticks)
            (on-draw world-to-scene)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)))

;; initial-world : PosReal -> World
;; GIVEN: the speed of the simulation, in seconds per tick
;;     (so larger numbers run slower)
;; RETURNS: the ready-to-serve state of the world
;; DESIGN STRATEGY : 
;; EXAMPLE: (initial-world 1)

(define (initial-world t)
  (make-world
   (cons (make-ball INIT-X-COORD INIT-Y-COORD 0 0) ballist)
   (make-racket INIT-X-COORD INIT-Y-COORD 0 0 false)
   true
   false
   t
   (* (/ 1 t) 3)
   mousev-1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS

;; dimensions of the ball
(define BALL-IMG
  (circle 3 "solid" "black"))
(define HALF-BALL-WIDTH 1.5)

;; dimensions of the racket
(define RKT-IMG
  (rectangle 47 7 "solid" "green"))
(define HALF-RKT-WIDTH 23.5)
(define HALF-RKT-HEIGHT 3.5)

;; dimensions of the mouse event
(define MEV-IMG
  (circle 4 "solid" "blue"))
(define HALF-MEV-WIDTH 2)

;; how fast the ball moves, in pixels/tick
(define BALL-SPEED-X 3)
(define BALL-SPEED-Y -9)

;; dimensions of the canvas
(define CANVAS-WIDTH 425)
(define CANVAS-HEIGHT 649)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
(define YELLOW-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT 'yellow))
(define INIT-X-COORD 330)
(define INIT-Y-COORD 384)

;; range for mouse click
(define CLICK-RANGE 25)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; DATA DEFINITIONS

;; REPRESENTATION:
;; A World is represented as a (make-world ballist wracket paused? selected?
;;                              wticks cycle mousev)
;; INTERPRETATION:
;; ballist : Ballist     represents the list of balls in the current world
;; wracket : Racket      represents the racket in the world
;; paused? : Boolean     is the world paused?
;; selected? : Boolean   is the racket selected?
;; wticks : PosReal      is the number of ticks passed for simulation
;; cycle  : PosReal      is the counter for decremented ticks
;; mousev : MouseEv      represntes the current mouse evemt in the world

;; IMPLEMENTATION:
(define-struct world (ballist wracket paused? selected? wticks cycle mousev))

;; CONSTRCTOR TEMPLATE:
;; (make-world Ballist Racket Boolean Boolean PosReal PosReal MouseEv)

;; OBSERVER TEMPLATE:
;; world-fn : World -> ??
;;(define (world-fn w)
;;  (... (world-ballist w) (world-wracket w) (world-paused? w)
;;        world-selected? world-ticks world-cycle world-mousev))

;; REPRESENTATION:
;; A Ball is represented as (make-ball x-posb y-posb x-velb y-velb)
;; INTERPRETATION:
;; x-posb, y-posb : Integer      the position of the center of the ball
;;                               in the scene 
;; x-velb, y-velb : Integer      represent the velocity components of the ball

;; IMPLEMENTATION
(define-struct ball (xposb yposb xvelb yvelb))

;; CONSTRUCTOR TEMPLATE:
;; (make-ball Integer Integer Integer Integer)

;; OBSERVER TEMPLATE:
;; template:
;; ball-fn : Ball -> ??
;;(define (ball-fn w)
;; (... (ball-x-posb w)
;;      (ball-y-posb w)
;;      (ball-x-velb w) 
;;      (ball-y-velb w)))

;; examples of ball, for testing

(define ball-test1 (make-ball INIT-X-COORD INIT-Y-COORD 0 0))
(define ball-test2 (make-ball INIT-X-COORD INIT-Y-COORD 2 -6))

;; REPRESENTATION:
;; A Ballist is represented as a list of Balls that are currently present in
;; the world

;; IMPLEMENTATION
(define ballist '())

;; CONSTRUCTOR TEMPLATES:
;; empty
;; (cons ball ballist)
;; -- WHERE
;;    ball  is a Ball
;;    ballist is an Ballist

;; OBSERVER TEMPLATE
;; (define (ballist-fn ballist)
;;   (cond
;;     [(empty? ballist) ...]
;;     [else (...
;;             (ball-fn (first ballist))
;; 	    (ballist-fn (rest ballist)))]))

(define ballist0
  (list
    (make-ball 330 384 0 0)))

(define ballist2
  (list
    (make-ball 330 384 3 -9)
    (make-ball 330 384 0 0)))

(define ballist1
  (list
    (make-ball 330 384 0 0)
    (make-ball 20 30 20 20)
    (make-ball 10 10 50 60)))

(begin-for-test
  (check-equal? (first ballist1) (make-ball 330 384 0 0)))

;; REPRESENTATION:
;; A Racket is represented as (make-racket x-posr y-posr x-velr y-velr select?)
;; INTERPRETATION:
;; x-posr, y-posr : Integer    the position of the center of the racket
;;                             in the scene 
;; x-velr, y-velr : Integer    represent the velocity components of the racket
;; select?        : Boolean    is racket selected or not

;; IMPLEMENTATION

(define-struct racket (xposr yposr xvelr yvelr select?))

;; CONSTRUCTOR TEMPLATE:
;; (make-racket Integer Integer Integer Integer Boolean)

;; OBSERVER TEMPLATE:
;; template:
;; racket-fn : Racket -> ??
;;(define (racket-fn w)
;; (... (racket-x-posr w)
;;      (racket-y-posr w)
;;      (racket-x-velr w) 
;;      (racket-y-velr w)
;;      (racket-select?)))

;; examples of racket, for testing

(define racket-test1 (make-racket INIT-X-COORD INIT-Y-COORD 0 0 false))
(define racket-test2 (make-racket INIT-X-COORD INIT-Y-COORD 2 -6 false))

;; REPRESENTATION:
;; A MouseEv is represented as (make-mousev mx my mev)
;; INTERPRETATION:
;; mx, my : Integer  the position of the center of the mouse click
;;                   in the scene 
;; mev : String      represent one of the mouse events
;;                   "button-down" "drag" "button-up"

;; IMPLEMENTATION

(define-struct mousev (mx my mev))

;; CONSTRUCTOR TEMPLATE:
;; (make-mouseve Integer Integer String)

;; OBSERVER TEMPLATE:
;; template:
;; mousev-fn : MouseEv -> ??
;;(define (mousev-fn w)
;; (... (mousev-mx w)
;;      (mousev-my w)
;;      (mousev-mev w)

(define mousev-1 (make-mousev 0 0 "button-up"))

;; examples of worlds, for testing

(define unpaused-world-at-init
  (make-world
   ballist0
   racket-test1
   false
   false
   0
   0
   mousev-1))

(define unpaused-world-at-3
  (make-world
   ballist0
   racket-test2
   false
   false
   0
   0
   mousev-1))

(define paused-world-at-init
  (make-world
   ballist0
   racket-test1
   true
   false
   0
   0
   mousev-1))

(define paused-world-at-3
  (make-world
   ballist0
   racket-test2
   true
   false
   0
   0
   mousev-1))

;; help function for key event

;; is-pause-key-event? : KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent represents a pause instruction

(define (is-pause-key-event? ke)
  (key=? ke " "))

;; is-up-key-event? : KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent represents a up instruction

(define (is-up-key-event? ke)
  (key=? ke "up"))

;; is-down-key-event? : KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent represents a down instruction

(define (is-down-key-event? ke)
  (key=? ke "down"))

;; is-left-key-event? : KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent represents a left instruction

(define (is-left-key-event? ke)
  (key=? ke "left"))

;; is-right-key-event? : KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent represents a right instruction

(define (is-right-key-event? ke)
  (key=? ke "right"))

;; is-b-key-event? : KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent represents a b instruction

(define (is-b-key-event? ke)
  (key=? ke "b"))

(define non-pause-key-event "q")

;; examples KeyEvents for testing

(begin-for-test
  (check-equal? (is-pause-key-event? " ") true)   
  (check-equal? (is-down-key-event? "down") true)
  (check-equal? (is-up-key-event? "up") true)
  (check-equal? (is-right-key-event? "right") true)
  (check-equal? (is-left-key-event? "left") true)
  (check-equal? (is-b-key-event? "b") true))

;;; END DATA DEFINITIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
;; FUNCTION DEFINITIONS

;; world-to-scene : World -> Scene
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world-to-scene paused-world-at-init) should return a canvas with
;; a ball and a racket at (330,384)
;; STRATEGY: Place ball and racket in turn.

(define (world-to-scene w)
  (if (>= 0 (world-cycle w))
      (set-init-world w)
      (if
       (and (world-paused? w) (not (world-ready-to-serve? w)))
       (set-paused-world w)       
       (if (world-selected? w)
           (set-mouse-world w)
           (set-moving-world w)))))

(define image-of-paused-world-at-init
  (place-image BALL-IMG 330 384
               (place-image RKT-IMG 330 384
                            EMPTY-CANVAS)))

;; set-init-world : World -> World
;; STARTEGY : Combine simpler functions

(define (set-init-world w)
  (scene-with-ball
   (world-balls (initial-world (check-ticks? w)))
   (scene-with-racket
    (world-racket (initial-world (check-ticks? w)))
    EMPTY-CANVAS)))

;; set-psused-world : World -> World
;; STARTEGY : Combine simpler functions

(define (set-paused-world w)
  (scene-with-ball
   (world-balls w)
   (scene-with-racket
    (world-racket w)
    YELLOW-CANVAS)))

;; set-moving-world : World -> World
;; STARTEGY : Combine simpler functions

(define (set-moving-world w)
  (scene-with-ball 
   (world-balls w)
   (scene-with-racket
    (world-racket w)
    EMPTY-CANVAS)))

;; set-mouse-world : World -> World
;; STARTEGY : Combine simpler functions

(define (set-mouse-world w)
  (scene-with-mouse
   (world-mousev w)
   (scene-with-ball
    (world-balls w)
    (scene-with-racket
     (world-racket w)
     EMPTY-CANVAS))))

;; check-ticks? : World -> Ticks
;; STARTEGY : Combine simpler functions

(define (check-ticks? w)
  (if (= 0 (world-wticks w))
      1/24
      (world-wticks w)))

;; tests

(begin-for-test
  (check-equal?
   (world-to-scene paused-world-at-init)
   image-of-paused-world-at-init
   "(world-to-scene paused-world-at-init) returned incorrect image"))

;; scene-with-ball : Ball Scene -> Scene
;; RETURNS: a scene like the given one, but with the given ball painted
;; on it.

(define (scene-with-ball bl s)
  (place-img-ball bl s))

;(trace scene-with-ball)

(define (place-img-ball bl s)
  (cond
    [(= 1 (length bl))
     (place-new-ball (first bl) s)]
    [else
     (place-img-ball (rest bl) (place-new-ball (first bl) s))]))
     
(define (place-new-ball b s)
  (place-image
       BALL-IMG
      (ball-xposb b) (ball-yposb b)
      s))

;; scene-with-racket : Racket Scene -> Scene
;; RETURNS: a scene like the given one, but with the given racket painted
;; on it.

(define (scene-with-racket r s)
  (place-image
   RKT-IMG
   (racket-xposr r) (racket-yposr r)
   s))

;; scene-with-mouse : Mousev Scene -> Scene
;; RETURNS: a scene like the given one, but with the given mouse event painted
;; on it.

(define (scene-with-mouse m s)
  (place-image
   MEV-IMG
   (mousev-mx m) (mousev-my m)
   s))

;; tests

(define image-at-initb (place-image
                        BALL-IMG INIT-X-COORD INIT-Y-COORD EMPTY-CANVAS))
(define image-at-initr (place-image
                        RKT-IMG INIT-X-COORD INIT-Y-COORD EMPTY-CANVAS))

;; world-ready-to-serve? : World -> Boolean
;; GIVEN: a world
;; RETURNS: true iff the world is in its ready-to-serve state
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (make-world (first ballist1)
;;    (make-racket 330 384 0 0 false) true false 1/24 mousev-1) = true
;; (make-world (first ballist1)
;;    (make-racket 330 384 0 0 false) false false 1/24 mousev-1) = false
;; (make-world (first ballist1)
;;    (make-racket 330 384 0 0 false) false false 1/24 mousev-1) = false
;; (make-world (first ballist1)
;;    (make-racket 330 289 0 0 false) false false 1/24 mousev-1) = false

(define (world-ready-to-serve? w)
  (if (ball-state (first (world-balls w)))
      (if
       (racket-state (world-racket w))
       (if
        (world-paused? w)
        true
        false)
       false)
      false))

;; TESTS

(define world1 (make-world ballist0
                           (make-racket 330 384 0 0 false)
                           true
                           false
                           1/24
                           72
                           mousev-1))

;; HELPER FUNCTIONS

;; ball-state : Ball -> Boolean
;; GIVEN : a Ball
;; RETURNS : true if the ball from the current world is in ready state
;; DESIGN STRATEGY : Cases on Ball
;; EXAMPLES :
;; (ball-state (make-ball 330 384 0 0)) = true
;; (ball-state (make-ball 330 384 7 0)) = false
;; (ball-state (make-ball 330 269 0 0)) = false

(define (ball-state b)
  (and
   (= (ball-xposb b) 330)
   (= (ball-yposb b) 384)
   (= (ball-xvelb b) 0)
   (= (ball-yvelb b) 0)))
        
;; TESTS

(begin-for-test
  (check-equal? (ball-state (make-ball 330 384 0 0)) true)
  (check-equal? (ball-state (make-ball 330 384 7 0)) false)
  (check-equal? (ball-state (make-ball 330 269 0 0)) false))

;; racket-state : Racket -> Boolean
;; GIVEN : a Racket
;; RETURNS : true if the racket from the current world is in ready state
;; DESIGN STRATEGY : Cases on Racket
;; EXAMPLES :
;; (racket-state (make-racket 330 384 0 0 false)) = true
;; (racket-state (make-racket 330 384 7 0 false)) = false
;; (racket-state (make-racket 330 269 0 0 false)) = false

(define (racket-state r)
  (and
   (= (racket-xposr r) 330)
   (= (racket-yposr r) 384)
   (= (racket-xvelr r) 0)
   (= (racket-yvelr r) 0)))
        
;; TESTS

(begin-for-test
  (check-equal? (racket-state (make-racket 330 384 0 0 false)) true)
  (check-equal? (racket-state (make-racket 330 384 7 0 false)) false)
  (check-equal? (racket-state (make-racket 330 269 0 0 false)) false))
   
;; world-after-tick : World -> World
;; GIVEN: any world that's possible for the simulation 
;; RETURNS: the world that should follow the given world
;;     after a tick 
;; DESIGN STRATEGY : Cases on whether the world is paused.

(define (world-after-tick w)
  (if (world-paused? w)
      (if (>= 0 (world-cycle w))
          (initial-world (world-wticks w))
          (make-world (world-balls w)
                      (world-racket w)
                      true
                      (world-selected? w)
                      (world-wticks w)
                      (- (world-cycle w) 1)
                      mousev-1))
      (ball-after-tick w)))

;; TESTS

(begin-for-test
  (check-equal? (world-after-tick
                 (make-world
                  ballist0
                  (make-racket 330 384 0 0 false) true false 1/24 72 mousev-1))
                (make-world
                 ballist0
                 (make-racket 330 384 0 0 false) true false 1/24 71 mousev-1)))

;; HELPER FUNCTIONS

;; ball-after-tick : World -> World
;; GIVEN a World
;; RETURNS : the state of world after a tick
;; DESIGN STRATEGY : Cases on ball

(define (ball-after-tick w)
  (cond
    [(ball-hits-racket w)
     (return-new-world w)]
    [(> 0 (+ (ball-yposb (first (world-balls w)))
             (ball-yvelb (first (world-balls w))) HALF-BALL-WIDTH))
     (ball-hits-front-wall w)]
    [(> 0 (+ (ball-xposb (first (world-balls w)))
             (ball-xvelb (first (world-balls w))) HALF-BALL-WIDTH))
     (ball-hits-left-wall w)]
    [(< CANVAS-WIDTH (+ (ball-xposb (first (world-balls w)))
                        (ball-xvelb (first (world-balls w))) HALF-BALL-WIDTH))
     (ball-hits-right-wall w)]
    [(< CANVAS-HEIGHT (+ (ball-yposb (first (world-balls w)))
                         (ball-yvelb (first (world-balls w))) HALF-BALL-WIDTH))
     (ball-hits-back-wall w)]
    [else
     (return-next-world w)]))

;; HELPER FUNCTION

;; ball-hits-racket : World -> World
;; STRATEGY : Cases on ball and racket

(define (ball-hits-racket w)
   (if(and (< (racket-yposr (world-racket w))
              (+ (ball-yposb (first (world-balls w)))
                               (ball-yvelb (first (world-balls w)))))
          (>= (racket-yposr (world-racket w))
              (ball-yposb (first (world-balls w)))))
     (ball-hits-racket-x1 w)
     false))

;; ball-hits-racket-x1 : World -> World
;; STRATEGY : Cases on racket

(define (ball-hits-racket-x1 w)
   (if(and (> (- (racket-xposr (world-racket w)) HALF-RKT-WIDTH)
               (+ (ball-xposb (first (world-balls w)))
                               (ball-xvelb (first (world-balls w)))))
            (> (- (racket-xposr (world-racket w)) HALF-RKT-WIDTH)
               (ball-xposb (first (world-balls w)))))
    false
    (ball-hits-racket-x2 w)))

;; ball-hits-racket-x2 : World -> World
;; STRATEGY : Cases on racket

(define (ball-hits-racket-x2 w)
   (if(and (< (+ (racket-xposr (world-racket w)) HALF-RKT-WIDTH)
               (+ (ball-xposb (first (world-balls w)))
                               (ball-xvelb (first (world-balls w)))))
            (> (+ (racket-xposr (world-racket w)) HALF-RKT-WIDTH)
               (ball-xposb (first (world-balls w)))))
    false
    true))                              

;; return-new-world : World -> World
;; STRATEGY : Cases on world and combine simpler functions

(define (return-new-world w)
  (make-world (new-ball-state w)
              (new-racket-state w)
              (world-paused? w)
              (world-selected? w)
              (world-wticks w)
              (world-cycle w)
              (world-mousev w)))

;; new-ball-state : World -> Ball
;; STRATEGY : returns the new position of ball after it hits racket

(define (new-ball-state w)
(cons
  (make-ball
   (+ (ball-xposb (first (world-balls w)))
      (ball-xvelb (first (world-balls w))))
   (+ (ball-yposb (first (world-balls w)))
      (- (racket-yvelr (world-racket w)) (ball-yvelb (first (world-balls w)))))
   (ball-xvelb (first (world-balls w)))
   (- (racket-yvelr (world-racket w)) (ball-yvelb (first (world-balls w)))))
  '()))

;; new-racket-state : World -> Racket
;; STRATEGY : Cases on racket

(define (new-racket-state w)
  (cond
    [(< (racket-yvelr (world-racket w)) 0)
     (make-racket (racket-xposr (world-racket w))
                  (racket-yposr (world-racket w))
                  (racket-xvelr (world-racket w))
                  0
                  false)]
    [else (world-racket w)]))

;; return-y-world : World -> World
;; STRATEGY : Cases on cycle

(define (return-y-world w)
  ( if(<= 1 (world-cycle w))
      (make-world (world-balls w)
                  (world-racket w)
                  true
                  (world-selected? w)
                  (world-wticks w)
                  (* (/ 1 (world-wticks w)) 3)
                  (world-mousev w))
      (make-world (world-balls w)
                  (world-racket w)
                  true
                  (world-selected? w)
                  (world-wticks w)
                  (- (world-cycle w) 1)
                  (world-mousev w))))

;; ball-hits-front-wall : World -> World
;; STRATEGY : Cases on ball

(define (ball-hits-front-wall w)
  (make-world
   (front-wall-conditions (world-balls w))
   (world-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; front-wall-conditions : Ballist -> Ballist
;; STRATEGY : Combine simpler functions

(define (front-wall-conditions bl)
  (cond
    [(= 1 (length bl)) (cons (front-wall (first bl)) '())]
    [else
     (cons (front-wall (first bl)) (front-wall-conditions (rest bl)))]))

;; front-wall : Ball -> Ball
;; STRATEGY : Combine simpler functions

(define (front-wall b)
  (make-ball
    (+ (ball-xposb b)
       (ball-xvelb b))
    (- (ball-yposb b)
       (ball-yvelb b))
    (ball-xvelb b)
    (- 0 (ball-yvelb b))))

(begin-for-test
  (check-equal? (front-wall (make-ball 10 10 20 20)) (make-ball 30 -10 20 -20)))

;; ball-hits-left-wall : World -> World
;; STRATEGY : Cases on ball

(define (ball-hits-left-wall w)
  (make-world
   (left-wall-conditions (world-balls w))
   (world-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; left-wall-conditions : Ballist -> Ballist
;; STRATEGY : Combine simpler functions

(define (left-wall-conditions bl)
  (cond
    [(= 1 (length bl)) (cons (left-wall (first bl)) '())]
    [else
     (cons (left-wall (first bl)) (left-wall-conditions (rest bl)))]))

;; left-wall : Ball -> Ball
;; STRATEGY : Combine simpler functions

(define (left-wall b)
   (make-ball
    (- 0 (+ (ball-xposb b)
            (ball-xvelb b)))
    (+ (ball-yposb b)
       (ball-yvelb b))
    (- 0 (ball-xvelb b))
    (ball-yvelb b)))

(begin-for-test
  (check-equal? (left-wall (make-ball 10 10 20 20)) (make-ball -30 30 -20 20)))

;; ball-hits-right-wall : World -> World
;; STRATEGY : Cases on ball

(define (ball-hits-right-wall w)
  (make-world
   (right-ball-conditions (world-balls w))
   (world-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; right-ball-conditions : Ballist -> Ballist
;; STRATEGY : Combine simpler functions

(define (right-ball-conditions bl)
  (cond
    [(= 1 (length bl)) (cons (check-right (first bl)) '())]
    [else
     (cons (check-right (first bl)) (right-ball-conditions (rest bl)))]))

;; check-right : Ball -> Ball
;; STRATEGY : Combine simpler functions

(define (check-right b)
  (make-ball
    (+ (ball-xposb b)
       (- 0 (ball-xvelb b)))
    (+ (ball-yposb b)
       (ball-yvelb b))
    (- 0 (ball-xvelb b))
    (ball-yvelb b)))

(begin-for-test
  (check-equal? (check-right (make-ball 10 10 20 20))
                (make-ball -10 30 -20 20)))

;; return-next-world : World -> World
;; STRATEGY : Cases on ball

(define (return-next-world w)
  (make-world
   (next-ball-cond (world-balls w))
   (world-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; next-ball-cond : Ballist -> Ballist
;; STRATEGY : Combine simpler functions

(define (next-ball-cond bl)
  (cond
    [(= 1 (length bl)) (cons (construct-ball (first bl)) '())]
    [else (cons (construct-ball (first bl)) (next-ball-cond (rest bl)))]))

;; construct-ball : Ball -> Ball
;; STRATEGY : Combine simpler functions 

(define (construct-ball b)
     (make-ball
    (+ (ball-xposb b)
       (ball-xvelb b))
    (+ (ball-yposb b)
      (ball-yvelb b))
    (ball-xvelb b)
    (ball-yvelb b)))

;; TEST

(begin-for-test
  (check-equal? (construct-ball (make-ball 10 10 20 20))
                (make-ball 30 30 20 20)))
     
;; ball-hits-back-wall : World -> World
;; STRATEGY : Combine simpler functions

(define (ball-hits-back-wall w)
          (make-world
          (world-balls w)
          (world-racket w)
          (not (world-paused? w))
          (world-selected? w)
          (world-wticks w)
          (- (* (/ 1 (world-wticks w)) 3) 1)
          (world-mousev w)))

;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a world and a key event
;; RETURNS: the world that should follow the given world
;;     after the given key event
;; DESIGN STRATEGY: Cases on key event

(define (world-after-key-event w kev)
  (cond
    [(is-pause-key-event? kev)
     (if (world-ready-to-serve? w)
         (world-rally-state w)
         (world-with-paused-toggled w))]
    [(is-up-key-event? kev) (world-with-up-toggled w)]
    [(is-down-key-event? kev) (world-with-down-toggled w)]
    [(is-left-key-event? kev) (world-with-left-toggled w)]
    [(is-right-key-event? kev) (world-with-right-toggled w)]
    [(is-b-key-event? kev) (world-with-b-toggled w)]
    [else w]))

;; HELPER FUNCTIONS

;; world-rally-state :  World
;; GIVEN :  NA
;; RETURNS: a world in rally state with a moving ball
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-rally-state w)
  (make-world
   (cons (make-ball
    (+ INIT-X-COORD BALL-SPEED-X)
    (+ INIT-Y-COORD BALL-SPEED-Y)
    BALL-SPEED-X
    BALL-SPEED-Y) ballist)
   (make-racket
    INIT-X-COORD
    INIT-Y-COORD
    0
    0
    false)
   false
   false
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))
 
;; world-with-paused-toggled : World -> World 
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with paused? toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-paused-toggled w)
  (make-world
   (world-balls w)
   (world-racket w)
   (not (world-paused? w))
   (world-selected? w)
   (world-wticks w)
   (- (* (/ 1 (world-wticks w)) 3) 1)
   (world-mousev w)))

;; world-with-up-toggled : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with up toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-up-toggled w)
  (cond
    [(world-paused? w) w]
    [else
     (cond
       [(racket-up-collide w)
        (make-world
   (world-balls w)
   (world-racket w)
   (not (world-paused? w))
   (world-selected? w)
   (world-wticks w)
   (- (* (/ 1 (world-wticks w)) 3) 1)
   (world-mousev w))]
       [else (new-racket-world w)])]))

;; racket-up-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with front wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (new-racket-world w)
  (make-world
   (world-balls w)
   (up-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; racket-up-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with front wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (up-racket w)
  (make-racket
   (racket-xposr (world-racket w))
   (+ (racket-yposr (world-racket w))
      (- (racket-yvelr (world-racket w)) 1))
   (racket-xvelr (world-racket w))
   (- (racket-yvelr (world-racket w)) 1)
   false))

;; racket-up-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with front wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (racket-up-collide w)
  (> HALF-RKT-HEIGHT (+ (racket-yposr (world-racket w))
                        (- (racket-yvelr (world-racket w)) 1))))

;; world-with-down-toggled : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with down toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-down-toggled w)
  (cond
    [(world-paused? w) w]
    [else
     (cond
       [(down-racket-collide w)
        (make-world
          (world-balls w)
          (world-racket w)
          (not (world-paused? w))
          (world-selected? w)
          (world-wticks w)
          (- (* (/ 1 (world-wticks w)) 3) 1)
          (world-mousev w))]
      [else (new-racket-down-world w)])]))

;; down-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with down wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (new-racket-down-world w)
  (make-world
   (world-balls w)
   (down-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; down-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with down wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (down-racket w)
  (make-racket
   (racket-xposr (world-racket w))
   (+ (racket-yposr (world-racket w))
      (+ (racket-yvelr (world-racket w)) 1))
   (racket-xvelr (world-racket w))
   (+ (racket-yvelr (world-racket w)) 1)
   false))

;; down-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with down wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (down-racket-collide w)
  (< CANVAS-HEIGHT
     (- (+ (racket-yposr (world-racket w))
        (+ (racket-yvelr (world-racket w)) 1)) HALF-RKT-HEIGHT)))

;; world-with-left-toggled : World -> World 
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with left toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-left-toggled w)
  (cond
    [(world-paused? w) w]
    [else
     (make-world
      (world-balls w)
      (left-racket w)
      (world-paused? w)
      (world-selected? w)
      (world-wticks w)
      (world-cycle w)
      (world-mousev w))]))

;; left-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with left wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (left-racket w)
  (make-racket
   (left-racket-collide  w)
   (racket-yposr (world-racket w))
   (- (racket-xvelr (world-racket w)) 1)
   (racket-yvelr (world-racket w))
   false))

;; left-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with left wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (left-racket-collide w)
  (if
   (< HALF-RKT-WIDTH                                     
      (- (+ (racket-xposr (world-racket w))              
            (- (racket-xvelr (world-racket w)) 1))           
         HALF-RKT-WIDTH))                    
   (- (+ (racket-xposr (world-racket w))              
         (- (racket-xvelr (world-racket w)) 1))           
      HALF-RKT-WIDTH)
   HALF-RKT-WIDTH))

;; world-with-right-toggled : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with right toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-right-toggled w)
  (cond
    [(world-paused? w) w]
    [else
     (make-world
      (world-balls w)
      (right-racket w)
      (world-paused? w)
      (world-selected? w)
      (world-wticks w)
      (world-cycle w)
      (world-mousev w))]))

;; right-racket : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with right wall
;; DESIGN STRATEGY: use constructor template for World on w

(define (right-racket w)
  (make-racket
   (right-racket-collide w)
   (racket-yposr (world-racket w))
   (+ (racket-xvelr (world-racket w)) 1)
   (racket-yvelr (world-racket w))
   false))

;; right-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with right wall
;; DESIGN STRATEGY: use constructor template for World on w
    
(define (right-racket-collide w)
  (if
   (> (- CANVAS-WIDTH HALF-RKT-WIDTH)                                    
      (+ (racket-xposr (world-racket w))             
         (+ (racket-xvelr (world-racket w)) 1)         
         HALF-RKT-WIDTH))                      
   (+ (racket-xposr (world-racket w))               
      (+ (racket-xvelr (world-racket w)) 1)           
      HALF-RKT-WIDTH)
   (- CANVAS-WIDTH HALF-RKT-WIDTH)))

;; world-with-b-toggled : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with b toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-b-toggled w)
  (cond
    [(or (world-paused? w)
         (world-ready-to-serve? w)) w]
    [else
     (make-world
      (add-new-ball w)
      (world-racket w)
      (world-paused? w)
      (world-selected? w)
      (world-wticks w)
      (world-cycle w)
      (world-mousev w))]))

(begin-for-test
  (check-equal? (world-with-b-toggled paused-world-at-init)
                paused-world-at-init))

;; add-new-ball : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with an added ball
;; DESIGN STRATEGY: use constructor template for World on w

(define (add-new-ball w)
  (cons (make-ball
         330
         384
         3
         -9)
        (world-balls w)))

(begin-for-test
  (check-equal? (add-new-ball unpaused-world-at-init) ballist2))

;; world-ball : World -> Ball
;; GIVEN : a world
;; RETURNS : the ball that's present in the world
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (world-ball (make-world (make-ball 5 15 4 2)
;;                (make-racket 6 17 5 9 false) true false 1/24 mousev-1)) =
;;                  (make-ball 5 15 4 2)

;(define (world-ball w)
;  (world-wball w))

;; TESTS

;(begin-for-test
;  (check-equal? (world-ball (make-world (make-ball 5 15 4 2)
;                                        (make-racket 6 17 5 9 false)
;                                        true false 1/24 72 mousev-1))
;                (make-ball 5 15 4 2)))

;; world-racket : World -> Racket
;; GIVEN : a world
;; RETURNS : the racket that's present in the world
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (world-racket (make-world (make-ball 5 15 4 2)
;;                (make-racket 6 17 5 9) false false) 1/24 mousev-1) =
;;                  (make-racket 6 17 5 9 false)

(define (world-racket w)
  (world-wracket w))

;; TESTS

(begin-for-test
  (check-equal? (world-racket (make-world (first ballist1)
                                          (make-racket 6 17 5 9 false)
                                          true false 1/24 72 mousev-1))
                (make-racket 6 17 5 9 false)))
    
;; ball-x : Ball -> Integer
;; GIVEN : a Ball
;; RETURNS : Int      the x coordinate of the ball's position,
;;     in graphics coordinates
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (ball-x (make-ball 5 15 4 2)) = 5

(define (ball-x ball)
  (ball-xposb ball))

;; TESTS

(begin-for-test
  (check-equal? (ball-x (make-ball 5 15 4 2)) 5))

;; ball-y : Ball -> Integer
;; GIVEN : a Ball
;; RETURNS : Int      the y coordinate of the ball's position,
;;     in graphics coordinates
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (ball-y (make-ball 5 15 4 2)) = 15

(define (ball-y ball)
  (ball-yposb ball))

;; TESTS

(begin-for-test
  (check-equal? (ball-y (make-ball 5 15 4 2)) 15))

;; racket-x : Racket -> Integer
;; GIVEN : a Racket
;; RETURNS : Int      the x coordinate of the racket's position,
;;     in graphics coordinates
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (racket-x (make-racket 5 15 4 2 false)) = 5

(define (racket-x racket)
  (racket-xposr racket))

;; TESTS

(begin-for-test
  (check-equal? (racket-x (make-racket 5 15 4 2 false)) 5))

;; racket-y : Racket -> Integer
;; GIVEN : a Racket
;; RETURNS : Int      the y coordinate of the racket's position,
;;     in graphics coordinates
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (racket-y (make-racket 5 15 4 2 false)) = 15

(define (racket-y racket)
  (racket-yposr racket))

;; TESTS

(begin-for-test
  (check-equal? (racket-y (make-racket 5 15 4 2 false)) 15))

;; ball-vx : Ball -> Integer
;; GIVEN : a Ball
;; RETURNS : Int      the vx component of the ball's velocity,
;;     in pixels per tick
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (ball-vx (make-ball 5 15 4 2)) = 4

(define (ball-vx ball)
  (ball-xvelb ball))

;; TESTS

(begin-for-test
  (check-equal? (ball-vx (make-ball 5 15 4 2)) 4))

;; ball-vy : Ball -> Integer
;; GIVEN : a Ball
;; RETURNS : Int      the vy component of the ball's velocity,
;;     in pixels per tick
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (ball-vy (make-ball 5 15 4 2)) = 2

(define (ball-vy ball)
  (ball-yvelb ball))

;; TESTS

(begin-for-test
  (check-equal? (ball-vy (make-ball 5 15 4 2)) 2))

;; racket-vx : Racket -> Integer
;; GIVEN : a Racket
;; RETURNS : Int      the vx component of the racket's velocity,
;;     in pixels per tick
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (racket-vx (make-racket 5 15 4 2 false)) = 4

(define (racket-vx racket)
  (racket-xvelr racket))

;; TESTS

(begin-for-test
  (check-equal? (racket-vx (make-racket 5 15 4 2 false)) 4))

;; racket-vy : Racket -> Integer
;; GIVEN : a Racket
;; RETURNS : Int      the vy component of the racket's velocity,
;;     in pixels per tick
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (racket-vy (make-racket 5 15 4 2 false)) = 2

(define (racket-vy racket)
  (racket-yvelr racket))

;; TESTS

(begin-for-test
  (check-equal? (racket-vy (make-racket 5 15 4 2 false)) 2))

;; world-after-mouse-event : World Int Int MouseEvent -> World
;; GIVEN: a world, the x and y coordinates of a mouse event,
;;     and the mouse event
;; RETURNS: the world that should follow the given world after
;;     the given mouse event 

(define (world-after-mouse-event w mx my mev)
  (cond
    [(mouse=? mev "button-down") (world-after-button-down w mx my)]
    [(mouse=? mev "drag") (world-after-drag w mx my)]
    [(mouse=? mev "button-up") (world-after-button-up w mx my)]
    [else w]))

;; HELPER FUNCTIONS

;; world-after-button-down : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions 

(define (world-after-button-down w mx my)
  (cond
    [(in-range? (world-racket w) mx my) (button-down-world w mx my)]
    [else w]))

;; world-after-button-down : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions  

(define (button-down-world w mx my)
  (make-world
   (world-balls w)
   (racket-after-mouse-event (world-racket w) mx my "button-down")
    (world-paused? w)
    true
    (world-wticks w)
    (world-cycle w)
    (make-mousev mx my "button-down")))

;; racket-after-mouse-event : Racket Int Int MouseEvent -> Racket
;; GIVEN: a racket, the x and y coordinates of a mouse event,
;;     and the mouse event
;; RETURNS: the racket as it should be after the given mouse event

(define (racket-after-mouse-event r mx my mev)
  (cond
    [(string=? mev "button-down")
     (make-racket
     (racket-xposr r)
      (racket-yposr r)
      (racket-xvelr r)
      (racket-yvelr r)
      true)]
    [(string=? mev "drag")
     (make-racket
        mx
        my
        0
        0
       (racket-select? r))]
    [(string=? mev "button-up")
     (make-racket
      (racket-xposr r)
      (racket-yposr r)
      (racket-xvelr r)
      (racket-yvelr r)
      false)]
    [else r]))

;; HELPER FUNCTION

;; in-range? : Racket Int Int -> Boolean
;; STRATEGY : Cases on racket

(define (in-range? r mx my)
  (and  (>= CLICK-RANGE (abs (- (racket-xposr r) mx))) 
        (>= CLICK-RANGE (abs (- (racket-yposr r) my)))))

;; world-after-drag : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions

(define (world-after-drag w mx my)
  (cond
    [(racket-selected? (world-racket w)) (drag-world w mx my)]
    [else w]))

;; world-after-drag : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions

(define (drag-world w mx my)
  (make-world
   (world-balls w)
   (racket-after-mouse-event (world-racket w) mx my "drag")
    (world-paused? w)
    (world-selected? w)
    (world-wticks w)
    (world-cycle w)
    (make-mousev mx my "drag")))    

;; world-after-button-up : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions

(define (world-after-button-up w mx my)
  (cond
    [(racket-selected? (world-racket w)) (button-up-world w mx my)]
    [else w]))

;; button-up-world : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions

(define (button-up-world w mx my)
  (make-world
   (world-balls w)
   (racket-after-mouse-event (world-racket w) mx my "button-up")
       (world-paused? w)
    (world-selected? w)
    (world-wticks w)
    (world-cycle w)
    (make-mousev mx my "button-up")))

;; racket-selected? : Racket-> Boolean
;; GIVEN: a racket
;; RETURNS: true iff the racket is selected

(define (racket-selected? r)
  (racket-select? r))

;; TESTS

(begin-for-test
  (check-equal? (racket-selected? (make-racket 5 2 8 9 false)) false)
  (check-equal? (racket-selected? (make-racket 5 2 8 9 true)) true))

;; world-balls : World -> BallList
;; GIVEN: a world
;; RETURNS: a list of the balls that are present in the world
;;     (but does not include any balls that have disappeared
;;     by colliding with the back wall)
;; STRATEGY : Combine simpler functions

(define (world-balls w)
  (world-ballist w))