#include <map>
#include <string>
#include <memory>
#include "Types.h"

#ifndef __SYMBOL_TABLE_H__
#define __SYMBOL_TABLE_H__

class Expression;

class SymbolTable
{
	private:
		std::map<const std::string, std::unique_ptr<Expression>> table;
	public:
		void put(const  std::string & name, std::unique_ptr<Expression> expression);
		Expression* get(const std::string& name);
};

#endif
