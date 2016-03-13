#include "Types.h"
#include <map>
#include <string>
#include <memory>

class SymbolTable
{
	private:
		std::map<const std::string, unique_ptr<Expression>> table;
	public:
		void put(const  std::string & name, unique_ptr<Expression> expression);
		Expression* get(const std::string& name);
};

