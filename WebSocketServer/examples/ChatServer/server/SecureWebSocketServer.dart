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

import "DynamicClassInstance.dart";




import "dart:convert";


class WebSocketDispatcher {

    var sockets;

    static final WebSocketDispatcher _wsd = new WebSocketDispatcher.create();

    factory WebSocketDispatcher(HttpRequest request) {
        WebSocketTransformer.upgrade(request).then((WebSocket socket) {
            _wsd.add(socket);
            socket.listen((e) => _wsd.handle_request(e), onDone: () => _wsd.sockets.remove(socket));
        });

        return _wsd;
    }

    WebSocketDispatcher.create() {
        print("create\n");
        this.sockets = new List();
    }

    void handle_request(var e) {
        print("handle request : " + e);
    }

    void on_close(var s) {
        print("close");
        this.sockets.remove(s);
    }

    void add(var socket) {
        sockets.add(socket);
        for (WebSocket s in sockets) {
            print(s);
            s.add(JSON.encode(["hello", "fuckers"]));
        }
    }
/* 
    WebSocketHandler(HttpRequest request) {
        WebSocketTransformer.upgrade(request).then((WebSocket socket) {
            this.socket = socket;
            socket.listen(this.on_data, onDone: on_close);
            this.on_open();
        });
    }
*/
}


class SecureWebSocketServer {
    Future webserver;

    SecureWebSocketServer([int port = 8433]) {
        this.webserver = HttpServer.bindSecure('0.0.0.0', port, certificateName: "CN=dartcert")

        this.webserver.then(this.on_startup);
    }
}

class WebSocketServer {
    
    Future webserver;

    WebSocketServer([int port = 8081]) {
        this.webserver = HttpServer.bind('0.0.0.0', port);

        this.webserver.then(this.on_startup);
    }

    void on_startup(HttpServer server) {
        server.listen(on_connection);
    }

    void on_connection(HttpRequest request) {
print("on connection");
        String method = request.uri.path.toString().substring(1);
        if (request.uri.queryParameters.containsKey("instance"))
            print(request.uri.queryParameters["instance"]);
//        WebSocketDispatcher wsd = new WebSocketDispatcher(request);
//print(wsd);
print("Method : " + method);
//print(request.uri.path);
//request.uri.queryParameters.forEach( (key, value) => print(value + key));
        new DynamicClassInstance(method, arguments : [request,]);
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

