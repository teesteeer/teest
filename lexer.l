%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void yyerror(char *s);
int yylex();
%}

%%

[ \t\n]+                    { /* Ignore whitespace */ }
[Ee][Nn][Tt][Ii][Tt][Yy]   { return ENTITY; }
[Ii][Ss]                    { return IS; }
[Aa][Rr][Cc][Hh][Ii][Tt][Ee][Cc][Tt][Uu][Rr][Ee] { return ARCHITECTURE; }
[Oo][Ff]                    { return OF; }
[Ss][Ii][Gg][Nn][Aa][Ll]    { return SIGNAL; }
[Bb][Ee][Gg][Ii][Nn]        { return BEGIN_TOKEN; }
[Ee][Nn][Dd]                { return END; }
":"                         { return yytext[0]; }
";"                         { return yytext[0]; }
"<="                        { return yytext[0]; }
[a-zA-Z_][a-zA-Z0-9_]*      { yylval.str = strdup(yytext); return IDENTIFIER; }
.                           { /* Ignore any other character */ }

%%

int yywrap(void) {
    return 1;
}

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
