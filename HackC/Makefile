all: run
build:
	@gcc -std=c99 -Wall hack.c parser.c -o hack
run: build
	@./hack $(file)
clean:
	rm hack
