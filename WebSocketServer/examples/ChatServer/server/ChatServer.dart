/*
        Author : Hans Kramer

          Date : Aug 2014

     Copyright : Hans Kramer

          Code : Example code demonstrating how to use the WebSockerServer

 */

library ChatServer;


import "dart:io";
import "dart:convert";

import "package:WebSocketServer/WebSocketServer.dart";


class ChatServer extends WebSocketHandlerSingleton {

    var user_list;

    static ChatServer self = new ChatServer.constructor();

    ChatServer.constructor() {
        this.user_list = {};
    }

    factory ChatServer(HttpRequest request, var args) => WebSocketHandlerSingleton.factory_constructor(self, request, args);

    void on_open(WebSocket socket, var args) {
        if (! args.containsKey('user')) 
            return;

        string name = this.get_unique_name(args['user'].toLowerCase());
            
        this.user_list[socket] = name;

        socket.add(JSON.encode(['connected', name]));
        this.send(JSON.encode(['message', name + " connected to chat"]), except: [socket,]);
        this.send(JSON.encode(['users',   this.user_list.values.toList()]));
    }

    void on_data(var event, var socket) {
        this.send(JSON.encode(['chat', this.user_list[socket], event]));
    }

    void on_close(var socket) {
        this.send(JSON.encode(['message', this.user_list[socket] + " left chat"]));
        this.user_list.remove(socket);
        this.send(JSON.encode(['users',   this.user_list.values.toList()]));
    }

    string get_unique_name(string name) {
        name = name.trim();
        if (name == "")
            name = "user";

        var your_name = name;
        for (int i=2; this.user_list.containsValue(your_name); i++)
            your_name = "${name} #" + i.toString();

        return your_name;
    }
}
