%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <math.h>

#include "y.tab.h"

#define T_EOF 0

int yylex();
double getDouble(char* original);
char getCharacter(char* original);
char* getString(char* original);

%}

%option case-insensitive
%option yylineno

%% 

"="          { return T_ASSIGN; }

"CALL"       { return T_CALL; }

"CHARACTER"  { return T_CHARACTER; }

":"          { return T_COLON; }

","          { return T_COMMA; }

"COMMON"     { return T_COMMON; }

"COMPLEX"    { return T_COMPLEX; }

"CONTINUE"   { return T_CONTINUE; }

"DATA"       { return T_DATA; }

"DO"         { return T_DO; }

"ELSE"       { return T_ELSE; }

"END"        { return T_END; }

"ENDDO"      { return T_ENDDO; }

"ENDIF"      { return T_ENDIF; }

"FUNCTION"   { return T_FUNCTION; }
 
"GOTO"       { return T_GOTO; }

"IF"         { return T_IF; }

"INTEGER"    { return T_INTEGER; }

"["          { return T_LBRACK; }

"LENGTH"     { return T_LENGTH; }

"LIST"       { return T_LIST; }

"LOGICAL"    { return T_LOGICAL; }

"("          { return T_LPAREN; }

"NEW"        { return T_NEW; }

"]"          { return T_RBRACK; }

"READ"       { return T_READ; }

"REAL"       { return T_REAL; }

"RETURN"     { return T_RETURN; }

")"          { return T_RPAREN; }

"STOP"       { return T_STOP; }

"STRING"     { return T_STRING; }

"SUBROUTINE" { return T_SUBROUTINE; }

"THEN"       { return T_THEN; }

"WRITE"      { return T_WRITE; }

".OR."       { return T_OROP; }

".AND."      { return T_ANDOP; }

".NOT."      { return T_NOTOP; }

"*"          { return T_MULOP; }

"/"          { return T_DIVOP; }

"**"         { return T_POWEROP; }

"+"|"-"      { strcpy(yylval.ystr, yytext);
			   return T_ADDOP; }

".GT."|".GE."|".LT."|".LE."|".EQ."|".NE."	{ strcpy(yylval.ystr, yytext);
											  return T_RELOP; }

[C](([A][D]*)|([D]+))[R]	{ strcpy(yylval.ystr, yytext);
								  return T_LISTFUNC; }

[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9]+_)*	{ strcpy(yylval.ystr, yytext);
										  return T_ID; }

(0($|([Xx][1-9a-fA-F][0-9a-fA-F]*)|([Oo][1-7][0-7]*)|([Bb]1[01]*)))|([1-9][0-9]*)	{ yylval.yint = (int) getDouble(yytext);
																					  return T_ICONST; }

(0[bB](((0|(1[01]*))?\.[01]*1[01]*)|(0|(1[01]*)\.?([01]*1[01]*)?)))|(0[oO](((0|([1-7][0-7]*))?\.[0-7]*[1-7][0-7]*)|(0|([1-7][0-7]*)\.?([0-7]*[1-7][0-7]*)?)))|(0[xX](((0|([1-9a-fA-F][0-9a-fA-F]*))?\.[0-9a-fA-F]*[1-9a-fA-F][0-9a-fA-F]*)|(0|([1-9a-fA-F][0-9a-fA-F]*)\.?([0-9a-fA-F]*[1-9a-fA-F][0-9a-fA-F]*)?)))|((((0|([1-9][0-9]*))?\.[0-9]*[1-9][0-9]*)|((0|([1-9][0-9]*))\.?([0-9]*[1-9][0-9]*)?))([eE](\+|\-)?(0|([1-9][0-9]*)))?)	{ yylval.ydouble = getDouble(yytext);
																																																																																																									          return T_RCONST; }

".TRUE."|".FALSE."	{ strcpy(yylval.ystr, yytext);
					  return T_LCONST; }

(\'([ -~]|(\\n)|(\\f)|(\\t)|(\\r)|(\\b)|(\\v))\')	{ yylval.ychar = getCharacter(yytext);
													  return T_CCONST; }

(\"(((\\n)|(\\f)|(\\t)|(\\r)|(\\b)|(\\v)|(\\\")|(\\.)|(\\$\n|[^"]))*\"))	{ strcpy(yylval.ystr, getString(yytext));
																		      return T_SCONST; }

\$.*\n       { /* This is a comment. */ }

[ \t\r\n]+   { /* This is a character that needs to be ignored. */ }

<<EOF>>      { return T_EOF; }

.            { 
			   printf("\nSimpleFortran: lexical error at line %d.\n", yylineno);
               exit(1);
			 }

%%

