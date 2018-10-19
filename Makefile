PROJECT_NAME=natc

bin/$(PROJECT_NAME): tmp/$(PROJECT_NAME).tab.c tmp/$(PROJECT_NAME).tab.h tmp/lex.yy.c
	gcc -o bin/$(PROJECT_NAME) tmp/$(PROJECT_NAME).tab.c tmp/lex.yy.c

tmp/$(PROJECT_NAME).tab.c: src/$(PROJECT_NAME).y
	yacc -Wall -o tmp/$(PROJECT_NAME).tab.c src/$(PROJECT_NAME).y

tmp/lex.yy.c: src/$(PROJECT_NAME).l
	lex -o tmp/lex.yy.c src/$(PROJECT_NAME).l

clean:
	rm tmp/*
	rm bin/*
