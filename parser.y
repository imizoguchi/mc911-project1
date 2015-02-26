%{
#include <stdio.h>

void yyerror(const char* errmsg);
int yywrap(void);
int yylex();

%}

%union{
	char *str;
	int intval;
}

%token <intval> T_DIGIT
%token <str> T_STRING
%token <void> T_NEWLINE
%type <str> cmd
%type <str> optional_arg
%type <str> mandatory_arg

%%

stmt_list:	stmt
		| 	stmt_list stmt


stmt: cmd 
	| T_NEWLINE
	| T_STRING
		{ printf("reduce stmt with string: %s\n", $1); }
	| T_DIGIT
		{ printf("reduce stmt with digit: %d\n", $1); }


cmd:	'\\' T_STRING optional_arg mandatory_arg
			{ printf("reduce cmd %s mand_arg: %s opt_arg: %s\n", $2, $3, $4); $$ = $2; }

	|	'\\' T_STRING mandatory_arg
		{ printf("reduce cmd %s mand_arg: %s\n", $2, $3); $$ = $2; }

optional_arg:	'[' T_STRING ']'
					{ $$ = $2; }

mandatory_arg:	'{' T_STRING '}'
					{ $$ = $2; }
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



