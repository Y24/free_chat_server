import 'dart:io';

import 'package:free_chat/protocol/entity/handle_result_entity.dart';

abstract class IProtocolService {
  Future<bool> init(WebSocket webSocket);
  bool send();
  Future<HandleResultEntity> handle(WebSocket webSocket);
  Future<void> dispose();
  get entity;
  void setEntity(entity);
}
