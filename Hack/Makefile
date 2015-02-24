all: run
build:
	xcrun --sdk macosx swiftc main.swift -o hack
run:
	xcrun --sdk macosx swift main.swift $(file)
clean:
	rm hack
