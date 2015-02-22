// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
//
// You can mutiply a number X by Y using addition by adding X+X+X...
// Y times.
//

  // counter to keep track of additions
  @i
  M=0
  // Initialise R2
  @R2
  M=0
(LOOP)
  // if (i=R1) goto END
  @i
  D=M
  @R1
  D=D-M
  @END
  D;JEQ
  // Add R0 to R2
  @R0
  D=M
  @R2
  M=D+M
  // i++
  @i
  M=M+1
  @LOOP
  0;JMP
(END)
  @END
  0;JMP
