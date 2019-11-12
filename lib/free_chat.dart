import 'dart:convert';
import 'dart:io';

import 'package:free_chat/enums.dart';
import 'package:free_chat/util/function_pool.dart';

class ChatProtocol {
  bool _connected = false;
  final int userId;
  final int toId;
  final bool isGroupChat;
  ProtocolEntity protocol;
  Stream<ProtocolEntity> protocolStream;
  WebSocket webSocket;
  ChatProtocol({
    this.userId,
    this.toId,
    this.isGroupChat,
    this.webSocket,
  });
  bool get connected => _connected;
  void newSend({
    int id,
    String content,
    DateTime timestamp,
  }) {
    assert(connected == true, '');
    protocol = ProtocolEntity(
      head: HeadEntity(
        id: id,
        code: ChatProtocolCode.newSend,
        timestamp: timestamp,
        isGroupChat: isGroupChat,
        fromId: userId,
        toId: toId,
      ),
      body: BodyEntity(
        message: Message(
          id: id,
          content: content,
        ),
      ),
    );
    webSocket.add(json.encode(protocol.toJson()));
  }

  bool close() {
    if (connected) webSocket.close();
    return connected;
  }
}

class ProtocolEntity {
  final HeadEntity head;
  final BodyEntity body;
  const ProtocolEntity({this.head, this.body})
      : assert(head != null),
        assert(body != null);
  ProtocolEntity.fromJson(Map<String, dynamic> j)
      : assert(j != null),
        head = HeadEntity.fromJson(json.decode(j['head'])),
        body = BodyEntity.fromJson(json.decode(j['body']));
  Map<String, dynamic> toJson() => {
        'head': json.encode(head.toJson()),
        'body': json.encode(body.toJson()),
      };
}

class HeadEntity {
  final int id;
  final ChatProtocolCode code;
  final DateTime timestamp;
  final bool isGroupChat;
  final int fromId;
  final int toId;
  HeadEntity({
    this.id,
    this.code,
    this.timestamp,
    this.isGroupChat,
    this.fromId,
    this.toId,
  })  : assert(id != null),
        assert(code != null),
        assert(timestamp != null),
        assert(isGroupChat != null),
        assert(fromId != null),
        assert(toId != null);
  HeadEntity.fromJson(Map<String, dynamic> j)
      : assert(j != null),
        id = j['id'],
        code = FunctionPool.getChatProtocolCodeByStr(j['code']),
        timestamp = DateTime.parse(j['timestamp']),
        isGroupChat = j['isGroupChat'],
        fromId = j['fromId'],
        toId = j['toId'];
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': FunctionPool.getStrByChatProtocolCode(code),
        'timestamp': timestamp.toString(),
        'isGroupChat': isGroupChat,
        'fromId': fromId,
        'toId': toId,
      };
}

class BodyEntity {
  final Message message;

  const BodyEntity({this.message}) : assert(message != null);
  BodyEntity.fromJson(Map<String, dynamic> j)
      : assert(j != null),
        message = Message.fromJson(json.decode(j['message']));

  Map<String, dynamic> toJson() => {
        'message': json.encode(message.toJson()),
      };
}

class Message {
  final int id;
  final String content;

  const Message({
    this.id,
    this.content,
  })  : assert(id != null),
        assert(content != null);
  Message.fromJson(final Map<String, dynamic> json)
      : assert(json != null),
        id = json['id'],
        content = json['content'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
      };
}
