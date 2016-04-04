%{
#include <cstdio>
#include <iostream>
using namespace std;

#include "script_parser.tab.h"
%}

%option outfile="script_scanner.c" header-file="script_scanner.h"
%option reentrant
%option bison-bridge 
%option extra-type="struct pass_to_bison*"

%%
[\n]         	 { yyextra->line++; }
[ \t]          ;
var		 { return VAR; }
if		 { return IF; }
else		 { return ELSE; }
print		 { return PRINT; }
[0-9]+           { yylval->ival = new ScriptInteger(yytext); return INT; }
[a-zA-Z0-9]+     { yylval->token = strdup(yytext); return TOKEN; }
["]([^"]|(\\\"))*["]     {yytext[strlen(yytext)-1] = '\0';yylval->sval = new ScriptString(yytext+1); return STRING;}
[+]              { return ADD; }
[\[]             { return LBRACKET; }
[\]]             { return RBRACKET; }
;		 { return SCOLIN; }
=		 { return ASSIGN; }
[{]		 { return LBRACE; }
[}]		 { return RBRACE; }
[(]		 { return LPAREN; }
[)]		 { return RPAREN; }
.                ;
%%
