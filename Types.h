#ifndef __TYPES_H__
#define __TYPES_H__
#include <string>
#include <iostream>
#include <memory>
#include <list>
#include "SymbolTable.h"
using namespace std;

class Expression {
public:
	virtual string toString() = 0;
	virtual unique_ptr<Expression> eval() = 0;
	virtual unique_ptr<Expression> add(Expression& e) = 0;
	virtual unique_ptr<Expression> index(Expression& e) = 0;

	friend ostream& operator << (ostream& os, Expression& e);
	virtual ~Expression();
};


class Assignable {
public:
	virtual void assign(unique_ptr<Expression> rval) = 0;
};


class ScriptVariable : public Expression, public Assignable {
private:
	string name;
	shared_ptr<SymbolTable> table;
public:
	ScriptVariable(shared_ptr<SymbolTable> table, const string & name);
	void assign(unique_ptr<Expression> rval);
	string toString();
	unique_ptr<Expression> eval();
	unique_ptr<Expression> add(Expression& e);
	unique_ptr<Expression> index(Expression& e);

	~ScriptVariable();
};

class ScriptInteger: public Expression {
private:
	int val;
public:
	ScriptInteger(int i);
	ScriptInteger(char* c);
	string toString() ;
	unique_ptr<Expression> eval();
	unique_ptr<Expression> add(Expression& e);
	unique_ptr<Expression> index(Expression& e);
	~ScriptInteger();


};

class ScriptString : public Expression {
private:
	string val;
public:
	ScriptString(const char* c);
	ScriptString(const string &c);
	string toString() ;
	unique_ptr<Expression> eval();
	unique_ptr<Expression> add(Expression& e);
	unique_ptr<Expression> index(Expression& e);
	~ScriptString();

};

class BinaryOperator : public Expression {
public:
	unique_ptr<Expression> add(Expression& e);
	unique_ptr<Expression> index(Expression& e);
	string toString() ;
};

class Assign : public BinaryOperator {
private:
	unique_ptr<Expression> lval;
	unique_ptr<Expression> rval;
public:
	Assign(Expression* lval, Expression* rval);
	unique_ptr<Expression> eval();
	~Assign();
};

class Add : public BinaryOperator {
private:
	unique_ptr<Expression> lval;
	unique_ptr<Expression> rval;
public:
	Add(Expression* larg, Expression* rarg);
	unique_ptr<Expression> eval();
	~Add();
};

class Index : public BinaryOperator {
private:
	unique_ptr<Expression> lval;
	unique_ptr<Expression> rval;
public:
	Index(Expression* larg, Expression* rarg);
	unique_ptr<Expression> eval();
	~Index();
};

class Statement {
private:
	int lineNo;
public:
	friend ostream& operator << (ostream& os, Statement& e);
	void setLineNo(int line);
	void wrapException(std::exception &e);
	virtual void execute(ostream & os)=0;
};

class ExpressionStatement: public Statement {
private: 
	unique_ptr<Expression> expr;
public:
	ExpressionStatement(Expression * e);
	void execute(ostream & os);
};

class VardeclStatement: public Statement {
private: 
	string name;
	unique_ptr<Expression> expr;
	shared_ptr<SymbolTable> table;
public:
	VardeclStatement(shared_ptr<SymbolTable> table, string name, Expression * e);
	VardeclStatement(shared_ptr<SymbolTable> table, string name);
	void execute(ostream & os);
};

class StatementBlock : public Statement {
private:
	list<unique_ptr<Statement>> stmt_list;
public:
	void execute(ostream & os);
	void addStatement(Statement * stmt);
};	

class Script : public StatementBlock {
};

class IfStatement : public Statement {
private:
	unique_ptr<Expression> cond;
	unique_ptr<Statement> trueStmt;
	unique_ptr<Statement> falseStmt;
public:
	IfStatement(Expression * cond, Statement * trueStmt);
	IfStatement(Expression * cond, Statement * trueStmt, Statement * falseStmt);
	void execute(ostream & os);
};	

class PrintStatement : public Statement {
private:
	unique_ptr<Expression> val;
public:
	PrintStatement(Expression * val);
	void execute(ostream & os);
};	


#endif
