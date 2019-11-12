import 'dart:convert';
import 'dart:io';

import 'package:free_chat/enums.dart';
import 'package:free_chat/protocol/entity/account_protocol_entity.dart';
import 'package:free_chat/protocol/entity/handle_result_entity.dart';
import 'package:free_chat/protocol/handler/base_protocol_handler.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class IAccountProtocolHandler implements IProtocolHandler {
  Future<HandleResultEntity> handleLogin();
  Future<HandleResultEntity> handleLogout();
  Future<HandleResultEntity> handleRegister();
  Future<HandleResultEntity> handleCleanUp();
}

class AccountProtocolHandler extends BaseProtocolHandler
    implements IAccountProtocolHandler {
  final String username;
  final String password;
  WebSocket _webSocket;
  AccountProtocolEntity protocolEntity;
  AccountProtocolHandler({this.username, this.password});
  @override
  String get collectionName => 'account';
  @override
  Future<bool> init() {
    return super.setUp();
  }

  @override
  Future<HandleResultEntity> handle(WebSocket webSocket) async {
    _webSocket = webSocket;
    switch (protocolEntity.head.code as AccountProtocolCode) {
      case AccountProtocolCode.login:
        return await handleLogin();
      case AccountProtocolCode.logout:
        return await handleLogout();
      case AccountProtocolCode.register:
        return await handleRegister();
      case AccountProtocolCode.cleanUp:
        return await handleCleanUp();
    }
    print('Here is a bug to be fixed');
    return null;
  }

  Future<bool> _authenticate() async {
    final result = await collection.findOne(where.eq('username', username));
    print('account: $result');
    return await collection
            .findOne(where.eq('username', username).eq('password', password)) !=
        null;
  }

  void _failtureResponse({String content}) {
    _webSocket.add(json.encode(AccountProtocolEntity(
      head: AccountHeadEntity(
        id: username,
        code: false,
        timestamp: DateTime.now(),
      ),
      body: AccountBodyEntity(content: content),
    ).toJson()));
  }

  void _successResponse() {
    _webSocket.add(json.encode(AccountProtocolEntity(
      head: AccountHeadEntity(
        id: username,
        code: true,
        timestamp: DateTime.now(),
      ),
      body: AccountBodyEntity(content: "Free Chat"),
    ).toJson()));
  }

  @override
  Future<HandleResultEntity> handleRegister() async {
    if (!await init()) {
      _failtureResponse(content: 'server');
      return HandleResultEntity(
        code: AccountProtocolCode.register,
        content: RegisterStatus.serverError,
      );
    }
    final result = await collection.findOne(where.eq('username', username));
    if (result != null) {
      _failtureResponse(content: 'username');
      return HandleResultEntity(
        code: AccountProtocolCode.register,
        content: RegisterStatus.invalidUsername,
      );
    } else {
      await collection.insert({
        'username': username,
        'password': password,
        'timestamp': DateTime.now(),
        'role': FunctionPool.getStrByRole(Role.user),
      });
      _successResponse();
      return HandleResultEntity(
        code: AccountProtocolCode.register,
        content: RegisterStatus.success,
      );
    }
  }

  @override
  Future<HandleResultEntity> handleLogin() async {
    if (!await init()) {
      _failtureResponse(content: 'server');
      return HandleResultEntity(
        code: AccountProtocolCode.login,
        content: LoginStatus.serverError,
      );
    }
    if (await _authenticate()) {
      _successResponse();
      return HandleResultEntity(
        code: AccountProtocolCode.login,
        content: LoginStatus.authenticationsuccess,
      );
    } else {
      _failtureResponse(content: 'password');
      return HandleResultEntity(
        code: AccountProtocolCode.login,
        content: LoginStatus.authenticationFailture,
      );
    }
  }

  @override
  Future<HandleResultEntity> handleCleanUp() async {
    if (!await init()) {
      _failtureResponse(content: 'server');
      return HandleResultEntity(
        code: AccountProtocolCode.cleanUp,
        content: LogoutOrCleanUpStatus.serverError,
      );
    }
    if (await _authenticate()) {
      await collection
          .remove(where.eq('username', username).eq('password', password));
      _successResponse();
      return HandleResultEntity(
        code: AccountProtocolCode.cleanUp,
        content: LogoutOrCleanUpStatus.success,
      );
    } else {
      _failtureResponse(content: 'password');
      return HandleResultEntity(
        code: AccountProtocolCode.cleanUp,
        content: LogoutOrCleanUpStatus.authenticationFailture,
      );
    }
  }

  @override
  Future<HandleResultEntity> handleLogout() async {
    if (!await init()) {
      _failtureResponse(content: 'server');
      return HandleResultEntity(
        code: AccountProtocolCode.logout,
        content: LogoutOrCleanUpStatus.serverError,
      );
    }
    if (await _authenticate()) {
      _successResponse();
      return HandleResultEntity(
        code: AccountProtocolCode.logout,
        content: LogoutOrCleanUpStatus.success,
      );
    } else {
      _failtureResponse(content: 'password');
      return HandleResultEntity(
        code: AccountProtocolCode.logout,
        content: LogoutOrCleanUpStatus.authenticationFailture,
      );
    }
  }

  @override
  Future<void> dispose() async {
    await super.close();
    await _webSocket?.close();
  }

  @override
  get entity => protocolEntity;

  @override
  void setEntity(entity) {
    protocolEntity = entity;
  }
}
