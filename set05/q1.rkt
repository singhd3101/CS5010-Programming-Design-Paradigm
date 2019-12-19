;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Arithmetic Expressions

(require rackunit)
(require "extras.rkt")
(check-location "05" "q1.rkt")

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
 block?)

;; CONSTANTS
(define LITERAL-EX "lit")
(define VARIABLE-EX "var")
(define OPERATION-EX "op")
(define CALL-EX "call")
(define BLOCK-EX "block")

;; DATA DEFINITIONS

;; An OperationName is represented as one of the following strings:
;;     -- "+"      (indicating addition)
;;     -- "-"      (indicating subtraction)
;;     -- "*"      (indicating multiplication)
;;     -- "/"      (indicating division)
;;
;; OBSERVER TEMPLATE:
;; operation-name-fn : OperationName -> ??
#;
 (define (operation-name-fn op)
    (cond ((string=? op "+") ...)
          ((string=? op "-") ...)
          ((string=? op "*") ...)
          ((string=? op "/") ...)))
          
;; An ArithmeticExpression is one of
;;     -- a Literal
;;     -- a Variable
;;     -- an Operation
;;     -- a Call
;;     -- a Block
;;
;; OBSERVER TEMPLATE:
;; arithmetic-expression-fn : ArithmeticExpression -> ??
#;
 (define (arithmetic-expression-fn exp)
    (cond ((literal? exp) ...)
          ((variable? exp) ...)
          ((operation? exp) ...)
          ((call? exp) ...)
          ((block? exp) ...)))

;; REPRESENTATIONS:

;; A Literal is represeted as (make-literalx typename lvalue)
;; INTERPRETATION:
;; typename : ArithmeticExpression      represents the data type name literal
;; lvalue:  Real           represents a real value of the literal

;; IMPLEMENTATION:
(define-struct literalx (typename lvalue))

;; CONSTRUCTOR TEMPLATE:
;;(make-literalx ArithmeticExpression Real)

