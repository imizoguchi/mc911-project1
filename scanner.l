%{
#include "parser.h" 
%}

WHITESPACE [\s]+
PARAGRAPH "\n"[\s\t]*"\n"+
STRING [a-zA-Z0-9]+
DIGIT  [0-9]+
DOCUMENTCLASS "\\documentclass"
USEPACKAGE "\\usepackage"
TITLE "\\title"	
AUTHOR "\\author"
BEGIN "\\begin"
END "\\end"
MAKETITLE "\\maketitle"
BOLD "\\textbf"
ITALIC "\\textit"
INCLUDEGRAPHICS "\\includegraphics"
CITE "\\cite"
BIBITEM "\\bibitem"
ITEM "\\item"
ESC "\\"[&%$#_{}]
ANY_CHAR .
%%

{PARAGRAPH}	{
			return T_PARAGRAPH;
		}
{DOCUMENTCLASS} { 	yylval.str = (char*) strdup(yytext);
		return T_DOCUMENTCLASS;
	}
{USEPACKAGE}	{ 	yylval.str = (char*) strdup(yytext);
		return T_USEPACKAGE;
	}
{TITLE}		{ 	yylval.str = (char*) strdup(yytext);
		return T_TITLE;
	}
{AUTHOR}	{ 	yylval.str = (char*) strdup(yytext);
		return T_AUTHOR;
	}
{BEGIN}	{ 	yylval.str = (char*) strdup(yytext);
		return T_BEGIN;
	}
{END}	{ 	yylval.str = (char*) strdup(yytext);
		return T_END;
	}
{MAKETITLE}	{ 	yylval.str = (char*) strdup(yytext);
		return T_MAKETITLE;
	}
{BOLD}	{ 	yylval.str = (char*) strdup(yytext);
		return T_BOLD;
	}
{ITALIC}	{ 	yylval.str = (char*) strdup(yytext);
		return T_ITALIC;
	}
{INCLUDEGRAPHICS}	{ 	yylval.str = (char*) strdup(yytext);
		return T_INCLUDEGRAPHICS;
	}
{CITE}	{ 	yylval.str = (char*) strdup(yytext);
		return T_CITE;
	}
{BIBITEM}	{ 	yylval.str = (char*) strdup(yytext);
		return T_BIBITEM;
	}
{ITEM}	{ 	yylval.str = (char*) strdup(yytext);
		return T_ITEM;
	}
{DIGIT}		{
			yylval.intval = strtol(yytext, NULL,10);
			return T_DIGIT;
		}
{STRING}	{
			yylval.str = (char*) strdup(yytext);
			return T_STRING;
		}

{ESC}	{
		yylval.str = (char*) strdup(yytext);
		return T_ESC;}
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


