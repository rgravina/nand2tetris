all: run
build:
	@gcc -std=c99 -Wall hack.c parser.c code.c -o hack
run: build
	@./hack $(file)
clean:
	rm hack
