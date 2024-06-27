CC = gcc
CFLAGS = -Wall -Wextra -ansi
SRC_DIR = src
TARGET = parser
FILENAME = parser.c
TARGET_DEBUG = debug

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC_DIR)/$(FILENAME)

$(TARGET_DEBUG): $(SRC)
	$(CC) $(CFLAGS) -DDEBUG -o $(TARGET) $(SRC_DIR)/$(FILENAME)

.PHONY: clean

clean:
	rm -f $(TARGET)
