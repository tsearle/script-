#ifndef __TYPES_H__
#define __TYPES_H__
#include <string>
#include <iostream>
using namespace std;

class Expression {
	public:
	virtual string getValue() const  = 0;
	virtual Expression& operator+(const Expression& e) = 0;

	friend ostream& operator << (ostream& os, const Expression& e);
};

class ScriptInteger: public Expression {
	int val;

public:
	ScriptInteger(int i);
	ScriptInteger(char* c);
	string getValue() const;
	ScriptInteger& operator+(const Expression& e);


};

class ScriptString : public Expression {
	string val;
public:
	ScriptString(char* c);
	ScriptString(string c);
	string getValue() const;
	ScriptString& operator+(const Expression& e);

};


#endif
