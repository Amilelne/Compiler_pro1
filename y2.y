
/* This is a simpled gcc grammar */
/* Copyright (C) 1987 Free Software Foundation, Inc. */
/* BISON parser for a simplied C by Jenq-kuen Lee  Sep 20, 1993    */

%{
#include <stdio.h>
#include <stdlib.h>
#include "code.h"
extern int lineno;
extern FILE *f_asm;
int    errcnt=0;
int    errline=0;
int    sym_index=0;
%}

%start program
%union { 
         int       token ;
         char      charv ;
         char      *ident;
       }
/* all identifiers   that are not reserved words
   and are not declared typedefs in the current block */
%token IDENTIFIER INTEGER FLOAT

/* reserved words that specify storage class.
   yylval contains an IDENTIFIER_NODE which indicates which one.  */
%token SCSPEC

/* reserved words that specify type.
   yylval contains an IDENTIFIER_NODE which indicates which one.  */
%token ENUM STRUCT UNION
%token<ident> TYPESPEC
/* reserved words that modify type: "const" or "volatile".
   yylval contains an IDENTIFIER_NODE which indicates which one.  */
%token TYPEMOD

%token CONSTANT

/* String constants in raw form.
   yylval is a STRING_CST node.  */
%token STRING


/* the reserved words */
%token SIZEOF  IF ELSE WHILE DO FOR SWITCH CASE DEFAULT_TOKEN
%token BREAK CONTINUE RETURN GOTO ASM

%type <ident> notype_declarator IDENTIFIER primary expr_no_commas

%type <token> CONSTANT

/* Define the operator tokens and their precedences.
   The value is an integer because, if used, it is the tree code
   to use in the expression made from the operator.  */
%left  <charv> ';'
%left IDENTIFIER  SCSPEC TYPESPEC TYPEMOD
%left  <charv> ','
%right <charv> '='
%right <token> ASSIGN 
%right <charv> '?' ':'
%left <charv> OROR
%left <charv> ANDAND
%left <charv> '|'
%left <charv> '^'
%left <charv> '&'
%left <token> EQCOMPARE
%left <token> NOTLESS NOTMORE  '>' '<' NOTEQUAL 
%left <charv> LSHIFT RSHIFT
%left <charv> '+' '-'
%left <token> '*' '/' '%'
%left HYPERUNARY 
%left <token> POINTSAT '.'
%nonassoc LOWER
%nonassoc ELSE
%right '!'
%right <token> UNARY PLUSPLUS MINUSMINUS 


%{
/* external function is defined here */
void error();
int TRACEON = 0;
%}     


%%

program: /* empty */
          { if (TRACEON) printf("1\n ");}
	| extdefs
          { if (TRACEON) printf("2\n ");}
	;

extdefs:
          extdef
          { if (TRACEON) printf("3\n ");}
	| extdefs  extdef
          { if (TRACEON) printf("4\n ");}
	;

extdef:
	 TYPESPEC notype_declarator ';'
	  { if (TRACEON) printf("7 ");
            set_global_vars($2);
          }
        | TYPESPEC notype_declarator '{' xdecls stmts '}'
          	  { if (TRACEON) printf("10 ");
                }
        | error ';'
	  { if (TRACEON) printf("12 "); }
	| ';'
	  { if (TRACEON) printf("13 "); }
	;

/* Must appear precede expr for resolve precedence problem */
/* A nonempty list of identifiers.  */

