import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:wstan_dart/path.dart';

Future<HttpServer> createServer(address, port) async {
  return await HttpServer.bind(address, port);
}

webSocketMessageHandler(Uint8List data) {
  // Stops here
}

useWebSocket(HttpRequest req) async {
  var socket = await WebSocketTransformer.upgrade(req);
  socket.listen(webSocketMessageHandler);
}

handleHttpRequest(server) async {
  await for (HttpRequest req in server) {
    if (isValidPath(req.uri.path)) {
      await useWebSocket(req);
    } else {
      throw new Exception('requested invalid path');
    }
  }
}

start(address, port) async {
  try {
    var server = await createServer(address, port);
    await handleHttpRequest(server);
  } catch (e) {
    print(e);
  }
}