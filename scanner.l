%{
#include "parser.h" 
%}

WHITESPACE [\s]+
NEWLINE "\n"
STRING [a-z][a-zA-Z0-9]*
DIGIT  [0-9]+
ANY_CHAR .

%%


{DIGIT}		{return T_DIGIT;}
{STRING}	{
			yylval.str = (char*) strdup(yytext);	
			return T_STRING;
		}

WHITESPACE {}
"\n" { return T_NEWLINE; }
"\\"	{return '\\';}
"{"		{return '{';}
"}"		{return '}';}
"["		{return '[';}
"]"		{return ']';}
{ANY_CHAR} {
	printf("Caracter %c (ASCII %d) inesperado.\n", yytext[0], yytext[0]);
}
	
%%

// Codigo C


