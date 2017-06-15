/* define.h */

typedef struct {
   char *name;
   unsigned int value;
} KWORD;

KWORD k_tab[]= {	/* keyword table */
   {	"break", 	BREAK	},
   {	"case", 	CASE	},
   {	"char", 	TYPESPEC	},
   {	"const",	TYPEMOD	},
   {    "continue", 	CONTINUE},
   {	"default", 	DEFAULT_TOKEN	},
   {    "do",       	DO      },
   {	"double", 	TYPESPEC	},
   {	"else", 	ELSE	},
   {    "for",      	FOR     },
   {    "if",       	IF      },
   {	"int", 		TYPESPEC	},
   {	"return", 	RETURN	},
   {	"switch", 	SWITCH	},
   {	"void", 	TYPESPEC	},
   {	"while", 	WHILE	}
};   

int lineno = 0;

#define FALSE		0
#define TRUE		1

typedef struct {
   char         *lexptr;
   unsigned int token;
   union {
      int   ival;
      float fval;
      char  *sval;
   } attrib;
} sym_type;

sym_type sym_tbl[100];
int sym_tbl_index=0;

