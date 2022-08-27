
CC=gcc
CFLAGS=-fPIC -pedantic -Wall -Wextra -march=native -shared

TARGET=empty_gym.so
SOURCES=$(shell echo c_src/*.c)
OBJECTS=$(SOURCES:.c=.o)

all: $(TARGET)

clean:
	rm -f ${OBJECTS} ${TARGET}

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS)

