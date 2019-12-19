;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; SIMULATION FOR SQUASH PRACTICE (SquashPractice2) 
;; A player practicing without an opponent with point sized ball and racket
;; moving within a rectangular court

;; start with (simulation 1/24)

(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(check-location "03" "q2.rkt")

(provide
 simulation
 initial-world
 world-ready-to-serve?
 world-after-tick
 world-after-key-event
 world-ball
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
 racket-selected?)

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
   (make-ball INIT-X-COORD INIT-Y-COORD 0 0)
   (make-racket INIT-X-COORD INIT-Y-COORD 0 0 false)
   true
   false))

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
;; A World is represented as a (make-world wball wracket paused? selected?)
;; INTERPRETATION:
;; wball : Ball          represents the ball in the world
;; wracket : Racket      represents the racket in the world
;; paused? : Boolean     is the world paused?
;; selected? : Boolean   is the racket selected?

;; IMPLEMENTATION:
(define-struct world (wball wracket paused? selected?))

;; CONSTRCTOR TEMPLATE:
;; (make-world Ball Racket Boolean Boolean)

;; OBSERVER TEMPLATE:
;; world-fn : World -> ??
;;(define (world-fn w)
;;  (... (world-wball w) (world-wracket w) (world-paused? w)
;;        world-selected?))

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
;; A Racket is represented as (make-racket x-posr y-posr x-velr y-velr select?)
;; INTERPRETATION:
;; x-posr, y-posr : Integer      the position of the center of the racket
;;                               in the scene 
;; x-velr, y-velr : Integer      represent the velocity components of the racket
;; select?        : Boolean      is racket selected or not

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

;; examples of worlds, for testing

(define unpaused-world-at-init
  (make-world
   ball-test1
   racket-test1
   false
   false))

(define unpaused-world-at-3
  (make-world
   ball-test2
   racket-test2
   false
   false))

(define paused-world-at-init
  (make-world
   ball-test1
   racket-test1
   true
   false))

(define paused-world-at-3
  (make-world
   ball-test2
   racket-test2
   true
   false))

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

(define non-pause-key-event "q")

;; examples KeyEvents for testing

(begin-for-test
  (check-equal? (is-pause-key-event? " ") true)   
  (check-equal? (is-down-key-event? "down") true)
  (check-equal? (is-up-key-event? "up") true)
  (check-equal? (is-right-key-event? "right") true)
  (check-equal? (is-left-key-event? "left") true))


;;; END DATA DEFINITIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
;; FUNCTION DEFINITIONS

;; world-to-scene : World -> Scene
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world-to-scene paused-world-at-init) should return a canvas with
;; a ball and a racket at (330,384)
;; STRATEGY: Place ball and racket in turn.

(define (world-to-scene w)
  (if
   (and (world-paused? w) (not (world-ready-to-serve? w)))
   (scene-with-ball
    (world-ball w)
    (scene-with-racket
     (world-racket w)
     YELLOW-CANVAS))        
   (scene-with-ball
    (world-ball w)
    (scene-with-racket
     (world-racket w)
     EMPTY-CANVAS))))

