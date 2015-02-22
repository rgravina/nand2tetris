// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

(LOOP)
  @FILL_SCREEN
  0;JMP

(FILL_SCREEN)
  // Set i to start of memory for screen
  @SCREEN
  D=A
  @i
  M=0
  M=D+M

(FILL_SCREEN2)
  // if done the last row, jump out
  @i
  D=M
  @24576
  D=D-A
  @LOOP
  D;JEQ

  // Set pixel black
  @i
  // get the memory location stored in i
  A=M
  // set it to 1111111111111111
  M=-1

  // row++
  @i
  M=M+1
  @FILL_SCREEN2
  0;JMP

  @LOOP
  0;JMP