/* modified */
expr_no_commas:
	primary
           { if (TRACEON) printf("15 ") ;
 	     $$= $1;
           }
	| expr_no_commas '+' expr_no_commas
		{ 
                  if (TRACEON) printf("16 ") ; 
                  fprintf(f_asm,"        lwi $r1,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        add $r0,$r0,$r1\n");
		  fprintf(f_asm,"        swi $r0,[$sp]\n");
		  $$= NULL;
                }
        | expr_no_commas '-' expr_no_commas
                {
                  if (TRACEON) printf("16.5 ") ;
                  fprintf(f_asm,"        lwi $r1,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        sub $r0,$r0,$r1\n");
		  fprintf(f_asm,"        swi $r0,[$sp]\n");
                  $$= NULL;
                }

	| expr_no_commas '=' expr_no_commas
		{ char *s;
		  if (TRACEON) printf("17 ") ;
		  s= $1;
		  if (!s) err("improper expression at LHS");
		  sym_index = look_up_symbol(s);
		  fprintf(f_asm,"        lwi $r0,[$sp]\n");
		  fprintf(f_asm,"        swi $r0,[$r5+%d]\n",sym_index*4);
		  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                }
	| expr_no_commas '*' expr_no_commas
		{ if (TRACEON) printf("18 ") ;
		  fprintf(f_asm,"        lwi $r1,[$sp]\n");
		  fprintf(f_asm,"        addi $sp,$sp,-4\n");
		  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        mul $r0,$r0,$r1\n");
		  fprintf(f_asm,"        swi $r0,[$sp]\n");
		  $$= NULL;
                }
        | expr_no_commas '/' expr_no_commas
                { if (TRACEON) printf("18.5 ") ;
                  fprintf(f_asm,"        lwi $r1,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        divsr $r0,$r1,$r0,$r1\n");
		  fprintf(f_asm,"        swi $r0,[$sp]\n");
                  $$= NULL;
                }

	| expr_no_commas NOTEQUAL expr_no_commas
		{
		  fprintf(f_asm,"        lwi $r1,[$sp]\n");
		  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        beq $r0,$r1,.L3\n");

		}
	| expr_no_commas '<' expr_no_commas
		{ if (TRACEON) printf("19 ") ; 
		  fprintf(f_asm,"        lwi $r1,[$sp]\n");
		  fprintf(f_asm,"        addi $sp,$sp,-4\n");
		  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
		  fprintf(f_asm,"        slt $ta,$r0,$r1\n");
		  fprintf(f_asm,"        beqz $ta,.L3\n");
		}
	| expr_no_commas '>' expr_no_commas
		{
                  fprintf(f_asm,"        lwi $r1,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
		  fprintf(f_asm,"        slts $r0,$r1,$r0\n");
                  fprintf(f_asm,"        beqz $r0,.L3\n");
		}
	| expr_no_commas NOTLESS expr_no_commas
		{
                  fprintf(f_asm,"        lwi $r1,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
	  	  fprintf(f_asm,"        sub $r0,$r1,$r0\n");
                  fprintf(f_asm,"        bgtz $r0,.L3\n");
		}
	| expr_no_commas NOTMORE expr_no_commas
		{
                  fprintf(f_asm,"        lwi $r1,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
                  fprintf(f_asm,"        lwi $r0,[$sp]\n");
                  fprintf(f_asm,"        addi $sp,$sp,-4\n");
		  fprintf(f_asm,"        sub $r0,$r0,$r1\n");
		  fprintf(f_asm,"        bgtz $r0,.L3\n");
		}
	;


/* modified */
primary:
        IDENTIFIER
  	{    	  
                  if (TRACEON) printf("20 ") ;
		  sym_index =look_up_symbol($1);
		  printf("$1=%s\n",$1);
		  fprintf(f_asm,"        lwi $r0, [$r5+(%d)]\n",sym_index*4);
		  fprintf(f_asm,"        addi $sp,$sp,4\n");
		  fprintf(f_asm,"        swi $r0,[$sp]\n");
		  $$=$1;
         }
	| CONSTANT
                { if (TRACEON) printf("21 ") ;
		  fprintf(f_asm,"        movi  $r0, %d\n",$1);
		  fprintf(f_asm,"        addi $sp,$sp,4\n");
		  fprintf(f_asm,"        swi $r0,[$sp]\n");
                }
	| STRING
		{ 
		  if (TRACEON) printf("22 ") ;
                }
	| primary PLUSPLUS  %prec PLUSPLUS
		{ 
		  if (TRACEON) printf("23 ") ;
                }
	| primary MINUSMINUS %prec MINUSMINUS
		{
		}
	| '(' expr_no_commas ')'
		{
		}
	| '!'  primary
		{
				if(TRACEON) printf("23.5 ");
				fprintf(f_asm,"        lwi $r0,[$sp]\n");
				fprintf(f_asm,"        addi $sp,$sp,-4\n");
				fprintf(f_asm,"        bnez $r0,.L3\n");
		}
        ;

notype_declarator:
	  notype_declarator '(' parmlist ')'  %prec '.'
		{   if (TRACEON) printf("24 ") ;
		    $$=$1;
                }                  
        | IDENTIFIER
		{   if (TRACEON) printf("25 ") ;
                    install_symbol($1);
		    sym_index = look_up_symbol($1);
                }                  
	;

/* This is what appears inside the parens in a function declarator.
   Is value is represented in the format that grokdeclarator expects.  */
parmlist:  /* empty */
               { if (TRACEON) printf("26 ") ; }
		
	| parms
  		{ if (TRACEON) printf("27 ") ;  }
		
	;

/* A nonempty list of parameter declarations or type names.  */
parms:	
	parm
  		{ if (TRACEON) printf("28 ") ;  }
	| parms ',' parm
  		{ if (TRACEON) printf("29 ") ;  }
	;

parm:
	  TYPESPEC notype_declarator
  		{ if (TRACEON) printf("30 ") ;  }
	| notype_declarator
		{ if (TRACEON) printf("30.5 ") ; }
   ;


/* at least one statement, the first of which parses without error.  */
/* stmts is used only after decls, so an invalid first statement
   is actually regarded as an invalid decl and part of the decls.  */

stmts:
	stmt
               { if (TRACEON) printf("31 ") ;  }
	| stmts stmt
               { if (TRACEON) printf("32 ") ;  }
	;


/* modified */
stmt:
	 expr_no_commas ';'
	{
	/*
	  fprintf(f_asm,"                pop  cx\n");
	  fprintf(f_asm,"           ;\n");*/
        }
	| func ';'
	{

	}
	| if_stmt
		{
		}
	| while_stmt
		{
		}
	| RETURN CONSTANT ';'
	  {
	  }
	;
func: IDENTIFIER '(' para_list ')'
	{
		fprintf(f_asm,"        bal %s\n",$1);
	}
	;
para_list_ele:
	  IDENTIFIER
	   {
		sym_index = look_up_symbol($1);
		if(sym_index!=-1)
			fprintf(f_asm,"        lwi $r0,[$r5+(%d)]\n",sym_index*4);
                else if(!strcmp($1,"HIGH"))
		{
			fprintf(f_asm,"        movi $r1,1\n");
		}
		else if(!strcmp($1,"LOW"))
		{
			fprintf(f_asm,"        movi $r1,0\n");
		}
	   }
	| CONSTANT
	  {
		fprintf(f_asm,"        movi $r0,%d\n",$1);
	  }
	;
para_list: para_list_ele
	   {
	   }
	| para_list ',' para_list_ele
	  {
	  }
	;
if_stmt: IF if_part  %prec LOWER
	  {
			if(TRACEON) printf("107 ");
			fprintf(f_asm,"        .L4: \n");
	  }
	|IF if_part  ELSE '{' xdecls stmts '}' %prec ELSE
	  {
			if(TRACEON) printf("108 ");
			fprintf(f_asm,"        .L4: \n");
	  }
	;
if_part:'(' expr_no_commas ')' '{' xdecls stmts '}'
		{
			if(TRACEON) printf("109 ");
			fprintf(f_asm,"        jal .L4\n");
			fprintf(f_asm,"        .L3: \n");
		}
	;
while_stmt:while_key '(' expr_no_commas ')' '{' xdecls stmts '}'
		{
			fprintf(f_asm,"        jal .L2\n");
			fprintf(f_asm,"        .L3: \n");
		}
	;
while_key:WHILE
		{
			fprintf(f_asm,"        .L2: \n");
		}
xdecls:
	/* empty */
           { if (TRACEON) printf("102 ") ; }
	| decls
           { if (TRACEON) printf("103 ") ; }
	;

decls:
	decl
           { if (TRACEON) printf("104 ") ;
           }
	| decls decl
           { if (TRACEON) printf("106 ") ;
           }
	;

decl:	 TYPESPEC notype_declarator ';'
            { if (TRACEON) printf("110 ") ;
		install_symbol($2);
		}
	|TYPESPEC notype_declarator '=' CONSTANT ';'
	    { if (TRACEON) printf("111 ");
		printf("$2=%s\n",$2);
	      fprintf(f_asm,"        movi $r0,%d\n",$4);
	      fprintf(f_asm,"        swi  $r0,[$r5+%d]\n",sym_index*4);
	      
	    }

%%


/*
 *	  s - the error message to be printed
 */
void 
yyerror(s)
	char   *s;
{
	err(s);
}


err(s)
char   *s;
{
	if (! errcnt++)
		errline = lineno;
         fprintf(stderr,"Error on line %d \n",lineno+1);
	
	exit(1);
}




