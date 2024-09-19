%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void yyerror(const char *s);
int yylex();

extern int yylineno;
extern char *yytext;

char *entity_id;
bool parsing_successful = true;

typedef struct Node {
    char *key;
    char *value;
    struct Node *next;
} Node;

Node *symbol_table = NULL;

Node *create_node(const char *key, const char *value);
bool insert_symbol(Node **head, const char *key, const char *value);
char *lookup_symbol(Node *head, const char *key);
void free_symbol_table(Node *head);
%}

%union { char *id; }

%start file
%token entity architecture signal is begin of assignmentOP end
%token <id> identifier INVALID_IDENTIFIER
%token exit_command

%type <id> signal_identifier

%%

file : entity_declaration architecture_declaration ;

entity_declaration : entity entity_identifier is end ';' ;

architecture_declaration : architecture identifier of identifier is
                           signal_declarations
                           begin
                           assignment_statements
                           end ';' {
    if (strcmp(entity_id, $4) != 0) {
        parsing_successful = false;
        printf("Line %d: \"%s\" doesn't match the declared entity name \"%s\"\n", yylineno, $4, entity_id);
    }
};

assignment_statement : identifier assignmentOP identifier ';' {
    char *lhs_type = lookup_symbol(symbol_table, $1);
    char *rhs_type = lookup_symbol(symbol_table, $3);
    
    if (!lhs_type) {
        parsing_successful = false;
        printf("Line %d: Unknown signal \"s_%s\"\n", yylineno, $1);
    } else if (!rhs_type) {
        parsing_successful = false;
        printf("Line %d: Unknown signal \"s_%s\"\n", yylineno, $3);
    } else if (strcmp(lhs_type, rhs_type) != 0) {
        parsing_successful = false;
        printf("Line %d: Signal types don't match in assignment. LHS type \"%s\", RHS type \"%s\".\n", yylineno, lhs_type, rhs_type);
    }
};

assignment_statements : assignment_statement assignment_statements | /* empty */ ;

signal_declaration : signal signal_identifier ':' signal_identifier ';' {
    if (!insert_symbol(&symbol_table, $2, $4)) {
        parsing_successful = false;
        printf("Line %d: %s is already defined\n", yylineno, $2);
    }
};

signal_declarations : signal_declaration signal_declarations | /* empty */ ;

entity_identifier : identifier { entity_id = $1; } 
                  | INVALID_IDENTIFIER {
                      entity_id = $1;
                      parsing_successful = false;
                      yyerror("Invalid identifier");
                  };

signal_identifier : identifier { $$ = $1; }
                  | INVALID_IDENTIFIER {
                      $$ = $1;
                      parsing_successful = false;
                      yyerror("Invalid identifier");
                  };

%%

Node *create_node(const char *key, const char *value) {
    Node *new_node = malloc(sizeof(Node));
    new_node->key = strdup(key);
    new_node->value = strdup(value);
    new_node->next = NULL;
    return new_node;
}

bool insert_symbol(Node **head, const char *key, const char *value) {
    if (lookup_symbol(*head, key)) {
        return false;
    }
    Node *new_node = create_node(key, value);
    new_node->next = *head;
    *head = new_node;
    return true;
}

char *lookup_symbol(Node *head, const char *key) {
    for (Node *current = head; current != NULL; current = current->next) {
        if (strcmp(current->key, key) == 0) {
            return current->value;
        }
    }
    return NULL;
}

void free_symbol_table(Node *head) {
    while (head != NULL) {
        Node *temp = head;
        head = head->next;
        free(temp->key);
        free(temp->value);
        free(temp);
    }
}

int main(void) {
    yyparse();
    if (parsing_successful) {
        printf("Parsing successful\n");
    }
    free_symbol_table(symbol_table);
    return 0;
}

void yyerror(const char *s) {
    printf("Line %d: %s %s\n", yylineno, s, yytext);
}
