%defines

%define parse.error verbose

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* const str);

const char* strformat(const char* const format, ...);

%}

%union
{
	int int_val;
    const char* str_val;
}

%token<int_val> LIT_INT
%token<str_val> LIT_STRING
%token<str_val> IDENTIFIER

%token L_ROUND R_ROUND L_CURLY R_CURLY
%token T_INT
%token KW_RETURN
%token SEMICOLON COMMA

%type<str_val> func_def id_def type params_def params_def_inner statement_block statements atomic_statement expression

%start src_code

%%

src_code
    : func_def { printf("%s\n", $1); }
    ;

func_def
    : id_def params_def statement_block { $$ = strformat("%s%s%s", $1, $2, $3); }
    ;

id_def
    : type IDENTIFIER { $$ = strformat("%s %s", $1, $2); }
    ;

type
    : T_INT { $$ = strdup("int"); }
    ;

params_def
    : L_ROUND R_ROUND { $$ = strdup("(void)"); }
    | L_ROUND params_def_inner R_ROUND { $$ = strformat("(%s)", $2); }
    ;

params_def_inner
    : id_def { $$ = $1; }
    | id_def COMMA params_def_inner { $$ = strformat("%s,%s", $1, $3); }
    ;

statement_block
    : L_CURLY statements R_CURLY { $$ = strformat("{%s}", $2); }
    ;

statements
    : atomic_statement { $$ = $1; }
    | atomic_statement statements { $$ = strformat("%s%s", $1, $2); }
    ;

atomic_statement
    : KW_RETURN SEMICOLON { $$ = strdup("return;"); }
    | KW_RETURN expression SEMICOLON { $$ = strformat("return %s;", $2); }
    ;

expression
    : LIT_INT { $$ = strformat("%d", $1); }
    ;

%%

extern int row;
extern int column;

int main(const int argc, const char** const argv)
{
    yyin = stdin;

    do
    {
        yyparse();
    }
    while(!feof(yyin));

	return 0;
}

void yyerror(const char* const str)
{
	fprintf(stderr, "Parse error at line %i column %i: %s\n", row + 1, column + 1, str);
	exit(-1);
}

const char* strformat(const char* const format, ...)
{
    va_list args;
    va_start(args, format);

    const int len = vsnprintf(malloc(10000), 10000, format, args);
    char* const str = (char*)malloc(len + 1);

    if (str == NULL)
    {
        fprintf(stderr, "Unable to allocate memory for string\n");
        exit(-1);
    }

    va_end(args);
    va_start(args, format);

    if (vsnprintf(str, len + 1, format, args) != len)
    {
        fprintf(stderr, "Unexpected string length\n");
        exit(-1);
    }

    va_end(args);

    str[len] = '\0';
    return str;
}
