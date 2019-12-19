;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; SIMULATION FOR SQUASH PRACTICE (SquashPractice4) 
;; A player practicing without an opponent with point sized ball and racket
;; moving within a rectangular court

;; start with (simulation 1/24)

(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(check-location "06" "q2.rkt")
         
(provide
 simulation
 initial-world
 world-ready-to-serve?
 world-after-tick
 world-after-key-event
 world-racket
 world-after-mouse-event
 ball-y
 ball-x
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
;; STRATEGY : 
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
;; STRATEGY : 
;; EXAMPLE: (initial-world 1)

(define (initial-world t)
  (make-world
   (cons (make-ball INIT-X-COORD INIT-Y-COORD 0 0) BALLIST)
   (make-racket INIT-X-COORD INIT-Y-COORD 0 0 false)
   true
   false
   t
   (* (/ 1 t) 3)
   MOUSEV))

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
(define-struct ball (x y vx vy))

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
(define BALLIST '())

;; CONSTRUCTOR TEMPLATES:
;; empty
;; (cons ball BALLIST)
;; -- WHERE
;;    ball  is a Ball
;;    BALLIST is an BALLIST

;; OBSERVER TEMPLATE
;; (define (BALLIST-fn BALLIST)
;;   (cond
;;     [(empty? BALLIST) ...]
;;     [else (...
;;             (ball-fn (first BALLIST))
;; 	    (BALLIST-fn (rest BALLIST)))]))

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

(define-struct racket (x y vx vy select?))

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

(define MOUSEV (make-mousev 0 0 "button-up"))

;; examples of worlds, for testing

(define unpaused-world-at-init
  (make-world
   ballist0
   racket-test1
   false
   false
   0
   0
   MOUSEV))

(define unpaused-world-at-3
  (make-world
   ballist0
   racket-test2
   false
   false
   0
   0
   MOUSEV))

(define paused-world-at-init
  (make-world
   ballist0
   racket-test1
   true
   false
   0
   0
   MOUSEV))

(define paused-world-at-3
  (make-world
   ballist0
   racket-test2
   true
   false
   0
   0
   MOUSEV))

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
      (if (and (world-paused? w) (= 0 (length (world-balls w))))
          (set-end-world w)
          (if
           (and (world-paused? w) (not (world-ready-to-serve? w)))
           (set-paused-world w)       
           (if (world-selected? w)
               (set-mouse-world w)
               (set-moving-world w))))))

(define image-of-end-world
  (place-image RKT-IMG INIT-X-COORD INIT-Y-COORD
               YELLOW-CANVAS))

(define image-of-paused-world-at-init
  (place-image BALL-IMG INIT-X-COORD INIT-Y-COORD
               (place-image RKT-IMG INIT-X-COORD INIT-Y-COORD
                            EMPTY-CANVAS)))

(define image-of-paused-world
  (place-image BALL-IMG 411 69
               (place-image RKT-IMG INIT-X-COORD INIT-Y-COORD
                            YELLOW-CANVAS)))

(define image-of-mouse-world
  (place-image MEV-IMG 324 366
               (place-image BALL-IMG 411 69
                            (place-image RKT-IMG 324 366
                                         EMPTY-CANVAS))))

(begin-for-test
  (check-equal? (world-to-scene
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 #f)
                  #t
                  #f
                  1/24
                  0
                  (make-mousev 0 0 "button-up")))
                image-of-paused-world-at-init)
  (check-equal? (world-to-scene
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 #f)
                  #t
                  #f
                  1/24
                  17
                  (make-mousev 0 0 "button-up")))
                image-of-paused-world-at-init)
  (check-equal? (world-to-scene
                 (make-world
                  (list (make-ball 411 69 -3 -9))
                  (make-racket 330 384 0 0 #f)
                  #t
                  #f
                  1/24
                  21
                  (make-mousev 0 0 "button-up")))
                image-of-paused-world)
  (check-equal? (world-to-scene
                 (make-world
                  (list (make-ball 411 69 -3 -9))
                  (make-racket 324 366 0 0 #t)
                  #f
                  #t
                  1/24
                  24
                  (make-mousev 324 366 "drag")))
                image-of-mouse-world)
  (check-equal? (world-to-scene
                 (make-world '()
                             (make-racket 330 384 0 0 #f) #t #f 1/24 4
                             (make-mousev 0 0 "button-up")))
                image-of-end-world))

;; set-end-world : World -> Scene
;; RETURNS: a Scene that portrays the given world when all the balls have
;; hit back wall
;; EXAMPLE: (set-end-world image-of-end-world) should return a yellow
;; canvas with a racket.
;; STRATEGY: Combine simpler functions.

(define (set-end-world w)
  (scene-with-racket
   (world-racket w)
   YELLOW-CANVAS))

;; set-init-world : World -> Scene
;; RETURNS: a Scene that portrays the given world at initial state
;; EXAMPLE: (set-init-world image-of-paused-world-at-init) should return a
;; paused world at initial state
;; STRATEGY: Combine simpler functions.

(define (set-init-world w)
  (scene-with-ball
   (world-balls (initial-world (check-ticks? w)))
   (scene-with-racket
    (world-racket (initial-world (check-ticks? w)))
    EMPTY-CANVAS)))

;; set-paused-world : World -> Scene
;; RETURNS: a Scene that portrays the given world in paused state
;; EXAMPLE: (set-paused-world image-of-paused-world) should return a
;; paused world in rally state.
;; STRATEGY: Combine simpler functions.

(define (set-paused-world w)
  (scene-with-ball
   (world-balls w)
   (scene-with-racket
    (world-racket w)
    YELLOW-CANVAS)))

;; set-moving-world : World -> Scene
;; RETURNS: a Scene that portrays the given world in rally state
;; EXAMPLE: (set-moving-world image-of-moving-world) should return a
;; world in rally state.
;; STRATEGY: Combine simpler functions.

(define (set-moving-world w)
  (scene-with-ball 
   (world-balls w)
   (scene-with-racket
    (world-racket w)
    EMPTY-CANVAS)))

;; set-mouse-world : World -> Scene
;; RETURNS: a Scene that portrays the given world with mouse event
;; EXAMPLE: (set-mouse-world image-of-mouse-world) should return a
;; pworld in rally state with mouse event.
;; STRATEGY: Combine simpler functions.

(define (set-mouse-world w)
  (scene-with-mouse
   (world-mousev w)
   (scene-with-ball
    (world-balls w)
    (scene-with-racket
     (world-racket w)
     EMPTY-CANVAS))))

;; check-ticks? : World -> Real
;; RETURNS: resets the number of ticks to 1/24 if reached 0
;; EXAMPLE : (check-ticks? world-with-0-ticks) => 1/24
;; STRATEGY: Combine simpler functions.

(define (check-ticks? w)
  (if (= 0 (world-wticks w))
      1/24
      (world-wticks w)))

;; tests

(begin-for-test
  (check-equal? (check-ticks? (make-world
                               (list (make-ball 330 384 0 0))
                               (make-racket 330 384 0 0 #f)
                               #t
                               #f
                               0
                               0
                               (make-mousev 0 0 "button-up")))
                1/24))

;; scene-with-ball : Ball Scene -> Scene 
;; RETURNS: a scene like the given one, but with the given ball painted
;; on it.
;; EXAMPLE : (scene-with-ball
;;           BALL-IMG INIT-X-COORD INIT-Y-COORD EMPTY-CANVAS)
;; should return animage with a ball at Initial coordinates
;; STRATEGY: Combine simpler functions.

(define (scene-with-ball bl s)
  (place-img-ball bl s place-new-ball))

;; place-img-ball : Ballist Scene Function -> Scene 
;; RETURNS: a scene like the given one, but with the given list of balls
;; painted on it.
;; EXAMPLE : (place-img-ball
;;           ballist1 set-paused-world) should print all the balls is
;; paused state.
;; STRATEGY: Use HOF foldr on Ballist.

;(define (place-img-ball bl s)
;  (cond
;    [(= 1 (length bl))
;     (place-new-ball (first bl) s)]
;    [else
;     (place-img-ball (rest bl) (place-new-ball (first bl) s))]))

(define (place-img-ball bl s place-new-ball)
  (foldr
   ;; Ball Scene -> Scene
   ;; GIVEN: a Balllist and a Scene
   ;; RETURNS: a scene with the input ball placed in it
   (lambda (b s) (place-new-ball b s))
   s
   bl))

;; place-new-ball : Ball Scene -> Scene 
;; RETURNS: a scene like the given one, but with the given ball
;; painted on it.
;; EXAMPLE : (place-new-ball
;;           ball set-paused-world) should print the ball in
;; paused state.
;; STRATEGY: Combine simpler functions
     
(define (place-new-ball b s)
  (place-image
   BALL-IMG
   (ball-x b) (ball-y b)
   s))

;; scene-with-racket : Racket Scene -> Scene
;; RETURNS: a scene like the given one, but with the given racket painted
;; on it.
;; EXAMPLE : (place-img
;;           racket set-end-world) should print the racket in end world state
;; STRATEGY : Combine simpler functions

(define (scene-with-racket r s)
  (place-image
   RKT-IMG
   (racket-x r) (racket-y r)
   s))

;; scene-with-mouse : Mousev Scene -> Scene
;; RETURNS: a scene like the given one, but with the given mouse event painted
;; on it.
;; EXAMPLE : (place-img
;;           MEV-IMG set-mouse-world) should print the mouse event in the
;;           given world
;; STRATEGY : Combine simpler functions

(define (scene-with-mouse m s)
  (place-image
   MEV-IMG
   (mousev-mx m) (mousev-my m)
   s))

;; TEST

(define image-at-initb (place-image
                        BALL-IMG INIT-X-COORD INIT-Y-COORD EMPTY-CANVAS))
(define image-at-initr (place-image
                        RKT-IMG INIT-X-COORD INIT-Y-COORD EMPTY-CANVAS))

;; world-ready-to-serve? : World -> Boolean
;; GIVEN: a world
;; RETURNS: true iff the world is in its ready-to-serve state
;; STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (make-world (first ballist1)
;;    (make-racket 330 384 0 0 false) true false 1/24 MOUSEV) = true
;; (make-world (first ballist1)
;;    (make-racket 330 384 0 0 false) false false 1/24 MOUSEV) = false
;; (make-world (first ballist1)
;;    (make-racket 330 384 0 0 false) false false 1/24 MOUSEV) = false
;; (make-world (first ballist1)
;;    (make-racket 330 289 0 0 false) false false 1/24 MOUSEV) = false

(define (world-ready-to-serve? w)
  (if (and (ball-state (first (world-balls w)))
           (racket-state (world-racket w))
           (world-paused? w))
      true
      false))

;; TESTS

(define world1 (make-world ballist0
                           (make-racket 330 384 0 0 false)
                           true
                           false
                           1/24
                           72
                           MOUSEV))
(define world2 (make-world ballist0
                           (make-racket 330 384 0 0 false)
                           false
                           false
                           1/24
                           72
                           MOUSEV))
(define world3 (make-world ballist0
                           (make-racket 330 384 10 10 false)
                           true
                           false
                           1/24
                           72
                           MOUSEV))

;; TEST

(begin-for-test
  (check-equal? (world-ready-to-serve?
                 world2) false)
  (check-equal? (world-ready-to-serve?
                 world3) false))

;; ball-state : Ball -> Boolean
;; GIVEN : a Ball
;; RETURNS : true if the ball from the current world is in ready state
;; STRATEGY : Cases on Ball
;; EXAMPLES :
;; (ball-state (make-ball 330 384 0 0)) = true
;; (ball-state (make-ball 330 384 7 0)) = false
;; (ball-state (make-ball 330 269 0 0)) = false

(define (ball-state b)
  (and
   (= (ball-x b) INIT-X-COORD)
   (= (ball-y b) INIT-Y-COORD)
   (= (ball-vx b) 0)
   (= (ball-vy b) 0)))
        
;; TESTS

(begin-for-test
  (check-equal? (ball-state (make-ball 330 384 0 0)) true)
  (check-equal? (ball-state (make-ball 330 384 7 0)) false)
  (check-equal? (ball-state (make-ball 330 269 0 0)) false))

;; racket-state : Racket -> Boolean
;; GIVEN : a Racket
;; RETURNS : true if the racket from the current world is in ready state
;; STRATEGY : Cases on Racket
;; EXAMPLES :
;; (racket-state (make-racket 330 384 0 0 false)) = true
;; (racket-state (make-racket 330 384 7 0 false)) = false
;; (racket-state (make-racket 330 269 0 0 false)) = false

(define (racket-state r)
  (and
   (= (racket-x r) INIT-X-COORD)
   (= (racket-y r) INIT-Y-COORD)
   (= (racket-vx r) 0)
   (= (racket-vy r) 0)))
        
;; TESTS

(begin-for-test
  (check-equal? (racket-state (make-racket 330 384 0 0 false)) true)
  (check-equal? (racket-state (make-racket 330 384 7 0 false)) false)
  (check-equal? (racket-state (make-racket 330 269 0 0 false)) false))
   
;; world-after-tick : World -> World
;; GIVEN: any world that's possible for the simulation 
;; RETURNS: the world that should follow the given world
;;     after a tick
;; EXAMPLE : (world-after-tick
;;                 (make-world
;;                  (list (make-ball 396 24 -3 -9))
;;                  (make-racket 330 384 0 0 #f) #f #f 1/24 40
;;                  (make-mousev 0 0 "button-up")))
;;                (make-world
;;                 (list (make-ball 393 15 -3 -9))
;;                (make-racket 330 384 0 0 #f) #f #f 1/24 40
;;                 (make-mousev 0 0 "button-up")))
;; STRATEGY : Cases on whether the world is paused.

(define (world-after-tick w)
  (if (world-paused? w)
      (check-cycle-conditions w)
      (ball-after-tick w)))

;; check-cycle-conditions : World -> World
;; GIVEN: any world that's not in paused state 
;; RETURNS: the world that should follow the given world
;;     after a tick
;; EXAMPLE : (check-cycle-conditions
;;                 (make-world
;;                  (list (make-ball 396 24 -3 -9))
;;                  (make-racket 330 384 0 0 #f) #f #f 1/24 40
;;                  (make-mousev 0 0 "button-up")))
;;                (make-world
;;                 (list (make-ball 393 15 -3 -9))
;;                 (make-racket 330 384 0 0 #f) #f #f 1/24 40
;;                 (make-mousev 0 0 "button-up")))
;; STRATEGY : Cases on world cycle.

(define (check-cycle-conditions w)
  (if (>= 0 (world-cycle w))
      (initial-world (world-wticks w))
      (paused-cycle-world w)))

(begin-for-test
  (check-equal? (check-cycle-conditions
                 (make-world
                  (list (make-ball 396 24 -3 -9))
                  (make-racket 330 384 0 0 #f) #f #f 1/24 40
                  (make-mousev 0 0 "button-up")))
                 (make-world
                 (list (make-ball 396 24 -3 -9))
                 (make-racket 330 384 0 0 #f) #t #f 1/24 39
                 (make-mousev 0 0 "button-up"))))

;; paused-cycle-world : World -> World
;; GIVEN: any world that's paused in rally state 
;; RETURNS: the world that should follow the given world
;;     after a tick
;; EXAMPLE :   (paused-cycle-world
;;                 (make-world
;;                  ballist0
;;                  (make-racket 330 384 0 0 false) true false 1/24 72 MOUSEV))
;;                (make-world
;;                 ballist0
;;                 (make-racket 330 384 0 0 false) true false 1/24 71 MOUSEV))
;; STRATEGY : Use constructor template of World on given world.

(define (paused-cycle-world w)
  (make-world (world-balls w)
              (world-racket w)
              true
              (world-selected? w)
              (world-wticks w)
              (- (world-cycle w) 1)
              MOUSEV))

;; TESTS

(begin-for-test
  (check-equal? (world-after-tick
                 (make-world
                  (list (make-ball 396 24 -3 -9))
                  (make-racket 330 384 0 0 #f) #f #f 1/24 40
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 393 15 -3 -9))
                 (make-racket 330 384 0 0 #f) #f #f 1/24 40
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-after-tick
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 #f) #t #f 1/24 0
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 330 384 0 0))
                 (make-racket 330 384 0 0 #f) #t #f 1/24 72
                 (make-mousev 0 0 "button-up"))))

;; ball-after-tick : World -> World
;; GIVEN: a World
;; RETURNS : the state of world after a tick
;; EXAMPLE : (ball-after-tick
;;                 (make-world
;;                  (list (make-ball 211 543 -3 9) (make-ball 178 642 -3 9))
;;                  (make-racket 330 384 0 0 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  17
;;                  (make-mousev 0 0 "button-up")))
;;                (make-world
;;                 (list (make-ball 208 552 -3 9))
;;                 (make-racket 330 384 0 0 #f)
;;                 #f
;;                 #f
;;                 1/24
;;                 17
;;                 (make-mousev 0 0 "button-up"))
;; STRATEGY : Cases on ball

(define (ball-after-tick w)
  (cond
    [(ball-hits-racket (world-balls w) (world-racket w))
     (return-new-world w)]
    [(ball-hits-front-wall-check w)
     (ball-hits-front-wall w)]
    [(ball-hits-left-wall-check w)
     (ball-hits-left-wall w)]
    [(ball-hits-right-wall-check w)
     (ball-hits-right-wall w)]
    [(ball-hits-back-wall-check w)
     (ball-hits-back-wall w)]
    [else
     (return-next-world w)]))

;; TEST

(begin-for-test
  (check-equal? (ball-after-tick
  (make-world
   (list (make-ball 304 264 -3 9)
         (make-ball 295 291 -3 9)
         (make-ball 265 381 -3 9))
   (make-racket 256 384 -2 0 #f)
   #f
   #f
   1/24
   49
   (make-mousev 0 0 "button-up")))
  (make-world
  (list (make-ball 301 273 -3 9)
        (make-ball 292 300 -3 9)
        (make-ball 262 372 -3 -9))
  (make-racket 256 384 -2 0 #f)
  #f
  #f
  1/24
  49
  (make-mousev 0 0 "button-up")))
  (check-equal? (ball-after-tick
                 (make-world
                  (list (make-ball 211 543 -3 9) (make-ball 178 642 -3 9))
                  (make-racket 330 384 0 0 #f)
                  #f
                  #f
                  1/24
                  17
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 208 552 -3 9))
                 (make-racket 330 384 0 0 #f)
                 #f
                 #f
                 1/24
                 17
                 (make-mousev 0 0 "button-up")))
  (check-equal? (ball-after-tick
                 (make-world
                  (list (make-ball 423 105 3 -9))
                  (make-racket 330 384 0 0 #f)
                  #f
                  #f
                  1/24
                  36
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 424 96 -3 -9))
                 (make-racket 330 384 0 0 #f)
                 #f
                 #f
                 1/24
                 36
                 (make-mousev 0 0 "button-up")))
  (check-equal? (ball-after-tick
                 (make-world
                  (list (make-ball 391 3 -3 9))
                  (make-racket 330 384 0 0 #f)
                  #f
                  #f
                  1/24
                  31
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 388 12 -3 9))
                 (make-racket 330 384 0 0 #f)
                 #f
                 #f
                 1/24
                 31
                 (make-mousev 0 0 "button-up")))
  (check-equal? (ball-after-tick
                 (make-world
                  (list (make-ball 394 6 -3 -9))
                  (make-racket 330 384 0 0 #f)
                  #f
                  #f
                  1/24
                  31
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 391 3 -3 9))
                 (make-racket 330 384 0 0 #f)
                 #f
                 #f
                 1/24
                 31
                 (make-mousev 0 0 "button-up")))

  (check-equal? (ball-after-tick
                 (make-world
                  (list (make-ball 0 42 -3 -9))
                  (make-racket 84 276 0 0 #t)
                  #f
                  #t
                  1/24
                  43
                  (make-mousev 84 276 "drag")))
                (make-world
                 (list (make-ball 3 33 3 -9))
                 (make-racket 84 276 0 0 #t)
                 #f
                 #t
                 1/24
                 43
                 (make-mousev 84 276 "drag"))))

;; ball-hits-racket : Ballist Racket -> World
;; RETURNS : true iff a ball is going to collide with racket in tentative tick
;; STRATEGY : Cases on ball
;; EXAMPLE: (ball-hits-racket '() (racket 84 276 0 0 #t))
;;     => false

(define (ball-hits-racket bl r)
  (cond
    [(empty? bl) false]
    [(make-temp-ball-list (first bl) r) true ]
    [else
     (ball-hits-racket (rest bl) r)]))

;; make-temp-ball-list : Ball Racket -> Boolean
;; RETURNS :true iff a ball is going to collide with racket in tentative tick
;; STRATEGY : Cases on ball velocity
;; EXAMPLE : (make-temp-ball-list (ball 0 42 -3 -9) (racket 84 276 0 0 #t))
;;           => false

(define (make-temp-ball-list b r)
  (cond
    [(= 0 (ball-vy b)) false]
    [else
     (if (> (ball-vy b) 0) 
         (create-temp-ball-list b r)
         false)]))

;; create-temp-ball-list : Ball Racket -> Boolean
;; RETURNS : true iff a ball is going to collide with racket in tentative tick
;; STRATEGY : Cases on ball and racket
;; EXAMPLE :(create-temp-ball-list (ball 391 3 -1/3 1)
;;                                (racket 330 384 0 0 #f))
;;     => False
;;  (make-mousev 0 0 "button-up"))

(define (create-temp-ball-list b r)
  (if (and (= (+ (ball-y b) (ball-vy b)) (+ (racket-y r) (racket-vy r)))
           (> (+ (racket-x r) HALF-RKT-WIDTH) (- (ball-x b) (ball-vx b)))
           (< (- (racket-x r) HALF-RKT-WIDTH) (- (ball-x b) (ball-vx b))))
      true
      (make-temp-ball-list
       (make-ball
        (ball-x b)
        (ball-y b)
        (- (ball-vx b) (/ (ball-vx b) (ball-vy b)))
        (- (ball-vy b) 1)) r)))

;; return-new-world : World -> World
;; STRATEGY : Cases on world and combine simpler functions
;; EXAMPLE (return-new-world
;  (make-world
;;   (list (make-ball 304 264 -3 9)
;;         (make-ball 295 291 -3 9)
;;         (make-ball 265 381 -3 9))
;;   (make-racket 256 384 -2 0 #f)
;;   #f
;;   #f
;;   1/24
;;   49
;;   (make-mousev 0 0 "button-up")))
;;  (make-world
;;  (list (make-ball 301 273 -3 9)
;;        (make-ball 292 300 -3 9)
;;        (make-ball 262 372 -3 -9))
;;  (make-racket 256 384 -2 0 #f)
;;  #f
;;  #f
;;  1/24
;;  49
;;  (make-mousev 0 0 "button-up"))
;; STRATEGY: Cases on ballist
     
(define (return-new-world w)
  (cond
    [(empty? (world-balls w))
     (empty-ball-hits-racket w)]
    [(make-temp-ball-list (first (world-balls w)) (world-racket w))
     (ball-collided w)]
    [else
     (final-world-after-collision w)]))

;; empty-ball-hits-racket : World -> World
;; GIVEN : a World in rally state
;; RETURNS : World that should follow the given world after collision
;; EXAMPLE (empty-ball-hits-racket
;;  (make-world
;;   (list (make-ball 304 264 -3 9)
;;   (make-racket 256 384 -2 0 #f)
;;   #f
;;   #f
;;   1/24
;;   49
;;   (make-mousev 0 0 "button-up")))
;;  (make-world
;;  '()
;;  (make-racket 256 384 -2 0 #f)
;;  #f
;;  #f
;;  1/24
;;  49
;;  (make-mousev 0 0 "button-up"))
;;STRATEGY : Use constructor template of World on w

(define (empty-ball-hits-racket w)
  (make-world '() (new-racket-state w)
              (world-paused? w)
              (world-selected? w)
              (world-wticks w)
              (world-cycle w)
              (world-mousev w)))

;; ball-collided : World -> World
;; GIVEN : a World in rally state
;; RETURNS : World that should follow the given world after first ball collides
;; with the racket
;; EXAMPLE (ball-collided
;;  (make-world
;;   (list (make-ball 304 264 -3 9)
;;         (make-ball 295 291 -3 9)
;;         (make-ball 265 381 -3 9))
;;   (make-racket 256 384 -2 0 #f)
;;   #f
;;   #f
;;   1/24
;;   49
;;   (make-mousev 0 0 "button-up")))
;;  (make-world
;;  (list (make-ball 301 273 -3 9)
;;        (make-ball 292 300 -3 9)
;;        (make-ball 262 372 -3 -9))
;;  (make-racket 256 384 -2 0 #f)
;;  #f
;;  #f
;;  1/24
;;  49
;;  (make-mousev 0 0 "button-up"))
;;STRATEGY : Use constructor template of World on w

(define (ball-collided w)
  (make-world (cons (new-ball-state w)
                    (check-collision-next-ball w))
              (new-racket-state w)
              (world-paused? w)
              (world-selected? w)
              (world-wticks w)
              (world-cycle w)
              (world-mousev w)))

;; check-collision-next-ball : World -> World
;; GIVEN: a world in rally state
;; RETURNS : given world with one ball less from Ballist
;; EXAMPLE (check-collision-next-ball
;;  (make-world
;;   (list (make-ball 304 264 -3 9)
;;         (make-ball 295 291 -3 9)
;;         (make-ball 265 381 -3 9))
;;   (make-racket 256 384 -2 0 #f)
;;   #f
;;   #f
;;   1/24
;;   49
;;   (make-mousev 0 0 "button-up")))
;;  (make-world
;;  (list (make-ball 292 300 -3 9)
;;        (make-ball 262 372 -3 -9))
;;  (make-racket 256 384 -2 0 #f)
;;  #f
;;  #f
;;  1/24
;;  49
;;  (make-mousev 0 0 "button-up"))
;;STRATEGY : Use constructor template of World on w

(define (check-collision-next-ball w)
  (world-balls (return-new-world
                (make-world (rest(world-balls w))
                            (world-racket w)
                            (world-paused? w)
                            (world-selected? w)
                            (world-wticks w)
                            (world-cycle w)
                            (world-mousev w)))))

;; final-world-after-collision : World -> World
;; GIVEN : a World in rally state
;; RETURNS : World thst should follow after collision
;; EXAMPLE (final-world-after-collision
;;  (make-world
;;   (list (make-ball 304 264 -3 9)
;;         (make-ball 295 291 -3 9)
;;         (make-ball 265 381 -3 9))
;;   (make-racket 256 384 -2 0 #f)
;;   #f
;;   #f
;;   1/24
;;   49
;;   (make-mousev 0 0 "button-up")))
;;  (make-world
;;  (list (make-ball 301 273 -3 9)
;;        (make-ball 292 300 -3 9)
;;        (make-ball 262 372 -3 -9))
;;  (make-racket 256 384 -2 0 #f)
;;  #f
;;  #f
;;  1/24
;;  49
;;  (make-mousev 0 0 "button-up"))
;;STRATEGY : Use constructor template of World on w

(define (final-world-after-collision w)
  (make-world(cons (construct-ball(first (world-balls w)))
                   (construct-rest-collision w))
             (world-racket w)
             (world-paused? w)
             (world-selected? w)
             (world-wticks w)
             (world-cycle w)
             (world-mousev w)))

;; construct-rest-collision : World -> World
;; GIVEN : a World in rally state
;; RETURNS : World thst should follow after collision
;; EXAMPLE (construct-rest-collision
;;  (make-world
;;   (list (make-ball 304 264 -3 9)
;;         (make-ball 295 291 -3 9)
;;         (make-ball 265 381 -3 9))
;;   (make-racket 256 384 -2 0 #f)
;;   #f
;;   #f
;;   1/24
;;   49
;;   (make-mousev 0 0 "button-up")))
;;  (make-world
;;  (list (make-ball 292 300 -3 9)
;;        (make-ball 262 372 -3 -9))
;;STRATEGY : Use constructor template of World on w

(define (construct-rest-collision w)
  (world-balls
   (return-new-world
    (make-world (rest(world-balls w))
                (world-racket w)
                (world-paused? w)
                (world-selected? w)
                (world-wticks w)
                (world-cycle w)
                (world-mousev w)))))

;; new-ball-state : World -> Ball
;; GIVEN :  a World in rally state
;; RETURNS : returns the new position of ball after it hits racket
;; STRATEGY: Use constructor template of Ball on ball from world
;; EXAMPLE : >(new-ball-state
;;  (world
;;   (list (ball 265 381 -3 9))
;;   (racket 256 384 -2 0 #f)
;;   #f
;;   #f
;;   1/24
;;  49
;;   (mousev 0 0 "button-up")))
;;   => (ball 262 372 -3 -9)

(define (new-ball-state w)
  (make-ball
   (+ (ball-x (first (world-balls w)))
      (ball-vx (first (world-balls w))))
   (+ (ball-y (first (world-balls w)))
      (- (racket-vy (world-racket w)) (ball-vy (first (world-balls w)))))
   (ball-vx (first (world-balls w)))
   (- (racket-vy (world-racket w)) (ball-vy (first (world-balls w))))))

;; new-racket-state : World -> Racket
;; GIVEN :  a World in rally state
;; RETURNS : returns the new position of racket after it hits ball
;; STRATEGY: Use constructor template of Racket on racket from world
;; EXAMPLE : (new-racket-state
;;                 (make-world
;;                  (list (make-ball 238 462 -3 9))
;;                  (make-racket 221 465 1 -3 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  48
;;                  (make-mousev 0 0 "button-up")))
;;    =>     (make-racket 221 465 1 0 #f))

(define (new-racket-state w)
  (cond
    [(< (racket-vy (world-racket w)) 0)
     (make-racket (racket-x (world-racket w))
                  (racket-y (world-racket w))
                  (racket-vx (world-racket w))
                  0
                  false)]
    [else (world-racket w)]))

;; TEST

(begin-for-test
  (check-equal? (new-racket-state
                 (make-world
                  (list (make-ball 238 462 -3 9))
                  (make-racket 221 465 1 -3 #f)
                  #f
                  #f
                  1/24
                  48
                  (make-mousev 0 0 "button-up")))
                (make-racket 221 465 1 0 #f)))

;; ball-hits-front-wall-check : World -> Boolean
;; GIVEN: a World
;; RETURNS : true iff any of the ball hits front wall
;; STRATEGY : Use HOF Ormap on Ballist
;; EXAMPLE: (ball-hits-front-wall-check
;;  (world
;;   (list (ball 0 42 -3 -9))
;;   (racket 84 276 0 0 #t)
;;   #f
;;   #t
;;   1/24
;;   43
;;  (mousev 84 276 "drag")))
;;    => #f

#|(define (ball-hits-front-wall-check w)
  (cond
    [(empty? (world-balls w)) false]
    [else
     (cond
       [(> 0 (+ (ball-y (first (world-balls w)))
                (ball-vy (first (world-balls w))) HALF-BALL-WIDTH)) true]
       [else (front-wall-check- w)])])) |#

(define (ball-hits-front-wall-check w)
  (ormap
   ;; Ball -> Ball
   ;; GIVEN: a Ball
   ;; RETURNS : true iff ball hits front wall
   ;; STRATEGY: Caseson velocity of Ball
   (lambda (b) (> 0 (+ (ball-y b)
                       (ball-vy b) HALF-BALL-WIDTH)))
   (world-balls w)))

#|

;; front-wall-check : World -> World
;; GIVEN: a world
;; RETURNS: state of the world if any of the ball hits front wall
;; STRATEGY : Use constructor template of World on w

(define (front-wall-check w)
  (ball-hits-front-wall-check
   (make-world
    (rest(world-balls w))
    (world-racket w)
    (world-paused? w)
    (world-selected? w)
    (world-wticks w)
    (world-cycle w)
    (world-mousev w))))|#

;; ball-hits-front-wall : World -> World
;; GIVEN: a world
;; RETURNS: state of the world if any of the ball hits front wall
;; STRATEGY : Use HOF Map on Ballist
;; EXAMPLE: (ball-hits-front-wall
;;                 (make-world
;;                  (list (make-ball 394 6 -3 -9) (make-ball 358 102 -3 9))
;;                  (make-racket 330 384 0 0 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  25
;;                  (make-mousev 0 0 "button-up")))
;;       =>         (make-world
;;                 (list (make-ball 391 3 -3 9) (make-ball 355 111 -3 9))
;;                (make-racket 330 384 0 0 #f)
;;                 #f
;;                 #f
;;                1/24
;;                 25
;;                 (make-mousev 0 0 "button-up"))

#|(define (ball-hits-front-wall w)
  (cond
    [(empty? (world-balls w)) (front-wall-empty-list w)]
    [(> 0 (+ (ball-y (first (world-balls w)))
             (ball-vy (first (world-balls w))) HALF-BALL-WIDTH))
     (first-ball-hits-front w)]
    [else
      (check-rest-ball-front w)])) |#

(define (ball-hits-front-wall w)
  (make-world
   (front-wall-cond w)
   (world-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; front-wall-cond : World -> Ballist
;; GIVEN: a World
;; RETURNS: state of the Ballist after checking if any ball hit front wall
;; STRATEGY : Use HOF Map on Ballist
;; EXAMPLE: (front-wall-cond
;;  (world
;;   (list (ball 394 6 -3 -9) (ball 358 102 -3 9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   25
;;   (mousev 0 0 "button-up")))
;; => (list (ball 391 3 -3 9) (ball 355 111 -3 9))

(define (front-wall-cond w)
  (map
   ;; Ball -> Ball
   ;; GIVEN: a Ball
   ;; RETURNS: state of the base on front wall collision
   ;; STRATEGY: Case on velociy of Ball
   (lambda (b)
     (if (> 0 (+ (ball-y b)
                 (ball-vy b) HALF-BALL-WIDTH))
         (front-wall b)
         (construct-ball b) ))
   (world-balls w)))

;; TEST

(begin-for-test
  (check-equal? (ball-hits-front-wall
                 (make-world
                  (list (make-ball 394 6 -3 -9) (make-ball 358 102 -3 9))
                  (make-racket 330 384 0 0 #f)
                  #f
                  #f
                  1/24
                  25
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 391 3 -3 9) (make-ball 355 111 -3 9))
                 (make-racket 330 384 0 0 #f)
                 #f
                 #f
                 1/24
                 25
                 (make-mousev 0 0 "button-up"))))

#|

;; front-wall-empty-list : World -> World
;; GIVEN: a World
;; RETURNS: state of the world with empty Ballist
;; STRATEGY : Use constructor template of World on w

(define (front-wall-empty-list w)
  (make-world '()
              (world-racket w)
              (world-paused? w)
              (world-selected? w)
              (world-wticks w)
              (world-cycle w)
              (world-mousev w)))

;; check-rest-ball-front : World -> World
;; GIVEN: a Ball
;; RETURNS: the state of the ballist after hitting front wall
;; STRATEGY : Use constructor template of World on w

(define (check-rest-ball-front w)
  (make-world (cons (construct-ball(first(world-balls w)))
                    (construct-rest-ball-front w))
                      (world-racket w)
                      (world-paused? w)
                      (world-selected? w)
                      (world-wticks w)
                      (world-cycle w)
                      (world-mousev w)))

;; construct-rest-ball-front : World -> Ballist
;; GIVEN: a World
;; RETURNS: the state of the ballist after hitting front wall
;; STRATEGY : Use constructor template of World on w

(define (construct-rest-ball-front w)
  (world-balls
   (ball-hits-front-wall
    (make-world (rest(world-balls w))
                (world-racket w)
                (world-paused? w)
                (world-selected? w)
                (world-wticks w)
                (world-cycle w)
                (world-mousev w)))))

;; first-ball-hits-front : World -> World
;; GIVEN: a World
;; RETURNS: the state of the World after any ball hits front wall
;; STRATEGY : Use constructor template of World on w

(define (first-ball-hits-front w)
  (make-world (cons (front-wall (first (world-balls w)))
                    (rest-ball-front w))
                 (world-racket w)
                 (world-paused? w)
                 (world-selected? w)
                 (world-wticks w)
                 (world-cycle w)
                 (world-mousev w)))

;; rest-ball-front : Ball -> Ballist
;; GIVEN: a Ball
;; RETURNS: the state of the ballist after hitting front wall
;; STRATEGY : Use constructor template of World on w

(define (rest-ball-front w)
  (world-balls
   (ball-hits-front-wall
    (make-world (rest(world-balls w))
                (world-racket w)
                (world-paused? w)
                (world-selected? w)
                (world-wticks w)
                (world-cycle w)
                (world-mousev w)))))|#

;; front-wall : Ball -> Ball
;; GIVEN: a Ball
;; RETURNS: the state of the ball after hitting front wall
;; STRATEGY : Use constructor template of Ball on b
;; EXAMPLE : >(front-wall (ball 394 6 -3 -9))
;; => (ball 391 3 -3 9)

(define (front-wall b)
  (make-ball
   (+ (ball-x b)
      (ball-vx b))
   (* 2 HALF-BALL-WIDTH)
   (ball-vx b)
   (- 0 (ball-vy b))))

;; ball-hits-left-wall-check : World -> Boolean
;; GIVEN: A World
;; RETURNS : true iff any of the ball hits right wall
;; STRATEGY : USE HOF Ormap on Ballist
;; EXAMPLE: (ball-hits-left-wall-check
;;  (world
;;   (list (ball 0 42 -3 -9))
;;   (racket 84 276 0 0 #t)
;;   #f
;;   #t
;;   1/24
;;   43
;;   (mousev 84 276 "drag")))
;;   => #t

#|(define (ball-hits-left-wall-check w)
  (cond
    [(empty? (world-balls w)) false]
    [else
     (cond
       [(> 0 (+ (ball-x (first (world-balls w)))
                (ball-vx (first (world-balls w))) HALF-BALL-WIDTH)) true]
       [else
         (left-wall-check w)])])) |#

(define (ball-hits-left-wall-check w)
  (ormap
   ;; Ball -> Boolean
   ;; GIVEN: a ball
   ;; RETURNS : true iff the ball hits left wall
   ;; STRATEGY: Cases on velocity of the ball
   (lambda (b) (> 0 (+ (ball-x b)
                       (ball-vx b) HALF-BALL-WIDTH)))
   (world-balls w)))

#|

;; left-wall-check : World -> World
;; GIVEN : a World
;; RETURNS : state of the world to check if rest of the ball hits left wall
;; STRATEGY : Use constructor template of World on w

(define (left-wall-check w)
  (ball-hits-left-wall-check
   (make-world (rest(world-balls w))
               (world-racket w)
               (world-paused? w)
               (world-selected? w)
               (world-wticks w)
               (world-cycle w)
               (world-mousev w))))|#

;; ball-hits-left-wall : World -> World
;; GIVEN : A World
;; RETURNS: state of the world after any of the ball hits left wall
;; STRATEGY : Use HOF Map on Ballist
;; EXAMPLE: (ball-hits-left-wall
;;  (world
;;   (list (ball 0 42 -3 -9))
;;   (racket 84 276 0 0 #t)
;;   #f
;;   #t
;;  1/24
;;  43
;;   (mousev 84 276 "drag")))
;;  =>  (world
;;  (list (ball 3 33 3 -9))
;;  (racket 84 276 0 0 #t)
;;  #f
;;  #t
;;  1/24
;;  43
;;  (mousev 84 276 "drag"))

#|(define (ball-hits-left-wall w)
  (cond
    [(> 0 (+ (ball-x (first (world-balls w)))
             (ball-vx (first (world-balls w))) HALF-BALL-WIDTH))
     (first-ball-hits-left w)]
    [else (check-rest-ball-left w)]))   |#

(define (ball-hits-left-wall w)
  (make-world
   (left-wall-cond w)
   (world-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; check-rest-ball-left : World -> World
;; GIVEN: a World
;; RETURNS: state of ball after any of the ball hits left wall
;; STRATEGY : Use HOF map on Ballist
;; EXAMPLE : (left-wall-cond
;;  (world
;;   (list (ball 0 42 -3 -9))
;;   (racket 84 276 0 0 #t)
;;   #f
;;   #t
;;   1/24
;;   43
;;   (mousev 84 276 "drag")))
;;    => (list (ball 3 33 3 -9))

(define (left-wall-cond w)
  (map
   ;; Ball-> BAll
   ;; GIVEN: a Ball
   ;; RETURNS: state of the ball if hits left wall
   ;; STRATEGY: Cases on velocity of ball
   (lambda (b)
     (if  (> 0 (+ (ball-x (first (world-balls w)))
                  (ball-vx (first (world-balls w)))
                  HALF-BALL-WIDTH))
          (left-wall b)
          (construct-ball b)))
   (world-balls w)))

(begin-for-test
  (check-equal? (left-wall-cond
  (make-world
   (list (make-ball 40 42 -3 -9))
   (make-racket 84 276 0 0 #t)
   #f
   #t
   1/24
   43
   (make-mousev 84 276 "drag")))
     (list (make-ball 37 33 -3 -9))))

#|

;; check-rest-ball-left : World -> World
;; GIVEN: a World
;; RETURNS: state of ball after any of the rest of ball hits left wall
;; STRATEGY : Use constructor template of World on w

(define (check-rest-ball-left w)
  (make-world (cons (construct-ball (first(world-balls w)))
                    (construct-left-ball-left w))
                      (world-racket w)
                      (world-paused? w)
                      (world-selected? w)
                      (world-wticks w)
                      (world-cycle w)
                      (world-mousev w)))

;; construct-left-ball-left : World -> Ballist
;; GIVEN: a World
;; RETURNS: state of ball after any of the rest of ball hits left wall
;; STRATEGY : Use constructor template of World on w

(define (construct-left-ball-left w)
  (world-balls
   (ball-hits-left-wall
    (make-world
     (rest(world-balls w))
     (world-racket w)
     (world-paused? w)
     (world-selected? w)
     (world-wticks w)
     (world-cycle w)
     (world-mousev w)))))

;; first-ball-hits-left : World -> World
;; GIVEN: a Ball
;; RETURNS: state of ball afterfirst ball hits left wall
;; STRATEGY : Use constructor template of World on w

(define (first-ball-hits-left w)
  (make-world (cons (left-wall (first (world-balls w)))
                     (rest(world-balls w)))
              (world-racket w)
              (world-paused? w)
              (world-selected? w)
              (world-wticks w)
              (world-cycle w)
              (world-mousev w)))|#
     
;; left-wall : Ball -> Ball
;; GIVEN: a Ball
;; RETURNS: state aof ball after hitting left wall
;; STRATEGY : Use constructor template of Ball on b
;; EXAMPLES: (left-wall (ball 0 42 -3 -9))
;;      => (ball 3 33 3 -9)

(define (left-wall b)
  (make-ball
   (* 2 HALF-BALL-WIDTH)
   (+ (ball-y b)
      (ball-vy b))
   (- 0 (ball-vx b))
   (ball-vy b)))

;; ball-hits-right-wall-check : World -> Boolean
;; GIVEN: a World
;; RETURNS : true iff a ball hits right wall
;; STRATEGY : Use HOF Ormap on Ballist
;; EXAMPLE: (ball-hits-right-wall-check
;;  (world
;;  (list (ball 391 3 -3 9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   31
;;   (mousev 0 0 "button-up")))
;;   => #f

#|(define (ball-hits-right-wall-check w)
  (cond
    [(empty? (world-balls w)) false]
    [else
     (cond
       [(< CANVAS-WIDTH
           (+ (ball-x (first (world-balls w)))
              (ball-vx (first (world-balls w))) HALF-BALL-WIDTH)) true]
       [else (right-wall-check w)])])) |#

(define (ball-hits-right-wall-check w)
  (ormap
   ;; Ball -> Boolean
   ;; GIVEN: a Ball
   ;; RETURNS: true iff a ball a ball hits right wall
   ;; STRATEGY: Cases on velocity of the ball
   (lambda (b) (< CANVAS-WIDTH (+ (ball-x b)
                                  (ball-vx b) HALF-BALL-WIDTH)))
   (world-balls w)))

#|

;; right-wall-check : World -> World
;; GIVEN : a World
;; RETURNS : state of the world to check if rest of the ball hits right wall
;; STRATEGY : Use constructor template of World on w

(define (right-wall-check w)
  (ball-hits-right-wall-check
   (make-world
    (rest(world-balls w))
    (world-racket w)
    (world-paused? w)
    (world-selected? w)
    (world-wticks w)
    (world-cycle w)
    (world-mousev w))))|#

;; ball-hits-right-wall : World -> World
;; GIVEN : a World
;; RETURNS : state of the world after a ball hits right wall
;; STRATEGY : Use HOF Map on Ballist
;; EXAMPLES : (ball-hits-right-wall
;;  (world
;;   (list (ball 423 105 3 -9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   36
;;   (mousev 0 0 "button-up")))
;; => (world
;;  (list (ball 424 96 -3 -9))
;;  (racket 330 384 0 0 #f)
;;  #f
;;  #f
;;  1/24
;;  36
;;  (mousev 0 0 "button-up")

#|(define (ball-hits-right-wall w)
  (cond
    [(empty? (world-balls w)) (right-wall-empty-list w)]
    [(< CANVAS-WIDTH (+ (ball-x (first (world-balls w)))
                        (ball-vx (first (world-balls w))) HALF-BALL-WIDTH))
     (first-ball-hits-right w)]
    [else
      (check-rest-ball-right w)]))|#

(define (ball-hits-right-wall w)
  (make-world
   (right-wall-cond w)
   (world-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; right-wall-cond : World -> Ballist
;; GIVEN: a World
;; RETURNS: new state of Ballist afyer hitting right wall
;; STRATEGY : Use HOF map on Ballist
;; EXAMPLE : (right-wall-cond
;;  (world
;;   (list (ball 423 105 3 -9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   36
;;   (mousev 0 0 "button-up")))
;; (list (ball 424 96 -3 -9))

(define (right-wall-cond w)
  (map
   ;; BAll -> BAll
   ;; GIVEN : a Ball
   ;; RETURNS: new state of ball after hitting right wall
   ;; STRATEGY: Cases on velocity of ball
   (lambda (b) (if (< CANVAS-WIDTH (+ (ball-x b)
                                      (ball-vx b) HALF-BALL-WIDTH))
                   (right-wall b) (construct-ball b)))
   (world-balls w)))

(begin-for-test
  (check-equal? (right-wall-cond
  (make-world
   (list (make-ball 400 105 3 -9))
   (make-racket 330 384 0 0 #f)
   #f
   #f
   1/24
   36
   (make-mousev 0 0 "button-up")))
(list (make-ball 403 96 3 -9))))

#|

;; right-wall-empty-list : World -> World
;; GIVEN: a World
;; RETURNS: new state of world with empty Ballist
;; STRATEGY : Use constructor template of World on w

(define (right-wall-empty-list w)
  (make-world '()
              (world-racket w)
              (world-paused? w)
              (world-selected? w)
              (world-wticks w)
              (world-cycle w)
              (world-mousev w)))

;; check-rest-ball-right : World -> World
;; GIVEN: a World
;; RETURNS: new state of world after first ball hits right wall
;; STRATEGY : Use constructor template of World on w

(define (check-rest-ball-right w)
  (make-world (cons (construct-ball(first(world-balls w)))
                    (construct-rest-ball-right w))
              (world-racket w)
              (world-paused? w)
              (world-selected? w)
              (world-wticks w)
              (world-cycle w)
              (world-mousev w)))

;; construct-rest-ball-right : World -> Ballist
;; GIVEN: a World
;; RETURNS: new state of world after first ball hits right wall
;; STRATEGY : Use constructor template of World on w

(define (construct-rest-ball-right w)
  (world-balls
   (ball-hits-right-wall
    (make-world
     (rest(world-balls w))
     (world-racket w)
     (world-paused? w)
     (world-selected? w)
     (world-wticks w)
     (world-cycle w)
     (world-mousev w)))))

;; first-ball-hits-right : World -> Ballist
;; GIVEN: a World
;; RETURNS: new state of world after first ball hits right wall
;; STRATEGY : Use constructor template of World on w

(define (first-ball-hits-right w)
  (make-world (cons (right-wall (first (world-balls w)))
                     (rest-right-wall w))
                 (world-racket w)
                 (world-paused? w)
                 (world-selected? w)
                 (world-wticks w)
                 (world-cycle w)
                 (world-mousev w)))

;; rest-right-wall : World -> Ballist
;; GIVEN: a World
;; RETURNS: new state of rest of balls in next tick
;; STRATEGY : Combine simpler functions

(define (rest-right-wall w)
  (world-balls
   (ball-hits-right-wall
    (make-world
     (rest(world-balls w))
     (world-racket w)
     (world-paused? w)
     (world-selected? w)
     (world-wticks w)
     (world-cycle w)
     (world-mousev w)))))|#

;; right-wall : Ball -> Ball
;; GIVEN: a BAll
;; RETURNS: new state of ball in next tick
;; STRATEGY : Combine simpler functions
;; EXAMPLE: (right-wall (ball 423 105 3 -9))
;;   =>     (ball 424 96 -3 -9)

(define (right-wall b)
  (make-ball
   (- CANVAS-WIDTH(- (+ (ball-x b)
                        (ball-vx b)) CANVAS-WIDTH))
   (+ (ball-y b)
      (ball-vy b))
   (- 0 (ball-vx b))
   (ball-vy b)))

;; return-next-world : World -> World
;; GIVEN: a World
;; RETURNS: state of world in next tick
;; EXAMPLE : (return-next-world
;;                 (make-world
;;                  (list (make-ball 286 318 -3 9))
;;                  (make-racket 349 332 0 0 #t)
;;                  #f
;;                  #t
;;                  1/24
;;                  37
;;                  (make-mousev 349 332 "drag")))
;;       =>         (make-world
;;                 (list (make-ball 283 327 -3 9))
;;                 (make-racket 349 332 0 0 #t)
;;                 #f
;;                 #t
;;                 1/24
;;                 37
;;                 (make-mousev 349 332 "drag")
;; STRATEGY : Cases on ball

(define (return-next-world w)
  (if (racket-select? (world-racket w))
      (make-world
       (next-ball-cond (world-balls w))
       (world-racket w)
       (world-paused? w)
       (world-selected? w)
       (world-wticks w)
       (world-cycle w)
       (world-mousev w))
      (make-racket-after-tick w)))

;; TEST

(begin-for-test
  (check-equal? (return-next-world
                 (make-world
                  (list (make-ball 286 318 -3 9))
                  (make-racket 349 332 0 0 #t)
                  #f
                  #t
                  1/24
                  37
                  (make-mousev 349 332 "drag")))
                (make-world
                 (list (make-ball 283 327 -3 9))
                 (make-racket 349 332 0 0 #t)
                 #f
                 #t
                 1/24
                 37
                 (make-mousev 349 332 "drag"))))

;; next-ball-cond : Ballist -> Ballist
;; GIVEN: a Ballist
;; RETURNS: Ballist state in next tick
;; STRATEGY : Combine simpler functions
;; EXAMPLE: (next-ball-cond (list (make-ball 153 717 -3 9)
;;                                (make-ball 150 726 -3 9)))
;; =>   (list (make-ball 150 726 -3 9) (make-ball 147 735 -3 9))

(define (next-ball-cond bl)
  (cond
    [(empty? bl) '()] 
    [(= 1 (length bl)) (cons (construct-ball (first bl)) '())]
    [else (cons (construct-ball (first bl)) (next-ball-cond (rest bl)))]))

;; TEST

(begin-for-test
  (check-equal?
   (next-ball-cond (list (make-ball 153 717 -3 9) (make-ball 150 726 -3 9)))
   (list (make-ball 150 726 -3 9) (make-ball 147 735 -3 9))))

;; construct-ball : Ball -> Ball
;; GIVEN : a Ball
;; RETURNS: state of ball in next tick
;; STRATEGY : Combine simpler functions
;; EXAMPLES: (construct-ball (make-ball 10 10 20 20))
;;                (make-ball 30 30 20 20)

(define (construct-ball b)
  (make-ball
   (+ (ball-x b)
      (ball-vx b))
   (+ (ball-y b)
      (ball-vy b))
   (ball-vx b)
   (ball-vy b)))

;; TEST

(begin-for-test
  (check-equal? (construct-ball (make-ball 10 10 20 20))
                (make-ball 30 30 20 20)))

;; ball-hits-back-wall-check : World -> Boolean
;; GIVEN: a world
;; RETURNS: true iff ball hits back wall
;; STRATEGY : Use HOF Ormap on Ballist
;; EXAMPLE : >(ball-hits-back-wall-check
;;  (world
;;   (list (ball 396 24 -3 -9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   40
;;   (mousev 0 0 "button-up")))
;;  => #f

#|(define (ball-hits-back-wall-check w)
  (cond
    [(empty? (world-balls w)) false]
    [else
     (cond
       [(< CANVAS-HEIGHT (+ (ball-y (first (world-balls w)))
                            (ball-vy (first (world-balls w))) HALF-BALL-WIDTH)) true]
       [else
         (back-wall-check w)])]))|#

(define (ball-hits-back-wall-check w)
  (ormap
   ;; Ball -> Boolean
   ;; GIVEN: a Ball
   ;; RETURNS: true iff ball hits back wall
   ;; STRATEGY: Cases on velocity of ball
   (lambda (b) (< CANVAS-HEIGHT
                  (+ (ball-y b)
                     (ball-vy b) HALF-BALL-WIDTH)))
   (world-balls w)))

#|

;; back-wall-check : World -> World
;; GIVEN: a World
;; RETURNS: a World after checking if the ball hits back wall
;; STRATEGY : Use constructor template of World on w

(define (back-wall-check w)
   (ball-hits-back-wall-check
     (make-world   (rest(world-balls w))
                   (world-racket w)
                   (world-paused? w)
                   (world-selected? w)
                   (world-wticks w)
                   (world-cycle w)
                   (world-mousev w)))|#

;; ball-hits-back-wall-cond : World -> World
;; GIVEN: a World
;; RETURNS: a World after one of the balls hit back wall
;; STRATEGY : Use HOF Map and Filter on Ballist
;; EXAMPLE : (ball-hits-back-wall-cond
;;  (world
;;   (list (ball 211 543 -3 9) (ball 178 642 -3 9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   17
;;   (mousev 0 0 "button-up"))
;; => (world
;;  (list (ball 208 552 -3 9))
;;  (racket 330 384 0 0 #f)
;;  #f
;;  #f
;;  1/24
;;  17
;;  (mousev 0 0 "button-up"))

#|(define (ball-hits-back-wall-cond w)
  (cond
    [(empty? (world-balls w)) (back-wall-empty-list w)]
    [(< CANVAS-HEIGHT (+ (ball-y (first (world-balls w)))
                         (ball-vy (first (world-balls w))) HALF-BALL-WIDTH))
     (first-ball-hits-back w)]
    [else
     (check-rest-ball-back w)]))|#

(define (ball-hits-back-wall-cond w)
  (make-world
   (back-wall-cond w)
   (world-racket w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; back-wall-cond : World -> Ballist
;; GIVEN: a world
;; RETURNS: a Ballist with the ball hitting back wall removed
;; STRATEGY: Cases on Ball velocity
;; EXAMPLE : (back-wall-cond
;;  (world
;;   (list (ball 211 543 -3 9) (ball 178 642 -3 9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   17
;;   (mousev 0 0 "button-up")))
;;   => (list (ball 208 552 -3 9))

(define (back-wall-cond w)
  (map construct-ball
       (filter
        ;; Ball -> Boolean
        ;; GIVEN : a Ball
        ;; RETURNS: tru iff the ball does not hit back wall
        ;; STRATEGY : Cases on velocity of ball
        (lambda (b) (> CANVAS-HEIGHT (+ (ball-y b)
                                        (ball-vy b) HALF-BALL-WIDTH)))
        (world-balls w))))

#|

;; back-wall-empty-list : World -> World
;; GIVEN: a world
;; RETURNS: a World with empty Ballist
;; STRATEGY: Use constructor template of World on

(define (back-wall-empty-list w)
  (make-world '()
  (world-racket w)
  (world-paused? w)
  (world-selected? w)
  (world-wticks w)
  (world-cycle w)
  (world-mousev w)))

;; first-ball-hits-back : World -> World
;; GIVEN: a world
;; RETURNS: a World after first ball hits back wall
;; STRATEGY: Use constructor template of World on 

(define (first-ball-hits-back w)
  (make-world (rest-back-wall w)
              (world-racket w)
              (world-paused? w)
              (world-selected? w)
              (world-wticks w)
              (world-cycle w)
              (world-mousev w)))

;; rest-back-wall : World -> Ballist
;; GIVEN: a world
;; RETURNS: a list of rest of the balls hitting back wall
;; STRATEGY: Use constructor template of World on 

(define (rest-back-wall w)
  (world-balls
   (ball-hits-back-wall-cond
    (make-world
    (rest(world-balls w))
    (world-racket w)
    (world-paused? w)
    (world-selected? w)
    (world-wticks w)
    (world-cycle w)
    (world-mousev w)))))

;; check-rest-ball-back : World -> World
;; GIVEN: a world
;; RETURNS: a world after first ball hits back wall
;; STRATEGY: Use constructor template of World on w

(define (check-rest-ball-back w)
  (make-world (cons (construct-ball(first(world-balls w)))
                    (construct-rest-back-ball w))
                 (world-racket w)
                 (world-paused? w)
                 (world-selected? w)
                 (world-wticks w)
                 (world-cycle w)
                 (world-mousev w)))

;; construct-rest-ball-back : World -> Ballist
;; GIVEN: a world
;; RETURNS: list of rest of the balls itting back wall
;; STRATEGY: Use constructor teplate of World on w

(define (construct-rest-ball-back w)
  (world-balls
   (ball-hits-back-wall-cond
    (make-world
     (rest(world-balls w))
     (world-racket w)
     (world-paused? w)
     (world-selected? w)
     (world-wticks w)
     (world-cycle w)
     (world-mousev w))))) |#

;; ball-hits-back-wall : World -> World
;; GIVEN: a world
;; RETURNS: the world that should follow the given world
;;     after a ball hits back wall
;; STRATEGY: Use constructor teplate of World on w

(define (ball-hits-back-wall w)
  (if (= 1 (length (world-balls w)))
      (make-world
       '()
       (world-racket w)
       (not (world-paused? w))
       (world-selected? w)
       (world-wticks w)
       (- (* (/ 1 (world-wticks w)) 3) 1)
       (world-mousev w))
      (ball-hits-back-wall-cond w)))

;; TEST

(begin-for-test
  (check-equal? (ball-hits-back-wall
                 (make-world
                  (list (make-ball 178 642 -3 9))
                  (make-racket 330 384 0 0 #f)
                  #f
                  #f
                  1/24
                  46
                  (make-mousev 0 0 "button-up")))
                (make-world '()
                            (make-racket 330 384 0 0 #f) #t #f 1/24 71
                            (make-mousev 0 0 "button-up"))))

;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a world and a key event
;; RETURNS: the world that should follow the given world
;;     after the given key event
;; STRATEGY: Cases on key event

(define (world-after-key-event w kev)
  (cond
    [(is-pause-key-event? kev)
     (check-pause-conditions w)]
    [(is-up-key-event? kev) (world-with-up-toggled w)]
    [(is-down-key-event? kev) (world-with-down-toggled w)]
    [(is-left-key-event? kev) (world-with-left-toggled w)]
    [(is-right-key-event? kev) (world-with-right-toggled w)]
    [(is-b-key-event? kev) (world-with-b-toggled w)]
    [else w]))

;; TEST

(begin-for-test
  (check-equal? (world-after-key-event
                 (make-world
                  (list (make-ball 295 291 -3 9))
                  (make-racket 300 384 0 10 #f)
                  #f
                  #f
                  1/24
                  14
                  (make-mousev 0 0 "button-up")) "left")
                (make-world
                 (list (make-ball 295 291 -3 9))
                 (make-racket 299 384 -1 10 #f)
                 #f
                 #f
                 1/24
                 14
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-after-key-event
                 (make-world
                  (list (make-ball 375 249 3 -9))
                  (make-racket 330 384 0 0 #f)
                  #f
                  #f
                  1/24
                  45
                  (make-mousev 0 0 "button-up")) "down")
                (make-world
                 (list (make-ball 375 249 3 -9))
                 (make-racket 330 384 0 1 #f)
                 #f
                 #f
                 1/24
                 45
                 (make-mousev 0 0 "button-up")))
  (check-equal?  (world-after-key-event 
                  (make-world
                   (list (make-ball 396 186 3 -9))
                   (make-racket 330 384 0 0 #f)
                   #f
                   #f
                   1/24
                   23
                   (make-mousev 0 0 "button-up")) "up")
                 (make-world
                  (list (make-ball 396 186 3 -9))
                  (make-racket 330 384 0 -1 #f)
                  #f
                  #f
                  1/24
                  23
                  (make-mousev 0 0 "button-up")))
  (check-equal?  (world-after-key-event
                  (make-world
                   (list (make-ball 330 384 0 0))
                   (make-racket 330 384 0 0 #f)
                   #t
                   #f
                   1/24
                   50
                   (make-mousev 0 0 "button-up")) " ")
                 (make-world
                  (list (make-ball 330 384 3 -9))
                  (make-racket 330 384 0 0 #f)
                  #f
                  #f
                  1/24
                  50
                  (make-mousev 0 0 "button-up")))
  (check-equal?  (world-after-key-event
                  (make-world
                   (list (make-ball 330 384 0 0))
                   (make-racket 330 384 0 0 false)
                   true
                   false
                   1/24
                   5
                   (make-mousev 0 0 "button-up"))
                  "right")
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 false)
                  true
                  false
                  1/24
                  5
                  (make-mousev 0 0 "button-up")))
  (check-equal? (world-after-key-event
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 false)
                  true
                  false
                  1/24
                  55
                  (make-mousev 0 0 "button-up"))
                 "b")
                (make-world
                 (list (make-ball 330 384 0 0))
                 (make-racket 330 384 0 0 false)
                 true
                 false
                 1/24
                 55
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-after-key-event
                 (make-world
                  (list (make-ball 399 177 3 -9))
                  (make-racket 330 384 0 0 false)
                  false
                  false
                  1/24
                  51
                  (make-mousev 0 0 "button-up"))
                 "r")
                (make-world
                 (list (make-ball 399 177 3 -9))
                 (make-racket 330 384 0 0 false)
                 false
                 false
                 1/24
                 51
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-after-key-event
                 (make-world
                  (list (make-ball 402 42 -3 -9))
                  (make-racket 330 384 0 0 false)
                  false
                  false
                  1/24
                  60
                  (make-mousev 0 0 "button-up"))
                 " ")
                (make-world
                 (list (make-ball 402 42 -3 -9))
                 (make-racket 330 384 0 0 false)
                 true
                 false
                 1/24
                 71
                 (make-mousev 0 0 "button-up"))))

(define (check-pause-conditions w)
  (if (world-ready-to-serve? w)
      (world-rally-state w)
      (world-with-paused-toggled w)))

;; HELPER FUNCTIONS

;; world-rally-state :  World -> World
;; GIVEN :  a World
;; RETURNS: a world in rally state with a moving ball
;; STRATEGY: use constructor template for World on w

(define (world-rally-state w)
  (make-world
   (cons (make-ball
          INIT-X-COORD
          INIT-Y-COORD
          BALL-SPEED-X
          BALL-SPEED-Y) BALLIST)
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
;; STRATEGY: use constructor template for World on w

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
;; STRATEGY: use constructor template for World on w

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

;; TEST

(begin-for-test
  (check-equal? (world-with-up-toggled
                 (make-world
                  (list (make-ball 375 51 -3 9))
                  (make-racket 330 6 0 -27 #f)
                  #t
                  #f
                  1/24
                  64
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 375 51 -3 9))
                 (make-racket 330 6 0 -27 #f)
                 #t
                 #f
                 1/24
                 64
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-with-up-toggled
                 (make-world
                  (list (make-ball 408 60 -3 -9))
                  (make-racket 330 6 0 -27 #f)
                  #f
                  #f
                  1/24
                  32
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 408 60 -3 -9))
                 (make-racket 330 6 0 -27 #f)
                 #t
                 #f
                 1/24
                 71
                 (make-mousev 0 0 "button-up"))))

;; racket-up-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with front wall
;; STRATEGY: use constructor template for World on w

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
;; STRATEGY: use constructor template for World on w

(define (up-racket w)
  (make-racket
   (racket-x (world-racket w))
   (racket-y (world-racket w))
   (racket-vx (world-racket w))
   (- (racket-vy (world-racket w)) 1)
   false))

;; racket-up-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with front wall
;; STRATEGY: use constructor template for World on w

(define (racket-up-collide w)
  (> HALF-RKT-HEIGHT (+ (racket-y (world-racket w))
                        (- (racket-vy (world-racket w)) 1))))

;; world-with-down-toggled : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with down toggled
;; STRATEGY: use constructor template for World on w

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

;; TEST

(begin-for-test
  (check-equal? (world-with-down-toggled
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 #f)
                  #t
                  #f
                  1/24
                  31
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 330 384 0 0))
                 (make-racket 330 384 0 0 #f)
                 #t
                 #f
                 1/24
                 31
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-with-down-toggled
                 (make-world
                  (list (make-ball 390 6 -3 -9))
                  (make-racket 330 637 0 22 #f)
                  #f
                  #f
                  1/24
                  44
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 390 6 -3 -9))
                 (make-racket 330 637 0 22 #f)
                 #t
                 #f
                 1/24
                 71
                 (make-mousev 0 0 "button-up"))))

;; down-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with down wall
;; STRATEGY: use constructor template for World on w

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
;; STRATEGY: use constructor template for World on w

(define (down-racket w)
  (make-racket
   (racket-x (world-racket w))
   (racket-y (world-racket w))
   (racket-vx (world-racket w))
   (+ (racket-vy (world-racket w)) 1)
   false))

;; down-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with down wall
;; STRATEGY: use constructor template for World on w

(define (down-racket-collide w)
  (< CANVAS-HEIGHT
     (- (+ (racket-y (world-racket w))
           (+ (racket-vy (world-racket w)) 1)) HALF-RKT-HEIGHT)))

;; world-with-left-toggled : World -> World 
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with left toggled
;; STRATEGY: use constructor template for World on w

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

;; TEST

(begin-for-test
  (check-equal? (world-with-left-toggled
                 (make-world
                  (list (make-ball 295 291 -3 9))
                  (make-racket 47/2 384 0 0 #f)
                  #f
                  #f
                  1/24
                  14
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 295 291 -3 9))
                 (make-racket 47/2 384 -1 0 #f)
                 #f
                 #f
                 1/24
                 14
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-with-left-toggled
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 false)
                  true
                  false
                  1/24
                  16
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 330 384 0 0))
                 (make-racket 330 384 0 0 false)
                 true
                 false
                 1/24
                 16
                 (make-mousev 0 0 "button-up"))))

;; left-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with left wall
;; STRATEGY: use constructor template for World on w

(define (left-racket w)
  (make-racket
   (left-racket-collide  w)
   (racket-y (world-racket w))
   (- (racket-vx (world-racket w)) 1)
   (racket-vy (world-racket w))
   false))

;; left-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with left wall
;; STRATEGY: use constructor template for World on w

(define (left-racket-collide w)
  (if
   (<= HALF-RKT-WIDTH                                     
       (- (+ (racket-x (world-racket w))              
             (- (racket-vx (world-racket w)) 1))           
          HALF-RKT-WIDTH))
   (- (racket-x (world-racket w)) 1) 
   HALF-RKT-WIDTH))

;; TEST

(begin-for-test
  (check-equal? (left-racket-collide
                 (make-world
                  (list (make-ball 384 24 -3 9))
                  (make-racket 47/2 384 -41 0 #f)
                  #f
                  #f
                  1/24
                  17
                  (make-mousev 0 0 "button-up")))
                47/2))

;; world-with-right-toggled : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with right toggled
;; STRATEGY: use constructor template for World on w
;; EXAMPLE : (world-with-right-toggled
;;                 (make-world
;;                  (list (make-ball 411 141 3 -9))
;;                  (make-racket 349 384 2 0 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  52
;;                  (make-mousev 0 0 "button-up")))
;;                (make-world
;;                 (list (make-ball 411 141 3 -9))
;;                 (make-racket 349 384 3 0 #f)
;;                 #f
;;                 #f
;;                1/24
;;                 52
;;                 (make-mousev 0 0 "button-up"))

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

;; TEST

(begin-for-test
  (check-equal? (world-with-right-toggled
                 (make-world
                  (list (make-ball 411 141 3 -9))
                  (make-racket 349 384 2 0 #f)
                  #f
                  #f
                  1/24
                  52
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 411 141 3 -9))
                 (make-racket 349 384 3 0 #f)
                 #f
                 #f
                 1/24
                 52
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-with-right-toggled
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 false)
                  true
                  false
                  1/24
                  4
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 330 384 0 0))
                 (make-racket 330 384 0 0 false)
                 true
                 false
                 1/24
                 4
                 (make-mousev 0 0 "button-up"))))


;; right-racket : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with right wall
;; STRATEGY: use constructor template for World on w
;; EXAMPLE : (right-racket
;;  (world
;;   (list (ball 411 141 3 -9))
;;   (racket 349 384 2 0 #f)
;;   #f
;;   #f
;;   1/24
;;   52
;;   (mousev 0 0 "button-up")))
;;   =>(racket 349 384 3 0 #f)

(define (right-racket w)
  (make-racket
   (right-racket-collide w)
   (racket-y (world-racket w))
   (+ (racket-vx (world-racket w)) 1)
   (racket-vy (world-racket w))
   false))

;; right-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with right wall
;; STRATEGY: use constructor template for World on w
;; EXAMPLE : (right-racket-collide
;;                 (make-world
;;                 (list (make-ball 351 123 -3 9))
;;                  (make-racket 803/2 384 18 0 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  43
;;                  (make-mousev 0 0 "button-up")))
;;    =>            803/2)
    
(define (right-racket-collide w)
  (if
   (> (- CANVAS-WIDTH HALF-RKT-WIDTH)                                    
      (+ (racket-x (world-racket w))             
         (+ (racket-vx (world-racket w)) 1)         
         HALF-RKT-WIDTH))
   (racket-x (world-racket w))
   (- CANVAS-WIDTH HALF-RKT-WIDTH)))

;; TEST

(begin-for-test
  (check-equal? (right-racket-collide
                 (make-world
                  (list (make-ball 351 123 -3 9))
                  (make-racket 803/2 384 18 0 #f)
                  #f
                  #f
                  1/24
                  43
                  (make-mousev 0 0 "button-up")))
                803/2))

;; world-with-b-toggled : World -> World
;; GIVEN :  a World
;; RETURNS: a World just like the given one, but with b toggled
;; STRATEGY: use constructor template for World on w
;; EXAMPLE: (world-with-b-toggled paused-world-at-init)
;;                paused-world-at-init)

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

;; TEST

(begin-for-test
  (check-equal? (world-with-b-toggled paused-world-at-init)
                paused-world-at-init)
  (check-equal? (world-with-b-toggled
                 (make-world
                  (list (make-ball 330 384 0 0))
                  (make-racket 330 384 0 0 false)
                  true
                  false
                  1/24
                  0
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 330 384 0 0))
                 (make-racket 330 384 0 0 false)
                 true
                 false
                 1/24
                 0
                 (make-mousev 0 0 "button-up")))
  (check-equal? (world-with-b-toggled
                 (make-world
                  (list (make-ball 381 231 3 -9))
                  (make-racket 330 384 0 0 false)
                  false
                  false
                  1/24
                  23
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 330 384 3 -9) (make-ball 381 231 3 -9))
                 (make-racket 330 384 0 0 false)
                 false
                 false
                 1/24
                 23
                 (make-mousev 0 0 "button-up"))))

;; add-new-ball : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the given one, but with an added ball
;; STRATEGY: use constructor template for World on w

(define (add-new-ball w)
  (cons (make-ball
         INIT-X-COORD
         INIT-Y-COORD
         BALL-SPEED-X
         BALL-SPEED-Y)
        (world-balls w)))

;; TEST

(begin-for-test
  (check-equal? (add-new-ball unpaused-world-at-init) ballist2))

;; world-racket : World -> Racket
;; GIVEN : a world
;; RETURNS : the racket that's present in the world
;; STRATEGY : Combine simpler functions
;; EXAMPLES :
;; (world-racket (make-world (make-ball 5 15 4 2)
;;                (make-racket 6 17 5 9) false false) 1/24 MOUSEV) =
;;                  (make-racket 6 17 5 9 false)

(define (world-racket w)
  (world-wracket w))

;; TESTS

(begin-for-test
  (check-equal? (world-racket (make-world (first ballist1)
                                          (make-racket 6 17 5 9 false)
                                          true false 1/24 72 MOUSEV))
                (make-racket 6 17 5 9 false)))
    
;; world-after-mouse-event : World Int Int MouseEvent -> World
;; GIVEN: a world, the x and y coordinates of a mouse event,
;;     and the mouse event
;; RETURNS: the world that should follow the given world after
;;     the given mouse event
;; STRATEGY: Cases on mouse event
;; EXAMPLE : (world-after-mouse-event
;;                 (make-world
;;                  (list (make-ball 396 24 -3 -9))
;;                  (make-racket 330 384 0 0 false)
;;                  false
;;                  false
;;                  1/24
;;                  68
;;                 (make-mousev 0 0 "button-up"))
;;                 321
;;                 381
;;                 "button-down")
;;  =>              (make-world
;;                 (list (make-ball 396 24 -3 -9))
;;                 (make-racket 330 384 0 0 true)
;;                 false
;;                 true
;;                 1/24
;;                 68
;;                 (make-mousev 321 381 "button-down")

(define (world-after-mouse-event w mx my mev)
  (cond
    [(mouse=? mev "button-down") (world-after-button-down w mx my)]
    [(mouse=? mev "drag") (world-after-drag w mx my)]
    [(mouse=? mev "button-up") (world-after-button-up w mx my)]
    [else w]))

;; TEST

(begin-for-test
  (check-equal? (world-after-mouse-event
                 (make-world
                  (list (make-ball 396 24 -3 -9))
                  (make-racket 330 384 0 0 false)
                  false
                  false
                  1/24
                  68
                  (make-mousev 0 0 "button-up"))
                 321
                 381
                 "button-down")
                (make-world
                 (list (make-ball 396 24 -3 -9))
                 (make-racket 330 384 0 0 true)
                 false
                 true
                 1/24
                 68
                 (make-mousev 321 381 "button-down")))
  (check-equal?
   (world-after-mouse-event
    (make-world
     (list (make-ball 216 204 -3 -9))
     (make-racket 273 364 0 0 #f)
     false
     true
     1/24
     17
     (make-mousev 273 364 "button-up"))
    -5
    -5
    "leave")
   (make-world
    (list (make-ball 216 204 -3 -9))
    (make-racket 273 364 0 0 false)
    false
    true
    1/24
    17
    (make-mousev 273 364 "button-up")))
  (check-equal? (world-after-mouse-event
                 (make-world
                  (list (make-ball 288 312 -3 9))
                  (make-racket 330 384 0 0 true)
                  false
                  true
                  1/24
                  17
                  (make-mousev 334 379 "button-down"))
                 332
                 379
                 "drag")
                (make-world
                 (list (make-ball 288 312 -3 9))
                 (make-racket 332 379 0 0 true)
                 false
                 true
                 1/24
                 17
                 (make-mousev 332 379 "drag")))
  (check-equal? (world-after-mouse-event
                 (make-world
                  (list (make-ball 255 321 -3 -9))
                  (make-racket 273 364 0 0 true)
                  false
                  true
                  1/24
                  17
                  (make-mousev 273 364 "drag"))
                 273
                 364
                 "button-up")
                (make-world
                 (list (make-ball 255 321 -3 -9))
                 (make-racket 273 364 0 0 false)
                 false
                 true
                 1/24
                 17
                 (make-mousev 273 364 "button-up"))))

;; HELPER FUNCTIONS

;; world-after-button-down : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; STRATEGY : Combine simpler functions 

(define (world-after-button-down w mx my)
  (cond
    [(in-range? (world-racket w) mx my) (button-down-world w mx my)]
    [else w]))

;; TEST

(begin-for-test
  (check-equal?
   (world-after-button-down
    (make-world
     (list (make-ball 408 150 3 -9))
     (make-racket 330 384 0 0 false)
     false
     false
     1/24
     37
     (make-mousev 0 0 "button-up"))
    332
    382)
   (make-world
    (list (make-ball 408 150 3 -9))
    (make-racket 330 384 0 0 true)
    false
    true
    1/24
    37
    (make-mousev 332 382 "button-down")))
  (check-equal?
   (world-after-button-down
    (make-world
     (list (make-ball 415 69 -3 -9))
     (make-racket 330 384 0 0 #f)
     #f
     #f
     1/24
     33
     (make-mousev 0 0 "button-up"))
    241
    510)
   (make-world
    (list (make-ball 415 69 -3 -9))
    (make-racket 330 384 0 0 #f)
    #f
    #f
    1/24
    33
    (make-mousev 0 0 "button-up"))))

;; world-after-button-down : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; STRATEGY : Combine simpler functions  

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
;; STRATEGY : Cases on mouse event

(define (racket-after-mouse-event r mx my mev)
  (cond
    [(string=? mev "button-down")
     (make-racket
      (racket-x r)
      (racket-y r)
      (racket-vx r)
      (racket-vy r)
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
      (racket-x r)
      (racket-y r)
      (racket-vx r)
      (racket-vy r)
      false)]
    [else r]))

;; HELPER FUNCTION

;; in-range? : Racket Int Int -> Boolean
;; GIVEN : a Racket, the x and y coordinates of a mouse event
;; RETURNS : true iff the button down is within 25px radius of center of the
;;           racket
;; STRATEGY : Cases on racket

(define (in-range? r mx my)
  (and  (>= CLICK-RANGE (abs (- (racket-x r) mx))) 
        (>= CLICK-RANGE (abs (- (racket-y r) my)))))

;; world-after-drag : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; STRATEGY : Combine simpler functions

(define (world-after-drag w mx my)
  (cond
    [(racket-selected? (world-racket w)) (drag-world w mx my)]
    [else w]))

;; TEST

(begin-for-test
  (check-equal?
   (world-after-drag
    (make-world
     (list (make-ball 423 105 3 -9))
     (make-racket 327 303 0 0 #f)
     #f
     #f
     1/24
     59
     (make-mousev 327 303 "drag"))
    327
    302)
   (make-world
    (list (make-ball 423 105 3 -9))
    (make-racket 327 303 0 0 #f)
    #f
    #f
    1/24
    59
    (make-mousev 327 303 "drag"))))

;; world-after-drag : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; STRATEGY : Combine simpler functions

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
;; STRATEGY : Combine simpler functions

(define (world-after-button-up w mx my)
  (cond
    [(racket-selected? (world-racket w)) (button-up-world w mx my)]
    [else w]))

;; TEST

(begin-for-test
  (check-equal?
   (world-after-button-up
    (make-world
     (list (make-ball 411 69 -3 -9))
     (make-racket 340 246 0 0 false)
     false
     false
     1/24
     35
     (make-mousev 0 0 "button-up"))
    340
    246)
   (make-world
    (list (make-ball 411 69 -3 -9))
    (make-racket 340 246 0 0 false)
    false
    false
    1/24
    35
    (make-mousev 0 0 "button-up"))))

;; button-up-world : World Int Int -> World
;; GIVEN : a world, the x and y coordinates of a mouse event
;; RETURNS : the world as it should be after the given mouse event
;; STRATEGY : Combine simpler functions

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
;; STRATEGY : Combine simpler functions

(define (racket-selected? r)
  (racket-select? r))

;; world-balls : World -> BallList
;; GIVEN: a world
;; RETURNS: a list of the balls that are present in the world
;;     (but does not include any balls that have disappeared
;;     by colliding with the back wall)
;; STRATEGY : Combine simpler functions

(define (world-balls w)
  (world-ballist w))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; right-racket-collide : World -> World
;; GIVEN :  a world
;; RETURNS: a world just like the world with the racket collided with right
;; wall
;; EXAMPLE : (make-racket-after-tick
;;                 (make-world
;;                  (list (make-ball 343 147 -3 9))
;;                  (make-racket 330 13 0 -11 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  52
;;                  (make-mousev 0 0 "button-up")))
;;       =>         (make-world
;;                 (list (make-ball 340 156 -3 9))
;;                 (make-racket 330 13 0 -11 #f)
;;                 #t
;;                 #f
;;                 1/24
;;                 71
;;                 (make-mousev 0 0 "button-up")
;; STRATEGY: Cases on speed of Racket from w
    
(define (make-racket-after-tick w)
  (cond
    [(check-speed-right w) (check-speed1-right w)]
    [(check-speed-left w) (check-speed1-left w)]
    [(check-speed-up w) (check-speed1-up w)]
    [(check-speed-down w) (check-speed1-down w)]
    [else
     (next-racket-world w)]))

;; TEST

(begin-for-test
  (check-equal? (make-racket-after-tick
                 (make-world
                  (list (make-ball 343 147 -3 9))
                  (make-racket 330 13 0 -11 #f)
                  #f
                  #f
                  1/24
                  52
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 340 156 -3 9))
                 (make-racket 330 13 0 -11 #f)
                 #t
                 #f
                 1/24
                 71
                 (make-mousev 0 0 "button-up")))
  (check-equal? (make-racket-after-tick
                 (make-world
                  (list (make-ball 378 240 3 -9))
                  (make-racket 330 384 1 0 #f)
                  #f
                  #f
                  1/24
                  32
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 381 231 3 -9))
                 (make-racket 331 384 1 0 #f)
                 #f
                 #f
                 1/24
                 32
                 (make-mousev 0 0 "button-up")))
  (check-equal? (make-racket-after-tick
                 (make-world
                  (list (make-ball 370 66 -3 9))
                  (make-racket 34 384 -10 0 #f)
                  #f
                  #f
                  1/24
                  45
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 367 75 -3 9))
                 (make-racket 47/2 384 0 0 #f)
                 #f
                 #f
                 1/24
                 45
                 (make-mousev 0 0 "button-up")))
  (check-equal? (make-racket-after-tick
                 (make-world
                  (list (make-ball 331 183 -3 9))
                  (make-racket 330 590 0 5 #f)
                  #f
                  #f
                  1/24
                  57
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 328 192 -3 9))
                 (make-racket 330 595 0 5 #f)
                 #f
                 #f
                 1/24
                 57
                 (make-mousev 0 0 "button-up"))))

;; next-racket-world : World -> World
;; GIVEN: a World
;; RETURNS : state of world in the next tick
;; EXAMPLE: (next-racket-world
;;  (world
;;   (list (ball 391 3 -3 9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   31
;;   (mousev 0 0 "button-up")))
;; (world
;;  (list (ball 388 12 -3 9))
;;  (racket 330 384 0 0 #f)
;;  #f
;;  #f
;;  1/24
;;  31
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of World on w

(define (next-racket-world w)
  (make-world
   (next-ball-cond (world-balls w))
   (next-world-racket-value w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; next-world-racket-value : World -> Boolean
;; GIVEN: a World
;; RETURNS : state of racket in the next tick
;; EXAMPLE: (next-world-racket-value
;;  (world
;;   (list (ball 391 3 -3 9))
;;   (racket 330 384 0 0 #f)
;;   #f
;;   #f
;;   1/24
;;   31
;;   (mousev 0 0 "button-up")))
;; => (racket 330 384 0 0 #f)
;; STRATEGY : Cases on speed of racket

(define (next-world-racket-value w)
  (make-racket
   (+ (racket-x (world-racket w)) (racket-vx (world-racket w)))
   (+ (racket-y (world-racket w)) (racket-vy (world-racket w)))
   (racket-vx (world-racket w))
   (racket-vy (world-racket w))
   (racket-select? (world-racket w))))

;; check-speed-right : World -> Boolean
;; GIVEN: a World
;; RETURNS : true iff speed of racket is positive
;; EXAMPLE: (check-speed1-right
;;                 (make-world
;;                  (list (make-ball 414 132 3 -9))
;;                  (make-racket 803/2 384 1 0 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  33
;;                  (make-mousev 0 0 "button-up")))
;;                => true
;; STRATEGY : Cases on speed of racket
  
(define (check-speed-right w)
  (if (> (racket-vx (world-racket w)) 0) true false))

;; check-speed1-right : World -> World
;; GIVEN: a World
;; RETURNS : state of world in the next tick
;; EXAMPLE: (check-speed1-right
;;                 (make-world
;;                  (list (make-ball 414 132 3 -9))
;;                  (make-racket 803/2 384 1 0 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  33
;;                  (make-mousev 0 0 "button-up")))
;;                (make-world
;;                 (list (make-ball 417 123 3 -9))
;;                 (make-racket 803/2 384 0 0 #f)
;;                 #f
;;                 #f
;;                 1/24
;;                 33
;;                (make-mousev 0 0 "button-up"))
;; STRATEGY : Cases on speed of racket

(define (check-speed1-right w)
  (if(< (- CANVAS-WIDTH HALF-RKT-WIDTH)                                    
        (+ (racket-x (world-racket w))             
           (racket-vx (world-racket w))         
           ))
     (racket-right-collide-cond w)
     (racket-moving-right w)))

;; TEST

(begin-for-test
  (check-equal? (check-speed1-right
                 (make-world
                  (list (make-ball 414 132 3 -9))
                  (make-racket 803/2 384 1 0 #f)
                  #f
                  #f
                  1/24
                  33
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 417 123 3 -9))
                 (make-racket 803/2 384 0 0 #f)
                 #f
                 #f
                 1/24
                 33
                 (make-mousev 0 0 "button-up"))))

;; racket-right-collide-cond : World -> World
;; GIVEN: a World
;; RETURNS : state of world in the next tick
;; EXAMPLE: (racket-right-collide-cond
;;  (world
;;   (list (ball 414 132 3 -9))
;;   (racket 803/2 384 1 0 #f)
;;   #f
;;   #f
;;   1/24
;;   33
;;   (mousev 0 0 "button-up")))
;; (world
;;  (list (ball 417 123 3 -9))
;;  (racket 803/2 384 0 0 #f)
;;  #f
;;  #f
;;  1/24
;;  33
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of World on w and Racket on racket

(define (racket-right-collide-cond w)
  (make-world
   (next-ball-cond (world-balls w))
   (make-racket
    (- CANVAS-WIDTH HALF-RKT-WIDTH)
    (racket-y (world-racket w))
    0
    (racket-vy (world-racket w))
    (racket-select? (world-racket w)))
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; racket-moving-right : World -> Racket
;; GIVEN: a World
;; RETURNS : state of world in the next tick
;; EXAMPLE: (racket-moving-right
;;  (world
;;   (list (ball 378 240 3 -9))
;;   (racket 330 384 1 0 #f)
;;   #f
;;   #f
;;   1/24
;;   32
;;   (mousev 0 0 "button-up")))
;; (world
;;  (list (ball 381 231 3 -9))
;;  (racket 331 384 1 0 #f)
;;  #f
;;  #f
;;  1/24
;;  32
 ;; (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of Racket on racket from w

(define (racket-moving-right w)
  (make-world
   (next-ball-cond (world-balls w))
   (racket-moving-right-value w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; racket-moving-right-value : World -> Racket
;; GIVEN: a World
;; RETURNS : state of world in the next tick
;; EXAMPLE: (racket-moving-right-value
;;  (world
;;   (list (ball 378 240 3 -9))
;;   (racket 330 384 1 0 #f)
;;   #f
;;   #f
;;   1/24
;;   32
;;   (mousev 0 0 "button-up")))
;; (racket 331 384 1 0 #f)
;; STRATEGY : Use constructor template of Racket on racket from w

(define (racket-moving-right-value w)
  (make-racket
   (+ (racket-x (world-racket w)) (racket-vx (world-racket w)))
   (+ (racket-y (world-racket w)) (racket-vy (world-racket w)))
   (racket-vx (world-racket w))
   (racket-vy (world-racket w))
   (racket-select? (world-racket w))))

;; check-speed-left : World -> World
;; GIVEN: a World
;; RETURNS : state of world in the next tick
;; EXAMPLE: (check-speed-left
;;                 (make-world
;;                  (list (make-ball 271 363 -3 9))
;;                  (make-racket 257 384 -1 0 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  53
;;                  (make-mousev 0 0 "button-up"))
;;             =>  true
;; STRATEGY : Cases on speed of Racket

(define (check-speed-left w)
  (if (< (racket-vx (world-racket w)) 0) true false))

;; check-speed1-left : World -> World
;; GIVEN: a World
;; RETURNS : state of world in the next tick
;; EXAMPLE: (check-speed1-left
;;                 (make-world
;;                  (list (make-ball 271 363 -3 9))
;;                  (make-racket 257 384 -1 0 #f)
;;                  #f
;;                  #f
;;                  1/24
;;                  53
;;                  (make-mousev 0 0 "button-up"))
;;             =>  (make-world
;;                 (list (make-ball 268 372 -3 9))
;;                 (make-racket 256 384 -1 0 #f)
;;                 #f
;;                 #f
;;                 1/24
;;                 53
;;                 (make-mousev 0 0 "button-up")
;; STRATEGY : Cases on speed of Racket

(define (check-speed1-left w)
  (if  (> HALF-RKT-WIDTH                                     
          (+ (racket-x (world-racket w))              
             (- (racket-vx (world-racket w)) 1)))           
       (racket-left-collide-cond w)
       (racket-moving-left w)))

;; TEST

(begin-for-test
  (check-equal? (check-speed1-left
                 (make-world
                  (list (make-ball 271 363 -3 9))
                  (make-racket 257 384 -1 0 #f)
                  #f
                  #f
                  1/24
                  53
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 268 372 -3 9))
                 (make-racket 256 384 -1 0 #f)
                 #f
                 #f
                 1/24
                 53
                 (make-mousev 0 0 "button-up"))))

;; racket-left-collide-cond : World -> World
;; GIVEN: a World
;; RETURNS :state of world in the next tick
;; EXAMPLE: (racket-left-collide-cond
;;  (world
;;   (list (ball 370 66 -3 9))
;;   (racket 34 384 -10 0 #f)
;;   #f
;;   #f
;;   1/24
;;   45
;;   (mousev 0 0 "button-up")))
;; (world
;;  (list (ball 367 75 -3 9))
;;  (racket 47/2 384 0 0 #f)
;;  #f
;;  #f
;;  1/24
;;  45
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of World on w and of Racket on racket

(define (racket-left-collide-cond w)
  (make-world
   (next-ball-cond (world-balls w))
   (make-racket
    HALF-RKT-WIDTH
    (racket-y (world-racket w))
    0
    (racket-vy (world-racket w))
    false)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; racket-moving-left : World -> World
;; GIVEN: a World
;; RETURNS :state of world in the next tick
;; EXAMPLE: (racket-moving-left
;;  (world
;;   (list (ball 271 363 -3 9))
;;   (racket 257 384 -1 0 #f)
;;   #f
;;   #f
;;   1/24
;;   53
;;   (mousev 0 0 "button-up")))
;; (world
;;  (list (ball 268 372 -3 9))
;;  (racket 256 384 -1 0 #f)
;;  #f
;;  #f
;;  1/24
;;  53
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of World on w

(define (racket-moving-left w)
  (make-world
   (next-ball-cond (world-balls w))
   (racket-moving-left-value w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; racket-moving-left-value : World -> Racket
;; GIVEN: a World
;; RETURNS :state of racket in the bext world
;; EXAMPLE: (racket-moving-left-value
;;  (world
;;   (list (ball 271 363 -3 9))
;;   (racket 257 384 -1 0 #f)
;;   #f
;;   #f
;;   1/24
;;   53
;;   (mousev 0 0 "button-up")))
;;    => (racket 256 384 -1 0 #f)
;; STRATEGY : Use constructor template of Racket on racket from w

(define (racket-moving-left-value w)
  (make-racket
   (+ (racket-x (world-racket w)) (racket-vx (world-racket w)))
   (+ (racket-y (world-racket w)) (racket-vy (world-racket w)))
   (racket-vx (world-racket w))
   (racket-vy (world-racket w))
   (racket-select? (world-racket w))))

;; check-speed-up : World -> Boolean
;; GIVEN: a World
;; RETURNS : true iff the racket velocity is negative
;; EXAMPLE: >(check-speed-up
;;  (world
;;   (list (ball 331 183 -3 9))
;;   (racket 330 590 0 5 #f)
;;   #f
;;   #f
;;   1/24
;;   57
;;   (mousev 0 0 "button-up")))
;;     => #f
;; STRATEGY : Case on speed of Racket

(define (check-speed-up w)
  (if (< (racket-vy (world-racket w)) 0) true false))

;; check-speed1-up : World -> Boolean
;; GIVEN: a World
;; RETURNS : true iff the racket is going up
;; EXAMPLE: (check-speed1-up
;;  (world
;;   (list (ball 328 192 -3 9))
;;   (racket 330 206 0 -4 #f)
;;   #f
;;   #f
;;   1/24
;;   30
;;   (mousev 0 0 "button-up")))
;; (world
;;  (list (ball 325 201 -3 9))
;;  (racket 330 202 0 -4 #f)
;;  #f
;;  #f
;;  1/24
;;  30
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Case on speed of Racket

(define (check-speed1-up w)
  (if   (> HALF-RKT-HEIGHT (+ (racket-y (world-racket w))
                              (- (racket-vy (world-racket w)) 1)))
        (up-racket-collide-cond w)
        (racket-moving-up w)))

;; TEST

(begin-for-test
  (check-equal? (check-speed1-up
                 (make-world
                  (list (make-ball 328 192 -3 9))
                  (make-racket 330 206 0 -4 #f)
                  #f
                  #f
                  1/24
                  30
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 325 201 -3 9))
                 (make-racket 330 202 0 -4 #f)
                 #f
                 #f
                 1/24
                 30
                 (make-mousev 0 0 "button-up"))))

;; up-racket-collide-cond : World -> World
;; GIVEN: a World
;; RETURNS : the state of world in next tick
;; EXAMPLE: (up-racket-collide-cond
;;  (world
;;   (list (ball 343 147 -3 9))
;;   (racket 330 13 0 -11 #f)
;;   #f
;;   #f
;;   1/24
;;   52
;;   (mousev 0 0 "button-up")))
;; (world
;;  (list (ball 340 156 -3 9))
;;  (racket 330 13 0 -11 #f)
;;  #t
;;  #f
;;  1/24
;;  71
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of World on w

(define (up-racket-collide-cond w)
  (make-world
   (next-ball-cond (world-balls w))
   (world-racket w)
   (not (world-paused? w))
   (world-selected? w)
   (world-wticks w)
   (- (* (/ 1 (world-wticks w)) 3) 1)
   (world-mousev w)))

;; racket-moving-up : World -> World
;; GIVEN: a World
;; RETURNS : the state of world in next tick
;; EXAMPLE: (racket-moving-up
;;  (world
;;   (list (ball 328 192 -3 9))
;;   (racket 330 206 0 -4 #f)
;;   #f
;;   #f
;;   1/24
;;   30
;;   (mousev 0 0 "button-up")))
;;  (world
;;  (list (ball 325 201 -3 9))
;;  (racket 330 202 0 -4 #f)
;;  #f
;;  #f
;;  1/24
;;  30
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of Racket on racket from w

(define (racket-moving-up w)
  (make-world
   (next-ball-cond (world-balls w))
   (racket-moving-up-value w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; racket-moving-up-value : World -> Racket
;; GIVEN: a World
;; RETURNS : the state of racket in next tick
;; EXAMPLE: (racket-moving-up-value
;;  (world
;;   (list (ball 328 192 -3 9))
;;   (racket 330 206 0 -4 #f)
;;   #f
;;   #f
;;   1/24
;;   30
;;   (mousev 0 0 "button-up")))
;;  (racket 330 202 0 -4 #f)
;; STRATEGY : Use constructor template of Racket on racket from w

(define (racket-moving-up-value w)
  (make-racket
   (+ (racket-x (world-racket w)) (racket-vx (world-racket w)))
   (+ (racket-y (world-racket w)) (racket-vy (world-racket w)))
   (racket-vx (world-racket w))
   (racket-vy (world-racket w))
   (racket-select? (world-racket w))))

;; check-speed-down : World -> Boolean
;; GIVEN: a World
;; RETURNS : true iff the racket is going down
;; EXAMPLE (check-speed-down
;;  (world
;;   (list (ball 331 183 -3 9))
;;   (racket 330 590 0 5 #f)
;;   #f
;;   #f
;;   1/24
;;   57
;;   (mousev 0 0 "button-up")))
;;      => true
;; STRATEGY : Case on velocity of the racket

(define (check-speed-down w)
  (if (> (racket-vy (world-racket w)) 0) true false))

;; check-speed1-down : World -> World
;; GIVEN: a World
;; RETURNS : the new state of the world after a tick
;; EXAMPLE (check-speed1-down
;;  (world
;;   (list (ball 214 534 -3 9))
;;   (racket 330 646 0 4 #f)
;;   #f
;;   #f
;;   1/24
;;   43
;;   (mousev 0 0 "button-up")))
;;(world
;;  (list (ball 211 543 -3 9))
;;  (racket 330 646 0 4 #f)
;;  #t
;;  #f
;;  1/24
;;  71
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Combine simpler functions

(define (check-speed1-down w)
  (if   (< CANVAS-HEIGHT
           (+ (racket-y (world-racket w))
              (+ (racket-vy (world-racket w)) 1)))
        (down-racket-collide-cond w)
        (racket-moving-down w)))

;; TEST

(begin-for-test
  (check-equal? (check-speed1-down
                 (make-world
                  (list (make-ball 214 534 -3 9))
                  (make-racket 330 646 0 4 #f)
                  #f
                  #f
                  1/24
                  43
                  (make-mousev 0 0 "button-up")))
                (make-world
                 (list (make-ball 211 543 -3 9))
                 (make-racket 330 646 0 4 #f)
                 #t
                 #f
                 1/24
                 71
                 (make-mousev 0 0 "button-up"))))

;; down-racket-collide-cond : World -> World
;; GIVEN: a World
;; RETURNS : the new state of the world after a tick
;; EXAMPLE (down-racket-collide-cond
;;  (world
;;   (list (ball 214 534 -3 9))
;;   (racket 330 646 0 4 #f)
;;   #f
;;   #f
;;   1/24
;;   43
;;   (mousev 0 0 "button-up")))
;; (world
;;  (list (ball 211 543 -3 9))
;;  (racket 330 646 0 4 #f)
;;  #t
;;  #f
;;  1/24
;;  71
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of World on w

(define (down-racket-collide-cond w)
  (make-world
   (next-ball-cond (world-balls w))
   (world-racket w)
   (not (world-paused? w))
   (world-selected? w)
   (world-wticks w)
   (- (* (/ 1 (world-wticks w)) 3) 1)
   (world-mousev w)))

;; racket-moving-down : World -> World
;; GIVEN: a World
;; RETURNS : the new state of the racket after a tick
;; EXAMPLE (racket-moving-down
;;  (world
;;   (list (ball 331 183 -3 9))
;;   (racket 330 590 0 5 #f)
;;   #f
;;   #f
;;   1/24
;;   57
;;   (mousev 0 0 "button-up")))
;;(world
;;  (list (ball 328 192 -3 9))
;;  (racket 330 595 0 5 #f)
;;  #f
;;  #f
;;  1/24
;;  57
;;  (mousev 0 0 "button-up"))
;; STRATEGY : Use constructor template of Racket on racket from world

(define (racket-moving-down w)
  (make-world
   (next-ball-cond (world-balls w))
   (racket-moving-down-value w)
   (world-paused? w)
   (world-selected? w)
   (world-wticks w)
   (world-cycle w)
   (world-mousev w)))

;; racket-moving-down-value : World -> World
;; GIVEN: a World
;; RETURNS : the new state of the racket after a tick
;; EXAMPLE  (racket-moving-down-value
;;  (world
;;   (list (ball 331 183 -3 9))
;;   (racket 330 590 0 5 #f)
;;   #f
;;  #f
;;   1/24
;;   57
;;   (mousev 0 0 "button-up")))
;; => (racket 330 595 0 5 #f)
;; STRATEGY : Use constructor template of Racket on racket from world

(define (racket-moving-down-value w)
  (make-racket
   (+ (racket-x (world-racket w)) (racket-vx (world-racket w)))
   (+ (racket-y (world-racket w)) (racket-vy (world-racket w)))
   (racket-vx (world-racket w))
   (racket-vy (world-racket w))
   (racket-select? (world-racket w))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


