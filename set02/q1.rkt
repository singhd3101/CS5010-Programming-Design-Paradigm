;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "02" "q1.rkt")

(provide
        make-lexer
        lexer-token
        lexer-input
        initial-lexer
        lexer-stuck?
        lexer-shift
        lexer-reset)

;; DATA DEFINITIONS

;; REPRESENTATION:
;; Lexer datatype is represented as (make-lexer tokenString inputString) with the
;; following fields:
;; tokenString : String   represents the token value
;; inputString : String   represents the input text

;; IMPLEMENTATION:
(define-struct lexer (tokenString inputString))

;; CONSTRUCTOR TEMPLATE:
;; (make-lexer String String)

;; OBSERVER TEMPLATE:
;; ball-fn : Ball -> ??
;;(define (lexer-fn lex)
;;  (... (lexer-tokenString lex)
;;       (lexer-tokenString lex)))

;; FUNCTION DEFINITIONS

;; make-lexer : tokString inpString -> lex
;; GIVEN :
;; tokString : String   represents the token value
;; inpString : String   represents the input text
;; RETURNS : a Lexer whose token string is tokString
;; and whose input string is inpString
;; EXAMPLES :
;; (make-lexer "abc" "1234") = (make-lexer "abc" "1234")

(make-lexer "abc" "1234")

;; TESTS