(define (world-to-new-scene w)
  (scene-with-ball
   (world-ball w)
   (scene-with-racket
    (world-racket w)
    (empty-scene 425 649 'yellow))))

(define image-of-paused-world-at-init
  (place-image BALL-IMG 330 384
               (place-image RKT-IMG 330 384
                            EMPTY-CANVAS)))

(begin-for-test
  (check-equal?
   (world-to-scene paused-world-at-init)
   image-of-paused-world-at-init
   "(world-to-scene paused-world-at-init) returned incorrect image"))

;; scene-with-ball : Ball Scene -> Scene
;; RETURNS: a scene like the given one, but with the given ball painted
;; on it.
(define (scene-with-ball b s)
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

;; tests

;;; check this visually to make sure it's what you want
(define image-at-initb (place-image
                        BALL-IMG INIT-X-COORD INIT-Y-COORD EMPTY-CANVAS))
(define image-at-initr (place-image
                        RKT-IMG INIT-X-COORD INIT-Y-COORD EMPTY-CANVAS))


;;; note: these only test whether world-to-scene calls place-image properly.
;;; it doesn't check to see whether image-at-20 is the right image!

(begin-for-test
  (check-equal? 
   (scene-with-ball ball-test1 EMPTY-CANVAS)
   image-at-initb
   "(scene-with-ball ball-test1 EMPTY-CANVAS)
     returned unexpected image or value")

  (check-equal?
   (scene-with-racket racket-test1 EMPTY-CANVAS)   
   image-at-initr
   "(scene-with-racket racket-test1 EMPTY-CANVAS)
     returned unexpected image or value"))

;; world-ready-to-serve? : World -> Boolean
;; GIVEN: a world
;; RETURNS: true iff the world is in its ready-to-serve state
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (make-world (make-ball 330 384 0 0)
;;    (make-racket 330 384 0 0 false) true false) = true
;; (make-world (make-ball 330 384 0 0)
;;    (make-racket 330 384 0 0 false) false false) = false
;; (make-world (make-ball 330 384 7 0)
;;    (make-racket 330 384 0 0 false) false false) = false
;; (make-world (make-ball 330 384 0 0)
;;    (make-racket 330 289 0 0 false) false false) = false

(define (world-ready-to-serve? w)
  (if (ball-state (world-ball w))
      (if
       (racket-state (world-racket w))
       (if
        (world-paused? w)
        true
        false)
       false)
      false))

;; TESTS

(define world1 (make-world (make-ball 330 384 0 0)
                           (make-racket 330 384 0 0 false)
                           true
                           false))

(begin-for-test
  (check-equal? (world-ready-to-serve? world1) true)
  (check-equal? (world-ready-to-serve?
                 (make-world (make-ball 330 384 0 0)
                             (make-racket 330 384 0 0 false)
                             false false)) false)
  (check-equal? (world-ready-to-serve? (make-world
                                        (make-ball 330 384 7 0)
                                        (make-racket 330 384 0 0 false)
                                         false false)) false)
  (check-equal? (world-ready-to-serve? (make-world
                                        (make-ball 330 384 0 0)
                                        (make-racket 330 289 0 0 false)
                                         false false)) false))

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
      w
      (ball-after-tick w)))

;; TESTS

(begin-for-test
  (check-equal? (world-after-tick
                 (make-world
                  (make-ball 330 384 0 0)
                  (make-racket 330 384 0 0 false) true false))
                (make-world
                 (make-ball 330 384 0 0)
                 (make-racket 330 384 0 0 false) true false)))

;; HELPER FUNCTIONS

;; ball-after-tick : World -> World
;; GIVEN a World
;; RETURNS : the state of world after a tick
;; DESIGN STRATEGY : Cases on ball

(define (ball-after-tick w)
  (cond
    [(ball-hits-racket w)
     (return-new-world w)]
    [(> 0 (+ (ball-yposb (world-ball w))
             (ball-yvelb (world-ball w)) HALF-BALL-WIDTH))
     (ball-hits-front-wall w)]
    [(> 0 (+ (ball-xposb (world-ball w))
             (ball-xvelb (world-ball w)) HALF-BALL-WIDTH))
     (ball-hits-left-wall w)]
    [(< CANVAS-WIDTH (+ (ball-xposb (world-ball w))
                        (ball-xvelb (world-ball w)) HALF-BALL-WIDTH))
     (ball-hits-right-wall w)]
    [(< CANVAS-HEIGHT (+ (ball-yposb (world-ball w))
                         (ball-yvelb (world-ball w)) HALF-BALL-WIDTH))
     (ball-hits-back-wall w)]
    [else
     (return-next-world w)]))

(define (ball-hits-racket w)
  (cond
    [(and (<= (ball-yposb (world-ball w))
              (+ (racket-yposr (world-racket w)) HALF-RKT-HEIGHT))
          (>= (ball-yposb (world-ball w))
              (- (racket-yposr (world-racket w)) HALF-RKT-HEIGHT)))
     (cond
       [(and (<= (ball-xposb (world-ball w))
                 (+ (racket-xposr (world-racket w)) HALF-RKT-WIDTH)) 
             (>= (ball-xposb (world-ball w))
                 (- (racket-xposr (world-racket w)) HALF-RKT-WIDTH))) true]
       [else false])]
    [else false]))

(define (return-new-world w)
  (make-world (new-ball-state w)
              (new-racket-state w)
              (world-paused? w)
              (world-selected? w)))

(define (new-ball-state w)
  (make-ball
      
   (+ (ball-xposb (world-ball w)) (ball-xvelb (world-ball w)))
   (+ (ball-yposb (world-ball w))
      (- (racket-yvelr (world-racket w)) (ball-yvelb (world-ball w))))
   (ball-xvelb (world-ball w))
   (- (racket-yvelr (world-racket w)) (ball-yvelb (world-ball w)))))

(define (new-racket-state w)
  (cond
    [(< (racket-yvelr (world-racket w)) 0)
     (make-racket (racket-xposr (world-racket w))
                  (racket-yposr (world-racket w))
                  (racket-xvelr (world-racket w))
                  0
                  false)]
    [else (world-racket w)]))

(define (ball-hits-front-wall w)
  (make-world
   (make-ball
    (+ (ball-xposb (world-ball w)) (ball-xvelb (world-ball w)))
    (- (ball-yposb (world-ball w)) (ball-yvelb (world-ball w)))
    (ball-xvelb (world-ball w))
    (- 0 (ball-yvelb (world-ball w))))
   (world-racket w)
   (world-paused? w)
   (world-selected? w)))

(define (ball-hits-left-wall w)
  (make-world
   (make-ball
    (- 0 (+ (ball-xposb (world-ball w)) (ball-xvelb (world-ball w))))
    (+ (ball-yposb (world-ball w)) (ball-yvelb (world-ball w)))
    (- 0 (ball-xvelb (world-ball w)))
    (ball-yvelb (world-ball w)))
   (world-racket w)
   (world-paused? w)
   (world-selected? w)))

(define (ball-hits-right-wall w)
  (make-world
   (make-ball
    (+ (ball-xposb (world-ball w)) (- 0 (ball-xvelb (world-ball w))))
    (+ (ball-yposb (world-ball w)) (ball-yvelb (world-ball w)))
    (- 0 (ball-xvelb (world-ball w)))
    (ball-yvelb (world-ball w)))
   (world-racket w)
   (world-paused? w)))

(define (return-next-world w)
  (make-world
   (make-ball
    (+ (ball-xposb (world-ball w)) (ball-xvelb (world-ball w)))
    (+ (ball-yposb (world-ball w)) (ball-yvelb (world-ball w)))
    (ball-xvelb (world-ball w))
    (ball-yvelb (world-ball w)))
   (world-racket w)
   (world-paused? w)
   (world-selected? w)))

(define (ball-hits-back-wall w)
  (initial-world 5))

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
    [else w]))

;; HELPER FUNCTIONS

;; world-rally-state :  World
;; GIVEN :  NA
;; RETURNS: a world in rally state with a moving ball
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-rally-state w)
  (make-world
   (make-ball
    (+ INIT-X-COORD BALL-SPEED-X)
    (+ INIT-Y-COORD BALL-SPEED-Y)
    BALL-SPEED-X
    BALL-SPEED-Y)
   (make-racket
    INIT-X-COORD
    INIT-Y-COORD
    0
    0
    false)
   false
   false))

;; world-with-paused-toggled : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with paused? toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-paused-toggled w)
  (make-world
   (world-ball w)
   (world-racket w)
   (not (world-paused? w))
   (world-selected? w)))

