%{
#include <cstdio>
#include <iostream>
using namespace std;

#include "script_parser.tab.h"
%}

%option outfile="script_scanner.c" header-file="script_scanner.h"
%option reentrant
%option bison-bridge 

%%
[ \t\n]          ;
var		 { return VAR; }
[0-9]+           { yylval->ival = new ScriptInteger(yytext); return INT; }
[a-zA-Z0-9]+     { yylval->token = strdup(yytext); return TOKEN; }
["]([^"]|(\\\"))*["]     {yytext[strlen(yytext)-1] = '\0';yylval->sval = new ScriptString(yytext+1); return STRING;}
[+]              { return ADD; }
;		 { return SCOLIN; }
=		 { return ASSIGN; }
.                ;
%%
