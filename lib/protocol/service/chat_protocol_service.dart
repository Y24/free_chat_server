import 'dart:io';

import 'package:free_chat/protocol/entity/handle_result_entity.dart';
import 'package:free_chat/protocol/handler/base_protocol_handler.dart';
import 'package:free_chat/protocol/sender/base_protocol_sender.dart';
import 'package:free_chat/protocol/service/base_protocol_service.dart';

class ChatProtocolService implements IProtocolService {
  dynamic protocolEntity;
  final IProtocolSender protocolSender;
  final IProtocolHandler protocolHandler;
  ChatProtocolService({this.protocolSender, this.protocolHandler});

  @override
  Future<bool> init(WebSocket webSocket) async {
    return protocolSender.init(webSocket) && await protocolHandler.init();
  }

  @override
  Future<HandleResultEntity> handle(WebSocket webSocket) async {
    protocolHandler.setEntity(protocolEntity);
    return await protocolHandler.handle(webSocket);
  }

  @override
  send() {
    protocolSender.setEntity(protocolEntity);
    return protocolSender.send();
  }

  @override
  Future<void> dispose({bool reserveWs = true}) async {
    if (!reserveWs) await protocolSender.dispose();
    await protocolHandler.dispose();
  }

  @override
  get entity => protocolEntity;

  @override
  void setEntity(entity) {
    protocolEntity = entity;
  }
}
