%{

#include<stdio.h>
#include<string.h>
int num_lines = 0,num_chars = 0;
char buf[100];
char str[80];
int pos=0;
int i=0;
int tmp=0;
int source=1;
int token=1;
%}
TYPES (void|string|int|char|double|const)
%x COMMENT
%%
"/*" {for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];BEGIN COMMENT;}
"#pragma"(" ")+"source"(" ")+"on"(" ")*[\n] {++num_lines;source=1;printf("%d:%s",num_lines,yytext);fprintf(yyout,"%d:%s",num_lines,yytext);}
"#pragma"(" ")+"source"(" ")+"on"(" ")*[/][/](.)*[\n] {++num_lines;source=1;printf("%d:%s",num_lines,yytext);fprintf(yyout,"%d:%s",num_lines,yytext);}
"#pragma"(" ")+"source"(" ")+"off"(" ")*[\n] {++num_lines;source=0;if(source) {printf("%d:%s",num_lines,yytext);fprintf(yyout,"%d:%s",num_lines,yytext);}}
"#pragma"(" ")+"source"(" ")+"off"(" ")*[/][/](.)*[\n] {++num_lines;source=0;if(source) {printf("%d:%s",num_lines,yytext);fprintf(yyout,"%d:%s",num_lines,yytext);}}
"#pragma"(" ")+"token"(" ")+"on"(" ")*[\n] {++num_lines;token=1;if(source) printf("%d:%s",num_lines,yytext);if(source) fprintf(yyout,"%d:%s",num_lines,yytext);}
"#pragma"(" ")+"token"(" ")+"on"(" ")*[/][/](.)*[\n] {++num_lines;token=1;if(source) printf("%d:%s",num_lines,yytext);if(source) fprintf(yyout,"%d:%s",num_lines,yytext);}
"#pragma"(" ")+"token"(" ")+"off"(" ")*[\n] {++num_lines;token=0;if(source) printf("%d:%s",num_lines,yytext);if(source) fprintf(yyout,"%d:%s",num_lines,yytext);}
"#pragma"(" ")+"token"(" ")+"off"(" ")*[/][/](.)*[\n] {++num_lines;token=0;if(source) printf("%d:%s",num_lines,yytext);if(source) fprintf(yyout,"%d:%s",num_lines,yytext);}
"#pragma"(" ")+[a-zA-Z0-9]+(" ")+("on"|"off") {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
^(#)(.)*[\n] {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
0/[0-9a-zA-Z] {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
[“] {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
[/][/][^\n]+[\n] { ++num_lines;if(source) printf("%d:%s",num_lines,yytext);if(source) fprintf(yyout,"%d:%s",num_lines,yytext);}
\n { ++num_lines ;buf[pos]='\0';if(source) printf("%d:%s\n",num_lines,buf);pos=0;if(source) fprintf(yyout,"%d:%s\n",num_lines,buf);}
[1-9][0-9]* {if(token) printf("#integer:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];if(token) fprintf(yyout,"#integer:%s\n",yytext);}
[0] {if(token) printf("#integer:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];if(token) fprintf(yyout,"#integer:%s\n",yytext);}
[0-9][.][0-9]* {  if(token) printf("#double:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];if(token) fprintf(yyout,"#double:%s\n",yytext);}
['][a-zA-Z]['] {  if(token) printf("#char:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i]; if(token) fprintf(yyout,"#char:%s\n",yytext);}
void|int|string|double|bool|char|null|for|while|do|if|else|switch|return|break|continue|const|true|false|struct|case|default|fclose|clearerr|feof|ferror|fflush|fgetpos|fopen|fread|freopen|fseek|fsetpos|ftell|fwrite|remove|rename|rewind|setbuf|setvbuf|tmpfile|tmpnam|fprintf|printf|sprintf|vfprintf|vprintf|vsprintf|fscanf|scanf|sscanf|fgetc|fgets|fputc|fputs|getc|getchar|gets|putc|putchar|puts|ungetc|perror  {if(token) printf( "#key:%s\n",yytext );for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];if(token) fprintf( yyout,"#key:%s\n",yytext );}
[+\-*/%!<>=] {if(token) printf("#op:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];if(token) fprintf(yyout,"#op:%s\n",yytext);}
"++"|"--"|"<="|">="|"=="|"!="|"&&"|"||" {if(token) printf("#op:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];if(token) fprintf(yyout,"#op:%s\n",yytext);}
":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}" {if(token) printf("#punc:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];   if(token) fprintf(yyout,"#punc:%s\n",yytext);}
[a-zA-Z_][a-zA-Z0-9_]* {if(token) printf("#id:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];if(token) fprintf(yyout,"#id:%s\n",yytext);}
=(" ")*[^0-9(" ")]+[0-9]+  {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
=(" ")*[^'(" ")]+'[^"]+' {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
=(" ")*[^"(" ")]+\"[^"]+\" {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
["][^\n]+["] {for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];for(i=0;i<yyleng;i++){if(yytext[i]!='\"') str[tmp++]=yytext[i]; }str[tmp]='\0';tmp=0;if(token) printf("#string:%s\n",str);if(token) fprintf(yyout,"#string:%s\n",str);}
{TYPES}(" ")+[^a-zA-Z0-9][a-zA-Z0-9_]*(" ")+(=)*(" ")* {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
[0-9]+[.]*[0-9]*[Ee][-+]*[0-9]+ {if(token) printf("#sci:%s\n",yytext);for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];if(token) fprintf(yyout,"#sci:%s\n",yytext);}
" " {for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];}
<COMMENT>"*/" {for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];BEGIN 0;}
<COMMENT>"/*" {for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];BEGIN COMMENT;}
<COMMENT>[^(*/|\n)]    {for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];}
<COMMENT>"*"  {for(i=0;i<yyleng;i++) buf[pos++]=yytext[i];}
<COMMENT>\n   {++num_lines;buf[pos]='\0';if(source) printf("%d:%s\n",num_lines,buf);pos=0;if(source) fprintf(yyout,"%d:%s\n",num_lines,buf);}
["][^"]*[;]   {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
[^"]+["][;]   {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
['][^']*[;]   {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
[^']+['][;]   {++num_lines;fprintf(stderr,"Error at line %d:%s\n",num_lines,yytext);exit(1);}
%%

int main(int argc,char *argv[])
{
 FILE *fp;
 fp = fopen("result.out","w+");
 yyout = fp;
 yylex();
 fclose(fp);
 return 0;
}
int yywrap() {
	return 1;
}
