;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Constant Expressions

(require rackunit)
(require "extras.rkt")
(check-location "05" "q2.rkt")

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
 variables-defined-by
 variables-used-by
 constant-expression?
 constant-expression-value)

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
;; (make-leaf-node data)
;; (make-ternary-node lson mson rson)
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

(define varlist '())

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
;; STRATEGY: Use observer template of Variable on input
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
;; STRATEGY: Use observer template of Operation on input
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
;; STRATEGY: Use observer template of callex on input
;; EXAMPLES: (see the examples given for call-operator and
;;           call-operands, which show the desired combined
;;           behavior of call and those functions)

(define (call inpexp inplist)
  (make-callex CALL-EX inpexp inplist))
          
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
    (make-ternary-node
     (make-leaf-node varinp)
     (make-leaf-node exp1)
     (make-leaf-node exp2)))

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
;; STRATEGY: Combine simpler functions
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
;; STRATEGY: Combine simpler functions
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
;; STRATEGY: Combine simpler funcions
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
;; STRATEGY: Combine simpler functions
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
;; STRATEGY: Combine simpler functions
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
  (ternary-node? inpval))

;; TESTS

(begin-for-test
  (check-equal? (block? (block (var "x5")
                      (lit 5)
                       (call (op "*")
                             (list (var "x6") (var "x7"))))) true)
  (check-equal? (block? (var"y")) false))

;; variables-defined-by : ArithmeticExpression -> StringList
;; GIVEN: an arithmetic expression
;; RETURNS: a list of the names of all variables defined by
;;     all blocks that occur within the expression, without
;;     repetitions, in any order
;; STRATEGY: Cases on block expression
;; EXAMPLE:
;;     (variables-defined-by
;;      (block (var "x")
;;             (var "y")
;;             (call (block (var "z")
;;                          (var "x")
;;                          (op "+"))
;;                   (list (block (var "x")
;;                                (lit 5)
;;                                (var "x"))
;;                         (var "x")))))
;;  => (list "x" "z") or (list "z" "x")

(define (variables-defined-by inpval)
  (cond
    [(leaf-node? inpval) (check-variable
                          (leaf-node-data inpval) varlist)]
    [(ternary-node? inpval)
                  (unique-list (append-func inpval))]))

(begin-for-test
  (check-equal? (variables-defined-by
      (block (var "x15")
             (var "y16")
             (var "z17"))) (list "x15" "z17"))
  (check-equal? (variables-defined-by
      (block (var "x15")
             (var "y16")
             (call (op "-") (list (var "y16") (var "z17")))))
                (list "x15" "y16" "z17"))
  (check-equal? (variables-defined-by
                (block (var "x")
                       (var "y")
                       (call (block (var "z")
                                    (var "x")
                                    (op "+"))
                             (list (block (var "x")
                                          (lit 5)
                                          (var "x"))
                                   (var "x")))))
                (list "z" "x")))

