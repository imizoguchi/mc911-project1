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

char *buf_title;
char *buf_author;
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
%token <void> T_NEWLINE
%token <void> T_WHITESPACE
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

%type <str> cmd
%type <str> text
%type <str> subtext

%%

stmt_list:	stmt
		| 	stmt_list stmt

stmt:	cmd
	| text {
			printf("%s", $1);
		}
	| T_PARAGRAPH {
			if(state == 0) {
					printf("\n\n");
				} else {
					printf("<p>");
				}
		}

cmd:	T_DOCUMENTCLASS '[' text ']' '{' text '}'
			{
				if(state == 0)
					printf("%s[%s]{%s}", $1, $3, $6);
				else
					printf("<html><head><script type=\"text/javascript\" src=\"https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML\"></script><script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js\"></script><script type=\"text/javascript\"></head><body>");

			}
	|	T_USEPACKAGE '[' text ']' '{' text '}'
			{
				if(state == 0)
					printf("%s[%s]{%s}", $1, $3, $6);
			}
	|	T_USEPACKAGE '{' text '}'
			{
				if(state == 0)
					printf("%s{%s}", $1, $3);
			}
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
				if(state == 0) {
					printf("%s{%s}", $1, $3);
				} else {
					if(streq($3,"itemize")) {
						printf("<ul>\n");
					} else if(streq($3,"thebibliography")) {
						printf("<h2>Bibliografia</h2><ul>\n");
					}
				}
			}
	|	T_END '{' text '}'
			{
				if(state == 0) {
					printf("%s{%s}", $1, $3);
				} else {
					if(streq($3,"itemize")) {
						printf("</ul>\n");
					}  else if(streq($3,"thebibliography")) {
						printf("</ul>\n");
					}
				}
			}
	|	T_MAKETITLE
			{
				if(state == 0) {
					printf("%s", $1);
				} else {
					printf("<h1>%s</h1>\n", buf_title);
				}
			}
	|	T_BOLD '{' text '}'
			{
				if(state == 0) {
					printf("%s{%s}", $1, $3);
				} else {
					printf("<b>%s</b>", $3);
				}
			}
	|	T_ITALIC '{' text '}'
			{
				if(state == 0) {
					printf("%s{%s}", $1, $3);
				} else {
					printf("<i>%s</i>", $3);
				}
			}
	|	T_INCLUDEGRAPHICS '{' text '}'
			{
				if(state == 0) {
					printf("%s{%s}", $1, $3);
				} else {
					printf("<img src=\"%s\" />", $3);
				}
			}
	|	T_CITE '{' text '}'
			{
				if(state == 0) {
					printf("%s{%s}", $1, $3);
				} else {
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
					printf("%s{%s}", $1, $3);
					reference[refCount] = strdup($3);
					refCount++;
				} else {
					printf("<li style=\"display:block\">[%d] ", refIt);
					refIt++;
				}
			}
	|	T_ITEM '[' text ']' {
				if(state == 0) {
					printf("%s[%s]", $1, $3);
				} else {
					printf("<li style=\"display:block\"><b>%s</b>", $3);
				}
			}
	|	T_ITEM {
				if(state == 0) {
					printf("%s", $1);
				} else {
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
%%

void yyerror(const char* errmsg)
{
	printf("***Error: %s\n", errmsg);
}


int yywrap(void){
	return 1;
}

char *treat_special_characters(char *str) {
	if(streq(str, "Ç")) {
		return "&Ccedil;";
	} else if(streq(str, "ç")) {
		return "&ccedil;";

	} else if(streq(str, "Á")) {
		return "&Aacute;";
	} else if(streq(str, "á")) {
		return "&aacute;";
	} else if(streq(str, "À")) {
		return "&Agrave;";
	} else if(streq(str, "à")) {
		return "&agrave;";
	} else if(streq(str, "Â")) {
		return "&Acirc;";
	} else if(streq(str, "â")) {
		return "&acirc;";
	} else if(streq(str, "Ã")) {
		return "&Atilde;";
	} else if(streq(str, "ã")) {
		return "&atilde;";

	} else if(streq(str, "É")) {
		return "&Eacute;";
	} else if(streq(str, "é")) {
		return "&eacute;";
	} else if(streq(str, "È")) {
		return "&Egrave;";
	} else if(streq(str, "è")) {
		return "&egrave;";
	} else if(streq(str, "Ê")) {
		return "&Ecirc;";
	} else if(streq(str, "ê")) {
		return "&ecirc;";

	} else if(streq(str, "Í")) {
		return "&Iacute;";
	} else if(streq(str, "í")) {
		return "&iacute;";

	} else if(streq(str, "Ó")) {
		return "&Oacute;";
	} else if(streq(str, "ó")) {
		return "&oacute;";
	} else if(streq(str, "Ò")) {
		return "&Ograve;";
	} else if(streq(str, "ò")) {
		return "&ograve;";
	} else if(streq(str, "Ô")) {
		return "&Ocirc;";
	} else if(streq(str, "ô")) {
		return "&ocirc;";
	} else if(streq(str, "Õ")) {
		return "&Otilde;";
	} else if(streq(str, "õ")) {
		return "&otilde;";

	} else if(streq(str, "Ú")) {
		return "&Uacute;";
	} else if(streq(str, "ú")) {
		return "&uacute;";
	} else if(streq(str, "Ù")) {
		return "&Ugrave;";
	} else if(streq(str, "ù")) {
		return "&ugrave;";
	}

	return str;
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
	freopen("my_stdout", "w", stdout);
	state = 0;
	yyparse();

	freopen("output.html", "w", stdout);
	yyin = fopen("my_stdout", "r");

	state = 1;
	yyparse();

	return 0;
}