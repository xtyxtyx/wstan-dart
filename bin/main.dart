// Copyright (c) 2017, kari. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/api.dart';

import 'package:wstan_dart/wstan_dart.dart' show WstanMessage, ListTag;

AESFastEngine aesEngine = new AESFastEngine();


main(List<String> arguments) async {
  String address = 'localhost';
  int port = 1080;
  String password = 'yGSt1AHtRPtNYQWW6ZUqjg==';

  var key = 
  aesEngine.init(false, new KeyParameter(key));

  var server = await HttpServer.bind(address, port);
  server.listen(requestListener);

}

requestListener(HttpRequest req) async {
  WebSocket webSocket = await WebSocketTransformer.upgrade(request);
  Socket freeSocket;
  await for (var data in webSocket) {
    var message = new WstanMessage.parse(data);

    switch (message.type) {
      case WstanMessage.CMD_REQ:
        var address = message.fields['address'].get().join('.');
        var port    = calculatePort(message.fields['port'].get());
        freeSocket  = await Socket.connect(address, port);
        // Pass the data from freeSocket to websocket ,
        // in which a type field is added to the data
        await for (var data in freeSocket) {
          webSocket.add([WstanMessage.CMD_DAT].add(data));
        }
        break;
      case WstanMessage.CMD_DAT:
        freeSocket.write(message.fields['data']);
        break;
      case WstanMessage.CMD_RES:
        freeSocket.destroy();
        break;
      default:
        throw new Exception('Unknown type.');
    }
  }
}

int calculatePort(List<int> data) => data[0] + data[1];
StreamTransformer<List<int>> warpData(List<int> data) async* {
  data.insert(0, WstanMessage.CMD_DAT);
  yield data;
}