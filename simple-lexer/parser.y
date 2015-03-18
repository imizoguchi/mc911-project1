%{
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>

void yyerror(const char* errmsg);
int yywrap(void);
int yylex();

char *concat(int count, ...);
int streq(char *str1, char *str2);
int executeCommand(char *cmd, char *arg, char *opt_arg);

char *buf_title;
char buffer[256];

%}

%union{
	char *str;
	int intval;
}

%token <intval> T_DIGIT
%token <str> T_STRING
%token <str> T_ANY
%token <void> T_NEWLINE
%token <str> T_LINEFEED
%type <str> cmd
%type <str> optional_arg
%type <str> mandatory_arg
%type <str> anything
%type <str> text
%type <str> optional_text
%%

stmt_list:	stmt
		| 	stmt_list stmt

stmt: cmd 
	| T_NEWLINE { printf("<p>\n");}
	| text
		{ printf("%s\n", $1); }


cmd:	'\\' T_STRING optional_arg mandatory_arg
			{ $$ = $2; }

	|	'\\' T_STRING mandatory_arg
		{ executeCommand($2, $3, NULL); $$ = $2; }
	
	|	'\\' T_STRING optional_text
		{ executeCommand($2, $3, NULL); $$ = $2; }


optional_arg:	'[' text ']'
					{ $$ = $2; }

mandatory_arg:	'{' text '}'
					{ $$ = $2; }

text:
		anything { $$=$1; }
	|	anything text { $$ = concat(2,$1,$2); }

optional_text:
		text { $$=$1; }
	|	/* empty */ { $$ = ""; }

anything:	T_STRING	{ $$ = $1; }
%%

void yyerror(const char* errmsg)
{
	printf("***Error: %s\n", errmsg);
}


int yywrap(void){
	return 1;
}

int main()
{
	yyparse();
	return 0;
}

int executeCommand(char *cmd, char *arg, char *opt_arg) {

	//printf("cmd: %s arg: %s\n", cmd, arg);

	// TITLE
	if(streq(cmd,"title")) {
		printf("<title>%s</title>\n", arg);
		buf_title = strdup(arg);

	// MAKE TITLE
	} else if(streq(cmd,"maketitle")) {
		printf("<h1>%s</h1>\n", buf_title);

	// BEGIN COMMANDS
	} else if(streq(cmd,"begin")) {
		if(streq(arg,"itemize")) {
			printf("<ul>\n");
		}

	// END COMMANDS
	} else if(streq(cmd,"end")) {
		if(streq(arg,"itemize")) {
			printf("</ul>\n");
		}		

	// ITEM
	} else if(streq(cmd,"item")) {
		printf("<li>%s</li>\n", arg);

	// BOLD
	} else if(streq(cmd,"textbf")) {
		printf("<b>%s</b>\n", arg);

	// ITALIC
	} else if(streq(cmd,"textit")) {
		printf("<i>%s</i>\n", arg);

	// INCLUDE GRAPHICS
	} else if(streq(cmd,"includegraphics")) {
		printf("<img src=\"%s\" />\n", arg);

	// ---- ESCAPES -----
	// $
	} else if(streq(cmd,"$")) {
		printf("$");

	// \
	} else if(streq(cmd,"\\")) {
		printf("$");
	}


	return 0;
}

int streq(char *str1, char *str2) {
	return strcmp(str1,str2) == 0;
}

 
char* concat(int count, ...)
{
    va_list ap;
    int len = 1, i;

    va_start(ap, count);
    for(i=0 ; i<count ; i++)
        len += strlen(va_arg(ap, char*));
    va_end(ap);

    char *result = (char*) calloc(sizeof(char),len);
    int pos = 0;

    // Actually concatenate strings
    va_start(ap, count);
    for(i=0 ; i<count ; i++)
    {
        char *s = va_arg(ap, char*);
        strcpy(result+pos, s);
        pos += strlen(s);
    }
    va_end(ap);

    return result;
}