/* Function to get the double value of integers and real numbers (for ICONST and RCONST). */
double getDouble(char* original) {
    double val = 0;
    int start = 0;
    int sign = 1;
    if (original[0] == '+') {
        start = 1;
    }
    else if (original[0] == '-') {
        start = 1;
        sign = -1;
    }

    if (original[start] == '0' && ( original[start + 1] == 'X' || original[start + 1] == 'x')) {
        int dotIndex = -1;
        for (int i = 0 ; i < strlen(original) ; i++) {
            if (original[i] == '.') {
                dotIndex = i;
            }
        }
        if (dotIndex == -1) {
            char copy[strlen(original)];
            for (int i = start + 2 ; i <= strlen(original) ; i++) {
                copy[i - start - 2] = original[i];
            }
            val = strtol(copy, NULL, 16);
        }
        else {
            for (int i = dotIndex - 1, power = 0 ; i > start + 1 ; i--, power++) {
                if (original[i] == 'A' || original[i] == 'B' || original[i] == 'C' || original[i] == 'D' || original[i] == 'E' || original[i] == 'F') {
                    val += (original[i] - 55) * pow(16, power);
                }
                else if (original[i] == 'a' || original[i] == 'b' || original[i] == 'c' || original[i] == 'd' || original[i] == 'e' || original[i] == 'f') {
                    val += (original[i] - 87) * pow(16, power);
                }
                else {
                    val += (original[i] - 48) * pow(16, power);
                }
            }
            for (int i = dotIndex + 1, power = -1 ; i < strlen(original) ; i++, power--) {
                if (original[i] == 'A' || original[i] == 'B' || original[i] == 'C' || original[i] == 'D' || original[i] == 'E' || original[i] == 'F') {
                    val += (original[i] - 55) * pow(16, power);
                }
                else if (original[i] == 'a' || original[i] == 'b' || original[i] == 'c' || original[i] == 'd' || original[i] == 'e' || original[i] == 'f') {
                    val += (original[i] - 87) * pow(16, power);
                }
                else {
                    val += (original[i] - 48) * pow(16, power);
                }
            }
            val = val * sign;
        }
    }
    else if (original[start] == '0' && ( original[start + 1] == 'O' || original[start + 1] == 'o')) {
        int dotIndex = -1;
        for (int i = 0 ; i < strlen(original) ; i++) {
            if (original[i] == '.') {
                dotIndex = i;
            }
        }
        if (dotIndex == -1) {
            char copy[strlen(original)];
            for (int i = start + 2 ; i <= strlen(original) ; i++) {
                copy[i - start - 2] = original[i];
            }
            val = strtol(copy, NULL, 8);
        }
        else {
            for (int i = dotIndex - 1, power = 0 ; i > start + 1 ; i--, power++) {
                val += (original[i] - 48) * pow(8, power);
            }
            for (int i = dotIndex + 1, power = -1 ; i < strlen(original) ; i++, power--) {
                val += (original[i] - 48) * pow(8, power);
            }
            val = val * sign;
        }
    }
    else if (original[start] == '0' && ( original[start + 1] == 'B' || original[start + 1] == 'b')) {
        int dotIndex = -1;
        for (int i = 0 ; i < strlen(original) ; i++) {
            if (original[i] == '.') {
                dotIndex = i;
            }
        }
        if (dotIndex == -1) {
            char copy[strlen(original)];
            for (int i = start + 2 ; i <= strlen(original) ; i++) {
                copy[i - start - 2] = original[i];
            }
            val = strtol(copy, NULL, 2);
        }
        else {
            for (int i = dotIndex - 1, power = 0 ; i > start + 1 ; i--, power++) {
                val += (original[i] - 48) * pow(2, power);
            }
            for (int i = dotIndex + 1, power = -1 ; i < strlen(original) ; i++, power--) {
                val += (original[i] - 48) * pow(2, power);
            }
            val = val * sign;
        }
    }
    else {
        val = strtod(original, NULL);
    }
    return val;
}

/* Function to correctly format characters (for CCONST). */
char getCharacter(char* original) {
    printf("%d\n", strlen(original));
    if (original[1] == '\\' && strlen(original) == 4) {
        if (original[2] == 'n') {
            return '\n';
        }
        else if (original[2] == 'f') {
            return '\f';
        }
        else if (original[2] == 't') {
            return '\t';
        }
        else if (original[2] == 'r') {
            return '\r';
        }
        else if (original[2] == 'b') {
            return '\b';
        }
        else if (original[2] == 'f') {
            return '\v';
        }
    }
    else return original[1];
}

/* Function to correctly format strings (for SCONST). */
char * getString(char* original) {
    char * final = (char *) malloc((strlen(original) + 1)*sizeof( char));
    int flag = 0;
    int i = 0;
    int j = 0;
    while (i < strlen(original))  {
        if (flag == 0 && original[i] == '\\') {
            flag = 1;
        }
        else if (flag == 1 && original[i] == '\n') {
            flag = 0;
        }
		else if (flag == 1 && (original[i] == 'n' || original[i] == 'f' || original[i] == 't' || original[i] == 'r' || original[i] == 'b' || original[i] == 'v' || original[i] == '"' || original[i] == '\\')) {
            flag = 0;
			if (original[i] == 'n') {
				final[j++] = '\n';
			}
			else if (original[i] == 'f') {
				final[j++] = '\f';
			}
			else if (original[i] == 't') {
				final[j++] = '\t';
			}
			else if (original[i] == 'r') {
				final[j++] = '\r';
			}
			else if (original[i] == 'b') {
				final[j++] = '\b';
			}
			else if (original[i] == 'v') {
				final[j++] = '\v';
			}
			else if (original[i] == '"') {
				final[j++] = '\"';
			}
			else if (original[i] == '\\') {
				final[j++] = '\\';
			}
        }
        else if (flag == 1 && original[i] != '\n') {
            flag = 0;
            final[j] = original[i];
            j++;
        }
        else if (flag != 0 || original[i] != '"'){
            final[j] = original[i];
            j++;
        }
        i++;
    }
    final[j] = '\0';
    return final;
}