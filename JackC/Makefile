all: run
build:
	@gcc -std=c11 -Wall jack.c parser.c code.c symbol.c -o jack
run: build
	@./jack $(file)
clean:
	rm jack
