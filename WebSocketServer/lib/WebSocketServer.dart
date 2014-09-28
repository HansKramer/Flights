/*
        Author : Hans Kramer

          Date : September 2013

     Copyright : Hans Kramer

 */

library WebSocketServer;

import 'dart:io';
import 'dart:math';
import 'dart:async';

import "dart:mirrors";

import "package:DynamicClassInstance/DynamicClassInstance.dart";

import "dart:convert";


class WebSocketServer {
    
    Future       webserver;
    list<string> allow;

    WebSocketServer({int port: 8081, list<string> allow: null}) {
        this.allow = allow;

        this.webserver = HttpServer.bind('0.0.0.0', port);

        this.webserver.then(this.on_startup);
    }

    void on_startup(HttpServer server) {
        server.listen(on_connection);
    }

    void on_connection(HttpRequest request) {
        String method = request.uri.path.toString().substring(1);
        if (this.allow == null || this.allow.contains(method))
            new DynamicClassInstance(method, arguments : [request, request.uri.queryParameters]); 
    }

}


abstract class WebSocketHandler {

    var socket;

    WebSocketHandler(HttpRequest request) {
        WebSocketTransformer.upgrade(request).then((WebSocket socket) {
            this.socket = socket;
            socket.listen(this.on_data, onDone: on_close);
            this.on_open();
        });
    }

    void send(message) {
        this.socket.add(message);
    }

    void on_data(e) {}

    void on_close() {}

    void on_open()  {}
}


abstract class WebSocketHandlerSingleton {

    var sockets;

    WebSocketHandlerSingleton() {
        this.sockets = [];
    }

    static function factory_constructor(var self, HttpRequest request, var args) {
        WebSocketTransformer.upgrade(request).then((WebSocket socket) {
            self.sockets.add(socket);
            self.on_open(socket, args);
            socket.listen(
                (e)         => self.on_data(e, socket), 
                onDone:  () {
                    self.on_close(socket);
                    self.sockets.remove(socket);
                },
                onError: () => print("awwww error")
            );
        });
    }

    void send(var message, {var except: null}) {
        if (except == null) 
            this.sockets.forEach((socket) => socket.add(message));
        else 
            if (except is List) 
                this.sockets.forEach((socket) => (! except.contains(socket)) && socket.add(message));
            else
                this.sockets.forEach((socket) => (socket != except) && socket.add(message));
    }

    void on_data(var event, WebSocket socket) {print("debug on_data");}

    void on_close(WebSocket socket) {print("debug on_close");}

    void on_open(WebSocket socket, var args) {print("debug on_open");}
}
