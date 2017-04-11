make:
	lex scanner.l;gcc -o scanner lex.yy.c -lfl;

