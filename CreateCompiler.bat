yacc -dv SimpleFortranParser.y
flex SimpleFortranLexer.l
gcc lex.yy.c y.tab.c -o SimpleFortranCompiler