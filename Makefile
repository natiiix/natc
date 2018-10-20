PROJECT_NAME=natc
SRC_DIR=src/
BIN_DIR=bin/
TMP_DIR=tmp/
TEST_DATA_DIR=test_data/

${BIN_DIR}$(PROJECT_NAME): ${TMP_DIR}$(PROJECT_NAME).tab.c ${TMP_DIR}$(PROJECT_NAME).tab.h ${TMP_DIR}lex.yy.c
	gcc -Wall -Wextra -g -o ${BIN_DIR}$(PROJECT_NAME) ${TMP_DIR}$(PROJECT_NAME).tab.c ${TMP_DIR}lex.yy.c

${TMP_DIR}$(PROJECT_NAME).tab.c: ${SRC_DIR}$(PROJECT_NAME).y
	yacc -Wall -o ${TMP_DIR}$(PROJECT_NAME).tab.c ${SRC_DIR}$(PROJECT_NAME).y

${TMP_DIR}lex.yy.c: ${SRC_DIR}$(PROJECT_NAME).l
	lex -o ${TMP_DIR}lex.yy.c src/$(PROJECT_NAME).l

clean:
	rm ${TMP_DIR}*
	rm ${BIN_DIR}*

test: ${BIN_DIR}$(PROJECT_NAME) ${TEST_DATA_DIR}simple.c ${TEST_DATA_DIR}hello.c
	$(call run_test,simple)
	$(call run_test,hello)
	$(call run_test,args)
	@ echo \\n\>\>\> All tests passed! \<\<\<

define run_test =
	@ ${BIN_DIR}${PROJECT_NAME} < ${TEST_DATA_DIR}${1}.c 1> ${TMP_DIR}${1}.c
	@ gcc -Wall -Wextra -o ${TMP_DIR}${1} ${TMP_DIR}${1}.c
	@ echo +++ Test \"${1}\": OK +++
endef
