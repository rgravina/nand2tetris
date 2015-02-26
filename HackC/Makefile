all: run
build:
	@gcc hack.c parser.c -o hack
run: build
	@./hack $(file)
clean:
	rm hack
