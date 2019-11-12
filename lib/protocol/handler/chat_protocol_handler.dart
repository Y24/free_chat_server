import 'dart:convert';
import 'dart:io';

import 'package:free_chat/enums.dart';
import 'package:free_chat/protocol/entity/chat_protocol_entity.dart';
import 'package:free_chat/protocol/entity/handle_result_entity.dart';
import 'package:free_chat/protocol/handler/base_protocol_handler.dart';

abstract class IChatProtocolHandler implements IProtocolHandler {
  Future<HandleResultEntity> handleNewSend();
  Future<HandleResultEntity> handleReSend();
  Future<HandleResultEntity> handleAccept();
  Future<HandleResultEntity> handleReject();
}

class ChatProtocolHandler extends BaseProtocolHandler
    implements IChatProtocolHandler {
  final id;
  final String password;
  final String from;
  final String to;
  final String content;
  final bool groupChatFlag;
  WebSocket _webSocket;
  ChatProtocolEntity protocolEntity;
  ChatProtocolHandler(
      {this.id,
      this.password,
      this.from,
      this.to,
      this.groupChatFlag,
      this.content});
  @override
  String get collectionName => 'chat';
  @override
  Future<bool> init() {
    return super.setUp();
  }

  @override
  Future<HandleResultEntity> handle(WebSocket webSocket) async {
    _webSocket = webSocket;
    switch (protocolEntity.head.code as ChatProtocolCode) {
      case ChatProtocolCode.newSend:
        return await handleNewSend();
      case ChatProtocolCode.reSend:
        return await handleReSend();
      case ChatProtocolCode.accept:
        return await handleAccept();
      case ChatProtocolCode.reject:
        return await handleReject();
    }
    print('Here is a bug to be fixed');
    return null;
  }

  Future<bool> _authenticate() async => true;
  /* await collection
          .findOne(where.eq('username', from).eq('password', password)) !=
      null; */
  void _response({ChatProtocolCode code, String content}) {
    final data = json.encode(ChatProtocolEntity(
      head: ChatHeadEntity(
        id: protocolEntity.head.id,
        code: code,
        timestamp: protocolEntity.head.timestamp,
        from: protocolEntity.head.from,
        to: protocolEntity.head.to,
        groupChatFlag: protocolEntity.head.groupChatFlag,
      ),
      body: ChatBodyEntity(content: content),
    ).toJson());
    print('data: $data');
    _webSocket.add(data);
  }

  @override
  Future<HandleResultEntity> handleNewSend() async {
    if (!await init()) {
      _response(code: ChatProtocolCode.reject, content: 'server');
      return HandleResultEntity(
        code: ChatProtocolCode.newSend,
        content: SendStatus.serverError,
      );
    }
    if (await _authenticate()) {
      //TODO:
      print(
          'handleNewSend: id: ${protocolEntity.head.id},content: ${protocolEntity.body.content}');
      _response(code: ChatProtocolCode.accept, content: 'Free Chat');
      return HandleResultEntity(
        code: ChatProtocolCode.newSend,
        content: SendStatus.success,
      );
    } else {
      _response(code: ChatProtocolCode.reject, content: 'password');
      return HandleResultEntity(
        code: ChatProtocolCode.newSend,
        content: SendStatus.reject,
      );
    }
  }

  @override
  Future<HandleResultEntity> handleAccept() async {
    if (!await init()) {
      _response(code: ChatProtocolCode.reject, content: 'server');
      return HandleResultEntity(
        code: ChatProtocolCode.accept,
        content: false,
      );
    }
    if (await _authenticate()) {
      //TODO:
      print('HandleAccept: username: $id,content: $content');
      return HandleResultEntity(
        code: ChatProtocolCode.accept,
        content: true,
      );
    } else {
      return HandleResultEntity(
        code: ChatProtocolCode.accept,
        content: false,
      );
    }
  }

  @override
  Future<HandleResultEntity> handleReSend() async {
    if (!await init()) {
      _response(code: ChatProtocolCode.reject, content: 'server');
      return HandleResultEntity(
        code: ChatProtocolCode.reSend,
        content: false,
      );
    }
    if (await _authenticate()) {
      //TODO:
      return HandleResultEntity(
        code: ChatProtocolCode.reSend,
        content: true,
      );
    } else {
      _response(code: ChatProtocolCode.reject, content: 'password');
      return HandleResultEntity(
        code: ChatProtocolCode.reSend,
        content: false,
      );
    }
  }

  @override
  Future<HandleResultEntity> handleReject() async {
    if (!await init()) {
      _response(code: ChatProtocolCode.reject, content: 'server');
      return HandleResultEntity(
        code: ChatProtocolCode.reject,
        content: false,
      );
    }
    if (await _authenticate()) {
      //TODO:
      return HandleResultEntity(
        code: ChatProtocolCode.reject,
        content: true,
      );
    } else {
      return HandleResultEntity(
        code: ChatProtocolCode.reject,
        content: false,
      );
    }
  }

  @override
  Future<void> dispose({bool reserveWs = true}) async {
    await super.close;
    if (!reserveWs) await _webSocket?.close();
  }

  @override
  get entity => protocolEntity;

  @override
  void setEntity(entity) {
    protocolEntity = entity;
  }
}
