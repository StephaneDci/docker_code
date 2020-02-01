#!/usr/bin/python

# NB python 3
#https://docs.python.org/3/library/http.server.html

import http.server
import socketserver

PORT = 6789

Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("Python : serving at port", PORT)
    httpd.serve_forever()
