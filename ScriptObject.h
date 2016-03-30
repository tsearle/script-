#include "Types.h"
#include <jsoncpp/json/json.h>

class ScriptObject : public Expression, public Assignable {
	private:
		shared_ptr<Json::Value> root;
		Json::Value * current;
	public:
		ScriptObject(const char* c);
		ScriptObject(const std::string &c);
		ScriptObject(const ScriptObject &obj);
		std::string toString();
		unique_ptr<Expression> eval();
		void assign(unique_ptr<Expression> rval);
		unique_ptr<Expression> add(Expression& e);
		unique_ptr<Expression> index(Expression& e);
};
