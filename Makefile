CC=gcc
CFLAGS=-Wall -g

simple_parser: lex.yy.c parser.tab.c parser.tab.h
	$(CC) $(CFLAGS) -o simple_parser lex.yy.c parser.tab.c -lfl

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

clean:
	rm -f simple_parser lex.yy.c parser.tab.c parser.tab.h
