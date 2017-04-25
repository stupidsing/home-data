#!/usr/bin/python
import socket
import sys
import thread

def server(settings):
	try:
		dock_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		dock_socket.bind(('', settings[2]))
		dock_socket.listen(5)
		while True:
			client_socket = dock_socket.accept()[0]
			server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			server_socket.connect((settings[0], settings[1]))
			thread.start_new_thread(forward, (client_socket, server_socket))
			thread.start_new_thread(forward, (server_socket, client_socket))
	finally:
		thread.start_new_thread(server, settings)

def forward(source, destination):
	string = ' '
	while string:
		string = source.recv(1024)
		if string:
			destination.sendall(string)
		else:
			source.shutdown(socket.SHUT_RD)
			destination.shutdown(socket.SHUT_WR)

if __name__ == '__main__':
	thread.start_new_thread(server, (['127.0.0.1', 8080, 80],))
	lock = thread.allocate_lock()
	lock.acquire()
	lock.acquire()
