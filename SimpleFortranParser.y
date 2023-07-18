%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

/* The integer values that correspond to the non terminal node types. */
typedef enum {PROGRAM, BODY, DECLARATIONS, DECLARATIONS_EMPTY, TYPE, VARS, UNDEF_VARIABLE_PAREN, UNDEF_VARIABLE, LISTSPEC, LISTSPEC_EMPTY, DIMS, DIM_ICONST, DIM_ID, CBLOCK_LIST, CBLOCK,
	ID_LIST_LIST, ID_LIST_ID, VALS_VALS, VALS_ID, VALUE_LIST, VALUES, VALUE, REPEAT_ICONST, REPEAT, SIGN, SIGN_EMPTY, CONSTANT, SIMPLE_CONSTANT_ICONST, SIMPLE_CONSTANT_RCONST,
	SIMPLE_CONSTANT_LCONST, SIMPLE_CONSTANT_CCONST, SIMPLE_CONSTANT_SCONST, COMPLEX_CONSTANT, STATEMENTS, LABELED_STATEMENT, LABEL, STATEMENT, SIMPLE_STATEMENT, ASSIGNMENT,
	VARIABLE_ID_PAREN, VARIABLE_LISTFUNC, VARIABLE_ID, EXPRESSIONS, EXPRESSION, LISTEXPRESSION, GOTO_STATEMENT, GOTO_STATEMENT_ID, LABELS, IF_STATEMENT, SUBROUTINE_CALL,
	IO_STATEMENT, READ_LIST, READ_ITEM, READ_ITEM_ID, ITER_SPACE, STEP, STEP_EMPTY, WRITE_LIST, WRITE_ITEM, WRITE_ITEM_ID, COMPOUND_STATEMENT, BRANCH_STATEMENT, TAIL, LOOP_STATEMENT,
	SUBPROGRAMS, SUBPROGRAMS_EMPTY, SUBPROGRAM, HEADER_LISTSPEC, HEADER_SUBROUTINE_PAREN, HEADER_SUBROUTINE_ID, FORMAL_PARAMETERS} nodeType;

/* The types of terminal symbols. */
typedef enum {INT, DOUBLE, ID} symbolType;

/* Struct that represents a terminal symbol. */			  
typedef struct symbol {
	symbolType type;
	int ival;
	double dval;
	char cval;
	char sval[100];
} symbol;

/* Struct that represents a node of the abstract syntax tree (AST). */
typedef struct astNode {
	nodeType type;
	symbol* val[2];
	struct astNode* children[4];
} astNode;

/* The root of the abstract syntax tree (AST). */
astNode* root;

/* Line counter exported from flex. */
extern int yylineno;

/* Definitions of default needed functions. */
int yyparse();
int yylex();
int yywrap(void) { return(1); }

/* Definitions of custom needed functions. */
void yyerror (const char * msg);
astNode* createNode (nodeType nodeType, symbol* s1, symbol* s2, astNode* child1, astNode* child2, astNode* child3, astNode* child4);
void printGaps(int n);
void printAST(astNode* p, int n);

%}

/* Union with the different types of the grammar's symbols (both for terminal and non terminal symbols). */
%union {
	int yint;
	double ydouble;
	char ychar;
	char ystr[100];
	struct astNode* astnode;
}

/* The integer number token that carries an integer value. */
%token<yint> T_ICONST

/* The real number token that carries a double value. */
%token<ydouble> T_RCONST

/* The character token that carries a char value. */
%token<ychar> T_CCONST

/* The string tokens that carry a string value. */
%token<ystr> T_ADDOP T_RELOP T_LISTFUNC T_ID T_LCONST T_SCONST

/* The rest of the string tokens. */
%token<ystr> T_ASSIGN T_CALL T_CHARACTER T_COLON T_COMMA T_COMMON T_COMPLEX T_CONTINUE T_DATA T_DO T_ELSE T_END T_ENDDO T_ENDIF T_FUNCTION T_GOTO T_IF T_INTEGER
%token<ystr> T_LBRACK T_LENGTH T_LIST T_LOGICAL T_LPAREN T_NEW T_RBRACK T_READ T_REAL T_RETURN T_RPAREN T_STOP T_STRING T_SUBROUTINE T_THEN
%token<ystr> T_WRITE T_OROP T_ANDOP T_NOTOP T_MULOP T_DIVOP T_POWEROP

