#ifndef __TYPES_H__
#define __TYPES_H__
#include <string>
#include <iostream>
#include <memory>
using namespace std;

class Expression {
	public:
	virtual string toString() = 0;
	virtual unique_ptr<Expression> eval() = 0;
	virtual unique_ptr<Expression> add(Expression& e) = 0;

	friend ostream& operator << (ostream& os, Expression& e);
	virtual ~Expression();
};

class ScriptInteger: public Expression {
	int val;
public:
	ScriptInteger(int i);
	ScriptInteger(char* c);
	string toString() ;
	unique_ptr<Expression> eval();
	unique_ptr<Expression> add(Expression& e);
	~ScriptInteger();


};

class ScriptString : public Expression {
	string val;
public:
	ScriptString(const char* c);
	ScriptString(const string &c);
	string toString() ;
	unique_ptr<Expression> eval();
	unique_ptr<Expression> add(Expression& e);
	~ScriptString();

};

class BinaryOperator : public Expression {
public:
	unique_ptr<Expression> add(Expression& e);
	string toString() ;
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



#endif
