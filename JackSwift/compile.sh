make file=../11/Square/
mv ../11/Square/Main.vm ../11/Square/Main2.vm
mv ../11/Square/Square.vm ../11/Square/Square2.vm
mv ../11/Square/SquareGame.vm ../11/Square/SquareGame2.vm
JackCompiler.sh ../11/Square/
diff -wu ../11/Square/Main2.vm ../11/Square/Main.vm
diff -wu ../11/Square/Square2.vm ../11/Square/Square.vm
diff -wu ../11/Square/SquareGame2.vm ../11/Square/SquareGame.vm

make file=../11/ConvertToBin/
mv ../11/ConvertToBin/Main.vm ../11/ConvertToBin/Main2.vm
JackCompiler.sh ../11/ConvertToBin/
diff -wu ../11/ConvertToBin/Main2.vm ../11/ConvertToBin/Main.vm

make file=../11/Seven/
mv ../11/Seven/Main.vm ../11/Seven/Main2.vm
JackCompiler.sh ../11/Seven/
diff -wu ../11/Seven/Main2.vm ../11/Seven/Main.vm

make file=../11/Average/
mv ../11/Average/Main.vm ../11/Average/Main2.vm
JackCompiler.sh ../11/Average/
diff -wu ../11/Average/Main2.vm ../11/Average/Main.vm

make file=../11/ComplexArrays/
mv ../11/ComplexArrays/Main.vm ../11/ComplexArrays/Main2.vm
JackCompiler.sh ../11/ComplexArrays/
diff -wu ../11/ComplexArrays/Main2.vm ../11/ComplexArrays/Main.vm

make file=../11/Pong/
mv ../11/Pong/Main.vm ../11/Pong/Main2.vm
mv ../11/Pong/Ball.vm ../11/Pong/Ball2.vm
mv ../11/Pong/Bat.vm ../11/Pong/Bat2.vm
mv ../11/Pong/PongGame.vm ../11/Pong/PongGame2.vm
JackCompiler.sh ../11/Pong/
diff -wu ../11/Pong/Main2.vm ../11/Pong/Main.vm
diff -wu ../11/Pong/Ball2.vm ../11/Pong/Ball.vm
diff -wu ../11/Pong/Bat2.vm ../11/Pong/Bat.vm
diff -wu ../11/Pong/PongGame2.vm ../11/Pong/PongGame.vm
