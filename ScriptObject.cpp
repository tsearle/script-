#include "ScriptObject.h"
#include <iostream>
#include <sstream>

ScriptObject::ScriptObject(const char* c) {
	std::istringstream iss(c);
	iss >> root;
}

ScriptObject::ScriptObject(const string &c) {
	std::istringstream iss(c);
	iss >> root;
}

ScriptObject::ScriptObject(const ScriptObject & obj) : root(root) {
}	

std::string ScriptObject::toString() {
	return std::string("::");
}

unique_ptr<Expression> ScriptObject::eval() {
	return unique_ptr<Expression>(new ScriptObject(*this));
}

unique_ptr<Expression> ScriptObject::add(Expression& e) {
	int lval = 0;

	cout << "Inside ScriptObject::add" << endl;

	if (root.isConvertibleTo(Json::ValueType::intValue)) {
		lval = root.asInt();
	}

	ScriptInteger lObj = ScriptInteger(lval);
	return lObj.add(e);
}
