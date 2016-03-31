#include <cstdio>
#include <iostream>

#include "script_parser.tab.h"
#include "script_scanner.h"

int main(int, char**) {
	std::string data("var something = 2+2; something=something+5;var arr = \"[[1,2,3],[4,5,6],[7,8,9]]\"; arr[1][2]=0;arr[1];");

	unique_ptr<Script> script = script_parse(data);

	try {
		script->execute(cout);
	} catch (std::invalid_argument &  e) {
		cout << e.what();
	}
	return 0;
}
