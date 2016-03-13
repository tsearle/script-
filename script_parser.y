%{
#include <cstdio>
#include <iostream>
#include <memory>
using namespace std;
#include "script_parser.tab.h"
#include "script_scanner.h"

 
void yyerror(yyscan_t scanner, const char *s);

#define scanner_handle state->scanner_ref

%}

%code requires {
#include "Types.h"
#include "SymbolTable.h"

struct pass_to_bison {
	SymbolTable * table;
	void * scanner_ref;
};



}

%pure-parser
%lex-param {(void*)(scanner_handle)}
%parse-param {pass_to_bison*state }

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
	| expr ASSIGN expr { Assignable * a = dynamic_cast<Assignable*>($1); if(a == nullptr) yyerror(state->scanner_ref,YY_("assign: invalid lval")); $$ = new Assign(a, $3); }
	;


%%

int main(int, char**) {
	pass_to_bison state;
	yylex_init(&state.scanner_ref);
	yyset_extra(&state, state.scanner_ref);
	YY_BUFFER_STATE bp = yy_scan_string("something = 3 + \"5\";\n7+8+4;\"Party on!\";", state.scanner_ref);
	yy_switch_to_buffer(bp, state.scanner_ref);
	yyparse(&state);
	yylex_destroy(state.scanner_ref);
}

void yyerror(yyscan_t scanner, const char *s) {
	cout << "EEK, parse error!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}
