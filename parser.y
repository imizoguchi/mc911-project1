%{
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>

extern FILE * yyin;

void yyerror(const char* errmsg);
int yywrap(void);
int yylex();

char *concat(int count, ...);
char *treat_special_characters(char *);
int streq(char *str1, char *str2);
int executeCommand(char *cmd, char *arg, char *opt_arg);

char *buf_title = "";
char *buf_author = "";
char buffer[256];
char *reference[50];
int refIt = 0;
int refCount = 0;
int state;

%}

%union{
	char *str;
	int intval;
}

%token <intval> T_DIGIT
%token <str> T_STRING
%token <str> T_ANY
%token <str> T_PARAGRAPH
%token <str> T_NEWLINE
%token <str> T_DOCUMENTCLASS
%token <str> T_USEPACKAGE
%token <str> T_TITLE
%token <str> T_AUTHOR
%token <str> T_BEGIN
%token <str> T_END
%token <str> T_MAKETITLE
%token <str> T_BOLD
%token <str> T_ITALIC
%token <str> T_INCLUDEGRAPHICS
%token <str> T_CITE
%token <str> T_BIBITEM
%token <str> T_ITEM
%token <str> T_ESC

%type <str> cmd
%type <str> text
%type <str> subtext

%%

stmt_list:	stmt
		| 	stmt_list stmt

stmt:	cmd
	| subtext {
			if(state == 1)
				printf("%s", $1);
		}
	| T_PARAGRAPH {
			if(state == 1) {
					printf("<p>");
				}
		}

cmd:	T_DOCUMENTCLASS '[' text ']' '{' text '}'
	|	T_DOCUMENTCLASS '{' text '}'
	|	T_USEPACKAGE '[' text ']' '{' text '}'
	|	T_USEPACKAGE '{' text '}'
	|	T_TITLE '{' text '}'
			{
				if(state == 0) {
					buf_title = strdup($3);
				} else {
					printf("<title>%s</title>\n", $3);
				}
			}
	|	T_AUTHOR '{' text '}'
			{
				if(state == 0) {
					buf_author = strdup($3);
				}
			}
	|	T_BEGIN '{' text '}'
			{
				if(state == 1) {
					if(streq($3,"itemize")) {
						printf("<ul>\n");
					} else if(streq($3,"thebibliography")) {
						printf("<h2>Bibliografia</h2><ul>\n");
					}
				}
			}
	|	T_END '{' text '}'
			{
				if(state == 1) {
					if(streq($3,"itemize")) {
						printf("</ul>\n");
					}  else if(streq($3,"thebibliography")) {
						printf("</ul>\n");
					}
				}
			}
	|	T_MAKETITLE
			{
				if(state == 1) {
					printf("<h1>%s</h1><h2>%s</h2>\n", buf_title, buf_author);
				}
			}
	|	T_BOLD '{' text '}'
			{
				if(state == 1) {
					printf("<b>%s</b>", $3);
				}
			}
	|	T_ITALIC '{' text '}'
			{
				if(state == 1) {
					printf("<i>%s</i>", $3);
				}
			}
	|	T_INCLUDEGRAPHICS '{' text '}'
			{
				if(state == 1) {
					printf("<img src=\"%s\" />", $3);
				}
			}
	|	T_CITE '{' text '}'
			{
				if(state == 1) {
					for(int i = 0; i < refCount; i++)
						if(streq(reference[i], $3)) {
							printf("[%d]", i);
							break;
						}
				}
			}
	|	T_BIBITEM '{' text '}'
			{
				if(state == 0) {
					reference[refCount] = strdup($3);
					refCount++;
				} else {
					printf("<li style=\"display:block\">[%d] ", refIt);
					refIt++;
				}
			}
	|	T_ITEM '[' text ']' {
				if(state == 1) {
					printf("<li style=\"display:block\"><b>%s</b>", $3);
				}
			}
	|	T_ITEM {
				if(state == 1) {
					printf("<li>");
				}
			}
text:	subtext	{
				$$ = $1;
			}
		| text subtext	{
				$$ = concat(2,$1, $2);
			}
subtext:	T_STRING {
				$$ = $1;
			}
		|	T_ANY {
				$$ = $1;
			}
		|	T_DIGIT {
				$$ = "Number";
			}
		|	T_ESC {
				$$ = (char*)malloc(sizeof(char)*2);
				$$[0] = $1[1];
				$$[1] = '\0';
		}
		|	T_NEWLINE {
				$$ = " ";
		}
%%

void yyerror(const char* errmsg)
{
	printf("***Error: %s\n", errmsg);
}

int yywrap(void){
	return 1;
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

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	state = 0;
	yyparse();

	freopen(argv[2], "w", stdout);
	yyin = fopen(argv[1], "r");

	state = 1;

	// Header
	printf("<html><head><meta charset=\"UTF-8\"><script type=\"text/javascript\" src=\"https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML\"></script><script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js\"></script></head><body>");
	
	yyparse();
	
	// Footer
	printf("<script type=\"text/x-mathjax-config\">MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script></body></html>");

	return 0;
}