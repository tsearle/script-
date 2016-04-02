#include <cstdio>
#include <iostream>
#include <sstream>

#include "script_parser.tab.h"
#include "script_scanner.h"

std::string getInput() {
	std::ostringstream oss;

	oss << std::cin.rdbuf();

	return oss.str();
}

int main(int, char**) {
	std::string data = getInput();
	std::ostringstream oss;

	unique_ptr<Script> script = script_parse(data);

	try {
		cout << "Invoking script" << endl;	
		script->execute(oss);
		cout << "ending script" << endl;
	} catch (std::invalid_argument &  e) {
		cout << e.what();
	}

	cout << "Result of Script" << endl << oss.str();
	return 0;
}
