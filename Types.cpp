#include "Types.h"
#include <cstdlib>
#include <sstream>

ostream& operator << (ostream& os, const Expression& e) {
	os << "Expr: "  << e.getValue();
	return os;
}

ScriptInteger::ScriptInteger(int i): val(i) {}
ScriptInteger::ScriptInteger(char* c): val(atoi(c)) {}

ScriptInteger& ScriptInteger::operator+(const Expression& e) {
	ScriptInteger* res = new ScriptInteger(0);
	cout << "About to dynamic cast!" << endl;
	const ScriptInteger* new_e = dynamic_cast<const ScriptInteger*>(&e);

	if (new_e == NULL) {
		cout << "Integer conversion failed using string" << endl;
		res->val = val + atoi(e.getValue().c_str());
	} else {
		cout << "Integer conversion ok for " << e << " doing fast math" << endl;
		res->val = val + new_e->val;
	}

	return *res;
}


string ScriptInteger::getValue() const {
	std::ostringstream stm;
	stm << val;
	return stm.str();
}

ScriptString::ScriptString(char* c) : val(c) {}

ScriptString::ScriptString(string c) : val(c) {}

string ScriptString::getValue() const {return val;}

ScriptString& ScriptString::operator+(const Expression& e) {
	ScriptString *res = new ScriptString((char*)"");
	return *res;
}
