import 'dart:async';
import 'dart:io';

abstract class IProtocolSender {
  bool init(WebSocket webSocket);
  bool send();
  Future<void> dispose();
  get entity;
  void setEntity(entity);
}

abstract class BaseProtocolSender {
  WebSocket webSocket;
  bool _connected = false;

  bool setUp(WebSocket ws) {
    if (_connected && webSocket != null) return true;
    if (ws != null) {
      webSocket = ws;
      _connected = true;
      return true;
    } else {
      return false;
    }
  }

  Future<void> close() async {
    _connected = false;
    await webSocket?.close();
  }
}
