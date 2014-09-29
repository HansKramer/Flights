/*
        Author : Hans Kramer

          Date : September 2013

     Copyright : Hans Kramer

 */


import "package:WebSocketServer/WebSocketServer.dart";

import "ChatServer.dart";


main() {
    WebSocketServer ss = new WebSocketServer(allow: ["Echo", "ChatServer"]);
}
