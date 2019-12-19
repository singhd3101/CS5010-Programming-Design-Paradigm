;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Power Ranking

(require rackunit)
(require "extras.rkt")
(check-location "08" "q2.rkt")

(provide
 tie
 defeated
 defeated?
 outranks
 outranked-by
 power-ranking)

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

;; power-ranking : OutcomeList -> CompetitorList
;; GIVEN: a list of outcomes
;; RETURNS: a list of all competitors mentioned by one or more
;;     of the outcomes, without repetitions, with competitor A
;;     coming before competitor B in the list if and only if
;;     the power-ranking of A is higher than the power ranking
;;     of B.
;; STRATEGY: Combine simpler functions
;; EXAMPLE:
;;     (power-ranking
;;      (list (defeated "A" "D")
;;            (defeated "A" "E")
;;            (defeated "C" "B")
;;            (defeated "C" "F")
;;            (tie "D" "B")
;;            (defeated "F" "E")))
;;  => (list "C"   ; outranked by 0, outranks 4
;;           "A"   ; outranked by 0, outranks 3
;;           "F"   ; outranked by 1, outranks 1
;;           "E"   ; outranked by 3
;;           "B"   ; outranked by 4, outranks 2, 50%
;;           "D")  ; outranked by 4, outranks 2, 50%

(define (power-ranking lst)
  (if (empty? lst)
      '()
      (fetch-names (sort (rankings lst) sort-by-ranking))))

;; fetch-names : PlayerProfileList -> CompetitorList
;; GIVEN: a list of PlayeProfiles
;; RETURNS: a list of all competitors who are present in PlayerProfileList
;; STRATEGY: Use HOF Map on lst
;; EXAMPLE: (fetch-names  (list
;;   (player-pf "A" 3 0 1)   (player-pf "E" 3 3 1)
;;   (player-pf "B" 3 3 2/3) (player-pf "C" 0 3 0)))
;;   =>  '("A" "E" "B" "C")

(define (fetch-names lst)
  (unique-list
   (map
    ;; PlayerProfile -> Competitor
    ;; GIVEN: a PlayerProfile
    ;; RETURNS: the name of the Competitor from PlayerProfile
    ;; STRATEGY: Combie simpler functions
   (lambda (x) (player-pf-name x))
   lst)))

;; rankings : OutcomeList -> PlayerProfileList
;; GIVEN: a list of Outcomes
;; RETURNS: a list of PlayerProfile of all the competitors who are present
;;          in PlayerProfileList
;; STRATEGY: Combine simpler functions and Initialize the invarient
;;           of total-players
;; EXAMPLE: (rankings  (list (defeat-result "A" "B") (defeat-result "B" "C")
;;          (tie-result "B" "E"))) =>
;;          (list  (player-pf "E" 3 3 1)  (player-pf "C" 0 3 0)
;;                 (player-pf "A" 3 0 1)  (player-pf "B" 3 3 2/3))