;; world-with-up-toggled : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with up toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-up-toggled w)
  (cond
    [(world-paused? w) w]
    [else
     (cond
       [(racket-up-collide w)(initial-world 5)]
       [else (new-racket-world w)])]))

(define (new-racket-world w)
  (make-world
   (world-ball w)
   (up-racket w)
   (world-paused? w)
   (world-selected? w)))

(define (up-racket w)
  (make-racket
   (racket-xposr (world-racket w))
   (+ (racket-yposr (world-racket w))
      (- (racket-yvelr (world-racket w)) 1))
   (racket-xvelr (world-racket w))
   (- (racket-yvelr (world-racket w)) 1)
   false))

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
       [(down-racket-collide w)(initial-world 5)]
       [else (new-racket-down-world w)])]))

(define (new-racket-down-world w)
  (make-world
   (world-ball w)
   (down-racket w)
   (world-paused? w)
   (world-selected? w)))

(define (down-racket w)
  (make-racket
   (racket-xposr (world-racket w))
   (+ (racket-yposr (world-racket w))
      (+ (racket-yvelr (world-racket w)) 1))
   (racket-xvelr (world-racket w))
   (+ (racket-yvelr (world-racket w)) 1)
   false))

(define (down-racket-collide w)
  (< CANVAS-HEIGHT
     (+ (racket-yposr (world-racket w))
        (+ (racket-yvelr (world-racket w)) 1))))

