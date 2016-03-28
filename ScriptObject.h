#include "Types.h"
#include <jsoncpp/json/json.h>

class ScriptObject : public Expression {
	private:
		Json::Value root;
	public:
		ScriptObject(const char* c);
		ScriptObject(const std::string &c);
		ScriptObject(const ScriptObject &obj);
		std::string toString();
		unique_ptr<Expression> eval();
		unique_ptr<Expression> add(Expression& e);
		//unique_ptr<Expression> index(Expression& e);
};
