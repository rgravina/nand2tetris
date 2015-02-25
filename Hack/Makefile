all: run
build:
	@xcrun --sdk macosx swiftc *.swift -o hack
run: build
	@./hack $(file)
clean:
	rm hack