;; append-func : ArithmeticExpression -> StringList
;; GIVEN: an Arithematic expression
;; RETURNS: a list of the names of all variables defined by
;;     all blocks that occur within the expression, without
;;     repetitions, in any order
;; STRATEGY: Cases on nodes of block
;; EXAMPLE: (append-func '(x15) '(y16 z17) 
;;     => '(x15 y16 z17)

(define (append-func inpval)
  (append
   (variables-defined-by (ternary-node-lson inpval))
   (variables-defined-by (ternary-node-rson inpval))))

;; TESTS

(begin-for-test
  (check-equal? (append-func
  (make-ternary-node
   (make-leaf-node (var "x15"))
   (make-leaf-node (var "y16"))
   (make-leaf-node (var "z17")))) '("x15" "z17")))

;; check-variable : ArithmeticExpression StringList -> StringList
;; GIVEN: an Arithematic expression and a StringList
;; RETURNS: a list of the names of all variables defined  within the expression
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-variable (var "x15") '("y16")) 
;;     => '("x15" "y16")

(define (check-variable inp l)
  (cond
    [(variable? inp) (cons (variable-name inp) l)]
    [(call? inp)(check-call inp l)]
    [(ternary-node? inp) (variables-defined-by inp)]
    [else l]))

;; TESTS

(begin-for-test
  (check-equal? (check-variable (var "x15") '("y16")) '("x15" "y16")))

;; check-call : ArithmeticExpression StringList -> StringList
;; GIVEN: an Arithematic expression and a StringList
;; RETURNS: an appended list of the names of all variables defined
;;          within the call expression
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-call (call (op "-")
;;                            list (var "y16") (var "z17"))
;;     => '("y16" "z17")

(define (check-call inp l)
  (append (check-operator inp l)
          (traverse-list (call-operands inp) l)))

;; TESTS

(begin-for-test
  (check-equal? (check-call (call (op "-")
                                  (list (var "y16") (var "z17"))) '())
                '("y16" "z17")))

;; check-operator : ArithmeticExpression StringList -> StringList
;; GIVEN: an Arithematic expression and a StringList
;; RETURNS: a list of variables declared in operator expression of call
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-operator (call (op "-")
;;                                (list (var "y16") (var "z17"))) '())
;;     => '()

(define (check-operator inp l)
  (if (ternary-node? (call-operator inp))
      (variables-defined-by (call-operator inp))
      (check-variable (call-operator inp) l)))

;; TESTS

(begin-for-test
  (check-equal? (check-operator (call (op "-")
                                (list (var "y16") (var "z17"))) '())
                '()))

;; traverse-list : ArithmeticExpression StringList -> StringList
;; GIVEN: an Arithematic expression and a StringList
;; RETURNS: a list of variables declared in operand expression of call
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (traverse-list (list (var "y16")(var "z17")) '())
;;     => '("y16" "z17")

(define (traverse-list lst l)
  (cond
    [(empty? lst) l]
    [else
     (append-list lst l)]))

;; TESTS

(begin-for-test
  (check-equal? (traverse-list (list (var "y16")(var "z17")) '())
                '("y16" "z17")))

;; append-list : ArithList StringList -> StringList
;; GIVEN: an Arithlist and a StringList
;; RETURNS: a list of variables declared in operand expression of call
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (append-list (list (var "x")) '("y"))
;;     => '("x" "y" "y")

(define (append-list lst l)
  (append (check-variable (first lst) l)
          (traverse-list (rest lst) l)))

;; TEST

(begin-for-test
  (check-equal? (append-list (list (var "x")) '("y"))
                 '("x" "y" "y")))

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

;; TESTS

(begin-for-test
  (check-equal? (unique-list '("y" "z" "x" "x"))
                 '("y" "z" "x")))

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
  (cond
    [(leaf-node? inpval) (check-var
                          (leaf-node-data inpval) varlist)]
    [(ternary-node? inpval)
                  (unique-list (block-rhs-func inpval))]))

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
                (list "y" "x"))
  (check-equal? (variables-used-by
                (block (var "x")
                       (var "y")
                       (block (var "z")
                              (var "x")
                              (var "y"))))
                (list "x" "y"))
  (check-equal? (variables-used-by
                (block (var "x")
                       (var "y")
                       (call (var "z")
                             (list (block (var "x")
                                          (lit 5)
                                          (var "x"))
                                   (var "x")))))
                (list "y" "z" "x")))

;; block-rhs-func : ArithematicExpression -> StringList
;; GIVEN: ArithematicExpression
;; RETURNS: a list of variables used in the input ArithematicExpression
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (block-rhs-func
;;                 (make-ternary-node
;;                 (make-leaf-node (var "z"))
;;                  (make-leaf-node (var "x"))
;;                  (make-leaf-node (var "y"))))
;;        =>      '("x" "y")

(define (block-rhs-func inpval)
  (append (variables-used-by (ternary-node-mson inpval))
          (variables-used-by (ternary-node-rson inpval))))

;; TEST

(begin-for-test
  (check-equal? (block-rhs-func
                 (make-ternary-node
                  (make-leaf-node (var "z"))
                  (make-leaf-node (var "x"))
                  (make-leaf-node (var "y"))))
                '("x" "y")))

;; check-var : ArithematicExpression StringList -> StringList
;; GIVEN: an ArithematicExpression and a StringList
;; RETURNS: a list of variables used in the input ArithematicExpression
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-var (var "y") '("z"))
;;                 '("y" "z")))

(define (check-var inp l)
  (cond
    [(variable? inp) (cons (variable-name inp) l)]
    [(call? inp)(check-new-call inp l)]
    [(ternary-node? inp) (variables-used-by inp)]
    [else l]))

;; TEST

(begin-for-test
  (check-equal? (check-var (var "y") '("z"))
                '("y" "z")))

;; check-new-call : ArithematicExpression StringList -> StringList
;; GIVEN: an ArithematicExpression and a StringList
;; RETURNS: a list of variables used in the input Call
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-new-call
;;                 (call (var "z")
;;                       (list
;;                        (make-ternary-node
;;                         (make-leaf-node (var "x"))
;;                         (make-leaf-node (lit 5))
;;                         (make-leaf-node (var "x")))
;;                        (var "x")))  '())
;;      =>  '("z" "x" "x")))

(define (check-new-call inp l)
  (append (check-new-operator inp l)
          (traverse-list (call-operands inp) l)))

;; TEST

(begin-for-test
  (check-equal? (check-new-call
                 (call (var "z")
                       (list
                        (make-ternary-node
                         (make-leaf-node (var "x"))
                         (make-leaf-node (lit 5))
                         (make-leaf-node (var "x")))
                        (var "x")))  '())
                '("z" "x" "x")))

;; check-new-operator : ArithematicExpression StringList -> StringList
;; GIVEN: an ArithematicExpression and a StringList
;; RETURNS: a list of variables used in the input Call operator
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (check-new-operator
;;                 (call   (var "z")
;;                         (list (make-ternary-node
;;                                (make-leaf-node (var "x"))
;;                                (make-leaf-node (lit 5))
;;                                (make-leaf-node (var "x")))
;;                               (var "x")))  '())
;;         =>       '("z")

(define (check-new-operator inp l)
  (if (ternary-node? (call-operator inp))
      (variables-used-by (call-operator inp))
      (check-variable (call-operator inp) l)))

;; TEST

(begin-for-test
  (check-equal? (check-new-operator
                 (call   (var "z")
                         (list (make-ternary-node
                                (make-leaf-node (var "x"))
                                (make-leaf-node (lit 5))
                                (make-leaf-node (var "x")))
                               (var "x")))  '())
                '("z")))

;; constant-expression? : ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true if and only if the expression is a constant
;;     expression
;; EXAMPLES:
;;     (constant-expression?
;;      (call (var "f") (list (lit -3) (lit 44))))
;;         => false
;;     (constant-expression?
;;      (call (op "+") (list (var "x") (lit 44))))
;;         => false
;;     (constant-expression?
;;      (block (var "x")
;;             (var "y")
;;             (call (block (var "z")
;;                          (call (op "*")
;;                                (list (var "x") (var "y")))
;;                          (op "+"))
;;                   (list (lit 3)
;;                         (call (op "*")
;;                               (list (lit 4) (lit 5)))))))
;;         => true

(define (constant-expression? inpex)
  (cond
    [(literal? inpex) true]
    [(call? inpex) (constant-in-call inpex)]
    [(ternary-node? inpex) (constant-in-block inpex)]
    [else false]))

;; TESTS

(begin-for-test
  (check-equal? (constant-expression?
                (call (var "f") (list (lit -3) (lit 44))))
                false)
  (check-equal? (constant-expression?
                (call (op "+") (list (var "x") (lit 44))))
                false)
  (check-equal? (constant-expression?
                (block (var "x")
                       (var "y")
                       (call (block (var "z")
                                    (call (op "*")
                                          (list (var "x") (var "y")))
                                    (op "+"))
                             (list (lit 3)
                                   (call (op "*")
                                         (list (lit 4) (lit 5)))))))
                true))

;; constant-in-call : ArithematicExpression -> Boolean
;; GIVEN: an ArithematicExpression
;; RETURNS: true if and only if the call expression is a constant
;;     expression
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (constant-in-call
;;                (call    (op "*")
;;                         (list (lit 4) (lit 5))))
;;       =>  true

(define (constant-in-call inp)
  (and (constant-in-operator inp)
       (constant-in-operands inp)))

;; TEST

(begin-for-test
  (check-equal? (constant-in-call
                (call    (op "*")
                         (list (lit 4) (lit 5))))
               true))

;; constant-in-operator : ArithematicExpression -> Boolean
;; GIVEN: an ArithematicExpression
;; RETURNS: true if and only if the call operator is a constant
;;     expression
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (constant-in-operator
;;                 (call   (op "*")
;;                         (list (lit 4) (lit 5))))
;;    =>     true

(define (constant-in-operator inp)
  (cond
    [(operation? (call-operator inp)) true]
    [(ternary-node? (call-operator inp))
     (constant-expression? (call-operator inp))]
    [else
     false]))

;; TEST

(begin-for-test
  (check-equal? (constant-in-operator
                 (call   (op "*")
                         (list (lit 4) (lit 5))))
                true))

;; constant-in-operands : ArithList -> Boolean
;; GIVEN: an ArithList
;; RETURNS: true iff there is a constant in input ArithList
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (constant-in-operands
;;                 (call    (op "*")
;;                          (list (lit 4) (lit 5))))
;;     =>           true

(define (constant-in-operands inp)
  (constant-in-list (call-operands inp)))

;; TEST

(begin-for-test
  (check-equal? (constant-in-operands
                 (call    (op "*")
                          (list (lit 4) (lit 5))))
                true))

;; constant-in-list : ArithList -> Boolean
;; GIVEN: an ArithList
;; RETURNS: true iff there is a constant in input ArithList
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (constant-in-list (list (lit 4) (lit 5)))
;;      =>    true

(define (constant-in-list lst)
  (cond
    [(empty? lst) true]
    [else
     (and (constant-expression? (first lst))
          (constant-in-list (rest lst)))]))

;; TEST

(begin-for-test
  (check-equal? (constant-in-list (list (lit 4) (lit 5)))
                true))

;; constant-in-block : ArithematicExpression -> Boolean
;; GIVEN: an ArithematicExpression
;; RETURNS: true iff there is a constant in input ArithList
;; STRATEGY: Combine simpler functions
;; EXAMPLE: (constant-in-list (list (lit 4) (lit 5)))
;;      =>    true

(define (constant-in-block inp)
  (cond
    [(operation? (block-body inp)) true]
    [else
     (constant-expression? (block-body inp))]))

;; TEST

(begin-for-test
  (check-equal? (constant-in-block
                 (make-ternary-node
                  (make-leaf-node (var "z"))
                  (make-leaf-node (call  (op "*")
                                         (list (var "x") (var "y"))))
                  (make-leaf-node (op "+"))))
                true))

;; constant-expression-value : ArithmeticExpression -> Real
;; GIVEN: an arithmetic expression
;; WHERE: the expression is a constant expression
;; RETURNS: the numerical value of the expression
;; STRATEGY: Combine simpler functions
;; EXAMPLES:
;;     (constant-expression-value
;;      (call (op "/") (list (lit 15) (lit 3))))
;;         => 5
;;     (constant-expression-value
;;      (block (var "x")
;;             (var "y")
;;           (call (block (var "z")
;;                          (call (op "*")
;;                                (list (var "x") (var "y")))
;;                          (op "+"))
;;                   (list (lit 3)
;;                         (call (op "*")
;;                               (list (lit 4) (lit 5)))))))
;;         => 23

(define (constant-expression-value inpex)
  (if (constant-expression? inpex)
      (cond
        [(literal? inpex) (literal-value inpex)]
        [(call? inpex) (call-value inpex)]
        [(ternary-node? inpex) (eval-block inpex)])
      0))

;; TEST

(begin-for-test
  (check-equal? (constant-expression-value (lit 5)) 5)
  (check-equal? (constant-expression-value
      (call (op "/") (list (lit 15) (lit 3)))) 5)
  (check-equal? (constant-expression-value
      (call (op "*") (list (lit 15) (lit 3) (lit 2)))) 90)
  (check-equal? (constant-expression-value
      (call (op "+") (list (lit 15) (lit 3) (lit 2)))) 20)
  (check-equal? (constant-expression-value
      (call (op "-") (list (lit 15) (lit 3)))) 12)
  (check-equal? (constant-expression-value
      (call (op "/") (list (lit 45) (lit 5) (lit 3)))) 3)
  (check-equal? (constant-expression-value
      (call (op "-") (list (lit 18) (lit 6) (lit 5) (lit 2)))) 5)
  (check-equal? (constant-expression-value;
      (block (var "x")
             (var "y")
           (call (block (var "z")
                          (call (op "*")
                                (list (var "x") (var "y")))
                          (op "+"))
                   (list (lit 3)
                        (call (op "*")
                               (list (lit 4) (lit 5))))))) 23)
  (check-equal? (constant-expression-value
      (block (var "x")
             (var "y")
             (block (var "z")
                     (call (op "*")
                           (list (var "x") (var "y")))
                     (lit 5)))) 5)
  (check-equal? (constant-expression-value;
      (block (var "x")
             (var "y")
           (call (block (var "z")
                          (call (op "*")
                                (list (var "x") (var "y")))
                          (op "-"))
                   (list (lit 53)
                        (call (op "*")
                               (list (lit 4) (lit 5))))))) 20)
  (check-equal? (constant-expression-value;
      (block (var "x")
             (var "y")
           (call (block (var "z")
                          (call (op "*")
                                (list (var "x") (var "y")))
                          (op "*"))
                   (list (lit 3)
                        (call (op "*")
                               (list (lit 4) (lit 5))))))) 60)
  (check-equal? (constant-expression-value;
      (block (var "x")
             (var "y")
           (call (block (var "z")
                          (call (op "*")
                                (list (var "x") (var "y")))
                          (op "/"))
                   (list (lit 60)
                         (call (op "*")
                               (list (lit 4) (lit 5)))
                         (block (var 5)
                                (var 7)
                                (lit 3)))))) 1)
  (check-equal? (constant-expression-value;
      (block (var "x")
             (var "y")
             (var "z"))) 0))

;; call-value : ArithmeticExpression -> Real
;; GIVEN: an arithmetic expression
;; WHERE: the expression is a constant expression
;; RETURNS: the numerical value of the call expression
;; STRATEGY: Use observer template of OperationName on input
;; EXAMPLES:
;;     (call-value
;;   (call    (op "*")
;;            (list (lit 4) (lit 5)))) => 20

(define (call-value inp)
  (if (ternary-node? (call-operator inp))
      (eval-node inp)
      (eval-operation inp)))

;; TEST

(begin-for-test
  (check-equal? (call-value
   (call    (op "*")
            (list (lit 4) (lit 5)))) 20))

;; eval-node : ArithmeticExpression -> Real
;; GIVEN: an arithmetic expression
;; WHERE: the expression is a constant expression
;; RETURNS: the numerical value of the block expression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (eval-node  (call
;;   (make-ternary-node
;;    (make-leaf-node (var "z"))
;;    (make-leaf-node (call   (op "*")
;;                            (list (var "x") (var "y"))))
;;    (make-leaf-node (op "/")))
;;                    (list (lit 60)
;;                          (call  (op "*")
;;                                (list (lit 4) (lit 5)))
;;                          (make-ternary-node
;;                           (make-leaf-node (var 5))
;;                           (make-leaf-node (var 7))
;;                           (make-leaf-node (lit 3))) => 1

(define (eval-node inp)
  (call-value (make-callex CALL-EX (eval-block (call-operator inp))
              (call-operands inp))))

;; TEST

(begin-for-test
  (check-equal?
   (eval-node  (call
   (make-ternary-node
    (make-leaf-node (var "z"))
    (make-leaf-node (call   (op "*")
                            (list (var "x") (var "y"))))
    (make-leaf-node (op "/")))
                    (list (lit 60)
                          (call  (op "*")
                                 (list (lit 4) (lit 5)))
                          (make-ternary-node
                           (make-leaf-node (var 5))
                           (make-leaf-node (var 7))
                           (make-leaf-node (lit 3)))))) 1))

;; eval-operation : ArithmeticExpression -> Real
;; GIVEN: an arithmetic expression
;; WHERE: the expression is a constant expression
;; RETURNS: the numerical value of the input expression
;; STRATEGY: Use observer template of Operation name on input
;; EXAMPLES: (eval-operation (call
;;                             (op "*")
;;                             (list (lit 4) (lit 5)))) => 20

(define (eval-operation inp)
  (cond
    [(string=? (eval-op inp) "+")
               (add-operation inp)]
    [(string=? (eval-op inp) "-")
               (sub-operation inp)]
    [(string=? (eval-op inp) "*")
               (multi-operation inp)]
    [(string=? (eval-op inp) "/")
               (div-operation inp)]))

;; TEST

(begin-for-test
  (check-equal? (eval-operation (call
                                 (op "*")
                                 (list (lit 4) (lit 5)))) 20))

;; eval-op : ArithmeticExpression -> Operation
;; GIVEN: an arithmetic expression
;; RETURNS: the operation present in the input expression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (eval-op
;;  (call   (op "*")
;;   (list (lit 4) (lit 5)))) => "*"

(define (eval-op inp)
  (operation-name (call-operator inp)))

;; TEST

(begin-for-test
  (check-equal? (eval-op
  (call   (op "*")
   (list (lit 4) (lit 5)))) "*"))

;; eval-op : ArithmeticExpression -> Operation
;; GIVEN: an arithmetic expression
;; RETURNS: the operation present in the input expression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (add-operation
;;  (call
;;   (op "+")
;;   (list (lit 15) (lit 3) (lit 2)))) => 20

(define (add-operation inp)
  (add-func (eval-list(call-operands inp))))

;; TEST

(begin-for-test
  (check-equal? (add-operation
  (call
   (op "+")
   (list (lit 15) (lit 3) (lit 2)))) 20))

;; sub-operation : ArithmeticExpression -> Operation
;; GIVEN: an arithmetic expression
;; RETURNS: the operation present in the input expression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (sub-operation
;;  (call (op "-")
;;        (list (lit 15) (lit 3)))) => 12

(define (sub-operation inp)
  (sub-func (reverse-func inp)
            (double-val inp)))

;; TEST

(begin-for-test
  (check-equal? (sub-operation
  (call (op "-")
        (list (lit 15) (lit 3)))) 12))

;; reverse-func : ArithList -> ArithList
;; GIVEN: an ArithList
;; RETURNS: a revers of given ArithList
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (reverse-func
;;  (call (op "-")
;;   (list (lit 15) (lit 3)))) => (list (lit 3) (lit 15))

(define (reverse-func inp)
  (reverse (call-operands inp)))

;; TEST

(begin-for-test
  (check-equal? (reverse-func
  (call (op "-")
   (list (lit 15) (lit 3)))) (list (lit 3) (lit 15))))

;; double-val : Literal -> Literal
;; GIVEN: an Literal
;; RETURNS: doubles the value of given literal
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (sub-operation

(define (double-val inp)
  (* 2 (literal-value(first(call-operands inp)))))

;; TEST

(begin-for-test
  (check-equal? (double-val
  (call (op "-")
   (list (lit 15) (lit 3)))) 30))

;; multi-operation : ArithematichExpression -> Real
;; GIVEN: an ArithematichExpression
;; RETURNS: returns the value of the input ArithematichExpression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (multi-operation
;;  (call (op "*")
;;   (list (lit 4) (lit 5)))) 20))

(define (multi-operation inp)
  (multi-func (eval-list (call-operands inp))))

;; TEST

(begin-for-test
  (check-equal? (multi-operation
  (call (op "*")
   (list (lit 4) (lit 5)))) 20))

;; div-operation : ArithematichExpression -> Real
;; GIVEN: an ArithematichExpression
;; RETURNS: returns the value of the input ArithematichExpression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (div-operation
;;  (call (op "/")
;;   (list (lit 15) (lit 3)))) =>  5

(define (div-operation inp)
  (div-func (exp-in-list inp)
            (square-val inp)))

;; TEST

(begin-for-test
  (check-equal? (div-operation
  (call (op "/")
   (list (lit 15) (lit 3)))) 5))

;; exp-in-list : ArithList -> ArithList
;; GIVEN: an ArithList
;; RETURNS: calculates and returns the value of ArithematicExpressions
;; present in the input list in list form
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (exp-in-list
;;  (call (op "/")
;;   (list (lit 15) (lit 3))))
;;     =>           (list (lit 3) (lit 15)

(define (exp-in-list inp)
  (eval-list (reverse-func inp)))

;; TEST

(begin-for-test
  (check-equal? (exp-in-list
  (call (op "/")
   (list (lit 15) (lit 3))))
                (list (lit 3) (lit 15))))

;; square-val : ArithematicExpression -> Real
;; GIVEN: an ArithematichExpression
;; RETURNS: calculates and returns the value of ArithematicExpressions
;; present in the input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (square-val
;;  (call (op "/")
;;   (list (lit 15) (lit  3)))) => 225

(define (square-val inp)
  (sqr (literal-value(first (call-operands inp)))))

;; TEST

(begin-for-test
  (check-equal? (square-val
  (call (op "/")
   (list (lit 15) (lit  3)))) 225))

;; add-func : ArithList -> Real
;; GIVEN: an ArithList
;; RETURNS: calculates and returns the value of ArithList
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (add-func (list (lit 3) (lit 20))) => 23

(define (add-func lst)
  (cond
    [(empty? lst) 0]
    [else
     (+ (literal-value (first lst))
        (add-func (rest lst)))]))

;; TEST

(begin-for-test
  (check-equal? (add-func (list (lit 3) (lit 20))) 23))

;; sub-func : ArithList -> Real
;; GIVEN: an ArithList
;; RETURNS: calculates and returns the value of ArithList
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (sub-func (list (lit 3) (lit 15)) 30) => 12

(define (sub-func lst s)
  (cond
    [(empty? lst) s]
    [else
     (call-in-list lst s)]))

;; TEST

(begin-for-test
  (check-equal? (sub-func (list (lit 3) (lit 15)) 30) 12))

;; call-in-list : ArithList -> Real
;; GIVEN: an ArithList
;; RETURNS: checks if there is call expression in the input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (call-in-list
;;  (list   (call (op "*")
;;                (list (lit 4) (lit 5)))
;;          (lit 53))
;;  106) => 20

(define (call-in-list lst s)
  (if (call? (first lst))
      (call-value (first lst))
      (subtract-value lst s)))

;; TEST

(begin-for-test
  (check-equal? (call-in-list
  (list   (call (op "*")
                (list (lit 4) (lit 5)))
          (lit 53))
  106) 20))

;; subtract-value : ArithList DoubleVal -> Real
;; GIVEN: an ArithList and
;; DoubleVal : Real   doubled value of the first member of the input list 
;; RETURNS: calculates the value of the input expression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (subtract-value (list (lit 3) (lit 15)) 30)
;;             =>  12

(define (subtract-value lst s)
  (- (sub-func (rest lst) s)
     (literal-value (first lst))))

;; TEST

(begin-for-test
  (check-equal? (subtract-value (list (lit 3) (lit 15)) 30)
                12))

;; multi-func : ArithList -> Real
;; GIVEN: an ArithList
;; RETURNS: calculates the value of the input expression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (multi-func (list (lit 4) (lit 5)))
;;              =>  20

(define (multi-func lst)
  (cond
    [(empty? lst) 1]
    [else
     (* (literal-value (first lst))
        (multi-func (rest lst)))]))

;; TEST

(begin-for-test
  (check-equal? (multi-func (list (lit 4) (lit 5)))
                20))

;; eval-list : ArithList -> ArithList
;; GIVEN: an ArithList
;; RETURNS: calculates the value of the input expression in input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (eval-list
;;  (list
;;   (lit 3)
;;   (call (op "*")
;;    (list (lit 4) (lit 5))))) => (list (lit 3) (lit 20)

(define (eval-list lst)
  (cond
    [(empty? lst) lst]
    [else
     (traverse-in-list lst)]))

;; TEST

(begin-for-test
  (check-equal? (eval-list
  (list
   (lit 3)
   (call (op "*")
    (list (lit 4) (lit 5))))) (list (lit 3) (lit 20))))

;; traverse-in-list : ArithList -> ArithList
;; GIVEN: an ArithList
;; RETURNS: calculates the value of the input expression in input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (traverse-in-list
;;  (list
;;   (lit 3)
;;   (call (op "*")
;;    (list (lit 4) (lit 5))))) => (list (lit 3) (lit 20))

(define (traverse-in-list lst)
  (if (call? (first lst))
      (add-call-value lst)
      (node-in-list lst)))

;; TEST

(begin-for-test
  (check-equal? (traverse-in-list
  (list
   (lit 3)
   (call (op "*")
    (list (lit 4) (lit 5))))) (list (lit 3) (lit 20))))

;; add-call-value : ArithList -> ArithList
;; GIVEN: an ArithList
;; RETURNS: calculates the value of the input expression in input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (add-call-value
;;  (list
;;   (call (op "*")
;;    (list (lit 4) (lit 5))))) => (list (lit 20))

(define (add-call-value lst)
  (cons (create-literal lst)
        (eval-list (rest lst))))

;; TEST

(begin-for-test
  (check-equal? (add-call-value
  (list
   (call (op "*")
    (list (lit 4) (lit 5))))) (list (lit 20))))

;; create-literal : ArithList -> Literal
;; GIVEN: an ArithList
;; RETURNS: calculates the literal of the input call expression in input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (create-literal
;;  (list
;;   (call (op "*")
;;    (list (lit 4) (lit 5))))) => (lit 20)

(define (create-literal lst)
  (make-literalx LITERAL-EX (call-value (first lst))))

;; TEST

(begin-for-test
  (check-equal? (create-literal
  (list
   (call (op "*")
    (list (lit 4) (lit 5))))) (lit 20)))

;; node-in-list : ArithList -> Literal
;; GIVEN: an ArithList
;; RETURNS: calculates the literal of the input block expression in input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (node-in-list
;;  (list
;;   (make-ternary-node
;;    (make-leaf-node (var 5))
;;    (make-leaf-node (var 7))
;;    (make-leaf-node (lit 3)))
;;   (lit 60))) => (list (lit 3) (lit 60))

(define (node-in-list lst)
  (if (ternary-node? (first lst))
      (add-node-value lst)
      (cons (first lst) (eval-list (rest lst)))))

;; TEST

(begin-for-test
  (check-equal?
   (node-in-list
  (list
   (make-ternary-node
    (make-leaf-node (var 5))
    (make-leaf-node (var 7))
    (make-leaf-node (lit 3)))
   (lit 60))) (list (lit 3) (lit 60))))

;; add-node-value : ArithList -> Literal
;; GIVEN: an ArithList
;; RETURNS: calculates the value of the input block expression in input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (add-node-value
;;  (list
;;   (make-ternary-node
;;    (make-leaf-node (var 5))
;;    (make-leaf-node (var 7))
;;    (make-leaf-node (lit 3)))
;;   (lit 60))) => (list (lit 3) (lit 60)

(define (add-node-value lst)
  (cons (node-to-list lst)
        (eval-list (rest lst))))

;; TEST

(begin-for-test
  (check-equal? (add-node-value
  (list
   (make-ternary-node
    (make-leaf-node (var 5))
    (make-leaf-node (var 7))
    (make-leaf-node (lit 3)))
   (lit 60))) (list (lit 3) (lit 60))))

;; node-to-list : ArithList -> Literal
;; GIVEN: an ArithList
;; RETURNS: calculates the literal of the input block expression in input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (node-to-list
;;  (list
;;  (make-ternary-node
;;   (make-leaf-node (var 5))
;;    (make-leaf-node (var 7))
;;    (make-leaf-node (lit 3)))
;;   (lit 60))) => (lit 3)

(define (node-to-list lst)
  (make-literalx LITERAL-EX (eval-block (first lst))))

;; TEST

(begin-for-test
  (check-equal? (node-to-list
  (list
   (make-ternary-node
    (make-leaf-node (var 5))
    (make-leaf-node (var 7))
    (make-leaf-node (lit 3)))
   (lit 60))) (lit 3)))

;; div-func : ArithList SqrVal -> Real
;; GIVEN: an ArithList and
;; SqrVal which is the square of first value of input list
;; RETURNS: calculates the value of the expressions in input list
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (div-func (list (lit 3) (lit 15)) 225)
;;            =>    5

(define (div-func lst s)
  (cond
    [(empty? lst) s]
    [else
     (/ (/ 1 (literal-value (first lst)))
        (/ 1 (div-func (rest lst) s)))]))

;; TEST

(begin-for-test
  (check-equal? (div-func (list (lit 3) (lit 15)) 225)
                5))

;; eval-block : ArithematicExpression -> Real
;; GIVEN: an ArithematicExpression
;; RETURNS: calculates the value of the input ArithematicExpression
;; STRATEGY: Combine simpler functions
;; EXAMPLES: (eval-block
;;  (make-ternary-node
;;   (make-leaf-node (var 5))
;;   (make-leaf-node (var 7))
;;   (make-leaf-node (lit 3)))) => 3

(define (eval-block inp)
  (cond
    [(ternary-node? (eval inp))
     (constant-expression-value (eval inp))]
    [(literal? (eval inp))
     (literal-value (eval inp))]
    [(call? (eval inp))
     (call-value (eval inp))]
    [(operation? (eval inp))
     (eval inp)]))

;; TEST

(begin-for-test
  (check-equal? (eval-block
  (make-ternary-node
   (make-leaf-node (var 5))
   (make-leaf-node (var 7))
   (make-leaf-node (lit 3)))) 3))

;; eval : Block -> ArithematicExpression
;; GIVEN: an Block
;; RETURNS: fetches the value of rson of input block
;; STRATEGY: Combine simpler functions
;; EXAMPLES:

(define (eval inp)
  (leaf-node-data (ternary-node-rson inp)))

;; TEST

(begin-for-test
  (check-equal? (eval-block
  (make-ternary-node
   (make-leaf-node (var 5))
   (make-leaf-node (var 7))
   (make-leaf-node (lit 3)))) 3))