%{
#include <cstdio>
#include <iostream>
#include <memory>
using namespace std;
#include "script_parser.tab.h"
#include "script_scanner.h"

 
void yyerror(yyscan_t scanner, const char *s);

%}

%code requires {
#include "Types.h"
}

%pure-parser
%lex-param {void * scanner}
%parse-param { void * scanner}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	ScriptInteger* ival;
	ScriptString*  sval;
	Expression* eval;
	ScriptVariable* var;
}

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT
%token <sval> STRING
%token <var> VARIABLE
%token ADD
%token ASSIGN
%token SCOLIN

%type <eval> expr

%right ASSIGN
%left ADD

%%
// this is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:

stmts:
	stmts stmt
	| stmt
;

stmt:
	expr SCOLIN	{ cout << "************Expresion Result: " << *($1->eval()) << endl; }

;

expr:
	INT      { $$ = $1; cout << "bison found an int: " << *$1 << endl; }
	| STRING { $$ = $1; cout << "bison found a string: " << *$1 << endl; }
	| VARIABLE { $$ = $1; cout << "bison found a variable" << endl; }
	| expr ADD expr { $$ = new Add($1, $3); }
	| expr ASSIGN expr { Assignable * a = dynamic_cast<Assignable*>($1); if(a == nullptr) yyerror(scanner,YY_("assign: invalid lval")); $$ = new Assign(a, $3); }
	;


%%

yyscan_t scanner;
int main(int, char**) {
	/*
	// open a file handle to a particular file:
	FILE *myfile = fopen("a.parser.file", "r");
	// make sure it is valid:
	if (!myfile) {
		cout << "I can't open a.parser.file!" << endl;
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
*/	
	yylex_init(&scanner);
	YY_BUFFER_STATE bp = yy_scan_string("something = 3 + \"5\";\n7+8+4;\"Party on!\";", &scanner);
	yy_switch_to_buffer(bp, scanner);
	yyparse(scanner);
	yylex_destroy(scanner);
}

void yyerror(yyscan_t scanner, const char *s) {
	cout << "EEK, parse error!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}
