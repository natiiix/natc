%option noyywrap

%{

#define YY_DECL int yylex()

#include "natc.tab.h"

int row = 0;
int column = 0;

void count(void);

%}

%%

[ \t\r\n]	            { count(); }
[0-9]+		            { count(); yylval.int_val = atoi(yytext); return LIT_INT; }
"("		                { count(); return L_ROUND; }
")"		                { count(); return R_ROUND; }
"{"		                { count(); return L_CURLY; }
"}"		                { count(); return R_CURLY; }
";"                     { count(); return SEMICOLON; }
"int"                   { count(); return T_INT; }
"return"		        { count(); return KW_RETURN; }
[a-zA-Z_][a-zA-Z0-9_]*  { count(); yylval.str_val = strdup(yytext); return IDENTIFIER; }
.                       { fprintf(stderr, "Unexpected character: \'%s\' at line %i column %i\n", yytext, row + 1, column + 1); exit(-1); }

%%

void count(void)
{
    // printf("[%s]\n", yytext);

	for (int i = 0; yytext[i] != '\0'; i++)
    {
        if (yytext[i] == '\n')
        {
			column = 0;
            row++;
        }
		else
        {
			column++;
        }
    }
}
