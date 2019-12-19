;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; ListPractice1

(require rackunit)
(require "extras.rkt")
(check-location "06" "q1.rkt")

(provide
    inner-product
    permutation-of?
    shortlex-less-than?
    permutations)

;; inner-product : RealList RealList -> Real
;; GIVEN: two lists of real numbers
;; WHERE: the two lists have the same length
;; RETURNS: the inner product of those lists
;; STRATEGY: Use HOF foldr on list1 and list2
;; EXAMPLES:
;;     (inner-product (list 2.5) (list 3.0))  =>  7.5
;;     (inner-product (list 1 2 3 4) (list 5 6 7 8))  =>  70
;;     (inner-product (list) (list))  =>  0

;(define (inner-product list1 list2)
;  (cond
;    [(check-empty? list1 list2) 0]
;    [else
;        (calculate-product list1 list2)]))

(define (inner-product list1 list2)
  ;; foldr: (Real Real -> Real) baseval RealList -> Real
  ;; GIVEN: a Combiner to be applied on the values of input list
  ;; baseval: Real  a base value for combiner function
  ;; RealList:  a list of Real numbers
  ;; RETURNS: sum of elements of the IntLits
  (foldr + 0 (create-list list1 list2)))

;; inner-product : RealList RealList -> Real
;; GIVEN: two lists of real numbers
;; WHERE: the two lists have the same length
;; RETURNS: the inner product of those lists
;; STRATEGY: Use HOF foldr on list1 and list2
;; EXAMPLES:

(define (create-list l1 l2)
  ;; foldr: (Real Real -> RealList) baseval RealList RealList -> RealList
  ;; GIVEN: a Combiner to be applied on the values of input 
  ;; baseval: Real  a base value for combiner function
  ;; RealList:  a list of Real numbers
  ;; RETURNS: sum of elements of the IntLits
  (foldr
   ;; lambda : Real Real combiner -> RealList
   ;; GIVEN : two real numbers
   ;; RETURNS : List with the product of two input numbers added to it
   (lambda (e1 e2 acc)
           (cons (* e1 e2) acc))
         '() l1 l2))

;; check-empty? : RealList RealList -> Boolean
;; GIVEN: two list
;; RETURNS: true iff both the list are empty
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;; '() '() => true
;; '(1) () => false

(define (check-empty? lst1 lst2)
  (and
   (empty? lst1)
   (empty? lst2)))

;; calculate-product : RealList RealList -> Boolean
;; GIVEN: two non empty list
;; RETURNS: inner product of list elements
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;; '(2.5) '(3.0) => 7.5
;; '(1 2 3 4) (5 6 7 8) => 70

;(define (calculate-product list1 list2)
; (+ (* (first list1) (first list2))
;    (if (check-empty? (rest list1) (rest list2))
;      0
;      (calculate-product (rest list1) (rest list2)))))

(begin-for-test
  (check-equal? (inner-product (list) (list)) 0)
  (check-equal? (inner-product (list 2.5) (list 3.0)) 7.5)
  (check-equal? (inner-product (list 1 2 3 4) (list 5 6 7 8)) 70))

;; permutation-of? : IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; WHERE: neither list contains duplicate elements
;; RETURNS: true if and only if one of the lists
;;     is a permutation of the other
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;;     (permutation-of? (list 1 2 3) (list 1 2 3)) => true
;;     (permutation-of? (list 3 1 2) (list 1 2 3)) => true
;;     (permutation-of? (list 3 1 2) (list 1 2 4)) => false
;;     (permutation-of? (list 1 2 3) (list 1 2)) => false
;;     (permutation-of? (list) (list)) => true

(define (permutation-of? list1 list2)
  (cond
    [(check-empty? list1 list2) true]
    [else
     (check-permutation list1 list2)]))

;; check-permutation : RealList RealList -> Boolean
;; GIVEN: two non empty list of same length
;; RETURNS: true iff one list is a permutation of the other
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;; '(1 2 3) '(3 1 2)  => true
;; '(2 1 3) '(4 1 3) => false

(define (check-permutation list1 list2)
  (cond
    [(length-equal? list1 list2)
        (list-values? list1 list2)]
    [else false]))

;; length-equal? : RealList RealList -> Boolean
;; GIVEN: two non empty list
;; RETURNS: true iff length  of one list is same as the other
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;; '(1 2 3) '(3 1 2)  => true
;; '(2 1 3) '(4 3) => false

(define (length-equal? list1 list2)
  (= (length list1)
     (length list2)))

;; list-values? : RealList RealList -> Boolean
;; GIVEN: two non empty list of same length
;; RETURNS: true iff one of the element matches with one of the element
;; of the second lisr
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;; '(1 2 3) '(3 1 2)  => true
;; '(3) '(4) => false

(define (list-values? list1 list2)
  (if (= (first list1) (first list2))
      (if (check-empty? (rest list1) (rest list2))
          true
          (list-values? (rest list1) (rest list2)))
      (= (first list1) (first (rest list2)))))

(begin-for-test
  (check-equal? (permutation-of? (list) (list)) true)
  (check-equal? (permutation-of? (list 1 2 3) (list 1 2 3)) true)
  (check-equal? (permutation-of? (list 1 2 3) (list 1 2)) false)
  (check-equal? (permutation-of? (list 1 2 3) (list 3 1 2)) true)
  (check-equal? (permutation-of? (list 3 1 2) (list 1 2 4)) false)
  (check-equal? (permutation-of? (list 3 1 2) (list 1 1 1)) false))

;; shortlex-less-than? : IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; RETURNS: true if and only either
;;     the first list is shorter than the second
;;  or both are non-empty, have the same length, and either
;;         the first element of the first list is less than
;;             the first element of the second list
;;      or the first elements are equal, and the rest of
;;             the first list is less than the rest of the
;;             second list according to shortlex-less-than?
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;;     (shortlex-less-than? (list) (list)) => false
;;     (shortlex-less-than? (list) (list 3)) => true
;;     (shortlex-less-than? (list 3) (list)) => false
;;     (shortlex-less-than? (list 3) (list 3)) => false
;;     (shortlex-less-than? (list 3) (list 1 2)) => true
;;     (shortlex-less-than? (list 3 0) (list 1 2)) => false
;;     (shortlex-less-than? (list 0 3) (list 1 2)) => true

(define (shortlex-less-than? list1 list2)
  (cond
    [(check-empty? list1 list2) false]
    [(match-length list1 list2)  true]
    [else (check-new-clause list1 list2)]))

;; match-length : RealList RealList -> Boolean
;; GIVEN: two non empty list
;; RETURNS: true iff length of first list is less than second
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;; '(1 2 3) '(3 1 2)  => false
;; '(3) '(2 4) => true

(define (match-length list1 list2)
  (< (length list1) (length list2)))

;; check-new-clause : RealList RealList -> Boolean
;; GIVEN: two list
;; RETURNS: true iff the first list shortlex than than second
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;; '(0 3) '(1 2)  => true
;; '(3 0) '(1 2) => false

(define (check-new-clause list1 list2)
  (cond
    [(and (not (check-empty? list1 list2))
          (length-equal? list1 list2))
     (next-check list1 list2)]
    [else false]))

;; STRATEGY : Combine simpler functions

(define (next-check list1 list2)
  (cond
    [(check-first? list1 list2) true]
    [(check-remaining list1 list2) true]
    [else false]))

;; RETURNS: true iff the first element list1 is less than first element of list2
;; STRATEGY : Combine simpler functions

(define (check-first? list1 list2)
  (< (first list1) (first list2)))

;; STRATEGY : Combine simpler functions

(define (check-remaining list1 list2)
  (if (= (first list1) (first list2))
      (shortlex-less-than? (rest list1) (rest list2))
      false))

;; TEST

(begin-for-test
  (check-equal? (shortlex-less-than? (list) (list)) false)
  (check-equal? (shortlex-less-than? (list) (list 3)) true)
  (check-equal? (shortlex-less-than? (list 3) (list)) false)
  (check-equal? (shortlex-less-than? (list 3) (list 3)) false)
  (check-equal? (shortlex-less-than? (list 3) (list 1 2)) true)
  (check-equal? (shortlex-less-than? (list 3 0) (list 1 2)) false)
  (check-equal? (shortlex-less-than? (list 0 3) (list 1 2)) true)
  (check-equal? (shortlex-less-than? (list 0 3) (list 0 5)) true))

;; permutations : IntList -> IntListList
;; GIVEN: a list of integers
;; WHERE: the list contains no duplicates
;; RETURNS: a list of all permutations of that list,
;;     in shortlex order
;; STRATEGY:  Combine simpler functions
;; EXAMPLES:
;;     (permutations (list))  =>  (list (list))
;;     (permutations (list 9))  =>  (list (list 9))
;;     (permutations (list 3 1 2))
;;         =>  (list (list 1 2 3)
;;                   (list 1 3 2)
;;                   (list 2 1 3)
;;                   (list 2 3 1)
;;                   (list 3 1 2)
;;                   (list 3 2 1))

(define (permutations lst)
  (sort (permute (sort lst <)) shortlex-less-than?))

;; permute : IntList -> IntListList
;; GIVEN: a list of integers
;; WHERE: the list contains no duplicates
;; RETURNS: a list of all permutations of that list
;; STRATEGY:  Use HOF map on lst (twice)
;; EXAMPLES: (permute '(1 2 3))
;;   => '((1 2 3) (2 1 3) (2 3 1) (1 3 2) (3 1 2) (3 2 1))

;(define (permute lst) 
;  (cond 
;    [(empty? lst) '(())]
;    [else 
;     (local
;       [(define (first-check restlst)
;         (local
;           [(define (second-check n) (insert-value restlst n (first lst)))]
;              (map second-check (create-sequence 0 (length restlst)))))]
 ;      (apply append (map first-check (permutations (rest lst)))))]))

(define (permute lst)
  (cond
    [(empty? lst) '(())]
    [else
      (apply append
             (map
              ;; startpos endpos -> IntList
              ;; GIVEN: an list of Integers
              ;; RETURNS: a permutation of list of Integers
              ;; STRATEGY: Combine simpler functions
              (lambda (restlst)
                  (map
                   ;; Int -> IntListList
                   ;; GIVEN: Int  position to insert value
                   ;; RETURNS: a new list of Integer
                   ;; STRATEGY : Combine sipler functions
                   (lambda (n)
                         (insert-value restlst n (first lst)))
                   (create-sequence 0 (length restlst))))
                          (permutations (rest lst))))]))

;; insert-value : IntList number element -> IntList
;; GIVEN: a list of integers
;; number : PosInt the position elere the element is to be inserted
;; element: PosInt the element to be inserted in the lisr
;; WHERE: the list contains no duplicates
;; RETURNS: a list of all permutations of that list
;; STRATEGY:  Combine simpler functions
;; EXAMPLES: (insert-value '(3 2) 2 1)
;;   => '(3 2 1)

(define (insert-value lst num e)
  (if (= 0 num)
      (cons e lst)
      (cons (first lst) 
            (insert-value (rest lst) (- num 1) e))))

;; create-sequence : startpos endpos -> IntList
;; GIVEN:
;; startpos: PosInt   starting position in sequence
;; endpos: PosInt ending position in sequence
;; number : PosInt the position elere the element is to be inserted
;; element: PosInt the element to be inserted in the lisr
;; WHERE: the list contains no duplicates
;; RETURNS: a list of all permutations of that list
;; STRATEGY:  Combine simpler functions
;; EXAMPLES: (create-sequence 0 2) => '(0 1 2)

(define (create-sequence start end)
  (if (= start end)
      (list end)
      (cons start (create-sequence (+ start 1) end))))

;; TEST

(begin-for-test
  (check-equal? (permutations '(1 2 3))
                (list (list 1 2 3)
                     (list 1 3 2)
                     (list 2 1 3)
                     (list 2 3 1)
                     (list 3 1 2)
                     (list 3 2 1))))