/* The non terminal symbols of the grammar. */
%type <astnode> program, body, declarations, type, vars, undef_variable, listspec, dims, dim, cblock_list, cblock, id_list, vals, value_list, 
	values, value, repeat, sign, constant, simple_constant, complex_constant, statements, labeled_statement, label, statement, simple_statement, 
	assignment, variable, expressions, expression, listexpression, goto_statement, labels, if_statement, subroutine_call, io_statement, read_list, 
	read_item, iter_space, step, write_list, write_item, compound_statement, branch_statement, tail, loop_statement, subprograms, subprogram,
	header, formal_parameters

/* The logical operators with lower precedence that the numerical operators. Precedence is T_NOTOP > T_ANDOP > T_OROP. */ 
%left T_OROP
%left T_ANDOP
%left T_NOTOP

/* The numerical operators with higher precedence that the logical operators. */
/* Precedence is T_POWEROP > T_MULOP = T_DIVOP > T_ADDOP > T_RELOP (the comparison operators). */ 
%left T_RELOP
%left T_ADDOP
%left T_MULOP T_DIVOP
%right T_POWEROP

/* Starting symbol. */
%start program

%%

program             :  body T_END subprograms
					   {
						   root = createNode(PROGRAM, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    ;

body                :  declarations statements
					   {
						   $$ = createNode(BODY, NULL, NULL, $1, $2, NULL, NULL);
					   }
                    ;
	  
declarations        :  declarations type vars
					   {
						   $$ = createNode(DECLARATIONS, NULL, NULL, $1, $2, $3, NULL);
					   }
                    |  declarations T_COMMON cblock_list
					   {
						   $$ = createNode(DECLARATIONS, NULL, NULL, $1, $3, NULL, NULL);
					   }
			        |  declarations T_DATA vals
					   {
						   $$ = createNode(DECLARATIONS, NULL, NULL, $1, $3, NULL, NULL);
					   }
					|  declarations header
					   {
						   $$ = createNode(DECLARATIONS, NULL, NULL, $1, $2, NULL, NULL);
					   }
			        |  /*  nothing  */
					   {
						   $$ = createNode(DECLARATIONS_EMPTY, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
			        ;
			  
type                :  T_INTEGER
					   {  
						   $$ = createNode(TYPE, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					|  T_REAL
					   {
						   $$ = createNode(TYPE, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					|  T_COMPLEX
					   {
						   $$ = createNode(TYPE, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					|  T_LOGICAL
					   {
						   $$ = createNode(TYPE, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					|  T_CHARACTER
					   {
						   $$ = createNode(TYPE, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					|  T_STRING
					   {
						   $$ = createNode(TYPE, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
                    ;
	  
vars                :  vars T_COMMA undef_variable
					   {
						   $$ = createNode(VARS, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  undef_variable
					   {
						   $$ = createNode(VARS, NULL, NULL, $1, NULL, NULL, NULL);
					   }
	                ;
	 
undef_variable      :  listspec T_ID T_LPAREN dims T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $2);
						   
						   $$ = createNode(UNDEF_VARIABLE_PAREN, s1, NULL, $1, $4, NULL, NULL);
					   }
                    |  listspec T_ID
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $2);
						   
						   $$ = createNode(UNDEF_VARIABLE, s1, NULL, $1, NULL, NULL, NULL);
					   }
				    ;
				
listspec            :  T_LIST
					   {
						   $$ = createNode(LISTSPEC, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  /*  nothing  */
					   {
						   $$ = createNode(LISTSPEC_EMPTY, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
		            ;
		  
dims                :  dims T_COMMA dim
					   {
						   $$ = createNode(DIMS, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  dim
					   {
						   $$ = createNode(DIMS, NULL, NULL, $1, NULL, NULL, NULL);
					   }
	                ;
	  
dim                 :  T_ICONST
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = INT;
						   s1->ival = $1;
						   
						   $$ = createNode(DIM_ICONST, s1, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  T_ID
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(DIM_ID, s1, NULL, NULL, NULL, NULL, NULL);
					   }
	                ;
	 
cblock_list         :  cblock_list cblock
					   {
						   $$ = createNode(CBLOCK_LIST, NULL, NULL, $1, $2, NULL, NULL);
					   }
                    |  cblock
					   {
						   $$ = createNode(CBLOCK_LIST, NULL, NULL, $1, NULL, NULL, NULL);
					   }
		         	;
			 
cblock              :  T_DIVOP T_ID T_DIVOP id_list
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $2);
						   
						   $$ = createNode(CBLOCK, s1, NULL, $4, NULL, NULL, NULL);
					   }
                    ;
		
id_list             :  id_list T_COMMA T_ID
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $3);
						   
						   $$ = createNode(ID_LIST_LIST, s1, NULL, $1, NULL, NULL, NULL);
					   }
                    |  T_ID
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(ID_LIST_ID, s1, NULL, NULL, NULL, NULL, NULL);
					   }
		            ;
		 
vals                :  vals T_COMMA T_ID value_list
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $3);
						   
						   $$ = createNode(VALS_VALS, s1, NULL, $1, $4, NULL, NULL);
					   }
                    |  T_ID value_list
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(VALS_ID, s1, NULL, $2, NULL, NULL, NULL);
					   }
	                ;

value_list          :  T_DIVOP values T_DIVOP
					   {
						   $$ = createNode(VALUE_LIST, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    ;

values              :  values T_COMMA value
					   {
						   $$ = createNode(VALUES, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  value
					   {
						   $$ = createNode(VALUES, NULL, NULL, $1, NULL, NULL, NULL);
					   }
		            ;
		
value               :  repeat sign constant
					   {
						   $$ = createNode(VALUE, NULL, NULL, $1, $2, $3, NULL);
					   }
                    |  T_ADDOP constant
					   {
						   $$ = createNode(VALUE, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  constant
					   {
						   $$ = createNode(VALUE, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

repeat              :  T_ICONST T_MULOP
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = INT;
						   s1->ival = $1;
						   
						   $$ = createNode(REPEAT_ICONST, s1, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  T_MULOP
					   {
						   $$ = createNode(REPEAT, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					;

sign                :  T_ADDOP
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(SIGN, s1, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  /*  nothing  */
					   {
						   $$ = createNode(SIGN_EMPTY, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					;

constant            :  simple_constant
					   {
						   $$ = createNode(CONSTANT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  complex_constant
					   {
						   $$ = createNode(CONSTANT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

simple_constant     :  T_ICONST
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = INT;
						   s1->ival = $1;
						   
						   $$ = createNode(SIMPLE_CONSTANT_ICONST, s1, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  T_RCONST
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = DOUBLE;
						   s1->dval = $1;
						   
						   $$ = createNode(SIMPLE_CONSTANT_RCONST, s1, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  T_LCONST
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(SIMPLE_CONSTANT_LCONST, s1, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  T_CCONST
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   s1->cval = $1;
						   
						   $$ = createNode(SIMPLE_CONSTANT_CCONST, s1, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  T_SCONST
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(SIMPLE_CONSTANT_SCONST, s1, NULL, NULL, NULL, NULL, NULL);
					   }
					;

complex_constant    :  T_LPAREN T_RCONST T_COLON sign T_RCONST T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = DOUBLE;
						   s1->dval = $2;
						   
						   symbol* s2 = (symbol*) malloc(sizeof(symbol));
						   if (!s2) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s2->type = DOUBLE;
						   s2->dval = $5;
						   
						   $$ = createNode(COMPLEX_CONSTANT, s1, s2, $4, NULL, NULL, NULL);
					   }
                    ;

statements          :  statements labeled_statement
					   {
						   $$ = createNode(STATEMENTS, NULL, NULL, $1, $2, NULL, NULL);
					   }
                    |  labeled_statement
					   {
						   $$ = createNode(STATEMENTS, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;
					
labeled_statement   :  label statement
					   {
						   $$ = createNode(LABELED_STATEMENT, NULL, NULL, $1, $2, NULL, NULL);
					   }
                    |  statement
					   {
						   $$ = createNode(LABELED_STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

label               :  T_ICONST
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = INT;
						   s1->ival = $1;
						   
						   $$ = createNode(LABEL, s1, NULL, NULL, NULL, NULL, NULL);
					   }
                    ;

statement           :  simple_statement
					   {
						   $$ = createNode(STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  compound_statement
					   {
						   $$ = createNode(STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

simple_statement    :  assignment
					   {
						   $$ = createNode(SIMPLE_STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  goto_statement
					   {
						   $$ = createNode(SIMPLE_STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  if_statement
					   {
						   $$ = createNode(SIMPLE_STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  subroutine_call
					   {
						   $$ = createNode(SIMPLE_STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  io_statement
					   {
						   $$ = createNode(SIMPLE_STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  T_CONTINUE
					   {
						   $$ = createNode(SIMPLE_STATEMENT, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  T_RETURN
					   {
						   $$ = createNode(SIMPLE_STATEMENT, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
                    |  T_STOP
					   {
						   $$ = createNode(SIMPLE_STATEMENT, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					;

assignment          :  variable T_ASSIGN expression
					   {
						   $$ = createNode(ASSIGNMENT, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    ;

variable            :  T_ID T_LPAREN expressions T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(VARIABLE_ID_PAREN, s1, NULL, $3, NULL, NULL, NULL);
					   }
                    |  T_LISTFUNC T_LPAREN expression T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(VARIABLE_LISTFUNC, s1, NULL, $3, NULL, NULL, NULL);
					   }
                    |  T_ID
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $1);
						   
						   $$ = createNode(VARIABLE_ID, s1, NULL, NULL, NULL, NULL, NULL);
					   }
					;

expressions         :  expressions T_COMMA expression
					   {
						   $$ = createNode(EXPRESSIONS, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  expression
					   {
						   $$ = createNode(EXPRESSIONS, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

expression          :  expression T_OROP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  expression T_ANDOP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  expression T_RELOP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  expression T_ADDOP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  expression T_MULOP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  expression T_DIVOP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  expression T_POWEROP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  T_NOTOP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  T_ADDOP expression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  variable
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  simple_constant
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  T_LENGTH T_LPAREN expression T_RPAREN
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $3, NULL, NULL, NULL);
					   }
                    |  T_NEW T_LPAREN expression T_RPAREN
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $3, NULL, NULL, NULL);
					   }
                    |  T_LPAREN expression T_RPAREN
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  T_LPAREN expression T_COLON expression T_RPAREN
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $2, $4, NULL, NULL);
					   }
                    |  listexpression
					   {
						   $$ = createNode(EXPRESSION, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

listexpression      :  T_LBRACK expressions T_RBRACK
					   {
						   $$ = createNode(LISTEXPRESSION, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  T_LBRACK T_RBRACK
					   {
						   $$ = createNode(LISTEXPRESSION, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					;

goto_statement      :  T_GOTO label
					   {
						   $$ = createNode(GOTO_STATEMENT, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  T_GOTO T_ID T_COMMA T_LPAREN labels T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $2);
						   
						   $$ = createNode(GOTO_STATEMENT_ID, s1, NULL, $5, NULL, NULL, NULL);
					   }
					;

labels              :  labels T_COMMA label
					   {
						   $$ = createNode(LABELS, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  label
					   {
						   $$ = createNode(LABELS, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

if_statement        :  T_IF T_LPAREN expression T_RPAREN label T_COMMA label T_COMMA label
					   {
						   $$ = createNode(IF_STATEMENT, NULL, NULL, $3, $5, $7, $9);
					   }
                    |  T_IF T_LPAREN expression T_RPAREN simple_statement
					   {
						   $$ = createNode(IF_STATEMENT, NULL, NULL, $3, $5, NULL, NULL);
					   }
					;

subroutine_call     :  T_CALL variable
					   {
						   $$ = createNode(SUBROUTINE_CALL, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    ;

io_statement        :  T_READ read_list
					   {
						   $$ = createNode(IO_STATEMENT, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  T_WRITE write_list
					   {
						   $$ = createNode(IO_STATEMENT, NULL, NULL, $2, NULL, NULL, NULL);
					   }
					;

read_list           :  read_list T_COMMA read_item
					   {
						   $$ = createNode(READ_LIST, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  read_item
					   {
						   $$ = createNode(READ_LIST, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

read_item           :  variable
					   {
						   $$ = createNode(READ_ITEM, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  T_LPAREN read_list T_COMMA T_ID T_ASSIGN iter_space T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $4);
						   
						   $$ = createNode(READ_ITEM_ID, s1, NULL, $2, $6, NULL, NULL);
					   }
					;

iter_space          :  expression T_COMMA expression step
					   {
						   $$ = createNode(ITER_SPACE, NULL, NULL, $1, $3, $4, NULL);
					   }
                    ;

step                :  T_COMMA expression
					   {
						   $$ = createNode(STEP, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  /*  nothing  */
					   {
						   $$ = createNode(STEP_EMPTY, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					;

write_list          :  write_list T_COMMA write_item
					   {
						   $$ = createNode(WRITE_LIST, NULL, NULL, $1, $3, NULL, NULL);
					   }
                    |  write_item
					   {
						   $$ = createNode(WRITE_LIST, NULL, NULL, $1, NULL, NULL, NULL);
					   }
					;

write_item          :  expression
					   {
						   $$ = createNode(WRITE_ITEM, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  T_LPAREN write_list T_COMMA T_ID T_ASSIGN iter_space T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $4);
						   
						   $$ = createNode(WRITE_ITEM_ID, s1, NULL, $2, $6, NULL, NULL);
					   }
					;

compound_statement  :  branch_statement
					   {
						   $$ = createNode(COMPOUND_STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }
                    |  loop_statement
					   {
						   $$ = createNode(COMPOUND_STATEMENT, NULL, NULL, $1, NULL, NULL, NULL);
					   }

branch_statement    :  T_IF T_LPAREN expression T_RPAREN T_THEN body tail
					   {
						   $$ = createNode(BRANCH_STATEMENT, NULL, NULL, $3, $6, $7, NULL);
					   }
                    ;

tail                :  T_ELSE body T_ENDIF
					   {
						   $$ = createNode(TAIL, NULL, NULL, $2, NULL, NULL, NULL);
					   }
                    |  T_ENDIF
					   {
						   $$ = createNode(TAIL, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					;

loop_statement      :  T_DO T_ID T_ASSIGN iter_space body T_ENDDO
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $2);
						   
						   $$ = createNode(LOOP_STATEMENT, s1, NULL, $4, $5, NULL, NULL);
					   }
                    ;

subprograms         :  subprograms subprogram
					   {
						   $$ = createNode(SUBPROGRAMS, NULL, NULL, $1, $2, NULL, NULL);
					   }
                    |  /*  nothing  */
					   {
						   $$ = createNode(SUBPROGRAMS_EMPTY, NULL, NULL, NULL, NULL, NULL, NULL);
					   }
					;

subprogram          :  header body T_END
					   {
						   $$ = createNode(SUBPROGRAM, NULL, NULL, $1, $2, NULL, NULL);
					   }
                    ;

header              :  type listspec T_FUNCTION T_ID T_LPAREN formal_parameters T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $4);
						   
						   $$ = createNode(HEADER_LISTSPEC, s1, NULL, $1, $2, $6, NULL);
					   }
                    |  T_SUBROUTINE T_ID T_LPAREN formal_parameters T_RPAREN
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $2);
						   
						   $$ = createNode(HEADER_SUBROUTINE_PAREN, s1, NULL, $4, NULL, NULL, NULL);
					   }
                    |  T_SUBROUTINE T_ID
					   {
						   symbol* s1 = (symbol*) malloc(sizeof(symbol));
						   if (!s1) {
							   yyerror("out of memory");
							   exit(1);
						   }
						   s1->type = ID;
						   strcpy(s1->sval, $2);
						   
						   $$ = createNode(HEADER_SUBROUTINE_ID, s1, NULL, NULL, NULL, NULL, NULL);
					   }
					;

formal_parameters   :  type vars T_COMMA formal_parameters
					   {
						   $$ = createNode(FORMAL_PARAMETERS, NULL, NULL, $1, $2, $4, NULL);
					   }
                    |  type vars
					   {
						   $$ = createNode(FORMAL_PARAMETERS, NULL, NULL, $1, $2, NULL, NULL);
					   }
					;

%%

/* Custom yyerror function which prints an error message before exiting the program. */
void yyerror (const char * msg)
{
	fprintf(stderr, "\nSimpleFortran: %s on line %d.\n", msg, yylineno);
	exit(1);
}

/* Function which creates and returns an abstract syntax tree (AST) node. */
astNode* createNode (nodeType nodeType, symbol* s1, symbol* s2, astNode* child1, astNode* child2, astNode* child3, astNode* child4) {
	astNode* n = (astNode*) malloc(sizeof(astNode));
	
	if (!n) {
		printf("Memory error\n");
		exit(1);
	}
	
	n->type = nodeType;
	
	n->val[0] = s1;
	n->val[1] = s2;
	
	n->children[0] = child1;
	n->children[1] = child2;
	n->children[2] = child3;
	n->children[3] = child3;

	return n;
}

/* Function to print gaps when printing the abstract syntax tree (AST). */
void printGaps(int n) {
	for (int i = 0 ; i < n ; i++) {
		printf(" ");
	}
}

/* Function to traverse and print the abstract syntax tree (AST). */
void printAST(astNode* p, int n) {
	int i;
	n = n + 3;
	
	if (p) {
		printGaps(n);
		switch (p->type) {
			case PROGRAM:
				printf("PROGRAM\n");
			break;
			case BODY:
				printf("BODY\n");
			break;
			case DECLARATIONS:
				printf("DECLARATIONS\n");
			break;
			case DECLARATIONS_EMPTY:
				printf("EMPTY DECLARATIONS\n");
			break;
			case TYPE:
				printf("TYPE\n");
			break;
			case VARS:
				printf("VARS\n");
			break;
			case UNDEF_VARIABLE_PAREN:
				printf("UNDEF_VARIABLE: LISTSPEC %s (DIMS)\n", (p->val[0])->sval);
			break;
			case UNDEF_VARIABLE:
				printf("UNDEF_VARIABLE: LISTSPEC %s\n", (p->val[0])->sval);
			break;
			case LISTSPEC:
				printf("LISTSPEC\n");
			break;
			case LISTSPEC_EMPTY:
				printf("EMPTY LISTSPEC\n");
			break;
			case DIMS:
				printf("DIMS\n");
			break;
			case DIM_ICONST:
				printf("DIM: %d\n", (p->val[0])->ival);
			break;
			case DIM_ID:
				printf("DIM: %s\n", (p->val[0])->sval);
			break;
			case CBLOCK_LIST:
				printf("CBLOCK_LIST\n");
			break;
			case CBLOCK:
				printf("CBLOCK: / %s / ID_LIST\n", (p->val[0])->sval);
			break;
			case ID_LIST_LIST:
				printf("ID_LIST: ID_LIST, %s\n", (p->val[0])->sval);
			break;
			case ID_LIST_ID:
				printf("ID_LIST: %s\n", (p->val[0])->sval);
			break;
			case VALS_VALS:
				printf("VALS: VALS, %s VALUE_LIST\n", (p->val[0])->sval);
			break;
			case VALS_ID:
				printf("VALS: %s VALUE_LIST\n", (p->val[0])->sval);
			break;
			case VALUE_LIST:
				printf("VALUE_LIST\n");
			break;
			case VALUES:
				printf("VALUES\n");
			break;
			case VALUE:
				printf("VALUE\n");
			break;
			case REPEAT_ICONST:
				printf("REPEAT: %d *\n", (p->val[0])->ival);
			break;
			case REPEAT:
				printf("REPEAT\n");
			break;
			case SIGN:
				printf("SIGN: %s\n", (p->val[0])->sval);
			break;
			case SIGN_EMPTY:
				printf("EMPTY SIGN\n");
			break;
			case CONSTANT:
				printf("CONSTANT\n");
			break;
			case SIMPLE_CONSTANT_ICONST:
				printf("SIMPLE_CONSTANT: %d\n", (p->val[0])->ival);
			break;
			case SIMPLE_CONSTANT_RCONST:
				printf("SIMPLE_CONSTANT: %.15f\n", (p->val[0])->dval);
			break;
			case SIMPLE_CONSTANT_LCONST:
				printf("SIMPLE_CONSTANT: %s\n", (p->val[0])->sval);
			break;
			case SIMPLE_CONSTANT_CCONST:
				printf("SIMPLE_CONSTANT: %c\n", (p->val[0])->cval);
			break;
			case SIMPLE_CONSTANT_SCONST:
				printf("SIMPLE_CONSTANT: %s\n", (p->val[0])->sval);
			break;
			case COMPLEX_CONSTANT:
				printf("COMPLEX_CONSTANT: (%.15f: SIGN %.15f)\n", (p->val[0])->dval, (p->val[1])->dval);
			break;
			case STATEMENTS:
				printf("STATEMENTS\n");
			break;
			case LABELED_STATEMENT:
				printf("LABELED_STATEMENT\n");
			break;
			case LABEL:
				printf("LABEL: %d\n", (p->val[0])->ival);
			break;
			case STATEMENT:
				printf("STATEMENT\n");
			break;
			case SIMPLE_STATEMENT:
				printf("SIMPLE_STATEMENT\n");
			break;
			case ASSIGNMENT:
				printf("ASSIGNMENT\n");
			break;
			case VARIABLE_ID_PAREN:
				printf("VARIABLE: %s (EXPRESSIONS)\n", (p->val[0])->sval);
			break;
			case VARIABLE_LISTFUNC:
				printf("VARIABLE: %s (EXPRESSION)\n", (p->val[0])->sval);
			break;
			case VARIABLE_ID:
				printf("VARIABLE: %s\n", (p->val[0])->sval);
			break;
			case EXPRESSIONS:
				printf("EXPRESSIONS\n");
			break;
			case EXPRESSION:
				printf("EXPRESSION\n");
			break;
			case LISTEXPRESSION:
				printf("LISTEXPRESSION\n");
			break;
			case GOTO_STATEMENT:
				printf("GOTO_STATEMENT\n");
			break;
			case GOTO_STATEMENT_ID:
				printf("GOTO_STATEMENT: goto %s, (LABELS)\n", (p->val[0])->sval);
			break;
			case LABELS:
				printf("LABELS\n");
			break;
			case IF_STATEMENT:
				printf("IF_STATEMENT\n");
			break;
			case SUBROUTINE_CALL:
				printf("SUBROUTINE_CALL\n");
			break;
			case IO_STATEMENT:
				printf("IO_STATEMENT\n");
			break;
			case READ_LIST:
				printf("READ_LIST\n");
			break;
			case READ_ITEM:
				printf("READ_ITEM\n");
			break;
			case READ_ITEM_ID:
				printf("READ_ITEM: (READ_LIST, %s = ITER_SPACE)\n", (p->val[0])->sval);
			break;
			case ITER_SPACE:
				printf("ITER_SPACE\n");
			break;
			case STEP:
				printf("STEP\n");
			break;
			case STEP_EMPTY:
				printf("EMPTY STEP\n");
			break;
			case WRITE_LIST:
				printf("WRITE_LIST\n");
			break;
			case WRITE_ITEM:
				printf("WRITE_ITEM\n");
			break;
			case WRITE_ITEM_ID:
				printf("WRITE_ITEM: (WRITE_LIST, %s = ITER_SPACE)\n", (p->val[0])->sval);
			break;
			case COMPOUND_STATEMENT:
				printf("COMPOUND_STATEMENT\n");
			break;
			case BRANCH_STATEMENT:
				printf("BRANCH_STATEMENT\n");
			break;
			case TAIL:
				printf("TAIL\n");
			break;
			case LOOP_STATEMENT:
				printf("LOOP_STATEMENT: do %s = ITER_SPACE BODY enddo\n", (p->val[0])->sval);
			break;
			case SUBPROGRAMS:
				printf("SUBPROGRAMS\n");
			break;
			case SUBPROGRAMS_EMPTY:
				printf("EMPTY SUBPROGRAMS\n");
			break;
			case SUBPROGRAM:
				printf("SUBPROGRAM\n");
			break;
			case HEADER_LISTSPEC:
				printf("HEADER: TYPE LISTSPEC function %s (FORMAL_PARAMETERS)\n", (p->val[0])->sval);
			break;
			case HEADER_SUBROUTINE_PAREN:
				printf("HEADER: subroutine %s (FORMAL_PARAMETERS)\n", (p->val[0])->sval);
			break;
			case HEADER_SUBROUTINE_ID:
				printf("HEADER: subroutine %s\n", (p->val[0])->sval);
			break;
			case FORMAL_PARAMETERS:
				printf("FORMAL_PARAMETERS\n");
			break;
			default:
				printf("UNKNOWN = %d\n", p->type);
			}
		printAST(p->children[0], n);
		printAST(p->children[1], n);
		printAST(p->children[2], n);
		printAST(p->children[3], n);
	}
}

/* Main function. */
int main ()
{
	int i = yyparse();
	if (!i) {
		printf("\nSimpleFortran: compilation successful.\n");
		printf("\nSimpleFortran: the abstract syntax tree (AST) is: \n\n");
		printAST(root, -3);
	}
	return i;
}