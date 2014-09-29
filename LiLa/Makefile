#g++ -I/opt/google/dartsdk/include -c lila-socket.c
#gcc -shared -Wl,-soname,liblila-socket.so -o liblila-socket.so lila-socket.o



lib/liblila_socket.so:	lila-socket.o
		gcc -shared -Wl,-soname,liblila_socket.so -o lib/liblila_socket.so lila-socket.o

lila-socket.o:		lila-socket.c lila-socket-const.dart
		g++ -I/opt/google/dartsdk/ -c lila-socket.c

lila-socket-const.dart:
		cat $(shell dpkg -L libc6-dev | grep bits/socket.h) | egrep "#define.(AF_|PF_)" | awk '{print $2}'
