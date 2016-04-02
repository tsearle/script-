#include "ScriptObject.h"
#include <iostream>
#include <sstream>

ScriptObject::ScriptObject(const char* c) : root(new Json::Value()) {
	std::istringstream iss(c);
	try {
		iss >> *root;
	} catch (Json::RuntimeError e) {
		throw std::invalid_argument(string("unable to convert to JSon Object: ") + e.what());
	}
	current = &(*root);
}

ScriptObject::ScriptObject(const string &c) : root(new Json::Value()) {
	std::istringstream iss(c);
	try {
		iss >> *root;
	} catch (Json::RuntimeError e) {
		throw std::invalid_argument(string("unable to convert to JSon Object: ") + e.what());
	}
	current = &(*root);
}

ScriptObject::ScriptObject(const ScriptObject & obj) : root(obj.root), current(obj.current) {
}	

std::string ScriptObject::toString() {
	std::ostringstream oss;
	oss << *current;
	return oss.str();
}

unique_ptr<Expression> ScriptObject::eval() {
	return unique_ptr<Expression>(new ScriptObject(*this));
}

void ScriptObject::assign(unique_ptr<Expression> rval) {
	std::istringstream iss(rval->toString());
	iss >> *current;
}

unique_ptr<Expression> ScriptObject::add(Expression& e) {
	int lval = 0;

	if (current->isConvertibleTo(Json::ValueType::intValue)) {
		lval = current->asInt();
	}

	ScriptInteger lObj = ScriptInteger(lval);
	return lObj.add(e);
}

unique_ptr<Expression> ScriptObject::index(Expression& e) {

	int idx = atoi(e.toString().c_str());

	unique_ptr<ScriptObject> result(new ScriptObject(*this));
	try {
		result->current = &((*current)[idx]);
	} catch(Json::LogicError e) {
		throw std::invalid_argument(std::string("unable to index: ") + e.what());
	}


	return result;
}
