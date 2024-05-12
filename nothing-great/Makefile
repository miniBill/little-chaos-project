CFLAGS=-Wall -pedantic -Wextra -Werror -fsanitize=undefined -fsanitize=address -fno-omit-frame-pointer

main: $(wildcard src/*.*) Makefile
	${CC} ${CFLAGS} -lm -o $@ src/main.c
