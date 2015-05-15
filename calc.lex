%option noyywrap

%{
#include "calc.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <inttypes.h>
#include <math.h>
%}

white [ \t]+
digit [0-9]
integer {digit}+
hex [0-9A-Fa-f]+h
bin [0-1]+b
exponent [eE][+-]?{integer}
real {integer}("."{integer})?{exponent}?

%%

{white} { }
{real} { yylval=atoll(yytext);
 return NUMBER;
}
{hex} {
    int insize = strlen(yytext);
    yytext[insize-1] = '\0';
    sscanf(yytext, "%"PRIx64"", &yylval);
    return HEXNUM;
}

{bin} {
    int insize = strlen(yytext);
    yytext[insize-1] = '\0';
    int64_t decimal=0, i=0, rem, n;
    sscanf(yytext, "%"PRId64"", &n);
    while (n!=0)
    {
        rem = n%10;
        n/=10;
        decimal += rem*pow(2,i);
        ++i;
    }

    yylval = decimal;
    return NUMBER;
}

"=" return EQ;
"loop" return LOOP;
"if" return IF;
"to" return TO;
"print10" return PRINT10;
"print16" return PRINT16;

"+" return PLUS;
"-" return MINUS;
"*" return TIMES;
"/" return DIVIDE;
"(" return LEFT;
")" return RIGHT;
"\n" return END;
"%" return MOD;
"{" return CLEFT;
"}" return CRIGHT;
"$r" return REG;
"SHOW" return SHOW;
. return ERROR;

%%
