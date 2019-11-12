import 'dart:async';
import 'dart:io';

import 'package:free_chat/protocol/entity/handle_result_entity.dart';
import 'package:free_chat/util/db_util.dart';
import 'package:mongo_dart/mongo_dart.dart';

typedef OnDataCallBack = void Function(dynamic);
typedef VoidCallback = void Function();

abstract class IProtocolHandler {
  Future<bool> init();
  Future<HandleResultEntity> handle(WebSocket webSocket);
  Future<void> dispose();
  get entity;
  void setEntity(entity);
}

abstract class BaseProtocolHandler {
  static final dbName = 'free_chat';
  Db _db;
  DbCollection _dbCollection;
  bool _connected = false;
  String get collectionName;
  DbCollection get collection => _dbCollection;
  bool get connected => _connected;
  Future<void> cleanUp() async {
    await _db?.close();
    _db = null;
    _connected = false;
  }

  Future<bool> setUp() async {
    if (_connected && _db != null && _dbCollection != null) return true;
    await cleanUp();
    try {
      _db = await DbUtil(dbname: dbName).db;
      _dbCollection = _db.collection(collectionName);
      _connected = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> close() async {
    await cleanUp();
  }
}