(begin-for-test
  (check-equal? (make-lexer "abc" "1234") (make-lexer "abc" "1234")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lexer-token : lex -> tokString
;; GIVEN :
;; lex : Lexer   represents a lexer
;; RETURNS : a String which is the token string of input lexer
;; DESIGN SRATEGY : Combine simpler function
;; (define (lexer-token lex)
;;          (lex-tokString lex))
;; EXAMPLES :
;; (lexer-token lex) = "abc"

(define (lexer-token lexer)
         (lexer-tokenString lexer))

;; TESTS

(begin-for-test
  (check-equal? (lexer-token (make-lexer "abc" "1234")) "abc" ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lexer-input: lex -> inpString
;; GIVEN :
;; lex : Lexer   represents a lexer
;; RETURNS : a String whose value is the input String
;; of the input Lexer
;; DESIGN SRATEGY : Combine simpler function
;; (define (lexer-input lex)
;;          (lex-inpString lex))
;; EXAMPLES :
;; (lexer-input lex) = "1234"

(define (lexer-input lexer)
         (lexer-inputString lexer))

;; TESTS

(begin-for-test
  (check-equal? (lexer-input (make-lexer "abc" "1234")) "1234" ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; initial-lexer: inpString -> lex
;; GIVEN :
;; inpString : String    any arbitrary string
;; RETURNS : a Lexer lex whose token string is empty
;;     and whose input string is the given string
;; DESIGN SRATEGY : Combine simpler function
;; (define (initial-lexer inp)
;;          (make-lex "" inp))
;; EXAMPLES :
;; (initial-lexer "1234") = (make-lexer "" "1234")

(define (initial-lexer inpString)
         (make-lexer "" inpString))

;; TESTS

(begin-for-test
  (check-equal? (initial-lexer "1234") (make-lexer "" "1234")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lexer-stuck? : lex -> flag
;; GIVEN :
;; lex: LEXER    an input lexer
;; RETURNS :
;; flag: BOOLEAN false if and only if the given Lexer's input string
;;     is non-empty and begins with an English letter or digit;
;;     otherwise returns true.
;; DESIGN SRATEGY : Condition on cases of input string
;; (define (lexer-stuck? lex)
;;          (cond
;;           [(string=? lex-inp "") true]
;;           [else
;;             (cond
;;               [(is-alphabetic lex-inp) false]
;;               [(is-numeric lex-inp) false]
;;               [else true])]))
;; EXAMPLES:
;;     (lexer-stuck? (make-lexer "abc" "1234"))  =>  false
;;     (lexer-stuck? (make-lexer "abc" "+1234"))  =>  true
;;     (lexer-stuck? (make-lexer "abc" ""))  =>  true

(define (lexer-stuck? lexer)
         (cond
           [(string=? (lexer-inputString lexer) "") true]
           [else
            (cond
            [(is-alphabetic (lexer-inputString lexer)) false]
           [(is-numeric (lexer-inputString lexer)) false]
           [else true])]))

;; TESTS

(begin-for-test
  (check-equal? (lexer-stuck? (make-lexer "abc" "1234")) false)
  (check-equal? (lexer-stuck? (make-lexer "abc" "+1234")) true)
  (check-equal? (lexer-stuck? (make-lexer "abc" "abc")) false)
  (check-equal? (lexer-stuck? (make-lexer "abc" "")) true))
  
;; HELPER FUNCTIONS

;; is-alphabetic : inp -> flagalpha
;; GIVEN :
;; inp: String is the input string of the provided lexer
;; RETURNS:
;; flagalpha : BOOLEAN is true if firct character of input string is
;;    alphabetic else false
;; DESIGN STRATEGY : Combine simpler functions
;; (define (is-alphabetic inp)
;;           (char-alphabetic? (string-ref inp 0)))
;; EXAMPLES:
;;      (is-alphabetic "abc") => true
;;      (is-alphabetic "123") => false

(define (is-alphabetic inp)
         (char-alphabetic? (string-ref inp 0)))

;; TESTS

(begin-for-test
  (check-equal? (is-alphabetic "abc") true)
  (check-equal? (is-alphabetic "123") false))

;; is-numeric : inp -> flagnum
;; GIVEN :
;; inp: String is the input string of the provided lexer
;; RETURNS:
;; flagnum : BOOLEAN is true if firct character of input string is
;;    numeric else false
;; DESIGN STRATEGY : Combine simpler functions
;; (define (is-numeric inp)
;;           (char-numeric? (string-ref inp 0)))
;; EXAMPLES:
;;      (is-numeric "abc") => false
;;      (is-numeric "123") => true

(define (is-numeric inp)
         (char-numeric? (string-ref inp 0)))

;; TESTS

(begin-for-test
  (check-equal? (is-numeric "abc") false)
  (check-equal? (is-numeric "123") true))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lexer-shift : lex -> lexnew
;; GIVEN :
;; lex : Lexer    an input lexer
;; RETURNS :
;; lexnew : Lexer If the given Lexer is stuck, returns the given Lexer.
;;   If the given Lexer is not stuck, then the token string
;;       of the result consists of the characters of the given
;;       Lexer's token string followed by the first character
;;       of that Lexer's input string, and the input string
;;       of the result consists of all but the first character
;;       of the given Lexer's input string.
;; DESIGN STRATEGY : cases on the input lexer lex
;;   (define (lexer-shift lex)
;;            (cond
;;             [(lexer-stuck? lex) lex]
;;             [else
;;               (make-lex (newtoken lex) (newinput lex))]))
;; EXAMPLES:
;;     (lexer-shift (make-lexer "abc" ""))
;;         =>  (make-lexer "abc" "")
;;     (lexer-shift (make-lexer "abc" "+1234"))
;;         =>  (make-lexer "abc" "+1234")
;;     (lexer-shift (make-lexer "abc" "1234"))
;;         =>  (make-lexer "abc1" "234")

(define (lexer-shift lexer)
         (cond
           [(lexer-stuck? lexer) lexer]
           [else
            (make-lexer (newtoken lexer) (newinput lexer))]))

(begin-for-test
  (check-equal? (lexer-shift (make-lexer "abc" "")) (make-lexer "abc" ""))
  (check-equal? (lexer-shift (make-lexer "abc" "+1234")) (make-lexer "abc" "+1234"))
  (check-equal? (lexer-shift (make-lexer "abc" "1234")) (make-lexer "abc1" "234")))

;; HELPER FUNCTIONS

;; newtoken : lex -> tokenval
;; GIVEN :
;; lex : Lexer    an input lexer
;; RETURNS :
;; tokenval : is the updated token string appended with first char of input string
;; DESIGN STRATEGY : Combine simpler functions
;;   (define (newtoken lex)
;;            ((string-append (lex-tok lex) (substring (lex-inp lex) 0 1)))
;; EXAMPLES:
;;     (newtokent (make-lexer "abc" "1234"))
;;         =>  "abc1"

(define (newtoken lexer)
         (string-append (lexer-tokenString lexer) (substring (lexer-inputString lexer) 0 1)))

;; TESTS

(begin-for-test
  (check-equal? (newtoken (make-lexer "abc" "1234")) "abc1"))

;; newinput : lex -> inputval
;; GIVEN :
;; lex : Lexer    an input lexer
;; RETURNS :
;; inputval : is the updated input string excluding the first char
;; DESIGN STRATEGY : Combine simpler functions
;;   (define (newinout lex)
;;            (substring (lex-inp lex) 1))
;; EXAMPLES:
;;     (newinput (make-lexer "abc" "1234"))
;;         =>  "234"

(define (newinput lexer)
         (substring (lexer-inputString lexer) 1))

;; TESTS

(begin-for-test
  (check-equal? (newinput (make-lexer "abc" "1234")) "234"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lexer-reset : lex -> newlex
;; GIVEN :
;; lex : Lexer    an input lexer
;; RETURNS :
;; newlex : a Lexer whose token string is empty and whose
;;     input string is empty if the given Lexer's input string
;;     is empty and otherwise consists of all but the first
;;     character of the given Lexer's input string.
;; DESIGN SRATEGY : Cases on the input lexer lex
;; (define (lexer-reset lex)
;;         (cond
;;           [(string=? (lex-inp lex) "") (make-lex "" "")]
;;           [else
;;            (make-lex "" (newinput lex))]
;;          ))
;; EXAMPLES:
;;     (lexer-reset (make-lexer "abc" ""))
;;         =>  (make-lexer "" "")
;;     (lexer-reset (make-lexer "abc" "+1234"))
;;         =>  (make-lexer "" "1234")

(define (lexer-reset lexer)
         (cond
           [(string=? (lexer-inputString lexer) "") (make-lexer "" "")]
           [else
            (make-lexer "" (newinput lexer))]
          ))

;; TESTS

(begin-for-test
  (check-equal? (lexer-reset (make-lexer "abc" ""))(make-lexer "" ""))
  (check-equal? (lexer-reset (make-lexer "abc" "+1234"))(make-lexer "" "1234")) )