// Copyright (c) 2017, kari. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

class ListTag<T> {
  List<T> _list;
  List<T> get list => this._list;
  
  int _start;
  int get start => this._start;
  int _end;
  int get end => this._end;

  ListTag(int start, int end, List<T> list){
    this._start = start;
    this._end = end;
    this._list = list;
  }

  List<T> get() {
    try {
      return this._list.sublist(this._start, this._end);
    } catch (e) {
      throw e;
    }
  }

  T getFirst() {
    try {
      return this._list[this._start];
    } catch (e) {
      throw new Exception('Can not get the first item.');
    }
  }
}

class WstanMessage {
  static const int CMD_REQ = 0x00;
  static const int CMD_DAT = 0x01;
  static const int CMD_RES = 0x02;

  static const int IPv4 = 0x01;
  static const int DOMAIN_NAME = 0x03;
  static const int IPv6 = 0x04;


  int _type;
  int get type => _type;
  List<int> _message;
  List<int> get message => this._message;
  Map<String, ListTag<int>> _fields = new Map();
  Map<String, ListTag<int>> get fields => _fields;

  WstanMessage.parse(List<int> message) {
    this._message = message;
    this._type = message[0];
    
    switch (this._type) {
      case WstanMessage.CMD_REQ:
        this._setRequestCommandFields();
        break;
      case WstanMessage.CMD_DAT:
        this._setDataCommandFields();
        break;
      case WstanMessage.CMD_RES:
        this._setResetCommandFields();
        break;
      default:
        throw new Exception('Can not parse message type');
    }
  }

  void _setRequestCommandFields() {
    this._fields['type']         = new ListTag(0, 1, _message);
    this._fields['timestamp']    = new ListTag(1, 9, _message);
    this._fields['reserved']     = new ListTag(9, 10, _message);
    this._fields['address-type'] = new ListTag(10, 11, _message);
    var addressType = this._fields['address-type'].getFirst();

    switch (addressType) {
      case WstanMessage.IPv4:
        this._fields['address'] = new ListTag(11, 15, _message);
        this._fields['port']    = new ListTag(15, 17, _message);
        this._fields['data']    = new ListTag(17, _message.length - 10, _message);
        this._fields['hmac']    = new ListTag(_message.length - 10, _message.length, _message);
        
        break;
      case WstanMessage.IPv6:
        this._fields['address'] = new ListTag(11, 27, _message);
        this._fields['port']    = new ListTag(27, 29, _message);
        this._fields['data']    = new ListTag(29, _message.length - 10, _message);
        this._fields['hmac']    = new ListTag(_message.length - 10, _message.length, _message);
        break;
      case WstanMessage.DOMAIN_NAME:
        this._fields['address-length'] = new ListTag(11, 12, _message);
        var addressLength = this._fields['address-length'].getFirst();
        
        this._fields['address'] = new ListTag(12, 12 + addressLength, _message);
        this._fields['port']    = new ListTag(12 + addressLength, 14 + addressLength, _message);
        this._fields['data']    = new ListTag(14 + addressLength, _message.length - 10, _message);
        this._fields['hmac']    = new ListTag(_message.length - 10, _message.length, _message);
        break;
      default:
        throw new Exception('Can not parse request message address type');
    }
  }

  void _setDataCommandFields() {
    this._fields['type'] = new ListTag(0, 1, _message);
    this._fields['data'] = new ListTag(1, _message.length, _message);
  }

  void _setResetCommandFields() {
    this._fields['type']   = new ListTag(0, 1, _message);
    this._fields['reason'] = new ListTag(1, _message.length - 10, _message);
    this._fields['hmac']   = new ListTag(_message.length - 10, _message.length, _message);
  }
}
