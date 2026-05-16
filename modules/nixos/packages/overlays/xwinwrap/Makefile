CC = gcc
CFLAGS= -g -Wall
INCLUDE = -L /usr/lib/x86_64-linux-gnu
LIBS = -lX11 -lXext -lXrender

all:
	${CC} xwinwrap.c ${CFLAGS} ${INCLUDE} ${LIBS} -o xwinwrap

install:
	cp xwinwrap ~/.local/bin/xwinwrap

clean:
	rm -f xwinwrap
