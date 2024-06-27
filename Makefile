CC = gcc
CFLAGS = -Wall -Wextra -ansi
SRC_DIR = src
TARGET = parser
FILENAME = parser.c

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(SRC_DIR)/$(TARGET) $(SRC)

clean:
	rm -f $(SRC_DIR)/$(TARGET)
