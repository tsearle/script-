FLEX=flex
CC=g++
CFLAGS=-std=c++0x -g
HEADERS=Types.h SymbolTable.h ScriptObject.h
SOURCES=Types.cpp SymbolTable.cpp ScriptObject.cpp script.cpp
BUILT_SOURCES=script_scanner.c script_parser.tab.c
BUILT_HEADERS=script_parser.tab.h script_scanner.h
LIBS=-lfl -ljsoncpp
BINARY=script

all: $(BINARY)

$(BINARY): $(SOURCES) $(BUILT_SOURCES) $(BUILT_HEADERS) $(HEADERS)
	$(CC) $(CFLAGS) $(SOURCES) $(BUILT_SOURCES) $(LIBS) -o $(BINARY)	

script_scanner.c script_scanner.h: script_scanner.l script_parser.tab.h
	$(FLEX) script_scanner.l

script_parser.tab.c script_parser.tab.h: script_parser.y
	bison -v -d script_parser.y -b script_parser
     
clean:
	rm -f $(BUILT_SOURCES) $(BUILT_HEADERS) $(BINARY)
