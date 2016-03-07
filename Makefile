FLEX=flex
CC=g++
HEADERS=Types.h
SOURCES=Types.cpp
BUILT_SOURCES=script_scanner.c script_parser.tab.c
BUILT_HEADERS=script_parser.tab.h script_scanner.h
LIBS=-lfl
BINARY=script

all: $(BINARY)

$(BINARY): $(SOURCES) $(BUILT_SOURCES) $(BUILT_HEADERS) $(HEADERS)
	$(CC) $(SOURCES) $(BUILT_SOURCES) $(LIBS) -o $(BINARY)	

script_scanner.c script_scanner.h: script_scanner.l script_parser.tab.h
	$(FLEX) script_scanner.l

script_parser.tab.c script_parser.tab.h: script_parser.y
	bison -d script_parser.y -b script_parser
     
clean:
	rm -f $(BUILT_SOURCES) $(BUILT_HEADERS) $(BINARY)
