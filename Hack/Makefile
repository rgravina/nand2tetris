all: run
build:
	xcrun --sdk macosx swiftc *.swift -o hack
run:
	xcrun --sdk macosx swift *.swift $(file)
clean:
	rm hack
