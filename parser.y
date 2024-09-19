%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

extern int yylex();
extern int yylineno;
extern char* yytext;

// Symbol table
struct Symbol {
    char *name;
    char *type;
};

#define MAX_SYMBOLS 100
struct Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

void add_symbol(char *name, char *type);
int find_symbol(char *name);
%}

%union {
    char *str;
}

%token ENTITY IS ARCHITECTURE OF SIGNAL BEGIN_TOKEN END
%token <str> IDENTIFIER
%type <str> entity_decl architecture_decl signal_decl assignment

%start program

%%

program : entity_decl architecture_decl { printf("Parsing successful\n"); }
        ;

entity_decl : ENTITY IDENTIFIER IS END ';'
            { 
                add_symbol($2, "entity");
                $$ = $2;
            }
            ;

architecture_decl : ARCHITECTURE IDENTIFIER OF IDENTIFIER IS 
                    signal_decl_list
                    BEGIN_TOKEN
                    statement_list
                    END ';'
                  {
                      if (strcmp($2, $4) != 0) {
                          yyerror("Entity name in architecture doesn't match entity declaration");
                      }
                      $$ = $2;
                  }
                  ;

signal_decl_list : /* empty */
                 | signal_decl_list signal_decl
                 ;

signal_decl : SIGNAL IDENTIFIER ':' IDENTIFIER ';'
            {
                add_symbol($2, $4);
                $$ = $2;
            }
            ;

statement_list : /* empty */
               | statement_list assignment
               ;

assignment : IDENTIFIER "<=" IDENTIFIER ';'
           {
               int idx1 = find_symbol($1);
               int idx2 = find_symbol($3);
               if (idx1 == -1 || idx2 == -1) {
                   yyerror("Undefined signal in assignment");
               } else if (strcmp(symbol_table[idx1].type, symbol_table[idx2].type) != 0) {
                   yyerror("Type mismatch in assignment");
               }
               $$ = $1;
           }
           ;

%%

void add_symbol(char *name, char *type) {
    if (symbol_count >= MAX_SYMBOLS) {
        yyerror("Symbol table full");
        exit(1);
    }
    symbol_table[symbol_count].name = strdup(name);
    symbol_table[symbol_count].type = strdup(type);
    symbol_count++;
}

int find_symbol(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

int main(void) {
    yyparse();
    return 0;
}
