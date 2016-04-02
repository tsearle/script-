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
#include <list>

struct pass_to_bison {
	shared_ptr<SymbolTable>  table;
	void * scanner_ref;
	list <StatementBlock*> scopes;
};

unique_ptr<Script> script_parse(std::string input);



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
%token RBRACKET
%token LBRACKET
%token ASSIGN
%token SCOLIN
%token VAR
%token LBRACE
%token RBRACE
%token LPAREN
%token RPAREN
%token IF
%token ELSE
%token PRINT

%type <eval> expr
%type <stmt> stmt
%type <stmt> stmtblk
%type <stmt> vardecl
%type <stmt> ifstmt 
%type <stmt> printstmt 

%destructor { cout << "freeing char*" << *$$ << endl; free($$); } <token>
%destructor { cout << "freeing INT " << *$$ << endl; free($$); } <ival>
%destructor { cout << "freeing STRING " << *$$ << endl; free($$); } <sval>
%destructor { cout << "freeing Statement " << *$$ << endl; free($$); } <stmt>
%destructor { cout << "freeing Expression " << *$$ << endl; free($$); } <eval>

%right ASSIGN
%left ADD
%left LBRACKET

%%
// this is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:

stmts:
	stmts stmt { state->scopes.back()->addStatement($2); }
	| stmt { state->scopes.back()->addStatement($1); }
;

stmt:
	expr SCOLIN	{ $$ = new ExpressionStatement($1); }
	| vardecl SCOLIN  { $$ = $1; }
	| stmtblk  { $$ = $1; }
	| ifstmt  { $$ = $1; }
	| printstmt  { $$ = $1; }
;

ifstmt:
	IF LPAREN expr RPAREN stmt ELSE stmt { $$ = new IfStatement($3, $5, $7); }
	| IF LPAREN expr RPAREN stmt { $$ = new IfStatement($3, $5); }
;

printstmt:
	PRINT expr SCOLIN { $$ = new PrintStatement($2); }
;

stmtblk:
	LBRACE {state->scopes.push_back(new StatementBlock());}	
		stmts 
	RBRACE { $$ = state->scopes.back(); state->scopes.pop_back();}
;


vardecl:
	VAR TOKEN { $$ = new VardeclStatement(state->table,$2); free($2);} 
	| VAR TOKEN ASSIGN expr { $$ = new VardeclStatement(state->table, $2, $4); free($2); }
;	

expr:
	INT      { $$ = $1; }
	| STRING { $$ = $1; }
	| TOKEN { $$ = new ScriptVariable(state->table, $1); } 
	| expr ADD expr { $$ = new Add($1, $3); }
	| expr LBRACKET expr RBRACKET { $$ = new Index($1, $3); }
	| expr ASSIGN expr { $$ = new Assign($1, $3); }
	;


%%

unique_ptr<Script> script_parse(std::string data) {
	unique_ptr<Script> my_script(new Script());
	pass_to_bison state;
	yylex_init(&state.scanner_ref);
	yyset_extra(&state, state.scanner_ref);
	state.table = unique_ptr<SymbolTable>(new SymbolTable());
	state.scopes.push_back(my_script.get());
	YY_BUFFER_STATE bp = yy_scan_string(data.c_str(), state.scanner_ref);
	yy_switch_to_buffer(bp, state.scanner_ref);
	yyparse(&state);
	yylex_destroy(state.scanner_ref);
	return my_script;
}

void yyerror(yyscan_t scanner, const char *s) {
	cerr << "EEK, parse error!  Message: " << s << endl;
	// might as well halt now:
//	exit(-1);
}
