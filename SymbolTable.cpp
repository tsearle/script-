#include "SymbolTable.h"

void SymbolTable::put(const std::string & name, unique_ptr<Expression> expression) {
	table.erase(name);
	table.insert(std::make_pair(name,std::move(expression)));
}

Expression* SymbolTable::get(const string&name) {
	std::map<const string,unique_ptr<Expression>>::iterator it = table.find(name);
   return (it == table.end()) ? nullptr : it->second.get();

}
