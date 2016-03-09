%{
#include <cstdio>
#include <iostream>
using namespace std;
#define YY_DECL extern int yylex()

#include "script_parser.tab.h"
%}

%option outfile="script_scanner.c" header-file="script_scanner.h"

%%
[ \t\n]          ;
[0-9]+           { yylval.ival = new ScriptInteger(yytext); return INT; }
[a-zA-Z0-9]+     { yylval.sval = new ScriptString(yytext); return STRING; }
["]([^"]|(\\\"))*["]     {yytext[strlen(yytext)-1] = '\0';yylval.sval = new ScriptString(yytext+1); return STRING;}
[+]              { return ADD; }
;		 { return SCOLIN; }
.                ;
%%
