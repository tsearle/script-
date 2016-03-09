#include "Types.h"
#include <cstdlib>
#include <sstream>

ostream& operator << (ostream& os, Expression& e) {
	os << "Expr: "  << e.toString();
	return os;
}

Expression::~Expression() { cout << "Parent Destructor" << endl; }

ScriptInteger::ScriptInteger(int i): val(i) {}
ScriptInteger::ScriptInteger(char* c): val(atoi(c)) {}

ScriptInteger::~ScriptInteger() {
	cout << "Deleting Integer " << val << endl;
}

unique_ptr<Expression> ScriptInteger::add(Expression& e) {
	unique_ptr<ScriptInteger> res = unique_ptr<ScriptInteger>(new ScriptInteger(0));
	cout << "About to dynamic cast!" << endl;
	const ScriptInteger* new_e = dynamic_cast<const ScriptInteger*>(&e);

	if (new_e == NULL) {
		cout << "Integer conversion failed using string" << endl;
		res->val = val + atoi(e.toString().c_str());
	} else {
		cout << "Integer conversion ok for " << e << " doing fast math" << endl;
		res->val = val + new_e->val;
	}

	return res;
}


string ScriptInteger::toString() {
	std::ostringstream stm;
	stm << val;
	return stm.str();
}

unique_ptr<Expression> ScriptInteger::eval() {
	unique_ptr<ScriptInteger> res = unique_ptr<ScriptInteger>(new ScriptInteger(val));
	return res;
}

ScriptString::ScriptString(const char* c) : val(c) {}

ScriptString::ScriptString(const string & c) : val(c) {}

ScriptString::~ScriptString() {
	cout << "Deleting String " << val << endl;
}

string ScriptString::toString() {return val;}

unique_ptr<Expression> ScriptString::eval() {
	unique_ptr<ScriptString> res = unique_ptr<ScriptString>(new ScriptString(val));
	return res;
}

unique_ptr<Expression> ScriptString::add(Expression& e) {
	unique_ptr<ScriptString> res = unique_ptr<ScriptString>(new ScriptString((char*)""));
	return res;
}

unique_ptr<Expression> BinaryOperator::add(Expression& e) {
	unique_ptr<Expression> val = eval();
	return val->add(e);
}

string BinaryOperator::toString() {
	const unique_ptr<Expression> val = eval();
	return val->toString();
}

Add::Add(Expression* lval, Expression* rval) : lval(unique_ptr<Expression>(lval)), rval(unique_ptr<Expression>(rval)) {}

unique_ptr<Expression> Add::eval() {
	return lval->add(*rval);
}

Add::~Add() {
	cout << "Destruction of Add(" << lval->toString() << ", " << rval->toString() << ")" << endl;
}