;; OBSERVER TEMPLATE
;;(define (literalx-fn l)
;;  (... (literalx-typename l) (literalx-lvalue l)

;; A Variable is represeted as (make-variablex typename stringval)
;; INTERPRETATION:
;; typename : ArithmeticExpression      represents the data type name variable
;; stringval:  String          represents a string value of the variable

;; IMPLEMENTATION:
(define-struct variablex (typename stringval))

;; CONSTRUCTOR TEMPLATE:
;;(make-variablex ArithmeticExpression String)

;; OBSERVER TEMPLATE
;;(define (variablex-fn v)
;;  (... (variablex-typename v) (variablex-stringval v)

;; A Operation is represeted as (make-operationx typename opval)
;; INTERPRETATION:
;; typename : ArithmeticExpression      represents the data type name operation
;; opval:  OperationName     represents as one of the operation names

;; IMPLEMENTATION:
(define-struct operationx (typename opval))

;; CONSTRUCTOR TEMPLATE:
;;(make-operationx ArithmeticExpression OperationName)

;; OBSERVER TEMPLATE
;;(define (operationx-fn o)
;;  (... (operationx-typename o) (operationx-opval o)

;; A Call is represeted as (make-callex typename arithexp arithlist)
;; INTERPRETATION:
;; typename : ArithmeticExpression       represents the data type name Call
;; arithexp : ArithematicExpression      represents an arithematic expression
;; arithlist : ArithematicExpressionList represents a list of arithematic
;;                                       expressions

;; IMPLEMENTATION:
(define-struct callex (typename arithexp arithlist))

;; CONSTRUCTOR TEMPLATE:
;;(make-callex ArithmeticExpression ArithematicExpression
;;                                  ArithematicExpressionList)

;; OBSERVER TEMPLATE
;;(define (callex-fn c)
;;  (... (callex-arithexp c) (callex-arithlist c)

;; A ArithematicExpressionList is represented as a list of 
;; ArithematicExpressions

;; IMPLEMENTATION
(define arexlist '())

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

;; A Block is represented as
;;(make-leaf-node data)
;;(make-ternary-node lson mson rson)
;; INTERPRETATION
;; data: ArithematicExpression      is represented as a data type block
;; lson: Variable                   represents a subtree of the node
;; mson, rson: ArithmeticExpression  represent the subtrees of the node

;; IMPLEMENTATION
(define-struct leaf-node (data))
(define-struct ternary-node (lson mson rson))

;; OBSERVER TEMPLATE:
;; block-fn : Block -> ??
;; (define (block-fn t)
;;  (cond
;;    [(leaf-node? t) (... (leaf-node-data t))]
;;    [(ternary-node? t) (... (tree-fn (ternary-node-lson t))
;;                            (tree-fn (ternary-node-mson t))
;;                            (tree-fn (ternary-node-rson t)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTION DEFINITIONS

;; lit : Real -> Literal
;; GIVEN: a real number
;; RETURNS: a literal that represents that number
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (see the example given for literal-value,
;;          which shows the desired combined behavior
;;          of lit and literal-value)

(define (lit realval)
  (make-literalx LITERAL-EX realval))

;; literal-value : Literal -> Real
;; GIVEN: a literal
;; RETURNS: the number it represents
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (literal-value (lit 17.4)) => 17.4

(define (literal-value inplit)
  (literalx-lvalue inplit))

;; TESTS

(begin-for-test
  (check-equal? (literal-value (lit 17.4)) 17.4))

;; var : String -> Variable
;; GIVEN: a string
;; WHERE: the string begins with a letter and contains
;;     nothing but letters and digits
;; RETURNS: a variable whose name is the given string
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (see the example given for variable-name,
;;          which shows the desired combined behavior
;;          of var and variable-name)

(define (var stringval)
  (make-variablex VARIABLE-EX stringval))
          
;; variable-name : Variable -> String
;; GIVEN: a variable
;; RETURNS: the name of that variable
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (variable-name (var "x15")) => "x15"

(define (variable-name inpvar)
  (variablex-stringval inpvar))

;; TESTS

(begin-for-test
  (check-equal? (variable-name (var "x15")) "x15"))

;; op : OperationName -> Operation
;; GIVEN: the name of an operation
;; RETURNS: the operation with that name
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (see the examples given for operation-name,
;;           which show the desired combined behavior
;;           of op and operation-name)

(define (op opname)
  (make-operationx OPERATION-EX opname))
          
;; operation-name : Operation -> OperationName
;; GIVEN: an operation
;; RETURNS: the name of that operation
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;;     (operation-name (op "+")) => "+"
;;     (operation-name (op "/")) => "/"

(define (operation-name inpop)
  (operationx-opval inpop))

;; TESTS

(begin-for-test
  (check-equal? (operation-name (op "+")) "+")
  (check-equal? (operation-name (op "/")) "/"))

;; call : ArithmeticExpression ArithmeticExpressionList -> Call
;; GIVEN: an operator expression and a list of operand expressions
;; RETURNS: a call expression whose operator and operands are as
;;     given
;; EXAMPLES: (see the examples given for call-operator and
;;           call-operands, which show the desired combined
;;           behavior of call and those functions)

(define (call inpexp inplist)
  (make-callex CALL-EX inpexp inplist))
          
;; call-operator : Call -> ArithmeticExpression
;; GIVEN: a call
;; RETURNS: the operator expression of that call
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
;; EXAMPLE:
;;     (call-operands (call (op "-")
;;                          (list (lit 7) (lit 2.5))))
;;         => (list (lit 7) (lit 2.5))

(define (call-operands inpcall)
  (callex-arithlist inpcall))

(begin-for-test
  (check-equal? (call-operands (call (op "-")
                                     (list (lit 7) (lit 2.5))))
                (list (lit 7) (lit 2.5))))

;; block : Variable ArithmeticExpression ArithmeticExpression
;;             -> ArithmeticExpression
;; GIVEN: a variable, an expression e0, and an expression e1
;; RETURNS: a block that defines the variable's value as the
;;     value of e0; the block's value will be the value of e1
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (see the examples given for block-var, block-rhs,
;;           and block-body, which show the desired combined
;;           behavior of block and those functions)

(define (block varinp exp1 exp2)
    (make-ternary-node
     (make-leaf-node varinp)
     (make-leaf-node exp1)
     (make-leaf-node exp2)))

;; block-var : Block -> Variable
;; GIVEN: a block
;; RETURNS: the variable defined by that block
;; STRATEGY: Using observer template of Block on input
;; EXAMPLE:
;;     (block-var (block (var "x5")
;;                       (lit 5)
;;                       (call (op "*")
;;                             (list (var "x6") (var "x7")))))
;;         => (var "x5")

(define (block-var inpblock)
  (leaf-node-data (ternary-node-lson inpblock)))

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
;; EXAMPLE:
;;     (block-rhs (block (var "x5")
;;                       (lit 5)
;;                       (call (op "*")
;;                             (list (var "x6") (var "x7")))))
;;         => (lit 5)

(define (block-rhs inpblock)
  (leaf-node-data (ternary-node-mson inpblock)))

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
;; EXAMPLE:
;;     (block-body (block (var "x5")
;;                        (lit 5)
;;                        (call (op "*")
;;                              (list (var "x6") (var "x7")))))
;;         => (call (op "*") (list (var "x6") (var "x7")))

(define (block-body inpblock)
  (leaf-node-data (ternary-node-rson inpblock)))

;; TESTS

(begin-for-test
  (check-equal? (block-body (block (var "x5")
                       (lit 5)
                       (call (op "*")
                             (list (var "x6") (var "x7")))))
                     (call (op "*") (list (var "x6") (var "x7")))))

;; literal?   : ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true if and only the expression is a literal
;; EXAMPLES:
;;     (literal? (lit 17.4))      => true
;;     (literal? (var "x5")       => false

(define (literal? inpval)
  (literalx? inpval))

;; TESTS

(begin-for-test
  (check-equal? (literal? (lit 17.4)) true)
  (check-equal? (literal? (var "x5")) false))

;; variable?  : ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true if and only the expression is a variable
;; EXAMPLES:
;; (variable? (block-body (block (var "y") (lit 3) (var "z"))))
;;         => true
;;     (variable? (block-rhs (block (var "y") (lit 3) (var "z"))))
;;         => false

(define (variable? inpval)
  (variablex? inpval))

;; TESTS

(begin-for-test
  (check-equal? (variable? (block-body (block (var "y") (lit 3) (var "z"))))
                true)
  (check-equal? (variable? (block-rhs (block (var "y") (lit 3) (var "z"))))
                false))

;; operation? : ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true if and only the expression is an operation
;; EXAMPLES:
;;     (operation? (op "+"))      => true
;;     (operation? (var "x5"))    => false

(define (operation? inpval)
  (operationx? inpval))

;; TESTS

(begin-for-test
  (check-equal? (operation? (op "+")) true)
  (check-equal? (operation? (var "x5")) false))

;; call?      : ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true if and only the expression is a call
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
;; EXAMPLES:
;;     (variable? (block-body (block (var "y") (lit 3) (var "z"))))
;;         => true
;;     (variable? (block-rhs (block (var "y") (lit 3) (var "z"))))
;;         => false

(define (block? inpval)
  (ternary-node? inpval))

(begin-for-test
  (check-equal? (block? (block (var "x5")
                      (lit 5)
                       (call (op "*")
                             (list (var "x6") (var "x7"))))) true)
  (check-equal? (block? (var"y")) false))