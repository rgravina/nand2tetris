// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

(LOOP)
  // look a keyboard and set fill if a key is pressed
  @24576
  D=M
  @SET_FILL
  // a value > 0 means a key has been pressed
  D;JGT

  // if execution gets here clear the screen
  @SET_CLEAR
  0;JMP

(AFTER_SET)
  @FILL_SCREEN
  0;JMP

(SET_FILL)
  // set to fill screen
  // 1111111111111111
  @operation
  M=-1
  @AFTER_SET
  0;JMP

(SET_CLEAR)
  // set to clear screen
  // 0000000000000000
  @operation
  M=0
  @AFTER_SET
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

  // get operation
  @operation
  D=M
  // Set pixel black
  @i
  // get the memory location stored in i
  A=M
  // set it to operation
  M=D

  // row++
  @i
  M=M+1
  @FILL_SCREEN2
  0;JMP

  @LOOP
  0;JMP
