CFLAGS=-Wall -pedantic -Wextra -Werror -fsanitize=undefined -fsanitize=address -fno-omit-frame-pointer

main: src/main.c src/letters.h Makefile
	${CC} ${CFLAGS} -lm -o $@ $<
