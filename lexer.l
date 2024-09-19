%{
#include "y.tab.h"
void yyerror (char *s);
int yylex();
%}

%%
(?i:entity|architecture|signal|is|of|begin|end)  { return yytext[0]; }
"<="                       { return assignmentOP; }
"exit"                     { return exit_command; }

[a-zA-Z_][a-zA-Z0-9]+      { yylval.id = strdup(yytext); return identifier; }

\n                         { yylineno++; }
[ \t\r]+                   { /* ignore whitespace */ }
[:=;]                      { return yytext[0]; }
[^a-zA-Z_ \t\n][a-zA-Z0-9]* { yylval.id = strdup(yytext); return INVALID_IDENTIFIER; }

%%
int yywrap(void) { return 1; }
