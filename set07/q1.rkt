;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Undefined Variables

(require rackunit)
(require "extras.rkt")
(check-location "07" "q1.rkt")

(provide
 lit
 literal-value
 var
 variable-name
 op
 operation-name
 call
 call-operator
 call-operands
 block
 block-var
 block-rhs
 block-body
 literal?
 variable?
 operation?
 call?
 block?
 undefined-variables)

;; CONSTANTS

;; List of variables defined by an ArtihematicExpression
(define VARLIST '())

;; List of variables used by an ArtihematicExpression
(define VARLIST-USED '())

;; List of variables used by an ArtihematicExpression
(define UNDEFINED '())

;; List of variables used by an ArtihematicExpression
(define DEFINED '())

;; DATA DEFINITIONS

;; An OperationName is represented as one of the following strings:
;;     -- "+"      (indicating addition)
;;     -- "-"      (indicating subtraction)
;;     -- "*"      (indicating multiplication)
;;     -- "/"      (indicating division)
;;
;; OBSERVER TEMPLATE:
;; operation-name-fn : OperationName -> ??

;; (define (operation-name-fn op)
;;    (cond ((string=? op "+") ...)
;;          ((string=? op "-") ...)
;;          ((string=? op "*") ...)
;;          ((string=? op "/") ...)))
          
;; An ArithmeticExpression is one of
;;     -- a Literal
;;     -- a Variable
;;     -- an Operation
;;     -- a Call
;;     -- a Block
;;
;; OBSERVER TEMPLATE:
;; arithmetic-expression-fn : ArithmeticExpression -> ??

;; (define (arithmetic-expression-fn exp)
;;    (cond ((literal? exp) ...)
;;          ((variable? exp) ...)
;;          ((operation? exp) ...)
;;          ((call? exp) ...)
;;          ((block? exp) ...)))

;; An OperationExpression is represented as one of the following
;; ArithematicExpression:
;;     -- an Operation     
;;     -- a Block     whose body is an operation expression
;;
;; OBSERVER TEMPLATE:
;; operation-exp-fn : OperationExpression -> ??

;; (define (operation-exp-fn ae)
;;    (cond ((operation? exp) ...)
;;          ((block? exp) ...)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; REPRESENTATIONS:

;; A Literal is represeted as (make-literal lvalue)
;; INTERPRETATION:
;; lvalue:  Real   represents a real value of the literal

;; IMPLEMENTATION:
(define-struct literal (lvalue))

;; CONSTRUCTOR TEMPLATE:
;;(make-literal Real)

;; OBSERVER TEMPLATE
;;(define (literal-fn l)
;;   (literal-lvalue l)

;; A Variable is represeted as (make-variable stringval)
;; INTERPRETATION:
;; stringval:  String          represents a string value of the variable

;; IMPLEMENTATION:
(define-struct variable (stringval))

;; CONSTRUCTOR TEMPLATE:
;;(make-variable String)

;; OBSERVER TEMPLATE
;;(define (variable-fn v)
;;  (... (variable-stringval v)

;; A Operation is represeted as (make-operation opval)
;; INTERPRETATION:
;; opval:  OperationName     represents as one of the operation names

;; IMPLEMENTATION:
(define-struct operation (opval))

;; CONSTRUCTOR TEMPLATE:
;;(make-operation OperationName)

;; OBSERVER TEMPLATE
;;(define (operation-fn o)
;;  (... (operation-opval o)

;; A Call is represeted as (make-callex arithexp arithlist)
;; INTERPRETATION:
;; arithexp : ArithematicExpression      represents an arithematic expression
;; arithlist : ArithematicExpressionList represents a list of arithematic
;;                                       expressions

;; IMPLEMENTATION:
(define-struct callex (arithexp arithlist))

;; CONSTRUCTOR TEMPLATE:
;;(make-callex ArithmeticExpression ArithematicExpressionList)                                  

;; OBSERVER TEMPLATE
;;(define (callex-fn c)
;;  (... (callex-arithexp c) (callex-arithlist c)

;; A ArithematicExpressionList is represented as a list of 
;; ArithematicExpressions

;; IMPLEMENTATION
(define AREXLIST '())

;; CONSTRUCTOR TEMPLATES:
;; empty
;; (cons arex arexist)
;; -- WHERE
;;    arex  is a ArithematicExpression
;;    arexlist is an ArithematicExpressionList

;; OBSERVER TEMPLATE
;; (define (arexlist-fn arexlist)
;;   (cond
;;     [(empty? arexlist) ...]
;;     [else (...
;;             (arex-fn (first arexlist))
;; 	    (arexlist-fn (rest arexlist)))]))

;; A Block is represented as (make-blockex bvar rhs body) 
;; INTERPRETATION
;; bvar: Variable    represents the variable defined by that block
;; rhs: ArithmeticExpression    whose value of the variable defined by
;;                              that block
;; body: ArithmeticExpression  value of the block expression

;; IMPLEMENTATION
(define-struct blockex (bvar rhs body))

;; CONSTRUCTOR TEMPLATE:
;;(make-blockex Variable ArithmeticExpression ArithematicExpression)                                  

;; OBSERVER TEMPLATE
;;(define (blockex-fn c)
;;  (... (blockex-bvar c) (blockex-rhs c) (blockex-body c)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTION DEFINITIONS

;; lit : Real -> Literal
;; GIVEN: a real number
;; RETURNS: a literal that represents that number
;; STRATEGY: Use observer template of Literal on input
;; EXAMPLE: (see the example given for literal-value,
;;          which shows the desired combined behavior
;;          of lit and literal-value)

(define (lit realval)
  (make-literal realval))

;; literal-value : Literal -> Real
;; GIVEN: a literal
;; RETURNS: the number it represents
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (literal-value (lit 17.4)) => 17.4

(define (literal-value inplit)
  (literal-lvalue inplit))

;; TESTS

(begin-for-test
  (check-equal? (literal-value (lit 17.4)) 17.4))

;; var : String -> Variable
;; GIVEN: a string
;; WHERE: the string begins with a letter and contains
;;     nothing but letters and digits
;; RETURNS: a variable whose name is the given string
;; STRATEGY: Use observer template of Variable on input
;; EXAMPLE: (see the example given for variable-name,
;;          which shows the desired combined behavior
;;          of var and variable-name)

(define (var stringval)
  (make-variable stringval))
          
;; variable-name : Variable -> String
;; GIVEN: a variable
;; RETURNS: the name of that variable
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (variable-name (var "x15")) => "x15"

(define (variable-name inpvar)
  (variable-stringval inpvar))

;; TESTS

(begin-for-test
  (check-equal? (variable-name (var "x15")) "x15"))

;; op : OperationName -> Operation
;; GIVEN: the name of an operation
;; RETURNS: the operation with that name
;; STRATEGY: Use observer template of Operation on input
;; EXAMPLES: (see the examples given for operation-name,
;;           which show the desired combined behavior
;;           of op and operation-name)

(define (op opname)
  (make-operation opname))
          
;; operation-name : Operation -> OperationName
;; GIVEN: an operation
;; RETURNS: the name of that operation
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;;     (operation-name (op "+")) => "+"
;;     (operation-name (op "/")) => "/"

(define (operation-name inpop)
  (operation-opval inpop))

;; TESTS

(begin-for-test
  (check-equal? (operation-name (op "+")) "+")
  (check-equal? (operation-name (op "/")) "/"))

;; call : ArithmeticExpression ArithmeticExpressionList -> Call
;; GIVEN: an operator expression and a list of operand expressions
;; RETURNS: a call expression whose operator and operands are as
;;     given
;; STRATEGY: Use observer template of callex on input
;; EXAMPLES: (see the examples given for call-operator and
;;           call-operands, which show the desired combined
;;           behavior of call and those functions)

(define (call inpexp inplist)
  (make-callex inpexp inplist))
          
;; call-operator : Call -> ArithmeticExpression
;; GIVEN: a call
;; RETURNS: the operator expression of that call
;; STRATEGY: Combine simpler functions
;; EXAMPLE:
;;     (call-operator (call (op "-")
;;                          (list (lit 7) (lit 2.5))))
;;         => (op "-")

(define (call-operator inpcall)
  (callex-arithexp inpcall))

;; TESTS

(begin-for-test
  (check-equal? (call-operator (call (op "-")
                                     (list (lit 7) (lit 2.5)))) (op "-"))) 
          
;; call-operands : Call -> ArithmeticExpressionList
;; GIVEN: a call
;; RETURNS: the operand expressions of that call
;; STRATEGY: Combine simpler functions
;; EXAMPLE:
;;     (call-operands (call (op "-")
;;                          (list (lit 7) (lit 2.5))))
;;         => (list (lit 7) (lit 2.5))

(define (call-operands inpcall)
  (callex-arithlist inpcall))

;; TESTS

(begin-for-test
  (check-equal? (call-operands (call (op "-")
                                     (list (lit 7) (lit 2.5))))
                (list (lit 7) (lit 2.5))))

;; block : Variable ArithmeticExpression ArithmeticExpression
;;             -> ArithmeticExpression
;; GIVEN: a variable, an expression e0, and an expression e1
;; RETURNS: a block that defines the variable's value as the
;;     value of e0; the block's value will be the value of e1
;; STRATEGY: Use observer template of Block on input
;; EXAMPLES: (see the examples given for block-var, block-rhs,
;;           and block-body, which show the desired combined
;;           behavior of block and those functions)

(define (block varinp exp1 exp2)
  (make-blockex varinp exp1 exp2))

;; block-var : Block -> Variable
;; GIVEN: a block
;; RETURNS: the variable defined by that block
;; STRATEGY: Combine simpler functions
;; EXAMPLE:
;;     (block-var (block (var "x5")
;;                       (lit 5)
;;                       (call (op "*")
;;                             (list (var "x6") (var "x7")))))
;;         => (var "x5")

(define (block-var inpblock)
  (blockex-bvar inpblock))

;; TESTS

(begin-for-test
  (check-equal? (block-var (block (var "x5")
                       (lit 5)
                       (call (op "*")
                             (list (var "x6") (var "x7")))))
                     (var "x5")))

;; block-rhs : Block -> ArithmeticExpression
;; GIVEN: a block
;; RETURNS: the expression whose value will become the value of
;;     the variable defined by that block
;; STRATEGY: Combine simpler functions
;; EXAMPLE:
;;     (block-rhs (block (var "x5")
;;                       (lit 5)
;;                       (call (op "*")
;;                             (list (var "x6") (var "x7")))))
;;         => (lit 5)

(define (block-rhs inpblock)
  (blockex-rhs inpblock))

;; TESTS

(begin-for-test
  (check-equal? (block-rhs (block (var "x5")
                       (lit 5)
                       (call (op "*")
                             (list (var "x6") (var "x7")))))
                     (lit 5))) 
          
;; block-body : Block -> ArithmeticExpression
;; GIVEN: a block
;; RETURNS: the expression whose value will become the value of
;;     the block expression
;; STRATEGY: Combine simpler functions
;; EXAMPLE:
;;     (block-body (block (var "x5")
;;                        (lit 5)
;;                        (call (op "*")
;;                              (list (var "x6") (var "x7")))))
;;         => (call (op "*") (list (var "x6") (var "x7")))

(define (block-body inpblock)
  (blockex-body inpblock))

;; TESTS

(begin-for-test
  (check-equal? (block-body (block (var "x5")
                       (lit 5)
                       (call (op "*")
                             (list (var "x6") (var "x7")))))
                     (call (op "*") (list (var "x6") (var "x7")))))

;; call?      : ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true if and only the expression is a call
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;;     (call? (call (op "-") (list (lit 7) (lit 2.5)))) => true
;;     (call? (var "x5"))    => false

(define (call? inpval)
  (callex? inpval))

;; TESTS

(begin-for-test
  (check-equal? (call? (call (op "-") (list (lit 7) (lit 2.5)))) true)
  (check-equal? (call? (var "x5")) false))

;; block?     : ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true if and only the expression is (respectively)
;;     a literal, variable, operation, call, or block
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;;     (variable? (block-body (block (var "y") (lit 3) (var "z"))))
;;         => true
;;     (variable? (block-rhs (block (var "y") (lit 3) (var "z"))))
;;         => false

(define (block? inpval)
  (blockex? inpval))

;; TESTS

(begin-for-test
  (check-equal? (block? (block (var "x5")
                      (lit 5)
                       (call (op "*")
                             (list (var "x6") (var "x7"))))) true)
  (check-equal? (block? (var"y")) false))

;; unique-list : StringList -> StringList
;; GIVEN: a StringList
;; RETURNS: a list of unique variables present in the input StringList
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (unique-list '("y" "z" "x" "x"))
;;     => '("y" "z" "x")

(define (unique-list lst)
  (cond
    [(empty? lst) '()]
    [(member (first lst) (rest lst))
         (unique-list (rest lst))]
    [else
         (cons (first lst) (unique-list (rest lst)))]))

;; variables-used-by : ArithmeticExpression -> StringList
;; GIVEN: an arithmetic expression
;; RETURNS: a list of the names of all variables used in
;;     the expression, including variables used in a block
;;     on the right hand side of its definition or in its body,
;;     but not including variables defined by a block unless
;;     they are also used
;; EXAMPLE:
;;     (variables-used-by
;;      (block (var "x")
;;             (var "y")
;;             (call (block (var "z")
;;                          (var "x")
;;                          (op "+"))
;;                   (list (block (var "x")
;;                                (lit 5)
;;                                (var "x"))
;;                         (var "x")))))
;;  => (list "x" "y") or (list "y" "x")

(define (variables-used-by inpval)
 (unique-list
  (cond
    [(variable? inpval) (cons (variable-name inpval) VARLIST-USED)]
    [(call? inpval) (check-new-call inpval)]
    [(block? inpval)(block-rhs-func inpval)]
    [else VARLIST-USED]))
)

;; TESTS

(begin-for-test
  (check-equal? (variables-used-by
      (block (var "x")
             (var "y")
             (call (block (var "z")
                          (var "x")
                          (op "+"))
                   (list (block (var "x")
                                (lit 5)
                                (var "x"))
                         (var "x")))))
       (list "y" "x")))

;; block-rhs-func : ArithematicExpression -> StringList
;; GIVEN: ArithematicExpression
;; RETURNS: a list of variables used in the input ArithematicExpression
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (block-rhs-func (blockex (variable "x") (literal 5)(variable "x")))
;;          =>    '("x" "x")

(define (block-rhs-func inpval)
  (append (variables-used-by (block-rhs inpval))
          (variables-used-by (block-body inpval))
          (add-lson-cond inpval)))

;; add-lson-cond : ArithematicExpression -> StringList
;; GIVEN: ArithematicExpression
;; RETURNS: var list in which block-var added to list iff its used
;;          in block-body
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (add-lson-cond (blockex (variable "x") (literal 5) (variable "x")))
;;             => '("x")

(define (add-lson-cond inpval)
  (if (member? (variable-name (block-var inpval))
               (variables-used-by (block-body inpval)))
      (cons (variable-name (block-var inpval)) '())
      '()))

;; check-new-call : ArithematicExpression StringList -> StringList
;; GIVEN: an ArithematicExpression and a StringList
;; RETURNS: a list of variables used in the input Call
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-new-call
;;  (callex
;;   (blockex (variable "z") (variable "x") (operation "+"))
;;   (list (blockex (variable "x") (literal 5) (variable "x"))
;;         (variable "x"))))
;;           => '("x" "x" "x")

(define (check-new-call inp)
  (append (variables-used-by (call-operator inp))
          (var-used-in-operand? (call-operands inp))))

;; var-used-in-operand? : ArithList -> StringList
;; GIVEN: an ArithematicExpression 
;; RETURNS: a list of variables used in the input Call operands
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (var-used-in-operand? (list (variable "x"))) => '("x")

(define (var-used-in-operand? lst)
  (cond
    [(empty? lst) VARLIST-USED]
    [else
     (append-used-list lst)]))

;; append-used-list : ArithList -> StringList
;; GIVEN: an ArithList
;; RETURNS: a list of variables used in the input Call operands
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (append-used-list (list (variable "x")))
;;           =>  '("x")

(define (append-used-list lst)
  (append (variables-used-by (first lst))
          (var-used-in-operand? (rest lst))))


;; undefined-variables : ArithmeticExpression -> StringList
;; GIVEN: an Arithmetic expression
;; RETURNS: a list of the names of all undefined variables
;;     for the expression, without repetitions, in any order
;; STRATEGY: Initialize the invariant of undef-variables?
;; EXAMPLE:
;;     (undefined-variables
;;      (call (var "f")
;;            (list (block (var "x")
;;                         (var "x")
;;                         (var "x"))
;;                  (block (var "y")
;;                         (lit 7)
;;                         (var "y"))
;;                  (var "z"))))
;;  => some permutation of (list "f" "x" "z")

(define (undefined-variables inp)
  (unique-list
   (combine-vars 
    (undef-variables? inp DEFINED))))

;; undef-variables? : ArithmeticExpression VarList-> StringList
;; GIVEN: an arbitrary arithmetic expression which is a part of some other
;; Arithematic Expression A and a list of 'vars'
;; WHERE: vars is the set of variables available at the start of
;; Arithematic Expression A.
;; RETURNS: a list of the names of all undefined variables
;;     for the expression, in any order
;; STRATEGY: Cases on input Arithematic Expqession
;; EXAMPLE: (undef-variables?
;;  (make-block
;;   (var "x")
;;   (var "y")
;;   (make-callex
;;    (op "+")
;;    (list
;;     (make-block (var "p") (var "a") (var "p"))
;;     (make-block (var "e") (lit 2) (var "p"))
;;     (var "z")))) '())
;;     => '("y" ("a") ("p") ("z"))

(define (undef-variables? inp dlist)
  (cond
    [(variable? inp) (cons (variable-name inp) UNDEFINED)]
    [(call? inp) (check-undef-call inp dlist)]
    [(block? inp) (undef-in-block inp dlist)]
    [else UNDEFINED]))

;; check-undef-call : ArithmeticExpression VarList-> StringList
;; GIVEN: an arithmetic expression and a list of 'vars'
;; WHERE: the input Arithematic Expression is a Call
;; RETURNS: a list of the names of all undefined variables
;;     for the expression, in any order
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-undef-call
;;  (callex (variable "a") (list (variable "b") (variable "c")))
;;  '())
;;  =>'("a" "b" "c")

(define (check-undef-call inp dlist)
  (append (undef-variables? (call-operator inp) dlist)
          (undef-in-list (call-operands inp) dlist)))

;; undef-in-list : ArithList VarList-> StringList
;; GIVEN: a list of Arithematic Expressoins and a list of 'vars'
;; RETURNS: a list of the names of all undefined variables
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (undef-in-list (list (variable "b") (variable "c")) '())
;;           => ("b" "c")

(define (undef-in-list inp dlist)
  (cond
    [(empty? inp) UNDEFINED]
    [else
     (append (undef-variables? (first inp) dlist)
             (undef-in-list (rest inp) dlist))]))

;; undef-in-block : ArithList VarList-> StringList
;; GIVEN: a list of Arithematic Expressoins and a list of 'vars'
;; RETURNS: a list of the names of all undefined variables
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (undef-in-block
;;   (make-block  (var "x")
;;                (var "y")
;;                (make-call  (op "+")
;;                            (list  (blockex (var "p")
;;                                            (var "a")
;;                                            (var "p"))
;;                                   (blockex (var "e")
;;                                            (lit 2)
;;                                            (var "p"))
;;                                   (var "z"))))
;;  '())
;;    => '("y" ("a") ("p") ("z"))

(define (undef-in-block inp dlist)
  (append (var-in-rhs? (block-rhs inp) dlist)
          (compare-list (cons (variable-name (block-var inp)) dlist)
                        (variables-used-by (block-body inp)))))

;; var-in-rhs? : ArithematicExpression VarList-> StringList
;; GIVEN: a list of Arithematic Expressoins and a list of 'vars'
;; RETURNS: a list of the names of all undefined variables
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (var-in-rhs? (variable "y") '())
;;           => '("y")

(define (var-in-rhs? inp dlist)
  (if (variable? inp)
      (cons (variable-name inp) UNDEFINED)
      (undef-variables? inp dlist)))

;; compare-list : VarList VarList -> StringList
;; GIVEN: two list of defined and used variables respectively
;; RETURNS: a list of the names of all undefined variables
;; STRATEGY: Use HOF Map on list of used variables
;; EXAMPLE: (compare-list '("x") '("a" "p" "z"))
;;          => <'(("a") ("p") ("z"))

(define (compare-list dlist ulist)
  (map
   ;; Variable -> VarList
   ;; GIVEN: a Variable
   ;; RETURNS: a list of undefined variables
   ;; STRATEGY: Combine simpler functiosn
   (lambda (u) (check-in-dlist u dlist))
     ulist))

;; check-in-dlist : VarList VarList -> StringList
;; GIVEN: two list of defined and used variables respectively
;; RETURNS: a list of the names of all undefined variables
;; STRATEGY: Use HOF Map on list of used variables
;; EXAMPLE: (check-in-dlist "y" '("x"))
;;          => '("y")

(define (check-in-dlist u dlist)
  (if (member? u dlist)
      UNDEFINED
      (cons u UNDEFINED)))

;; combine-vars : VarVarList -> StringList
;; GIVEN: two list of defined and used variables respectively
;; RETURNS: a list of the names of all undefined variables
;; STRATEGY: Use HOF Map on list of used variables
;; EXAMPLE: (combine-vars '("a")) =>  '("a")

(define (combine-vars lst)
  (cond
    [(empty? lst) '()]
    [(not (list? lst)) (list lst)]
    [else
     (append (combine-vars (first lst))
             (combine-vars (rest lst)))]))

(begin-for-test
  (check-equal? (undefined-variables
                 (block (var "x")
                        (var "y")
                        (var "z")))
                 '("y" "z"))
  (check-equal? (undefined-variables
                 (block (var "x")
                        (var "y")
                        (var "x")))
                 '("y"))
  (check-equal? (undefined-variables
                 (call (var "a")
                       (list (var "b")
                             (var "c"))))
                 '("a" "b" "c"))
  (check-equal? (undefined-variables
                (var "a"))
                 '("a"))
  (check-equal? (undefined-variables
                (call (var "f")
                      (list (block (var "x")
                                   (var "x")
                                   (var "x"))
                            (block (var "y")
                                   (lit 7)
                                   (var "y"))
                            (var "z"))))
                '("f" "x" "z" ))
  (check-equal? (undefined-variables
                (block (var "x")
                       (var "y")
                       (block (var "y")
                              (lit 7)
                              (var "x"))))
                '("y"))
  (check-equal? (undefined-variables
                (block (var "x")
                       (var "y")
                       (call (op "+")
                             (list (var "x")
                                   (var "y")))))
                '("y"))
  (check-equal? (undefined-variables
                (block (var "x")
                       (var "y")
                       (call (op "+")
                             (list (block (var "p")
                                          (var "a")
                                          (var "p"))
                                   (block (var "e")
                                          (lit 2)
                                          (var "p"))
                                   (var "z")))))
                '("y" "a" "p" "z")))
