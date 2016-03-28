#include <cstdio>
#include <iostream>

#include "script_parser.tab.h"
#include "script_scanner.h"

int main(int, char**) {
	pass_to_bison state;
	yylex_init(&state.scanner_ref);
	yyset_extra(&state, state.scanner_ref);
	state.table = unique_ptr<SymbolTable>(new SymbolTable());
	YY_BUFFER_STATE bp = yy_scan_string("var something = 2+2; something=something+5;something-2;something=something+1;", state.scanner_ref);
	yy_switch_to_buffer(bp, state.scanner_ref);
	yyparse(&state);
	yylex_destroy(state.scanner_ref);
}

void yyerror(yyscan_t scanner, const char *s) {
	cout << "EEK, parse error!  Message: " << s << endl;
	// might as well halt now:
//	exit(-1);
}
