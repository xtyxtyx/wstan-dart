// Copyright (c) 2017, kari. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:wstan_dart/wstan_dart.dart';
import 'package:test/test.dart';

void main() {
  test('ListTag', () {
    var list = [1, 2, 3, 4, 5, 6, 7];
    var listTag = new ListTag<int>(2, 5, list);
    var result = listTag.get();
    var resultFirst = listTag.getFirst();

    expect(result, [3, 4, 5]);
    expect(resultFirst, 3);
  });

  test('WstanMessage', () {
    var reqMessage = [0x00, 
                      0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
                      0x00,
                      0x01,
                      0x03, 0x03, 0x03, 0x03,
                      0x04, 0x04,
                      0x05, 0x05, 0x05,
                      0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06];
    var wstanMessage = new WstanMessage.parse(reqMessage);

    var type = wstanMessage.type;
    expect(type, WstanMessage.CMD_REQ);

    var timestamp = wstanMessage.fields['timestamp'].get();
    expect(timestamp, [0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01]);

    var reserved = wstanMessage.fields['reserved'].get();
    expect(reserved, [0x00]);

    var addressType = wstanMessage.fields['address-type'].get();
    expect(addressType, [0x01]);

    var address = wstanMessage.fields['address'].get();
    expect(address, [0x03, 0x03, 0x03, 0x03]);

    var port = wstanMessage.fields['port'].get();
    expect(port, [0x04, 0x04]);

    var data = wstanMessage.fields['data'].get();
    expect(data, [0x05, 0x05, 0x05]);

    var hmac = wstanMessage.fields['hmac'].get();
    expect(hmac, [0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06]);
  });
}
