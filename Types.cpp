#include "Types.h"
#include <cstdlib>

ScriptInteger::ScriptInteger(int i): val(i) {};
ScriptInteger::ScriptInteger(char* c): val(atoi(c)) {};

ostream& operator << (ostream& os, const ScriptInteger& si) {
	os << si.val;
	return os;
}

ScriptString::ScriptString(char* c) : val(c) {};

ScriptString::ScriptString(string c) : val(c) {};

ostream& operator << (ostream& os, const ScriptString& ss) {
	os << ss.val;
	return os;
}
