#ifndef __TYPES_H__
#define __TYPES_H__
#include <string>
#include <iostream>
using namespace std;

class ScriptInteger {
	int val;

public:
	ScriptInteger(int i);
	ScriptInteger(char* c);

	friend ostream& operator << (ostream& os, const ScriptInteger& si);

};

class ScriptString {
	string val;
public:
	ScriptString(char* c);
	ScriptString(string c);

	friend ostream& operator << (ostream& os, const ScriptString& ss);
};


#endif
