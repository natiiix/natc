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
%token<str_val> INCLUDE_NAME

%token L_ROUND R_ROUND L_CURLY R_CURLY L_SQUARE R_SQUARE L_ANGLE R_ANGLE
%token T_INT
%token KW_RETURN
%token HASH_INCLUDE
%token PLUS MINUS ASTERISK SLASH MODULO
%token SEMICOLON COMMA

%type<str_val> code_parts top_level_statement include func_def id_def type func_def_params func_def_params_inner statement_block statements atomic_statement func_call func_call_args func_call_args_inner expression

%start full_source_code

%%

full_source_code
    : code_parts { printf("%s", $1); }
    ;

code_parts
    : top_level_statement { $$ = $1; }
    | top_level_statement code_parts { $$ = strformat("%s%s", $1, $2); }
    ;

top_level_statement
    : func_def { $$ = $1; }
    | include { $$ = $1; }
    ;

include
    : HASH_INCLUDE LIT_STRING { $$ = strformat("#include %s\n", $2); }
    | HASH_INCLUDE INCLUDE_NAME { $$ = strformat("#include %s\n", $2); }

func_def
    : id_def func_def_params statement_block { $$ = strformat("%s%s%s\n", $1, $2, $3); }
    ;

id_def
    : type IDENTIFIER { $$ = strformat("%s %s", $1, $2); }
    ;

type
    : T_INT { $$ = strdup("int"); }
    ;

func_def_params
    : L_ROUND R_ROUND { $$ = strdup("(void)"); }
    | L_ROUND func_def_params_inner R_ROUND { $$ = strformat("(%s)", $2); }
    ;

func_def_params_inner
    : id_def { $$ = $1; }
    | id_def COMMA func_def_params_inner { $$ = strformat("%s,%s", $1, $3); }
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
    | func_call { $$ = $1; }
    ;

func_call
    : IDENTIFIER func_call_args SEMICOLON { $$ = strformat("%s%s;", $1, $2); }
    ;

func_call_args
    : L_ROUND R_ROUND { $$ = strdup("()"); }
    | L_ROUND func_call_args_inner R_ROUND { $$ = strformat("(%s)", $2); }
    ;

func_call_args_inner
    : expression { $$ = $1; }
    | expression COMMA func_call_args_inner { $$ = strformat("%s,%s", $1, $3); }
    ;

expression
    : LIT_INT { $$ = strformat("%d", $1); }
    | LIT_STRING { $$ = $1; }
    ;

%%

extern int row;
extern int column;

void yyparse_loop(void)
{
	do
	{
		yyparse();
	}
	while(!feof(yyin));
}

int main(const int argc, const char** const argv)
{
    if (argc == 1)
    {
        // printf("STDIN\n");
	    yyin = stdin;
        yyparse_loop();
    }
    else
    {
        for (int i = 1; i < argc; i++)
        {
            // printf("FILE: %s\n", argv[i]);
            yyin = fopen(argv[i], "r");
            yyparse_loop();
        }
    }

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
