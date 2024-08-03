CHALLENGE=exec_shellcode

CC=gcc
FLAGS=-fno-stack-protector -z execstack

SRC=$(CHALLENGE).c
BIN=$(CHALLENGE)

$(BIN):
	@echo "Compiling..."
	$(CC) -o $@ $(SRC) $(FLAGS)