(define (rankings lst)
  (calculate-ranking lst (total-players lst '())))

;; total-players : OutcomeList -> PlayerScoreList
;; GIVEN: a list of Outcomes
;; RETURNS: a list of PlayerScore of all the competitors who are present
;;          in OutcomeList
;; STRATEGY: Combine simpler functions
;; HALTING MEASURE: Length of lst
;; EXAMPLE: (total-players(list (defeat-result "A" "B") (defeat-result "B" "C")
;;          (tie-result "B" "E"))  '()) =>
;;          (list  (player-sc "E" 0 1)  (player-sc "C" 1 1)
;;                 (player-sc "A" 0 1)  (player-sc "B" 1 3))

(define (total-players lst plst)
  (cond
    [(empty? lst) '()]
    [else
     (if (empty? (rest lst))
         (extract-players (first lst) plst)
         (total-players (rest lst) (extract-players (first lst) plst)))]))

;; extract-players : Outcome PlayerScoreList -> PlayerScoreList
;; GIVEN: an Outcome and a list of PlayerScores
;; RETURNS: a list of PlayerScores including the Competitors in the input
;;          Outcome
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (extract-players (defeat-result "A" "B") '())
;;          => (list (player-sc "A" 0 1) (player-sc "B" 1 1))

(define (extract-players o plst)
  (if (defeat-result? o)
      (is-player-present-d? (defeat-result-pa o)
                            (defeat-result-pb o)
                            plst)
      (is-player-present-t? (tie-result-pa o)
                            (tie-result-pb o)
                            plst)))

;; is-player-present-d? : Competitor Competitor PlayerScoreList
;;                        -> PlayerScoreList
;; GIVEN: Two competitors and a list of PlayerScores
;; RETURNS: An updated PlayerScoreList based on the input Competitors
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (is-player-present-d? "A" "B" '())
;;          => (list (player-sc "A" 0 1) (player-sc "B" 1 1))

(define (is-player-present-d? px py plst)
  (is-player-present? px
                      add-func
                      (is-player-present? py
                                          lost-func
                                          plst)))

;; is-player-present-t? : Competitor Competitor PlayerScoreList
;;                        -> PlayerScoreList
;; GIVEN: Two competitors and a list of PlayerScores
;; RETURNS: An updated PlayerScoreList based on the input Competitors
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (is-player-present-t?  "B"  "E"
;;          (list (player-sc "C" 1 1) (player-sc "A" 0 1) (player-sc "B" 1 2)))
;;          => (list  (player-sc "E" 0 1)  (player-sc "C" 1 1)
;;                    (player-sc "A" 0 1)  (player-sc "B" 1 3))

(define (is-player-present-t? px py plst)
  (is-player-present? px
                      add-func
                      (is-player-present? py
                                          add-func
                                          plst)))

;; is-player-present? : Competitor (Competitor -> PlayerScore) PlayerScoreList
;;                      -> PlayerScoreList
;; GIVEN: A competitors, a function and a list of PlayerScores
;; RETURNS: An updated PlayerScoreList based on the input Competitor
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (is-player-present? "B" #<procedure:lost-func> '())
;;           => (list (player-sc "B" 1 1))

(define (is-player-present? px fn plst)
  (if (match-func px plst)
      (change-score px fn plst)
      (cons (fn (make-player-sc px 0 0)) plst)))

;; match-func : Competitor PlayerScoreList -> Boolean
;; GIVEN: A competitors and a list of PlayerScores
;; RETURNS: true iff the Competitor is present in the PlayerScoreList
;; STRATEGY: Use HOF Ormap on plst
;; EXAMPLE: (match-func "B" '()) => false

(define (match-func px plst)
  (ormap
   ;; PlayerScore -> Boolean
   ;; GIVEN: a PlayerScore
   ;; RETURNS: true iff the input Competitor is present in the PlayerScore
   ;; STRATEGY: Combine simpler functions
   (lambda (x) (string=? (player-sc-name x) px))
    plst))

;; change-score : Competitor (Competitor -> PlayerScore) PlayerScoreList
;;                -> PlayerScoreList
;; GIVEN: A competitors, a function and a list of PlayerScores
;; RETURNS: An updated PlayerScoreList based on the input Competitor
;; STRATEGY: Use HOF Map on plst
;; EXAMPLE: (change-score  "B" add-func
;;     (list (player-sc "C" 1 1) (player-sc "A" 0 1) (player-sc "B" 1 1)))
;;     => (list (player-sc "C" 1 1) (player-sc "A" 0 1) (player-sc "B" 1 2))
 
(define (change-score px fn plst)
  (map
   ;; PlayerScore -> PlayerScore
   ;; GIVEN: a PlayerScore
   ;; RETURNS: The updated PlayerScore for input Competitor
   ;; STRATEGY: Combine simpler functions
    (lambda (x) (if (string=? (player-sc-name x) px)
                (fn x)
                x))
    plst))

;; lost-func : Competitor -> PlayerScore
;; GIVEN: A Competitor
;; RETURNS: a PlayerScore for the Competitor
;; STRATEGY: Use constructor template of PlayerScore
;; EXAMPLE: (lost-func (player-sc "E" 1 1)) => (player-sc "E" 2 2)

(define (lost-func px)
  (make-player-sc (player-sc-name px)
                  (add1 (player-sc-lost px))
                  (add1 (player-sc-total px))))

;; add-func : Competitor -> PlayerScore
;; GIVEN: A Competitor
;; RETURNS: a PlayerScore for the Competitor
;; STRATEGY: Use constructor template of PlayerScore
;; EXAMPLE: (add-func (player-sc "F" 1 1)) => (player-sc "F" 1 2)

(define (add-func px)
  (make-player-sc (player-sc-name px)
                  (player-sc-lost px)
                  (add1 (player-sc-total px))))

;; calculate-ranking : OutcomeList PlayerScoreList -> PlayerProfileList
;; GIVEN: An OutcomeList and a PlayerScoreList
;; RETURNS: a PlayerProfileList for all the Competitor present in OutcomeList
;; STRATEGY: Combine simpler funcitons
;; HALTING MEASURE: Length of plst
;; EXAMPLE: (calculate-ranking
;;  (list (defeat-result "A" "B") (defeat-result "B" "C") (tie-result "B" "E"))
;;  (list   (player-sc "E" 0 1)   (player-sc "C" 1 1)
;;          (player-sc "A" 0 1)   (player-sc "B" 1 3))) =>
;;  (list   (player-pf "E" 3 3 1)  (player-pf "C" 0 3 0)
;;          (player-pf "A" 3 0 1)  (player-pf "B" 3 3 2/3))

(define (calculate-ranking lst plst)
  (cond
    [(empty? plst) '()]
    [else
     (append (create-profile lst (first plst))
             (calculate-ranking lst (rest plst)))]))

;; create-profile : OutcomeList PlayerScore -> PlayerProfileList
;; GIVEN: An OutcomeList and a PlayerScore
;; RETURNS: a PlayerProfileList for all the Competitor present in PlayerScore
;; STRATEGY: Use constructor template for PlayerProfile
;; EXAMPLE: (create-profile  (list (defeat-result "A" "B")
;;          (defeat-result "B" "C") (tie-result "B" "E"))
;;          (player-sc "E" 0 1)) => (list (player-pf "E" 3 3 1))

(define (create-profile lst p)
  (cons
   (make-player-pf
    (player-sc-name p)
    (length (outranks (player-sc-name p) lst))
    (length (outranked-by (player-sc-name p) lst))                  
    (calculate-perc p))                    
    PFLIST))

;; calculate-perc : PlayerScore -> Real
;; GIVEN: A PlayerScore
;; RETURNS: the non-losing percentage for the Competitor present in PlayerScore
;; STRATEGY: Combine simpler fucntions
;; EXAMPLE: (calculate-perc (player-sc "F" 1 2)) => 1/2

(define (calculate-perc p)
  (- 1 (/ (player-sc-lost p) (player-sc-total p))))

;; sort-by-ranking : PlayerProfile PlayerProfile -> Boolean
;; GIVEN: Two PlayerProfiles
;; RETURNS: true iff first PlayerProfile is ranked above the second
;; STRATEGY: Cases on input PlayerProfiles
;; EXAMPLE: (sort-by-ranking (player-pf "D" 2 4 1/2) (player-pf "B" 2 4 1/2))
;;          => false

(define (sort-by-ranking px py)
  (cond
    [(check-outranked-cond px py) true]
    [(check-outranks-cond px py)  true]
    [(check-perc-cond px py) true]
    [(check-name-cond px py) true]
    [else false]))

;; check-outranked-cond : PlayerProfile PlayerProfile -> Boolean
;; GIVEN: Two PlayerProfiles
;; RETURNS: true iff first PlayerProfile is outranked by less
;;          Competitors than the second
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-outranked-cond (player-pf "E" 0 3 0) (player-pf "F" 1 1 1/2))
;;          => false

(define (check-outranked-cond px py)
  (< (player-pf-no-outranked px) (player-pf-no-outranked py)))

;; check-outranks-cond : PlayerProfile PlayerProfile -> Boolean
;; GIVEN: Two PlayerProfiles
;; RETURNS: true iff first PlayerProfile outranks more
;;          Competitors than the second
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-outranks-cond (player-pf "E" 0 3 0) (player-pf "F" 1 1 1/2))
;;           => false

(define (check-outranks-cond px py)
  (and (= (player-pf-no-outranked px) (player-pf-no-outranked py))
       (> (player-pf-no-outranks px) (player-pf-no-outranks py))))

;; check-perc-cond : PlayerProfile PlayerProfile -> Boolean
;; GIVEN: Two PlayerProfiles
;; RETURNS: true iff first PlayerProfile has better non-losing percentage
;;          than the second
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-perc-cond (player-pf "E" 0 3 0) (player-pf "F" 1 1 1/2))
;;          => false

(define (check-perc-cond px py)
  (and (= (player-pf-no-outranked px) (player-pf-no-outranked py))
       (= (player-pf-no-outranks px) (player-pf-no-outranks py))
       (> (player-pf-perc px) (player-pf-perc py))))

(begin-for-test
  (check-equal? (sort-by-ranking
     (make-player-pf "P" 1 0 1) (make-player-pf "Q" 1 0 8/9)) true))

;; check-name-cond : PlayerProfile PlayerProfile -> Boolean
;; GIVEN: Two PlayerProfiles
;; RETURNS: true iff the name of Competitor in first PlayerProfile is
;;          ranked before the second by String<?
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-name-cond (player-pf "E" 0 3 0) (player-pf "F" 1 1 1/2))
;;          =>  false

(define (check-name-cond px py)
  (and (= (player-pf-no-outranked px) (player-pf-no-outranked py))
       (= (player-pf-no-outranks px) (player-pf-no-outranks py))
       (= (player-pf-perc px) (player-pf-perc py))
       (string<? (player-pf-name px) (player-pf-name py))))

;; TEST

(begin-for-test
  (check-equal? (power-ranking
      (list (defeated "A" "B") (defeated "B" "C") (tie "B" "E")))
                '("A" "E" "B" "C"))
  (check-equal? (power-ranking
      (list (defeated "A" "B")
            (defeated "A" "C")
            (defeated "E" "B")
            (defeated "E" "C")))
   (list "A" "E" "B" "C"))
  (check-equal? (power-ranking
      (list (defeated "A" "D")
            (defeated "A" "E")
            (defeated "C" "B")
            (defeated "C" "F")
            (tie "D" "B")
            (defeated "F" "E")))
   (list "C" "A" "F" "E" "B" "D")))