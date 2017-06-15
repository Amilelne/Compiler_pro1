make:
	lex ss2.source
	yacc -vd y2.y
	cc -o codegen lex.yy.c y.tab.c code.c -ll
	
