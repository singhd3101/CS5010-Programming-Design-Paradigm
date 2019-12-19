;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; OutRanking

(require rackunit)
(require "extras.rkt")
(check-location "08" "q1.rkt")

(provide
 tie
 defeated
 defeated?
 outranks
 outranked-by)

;; DATA DEFINITIONS

;; A Competitor is represented as a String (any string will do).

;; An Outcome is one of
;;     -- a Tie
;;     -- a Defeat
;;
;; OBSERVER TEMPLATE:
;; outcome-fn : Outcome -> ??

;; (define (outcome-fn o)
;;            (cond ((tie? o) ...)
;;                  ((defeat? o) ...)))

;; A Contest is represented as (make-contest outcome player-a player-b)
;; where
;; outcome: Outcome                  represents the result of the contest
;; player-a, player-b : Competitor   each represents one of he competitors in
;;                                   contest

(define-struct contest (outcome player-a player-b))

;; CONSTRUCTOR TEMPLATE
;; (make-contest Outcome Competitor Competitor)

;; OBSERVER TEMPLATE
;;(define (contest-fn c)
;;   (contest-outcome c)
;;   (contest-player-a c)
;;   (contest-player-b c)

;; A Tie is represented as (make-tie-result player-a player-b)
;; where
;; player-a, player-b : Competitor   each represents one of he competitors in
;;                                   contest

(define-struct tie-result (pa pb))

;; CONSTRUCTOR TEMPLATE
;; (make-tie-result Competitor Competitor)

;; OBSERVER TEMPLATE
;;(define (tie-result-fn c)
;;   (tie-result-pa c)
;;   (tie-result-pb c)

;; A Defeat is represented as (make-defeat-result player-a player-b)
;; where
;; outcome: Outcome                  represents the Tie outcome
;; player-a, player-b : Competitor   each represents one of he competitors in
;;                                   contest

(define-struct defeat-result (pa pb))

;; CONSTRUCTOR TEMPLATE
;; (make-defeat-result Competitor Competitor)

;; OBSERVER TEMPLATE
;;(define (defeat-result-fn c)
;;   (defeat-result-pa c)
;;   (defeat-result-pb c)

;; A PlayerProfile is represented as
;;(make-player-pf name no-outranks no-outranked perc)
;; where
;; name: Competitor        represents the name of the Competitor
;; no-outranks: NonNegInt  represents the number of Competitors the
;;                         Competitor outranks
;; no-outranked: NonNegInt represents the number of Competitors who outrank
;;                         the Competitor
;; perc: Real              represent the non losing percentage of the
;;                         Competitor
;; WHERE 0 <= non-losing-perc <= 1

(define-struct player-pf (name no-outranks no-outranked perc))

;; CONSTRUCTOR TEMPLATE
;; (make-player-pf Competitor NonNegInt NonNegInt Real)

;; OBSERVER TEMPLATE
;;(define (player-pf-fn p)
;;   (player-pf-name p)
;;   (player-pf-no-outranks p)
;;   (player-pf-no-outranked p)
;;   (player-pf-perc p)

;; A PlayerScore is represented as
;;(make-player-sc name lost total)
;; where
;; name: Competitor  represents the name of the Competitor
;; lost: NonNegInt   represents the number of Outcomes in which the
;;                   Competitor was defeated
;; total: NonNegInt  represents the total number of Outcomes in which the
;;                   Competitor was present

(define-struct player-sc (name lost total))

;; CONSTRUCTOR TEMPLATE
;; (make-player-sc Competitor NonNegInt NonNegInt)

;; OBSERVER TEMPLATE
;;(define (player-sc-fn p)
;;   (player-sc-name p)
;;   (player-sc-lost p)
;;   (player-sc-total p)

;; A OutrankList is represented as a list of Competitors outranked by an
;; an arbitrary Competitor.

;; IMPLEMENTATION
(define OUTRANKS '())

;; CONSTRUCTOR TEMPLATES:
;; empty
;; (cons competitor outranklist)
;; -- WHERE
;;    competitor is a Competitor
;;    outranklist is an OutrankList

;; OBSERVER TEMPLATE
;; (define (outranklist-fn outranklist)
;;   (cond
;;     [(empty? outranklist) ...]
;;     [else (...
;;             (competitor-fn (first outranklist))
;; 	    (outranklist-fn (rest outranklist)))]))

;; A OutrankedList is represented as a list of Competitors who all
;; outrank an arbitrary Competitor

;; IMPLEMENTATION
(define OUTRANKED '())

;; CONSTRUCTOR TEMPLATES:
;; empty
;; (cons competitor outrankedlist)
;; -- WHERE
;;    competitor is a Competitor
;;    outrankedlist is an OutrankedList

;; OBSERVER TEMPLATE
;; (define (outrankedlist-fn outrankedlist)
;;   (cond
;;     [(empty? outrankedlist) ...]
;;     [else (...
;;             (Competitor-fn (first outrankedlist))
;; 	    (outrankedlist-fn (rest outrankedlist)))]))

;; A ProfileList is represented as a list of Player Profiles .

;; IMPLEMENTATION
(define PFLIST '())

;; CONSTRUCTOR TEMPLATES:
;; empty
;; (cons profile profilelist)
;; -- WHERE
;;    profile is a Player-pf
;;    profilelist is a ProfileList

;; OBSERVER TEMPLATE
;; (define (profilelist-fn profilelist)
;;   (cond
;;     [(empty? profilelist) ...]
;;     [else (...
;;           (Player-pf-fn (first profilelist))
;; 	     (profilelist-fn (rest profilelist)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; REPRESENTATION

;; tie : Competitor Competitor -> Tie
;; GIVEN: the names of two competitors
;; RETURNS: an indication that the two competitors have
;;     engaged in a contest, and the outcome was a tie
;; EXAMPLE: (see the examples given below for defeated?,
;;     which shows the desired combined behavior of tie
;;     and defeated?)

(define (tie pa pb)
  (make-tie-result pa pb))

;; defeated : Competitor Competitor -> Defeat
;; GIVEN: the names of two competitors
;; RETURNS: an indication that the two competitors have
;;     engaged in a contest, with the first competitor
;;     defeating the second
;; EXAMPLE: (see the examples given below for defeated?,
;;     which shows the desired combined behavior of defeated
;;     and defeated?)

(define (defeated pa pb)
  (make-defeat-result pa pb))

;; defeated? : Competitor Competitor OutcomeList -> Boolean
;; GIVEN: the names of two competitors and a list of outcomes
;; RETURNS: true if and only if one or more of the outcomes indicates
;;     the first competitor has defeated or tied the second
;; STRATEGY: Combine simpler functions and use HOF Filter on clist
;; EXAMPLES:
;;     (defeated? "A" "B" (list (defeated "A" "B") (tie "B" "C")))
;;  => true
;;
;;     (defeated? "A" "C" (list (defeated "A" "B") (tie "B" "C")))
;;  => false
;;
;;     (defeated? "B" "A" (list (defeated "A" "B") (tie "B" "C")))
;;  => false
;;
;;     (defeated? "B" "C" (list (defeated "A" "B") (tie "B" "C")))
;;  => true
;;
;;     (defeated? "C" "B" (list (defeated "A" "B") (tie "B" "C")))
;;  => true

(define (defeated? pa pb clist)
  (cond
    [(empty? clist) false]
    [else
     (if (check-defeated-outcome pa pb (filter-list defeat-result? clist))
         true
         (check-tie-outcome pa pb (filter-list tie-result? clist)))]))

;; check-defeated-outcome : Competitor Competitor OutcomeList -> Boolean
;; GIVEN: the names of two competitors and a list of outcomes
;; RETURNS: true if and only if one or more of the outcomes indicates
;;     the first competitor has defeated the second
;; STRATEGY: Use HOF Andmap on lst
;; EXAMPLES: (check-defeated-outcome "A" "B" (list (defeat-result "A" "B")))
;;           => true

(define (check-defeated-outcome pa pb lst)
  (andmap
   ;; Competitor Competitor -> Boolean
   ;; GIVEN: Two Competitors
   ;; RETURNS: true iff one competitor has defeated the second
   ;; STRATEGY: Combine simpler functions
   (lambda (x) (and (string=? (defeat-result-pa x) pa)
                    (string=? (defeat-result-pb x) pb)))
   lst))

;; check-tie-outcome : Competitor Competitor OutcomeList -> Boolean
;; GIVEN: the names of two competitors and a list of outcomes
;; RETURNS: true if and only if one or more of the outcomes indicates
;;     the first competitor has tied with the second
;; STRATEGY: Use HOF Andmap on lst
;; EXAMPLES: (check-tie-outcome "A" "C" (list (tie-result "B" "C")))
;;           => false

(define (check-tie-outcome pa pb lst)
  (andmap
   ;; Competitor Competitor -> Boolean
   ;; GIVEN: Two Competitors
   ;; RETURNS: true iff one competitor has defeated the second
   ;; STRATEGY: Combine simpler functions
   (lambda (x) (or (and (string=? (tie-result-pa x) pa)
                        (string=? (tie-result-pb x) pb))
                   (and (string=? (tie-result-pa x) pb)
                        (string=? (tie-result-pb x) pa))))
     lst))

;; filter-list : Outcome OutcomeList -> OutcomeList
;; GIVEN: a type of Cutcome and a list of outcomes
;; RETURNS: an OutcomeList filtered by the type of Outcome
;; STRATEGY: Use HOF Filter on lst
;; EXAMPLES: (filter-list defeat-result?
;;   (list (defeat-result "A" "B")
;;         (defeat-result "B" "C")
;;         (tie-result "B" "E")))
;;   =>    (list (defeat-result "A" "B") (defeat-result "B" "C"))

(define (filter-list outcome lst)
  (filter
   ;; Outcome -> Boolean
   ;; GIVEN: an Outcome
   ;; RETURNS: true iff the Outcome is of the input type
   ;; STRATEGY: Combine simpler functions
   (lambda (x) (outcome x))
   lst))

(begin-for-test
  (check-equal? (defeated? "A" "B" (list (defeated "A" "B") (tie "B" "C")))
                true)
  (check-equal? (defeated? "A" "C" (list (defeated "A" "B") (tie "B" "C")))
                false)
  (check-equal? (defeated? "B" "A" (list (defeated "A" "B") (tie "B" "C")))
                false)
  (check-equal? (defeated? "B" "C" (list (defeated "A" "B") (tie "B" "C")))
                true)
  (check-equal? (defeated? "C" "B" (list (defeated "A" "B") (tie "B" "C")))
                true)
  (check-equal? (defeated? "C" "B" '())
                false))

;; outranks : Competitor OutcomeList -> CompetitorList
;; GIVEN: the name of a competitor and a list of outcomes
;; RETURNS: a list of the competitors outranked by the given
;;     competitor, in alphabetical order
;; NOTE: it is possible for a competitor to outrank itself
;; STRATEGY: Combine simpler  functions and Initialize the invarient for
;;           outranks-list
;; EXAMPLES:
;;     (outranks "A" (list (defeated "A" "B") (tie "B" "C")))
;;  => (list "B" "C")
;;
;;     (outranks "B" (list (defeated "A" "B") (defeated "B" "A")))
;;  => (list "A" "B")
;;
;;     (outranks "C" (list (defeated "A" "B") (tie "B" "C")))
;;  => (list "B" "C")

(define (outranks pa lst)
  (unique-list
   (sort (outranks-list pa lst '()) string<?)))

;; outranks-list : Competitor OutcomeList PlayerScoreList -> CompetitorList
;; GIVEN: the name of a competitor, a list of outcomes and
;;        a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; EXAMPLES: (outranks-list "A" (list (defeat-result "A" "B")
;;                                    (tie-result "B" "C")) '())
;;           => '("B" "B" "C" "B" "C")

(define (outranks-list pa lst plst)
  (if (member pa plst)
      '()
      (create-outranks-list pa lst (cons pa plst))))

;; create-outranks-list : Competitor OutcomeList PlayerScoreList
;;                        -> CompetitorList
;; GIVEN: the name of a competitor, a list of outcomes and
;;        a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; HALTING MEASURE: Length of OutcomeList
;; EXAMPLES: (create-outranks-list  "A"
;;           (list (defeat-result "A" "B") (tie-result "B" "C"))
;;           '("A"))   => '("B" "B" "C" "B" "C")

(define (create-outranks-list pa lst plst)
  (cond
    [(empty? lst) '()]
    [else
     (append-outranks pa lst plst)]))

;; append-outranks : Competitor OutcomeList PlayerScoreList
;;                        -> CompetitorList
;; GIVEN: the name of a competitor, a list of outcomes and
;;        a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; EXAMPLES: (append-outranks  "A"
;;           (list (defeat-result "A" "B") (tie-result "B" "C"))
;;           '("A")) => '("B" "B" "C" "B" "C")

(define (append-outranks pa lst plst)
  (append (outranks-by-defeat pa (filter-list defeat-result? lst) lst plst)
          (outranks-by-tie pa (filter-list tie-result? lst) lst plst)))

;; outranks-by-defeat : Competitor OutcomeList OutcomeList PlayerScoreList
;;                      -> CompetitorList
;; GIVEN: the name of a competitor, a list of defeat outcomes,
;;        a list of total outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler functions
;; HALTING MEASURE: Length of newlst
;; EXAMPLES: (outranks-by-defeat  "A"
;;  (list (defeat-result "A" "B"))
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("A")) => '("B" "B" "C" "B" "C")

(define (outranks-by-defeat pa newlst oldlst plst)
  (cond
    [(empty? newlst) '()]
    [else
     (create-defeat-list pa newlst oldlst plst)]))

;; create-defeat-list : Competitor OutcomeList OutcomeList PlayerScoreList
;;                      -> CompetitorList
;; GIVEN: the name of a competitor, a list of defeat outcomes,
;;        a list of total outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; EXAMPLES: (create-defeat-list "A"
;;  (list (defeat-result "A" "B"))
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("A")) => '("B" "B" "C" "B" "C")

(define (create-defeat-list pa newlst oldlst plst)
  (if (string=? (defeat-result-pa (first newlst)) pa)
      (append-defeat-list pa newlst oldlst plst)
      (outranks-by-defeat pa (rest newlst) oldlst plst)))

;; append-defeat-list : Competitor OutcomeList OutcomeList PlayerScoreList
;;                      -> CompetitorList
;; GIVEN: the name of a competitor, a list of defeat outcomes,
;;        a list of total outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; EXAMPLES: (append-defeat-list "A"
;;  (list (defeat-result "A" "B"))
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("A")) => '("B" "B" "C" "B" "C")

(define (append-defeat-list pa newlst oldlst plst)
  (append (outranks-by-defeat pa (rest newlst) oldlst plst)
          (def-to-outranks (defeat-result-pb (first newlst))
            oldlst plst)))

;; def-to-outranks : Competitor OutcomeList PlayerScoreList
;;                   -> CompetitorList
;; GIVEN: the name of a competitor, a list of total outcomes
;;         and a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; EXAMPLES: (def-to-outranks  "B"
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("A")) => '("B" "B" "C" "B" "C")

(define (def-to-outranks px oldlst plst)
  (append (cons px OUTRANKS)
          (outranks-list px oldlst plst)))

;; outranks-by-tie : Competitor OutcomeList OutcomeList PlayerScoreList
;;                   -> CompetitorList
;; GIVEN: the name of a competitor, a list of tie outcomes,
;;         a list of tie outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; HALTING MEASURE: Length of newlst
;; EXAMPLES: (outranks-by-tie  "A"
;;  (list (tie-result "B" "C"))
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;   '("A")) => '()

(define (outranks-by-tie pa newlst oldlst plst)
  (cond
    [(empty? newlst) '()]
    [else
     (outranks-by-tie-cond pa newlst oldlst plst)]))

;; outranks-by-tie-cond : Competitor OutcomeList OutcomeList PlayerScoreList
;;                   -> CompetitorList
;; GIVEN: the name of a competitor, a list of tie outcomes,
;;         a list of tie outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; EXAMPLES: (outranks-by-tie-cond  "A"
;;  (list (tie-result "B" "C"))
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("A")) => '()

(define (outranks-by-tie-cond pa newlst oldlst plst)
  (if (player-in-tie pa (first newlst))
      (append-tie-list pa newlst oldlst plst)
      (outranks-by-tie pa (rest newlst) oldlst plst)))

;; append-tie-list : Competitor OutcomeList OutcomeList PlayerScoreList
;;                   -> CompetitorList
;; GIVEN: the name of a competitor, a list of tie outcomes,
;;         a list of tie outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;     competitor
;; STRATEGY: Combine simpler  functions
;; EXAMPLES:  (append-tie-list   "C"
;;   (list (tie-result "B" "C"))
;;   (list (defeat-result "A" "B") (tie-result "B" "C"))
;;   '("C" "B" "A")) => '("B" "C")

(define (append-tie-list pa newlst oldlst plst)
  (append (outranks-by-tie pa (rest newlst) oldlst plst)
          (tie-to-outranks (tie-result-pa (first newlst))
                           (tie-result-pb (first newlst))
                            pa oldlst plst)))

;; player-in-tie : Competitor Outcome -> Boolean
;; GIVEN: a Competitor and a Tie Outcome
;; RETURNS: true iff the Competitor is present in the input Outcome
;; STRATEGY: Combine simpler  functions
;; EXAMPLES: (player-in-tie "B" (tie-result "D" "B"))
;;           => true

(define (player-in-tie pa px)
  (or (string=? (tie-result-pa px) pa)
      (string=? (tie-result-pb px) pa)))

;; tie-to-outranks : Competitor Competitor Competitor OutcomeList 
;;                   PlayerScoreList -> CompetitorList
;; GIVEN: a Competitor, two Tie outcome Competitors, a list of total outcomes,
;;        and a list of PlayerScores
;; RETURNS: a list of the competitors outranked by the given
;;          competitor
;; STRATEGY: Combine simpler  functions
;; EXAMPLES: (tie-to-outranks   "B"   "C"   "C"
;;   (list (defeat-result "A" "B") (tie-result "B" "C"))
;;   '("C" "B" "A")) => '("B" "C")

(define (tie-to-outranks px py pa oldlst plst)
  (append (cons px (cons py OUTRANKS))
          (if (string=? px pa)
              (outranks-list py oldlst plst)
              (outranks-list px oldlst plst))))

;; TEST

(begin-for-test
  (check-equal? (outranks "A" (list (defeated "A" "B") (tie "B" "C")))
                '("B" "C"))
  (check-equal? (outranks "B" (list (defeated "A" "B") (defeated "B" "A")))
                '("A" "B"))
  (check-equal? (outranks "C" (list (defeated "A" "B") (tie "B" "C")))
                '("B" "C"))
  (check-equal? (outranks "A" (list (defeated "A" "D")
            (defeated "A" "E")
            (defeated "C" "B")
            (defeated "C" "F")
            (tie "D" "B")
            (defeated "F" "E")))
                '("B" "D" "E")))

;; unique-list : StringList -> StringList
;; GIVEN: a StringList
;; RETURNS: a list of unique variables present in the input StringList
;; STRATEGY: Combine simpler functions
;; HALTING MEASURE: Length of lst
;; EXAMPLE: (unique-list '("y" "z" "x" "x"))
;;     => '("y" "z" "x")

(define (unique-list lst)
  (cond
    [(empty? lst) '()]
    [(member (first lst) (rest lst))
     (unique-list (rest lst))]
    [else
     (cons (first lst) (unique-list (rest lst)))]))
  
;; outranked-by : Competitor OutcomeList -> CompetitorList
;; GIVEN: the name of a competitor and a list of outcomes
;; RETURNS: a list of the competitors that outrank the given
;;     competitor, in alphabetical order
;; NOTE: it is possible for a competitor to outrank itself
;; STRATEGY: Combine simpler functions and Initialize the invarient
;;           of outranked-by-list
;; EXAMPLES:
;;     (outranked-by "A" (list (defeated "A" "B") (tie "B" "C")))
;;  => (list)
;;
;;     (outranked-by "B" (list (defeated "A" "B") (defeated "B" "A")))
;;  => (list "A" "B")
;;
;;     (outranked-by "C" (list (defeated "A" "B") (tie "B" "C")))
;;  => (list "A" "B" "C")

(define (outranked-by pa lst)
  (unique-list
   (sort (outranked-by-list pa lst '()) string<?)))

;; outranked-by-list : Competitor OutcomeList PlayerScoreList -> CompetitorList
;; GIVEN: the name of a competitor and a list of outcomes
;;        a list of PlayerScores
;; RETURNS: a list of the competitors that outrank the given
;;     competitor
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (outranked-by-list  "A"
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '()) => '("A" "B")

(define (outranked-by-list pa lst clst)
  (if (member pa clst)
      '()
      (create-outranked-list pa lst clst)))

;; create-outranked-list : Competitor OutcomeList PlayerScoreList
;;                         -> CompetitorList
;; GIVEN: the name of a competitor, a list of total outcomes
;;        and a list of PlayerScores
;; RETURNS: a list of the competitors that outrank the given
;;          competitor
;; STRATEGY: Combine simpler functions
;; HALTING MEASURE: Length of lst
;; EXAMPLES: (create-outranked-list  "A"
;; (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '()) => '("A" "B")
  
(define (create-outranked-list pa lst clst)
  (cond
    [(empty? lst) '()]
    [else
     (append-outranked-list pa lst (cons pa clst))]))

;; append-outranked-list : Competitor OutcomeList PlayerScoreList
;;                         -> CompetitorList
;; GIVEN: the name of a competitor, a list of total outcomes
;;        and a list of PlayerScores
;; RETURNS: a list of the competitors that outrank the given
;;          competitor
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (append-outranked-list  "A"
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("A")) => '("A" "B")

(define (append-outranked-list pa lst clst)
  (append (outranked-by-defeat pa (filter-list defeat-result? lst) lst clst)
          (outranked-by-tie pa (filter-list tie-result? lst) lst clst)))

;; outranked-by-defeat : Competitor OutcomeList OutcomeList PlayerScoreList
;;                       -> CompetitorList
;; GIVEN: the name of a competitor, a list of tie outcomes,
;;        a list of total outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors that outrank the given
;;          competitor
;; STRATEGY: Combine simpler functions
;; HALTING MEASURE: Length of newlst
;; EXAMPLES: (outranked-by-defeat  "A"  '()
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("A")) =>  '()

(define (outranked-by-defeat pa newlst oldlst clst)
  (cond
    [(empty? newlst) '()]
    [else
     (if (string=? (defeat-result-pb (first newlst)) pa)
         (append-outranked pa newlst oldlst clst)
         (outranked-by-defeat pa (rest newlst) oldlst clst))]))

;; append-outranked : Competitor OutcomeList OutcomeList PlayerScoreList
;;                    -> CompetitorList
;; GIVEN: the name of a competitor, a list of tie outcomes,
;;        a list of total outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors that outrank the given
;;          competitor
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (append-outranked  "B"
;;  (list (defeat-result "A" "B") (defeat-result "B" "A"))
;;  (list (defeat-result "A" "B") (defeat-result "B" "A")) => '("A" "B")

(define (append-outranked pa newlst oldlst clst)
  (append (cons (defeat-result-pa (first newlst)) OUTRANKED)
          (outranked-by-list (defeat-result-pa (first newlst)) oldlst clst)
          (outranked-by-defeat pa (rest newlst) oldlst clst)))

;; outranked-by-tie : Competitor OutcomeList OutcomeList PlayerScoreList
;;                    -> CompetitorList
;; GIVEN: the name of a competitor, a list of tie outcomes,
;;        a list of total outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors that outrank the given
;;          competitor
;; STRATEGY: Combine simpler functions
;; HALTING MEASURE: Length of newlst
;; EXAMPLES: (outranked-by-tie  "A"  '()
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("A")) => '()

(define (outranked-by-tie pa newlst oldlst clst)
  (cond
    [(empty? newlst) '()]
    [else
      (if (or (string=? (tie-result-pa (first newlst)) pa)
              (string=? (tie-result-pb (first newlst)) pa))
          (append-outranked-tie pa newlst oldlst clst)
          (outranked-by-tie pa (rest newlst) oldlst clst))]))

;; append-outranked-tie : Competitor OutcomeList OutcomeList PlayerScoreList
;;                        -> CompetitorList
;; GIVEN: the name of a competitor, a list of tie outcomes,
;;        a list of total outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors that outrank the given
;;          competitor
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (append-outranked-tie   "B"
;;   (list (tie-result "B" "C"))
;;   (list (defeat-result "A" "B") (tie-result "B" "C"))
;;   '("B" "C")) =>  '("B" "C")

(define (append-outranked-tie pa newlst oldlst clst)
  (append (cons (tie-result-pa (first newlst))
                (cons (tie-result-pb (first newlst)) OUTRANKED))
          (outranked-player-list pa newlst oldlst clst)
          (outranked-by-tie pa (rest newlst) oldlst clst)))

;; outranked-player-list : Competitor OutcomeList OutcomeList PlayerScoreList
;;                        -> CompetitorList
;; GIVEN: the name of a competitor, a list of tie outcomes,
;;        a list of total outcomes and a list of PlayerScores
;; RETURNS: a list of the competitors that outrank the given
;;          competitor
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (outranked-player-list  "C"
;;  (list (tie-result "B" "C"))
;;  (list (defeat-result "A" "B") (tie-result "B" "C"))
;;  '("C")) => '("A" "B" "C")

(define (outranked-player-list pa newlst oldlst clst)
  (if (string=? (tie-result-pa (first newlst)) pa)
      (outranked-by-list (tie-result-pb (first newlst)) oldlst clst)
      (outranked-by-list (tie-result-pa (first newlst)) oldlst clst)))

;; TEST

(begin-for-test
  (check-equal? (outranked-by "A" (list (defeated "A" "B") (tie "B" "C")))
                '())
  (check-equal? (outranked-by "B" (list (defeated "A" "B") (defeated "B" "A")))
                (list "A" "B"))
  (check-equal? (outranked-by "C" (list (defeated "A" "B") (tie "B" "C")))
                (list "A" "B" "C")))