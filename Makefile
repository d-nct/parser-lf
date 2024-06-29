CC = gcc
CFLAGS = -Wall -Wextra -ansi
SRC_DIR = src
TARGET = parser
FILENAME = main.c
TARGET_DEBUG = debug

.PHONY: clean

$(TARGET): $(SRC)
	@$(CC) $(CFLAGS) -o $(TARGET) $(SRC_DIR)/$(FILENAME)

$(TARGET_DEBUG): $(SRC)
	$(CC) $(CFLAGS) -DDEBUG -o $(TARGET) $(SRC_DIR)/$(FILENAME)

clean:
	@rm -f $(TARGET)
