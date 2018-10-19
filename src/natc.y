%defines

%define parse.error verbose

%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* const str);

extern int row;
extern int column;

%}

%union
{
	int int_val;
    char* str_val;
}

%token<int_val> LIT_INT
%token<str_val> LIT_STRING
%token<str_val> IDENTIFIER

%token L_ROUND R_ROUND L_CURLY R_CURLY
%token T_INT
%token KW_RETURN
%token SEMICOLON

%start src_code

%%

src_code
    : func_def
    ;

func_def
    : id_def params_def statement_block
    ;

id_def
    : type IDENTIFIER
    ;

type
    : T_INT
    ;

params_def
    : L_ROUND R_ROUND
    ;

statement_block
    : L_CURLY statements R_CURLY
    ;

statements
    : atomic_statement
    | atomic_statement statements
    ;

atomic_statement
    : KW_RETURN SEMICOLON
    | KW_RETURN expression SEMICOLON
    ;

expression
    : LIT_INT
    ;

%%

int main(const int argc, const char** const argv)
{
    yyin = stdin;

    do
    {
        yyparse();
    }
    while(!feof(yyin));

    printf("OK\n");
	return 0;
}

void yyerror(const char* const str)
{
	fprintf(stderr, "Parse error at line %i column %i: %s\n", row + 1, column + 1, str);
	exit(-1);
}
