all: run
build:
	@xcrun --sdk macosx swiftc *.swift -o jack
run: build
	@./jack $(file)
clean:
	rm jack
