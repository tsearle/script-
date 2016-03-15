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
	shared_ptr<SymbolTable>  table;
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
	Statement* stmt;
	char * token;
}

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT
%token <sval> STRING
%token <token> TOKEN
%token ADD
%token ASSIGN
%token SCOLIN
%token VAR

%type <eval> expr
%type <stmt> stmt
%type <stmt> vardecl

%right ASSIGN
%left ADD

%%
// this is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:

stmts:
	stmts stmt { try {cout << "Stmt2: " << *$2 << endl;} catch(std::invalid_argument &  e) { cout << e.what() << endl; yyerror(state->scanner_ref,"WTF?!?"); }}
	| stmt { try { cout << "Stmt: " << *$1 << endl; } catch(std::invalid_argument &  e) { cout << e.what() << endl; yyerror(state->scanner_ref,"WTF?!?"); }}
;

stmt:
	expr SCOLIN	{ $$ = new ExpressionStatement($1); }
	| vardecl SCOLIN  { $$ = $1; }

;

vardecl:
	VAR TOKEN { cout << "vardecl: found token" << endl; $$ = new VardeclStatement(state->table,$2); free($2);} 
	| VAR TOKEN ASSIGN expr { cout << "Declaring " << $2 << " with initial value of "<< *$4<< endl;$$ = new VardeclStatement(state->table, $2, $4); free($2); }
;	

expr:
	INT      { $$ = $1; cout << "bison found an int: " << *$1 << endl; }
	| STRING { $$ = $1; cout << "bison found a string: " << *$1 << endl; }
	| TOKEN { cout << "expr: found token" << endl; $$ = new ScriptVariable(state->table, $1); } 
	| expr ADD expr { $$ = new Add($1, $3); }
	| expr ASSIGN expr { Assignable * a = dynamic_cast<Assignable*>($1); if(a == nullptr) yyerror(state->scanner_ref,YY_("assign: invalid lval")); $$ = new Assign(a, $3); }
	;


%%

int main(int, char**) {
	pass_to_bison state;
	yylex_init(&state.scanner_ref);
	yyset_extra(&state, state.scanner_ref);
	state.table = unique_ptr<SymbolTable>(new SymbolTable());
	YY_BUFFER_STATE bp = yy_scan_string("var something = 2+2; something=something+5;something2+2;", state.scanner_ref);
	yy_switch_to_buffer(bp, state.scanner_ref);
	yyparse(&state);
	yylex_destroy(state.scanner_ref);
}

void yyerror(yyscan_t scanner, const char *s) {
	cout << "EEK, parse error!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}
