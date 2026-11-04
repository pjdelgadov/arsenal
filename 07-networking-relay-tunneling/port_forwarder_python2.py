#!/usr/bin/env python2
import socket
import select
import sys

LISTEN_IP = "172.16.1.23"
LISTEN_PORT = 445

REMOTE_IP = "10.10.14.30"
REMOTE_PORT = 445

def forward(client):
    remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    remote.connect((REMOTE_IP, REMOTE_PORT))

    sockets = [client, remote]

    while True:
        readable, _, errored = select.select(sockets, [], sockets)
        if errored:
            break

        for s in readable:
            try:
                data = s.recv(8192)
            except:
                return

            if not data:
                return

            if s is client:
                remote.sendall(data)
            else:
                client.sendall(data)

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LISTEN_IP, LISTEN_PORT))
    server.listen(50)

    print("[+] Listening on %s:%d -> %s:%d" % (LISTEN_IP, LISTEN_PORT, REMOTE_IP, REMOTE_PORT))

    while True:
        client, addr = server.accept()
        print("[+] Connection from %s:%d" % addr)

        pid = os.fork() if hasattr(os, "fork") else None
        if pid == 0:
            server.close()
            forward(client)
            client.close()
            sys.exit(0)
        elif pid:
            client.close()
        else:
            forward(client)
            client.close()

if __name__ == "__main__":
    import os
    main()