;; world-with-left-toggled : World -> World 
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with left toggled
;; DESIGN STRATEGY: use constructor template for World on w

(define (world-with-left-toggled w)
  (cond
    [(world-paused? w) w]
    [else
     (make-world
      (world-ball w)
      (left-racket w)
      (world-paused? w)
      (world-selected? w))]))

(define (left-racket w)
  (make-racket
   (left-racket-collide  w)
   (racket-yposr (world-racket w))
   (- (racket-xvelr (world-racket w)) 1)
   (racket-yvelr (world-racket w))
   false))

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
      (world-ball w)
      (right-racket w)
      (world-paused? w)
      (world-selected? w))]))

(define (right-racket w)
  (make-racket
   (right-racket-collide w)
   (racket-yposr (world-racket w))
   (+ (racket-xvelr (world-racket w)) 1)
   (racket-yvelr (world-racket w))
   false))
    
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

;; world-ball : World -> Ball
;; GIVEN : a world
;; RETURNS : the ball that's present in the world
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (world-ball (make-world (make-ball 5 15 4 2)
;;                (make-racket 6 17 5 9 false) true false)) =
;;                  (make-ball 5 15 4 2)

(define (world-ball w)
  (world-wball w))

;; TESTS

(begin-for-test
  (check-equal? (world-ball (make-world (make-ball 5 15 4 2)
                                        (make-racket 6 17 5 9 false)
                                        true false))
                (make-ball 5 15 4 2)))

;; world-racket : World -> Racket
;; GIVEN : a world
;; RETURNS : the racket that's present in the world
;; DESIGN STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (world-racket (make-world (make-ball 5 15 4 2)
;;                (make-racket 6 17 5 9) false false)) =
;;                  (make-racket 6 17 5 9 false)

(define (world-racket w)
  (world-wracket w))

;; TESTS

(begin-for-test
  (check-equal? (world-racket (make-world (make-ball 5 15 4 2)
                                          (make-racket 6 17 5 9 false)
                                          true false))
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
      [(racekt-selected? (racket-after-mouse-event (world-racket w) mx my mev))
       (make-world
         (world-ball w)
         (racket-after-mouse-event (world-racket w) mx my mev)
         (world-paused? w)
         true)]
      [else w]))

;; racket-after-mouse-event : Racket Int Int MouseEvent -> Racket
;; GIVEN: a racket, the x and y coordinates of a mouse event,
;;     and the mouse event
;; RETURNS: the racket as it should be after the given mouse event

(define (racket-after-mouse-event r mx my mev)
  (cond
    [(mouse=? mev "button-down")(racket-after-button-down r mx my)]
    [(mouse=? mev "drag")(racket-after-drag r mx my)]
    [(mouse=? mev "button-up")(racket-after-button-up r mx my)]
    [else r]))

;; HELPER FUNCTIONS

;; racket-after-button-down : Racket Int Int -> Racket
;; GIVEN : a racket, the x and y coordinates of a mouse event
;; RETURNS : the racket as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions

(define (racket-after-button-down r mx my)
  (cond
    []
    [else r])

;; racket-after-button-down : Racket Int Int -> Racket
;; GIVEN : a racket, the x and y coordinates of a mouse event
;; RETURNS : the racket as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions

(define (racket-after-drag r mx my)
  true)

;; racket-after-button-down : Racket Int Int -> Racket
;; GIVEN : a racket, the x and y coordinates of a mouse event
;; RETURNS : the racket as it should be after the given mouse event
;; DESIGN STRATEGY : Combine simpler functions

(define (racket-after-button-up r mx my)
  true)

;; racket-selected? : Racket-> Boolean
;; GIVEN: a racket
;; RETURNS: true iff the racket is selected

(define (racket-selected? r)
  (racket-select? r))

;; TESTS

(begin-for-test
  (check-equal? (racket-selected? (make-racket 5 2 8 9 false)) false)
  (check-equal? (racket-selected? (make-racket 5 2 8 9 true)) true))