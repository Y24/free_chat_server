import 'dart:convert';
import 'dart:io';

import 'package:free_chat/protocol/entity/chat_protocol_entity.dart';
import 'package:free_chat/protocol/sender/base_protocol_sender.dart';

abstract class IChatProtocolSender implements IProtocolSender {}

class ChatProtocolSender extends BaseProtocolSender
    implements IChatProtocolSender {
  final id;
  final String password;
  final String from;
  final String to;
  final bool groupChatFlag;
  ChatProtocolEntity protocolEntity;
  ChatProtocolSender(
      {this.id, this.password, this.from, this.to, this.groupChatFlag});
  @override
  bool init(WebSocket webSocket) {
    return super.setUp(webSocket);
  }

  @override
  bool send() {
    try {
      final data = json.encode(protocolEntity.toJson());
      print('send: $data');
      webSocket.add(data);
      return true;
    } catch (e) {
      print('chat _send error: $e');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    await super.close();
  }

  @override
  get entity => protocolEntity;

  @override
  void setEntity(entity) {
    protocolEntity = entity;
  }
}
