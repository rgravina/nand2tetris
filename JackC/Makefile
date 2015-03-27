all: run
build:
	@gcc -std=c11 -Wall jack.c asm_parser.c code.c symbol.c -o jack
run: build
	@./jack $(file)
clean:
	rm jack
