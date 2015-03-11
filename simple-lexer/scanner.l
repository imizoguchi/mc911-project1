%{
#include "parser.h" 
%}

WHITESPACE [\s]+
LINEFEED "\n"
STRING [a-z][a-zA-Z0-9]*
DIGIT  [0-9]+
ANY_CHAR .

%%


{DIGIT}		{
			yylval.intval = strtol(yytext, NULL,10);
			return T_DIGIT;
		}
{STRING}	{
			yylval.str = (char*) strdup(yytext);
			return T_STRING;
		}

WHITESPACE {}
LINEFEED { return T_LINEFEED; }
([\n\r]|[\n])([\n\r]|[\n])+ { return T_NEWLINE; }
"\\"	{return '\\';}
"{"		{return '{';}
"}"		{return '}';}
"["		{return '[';}
"]"		{return ']';}

{ANY_CHAR} {
	yylval.str = (char*) strdup(yytext);
	return T_ANY;
}
%%

// Codigo C


