import 'dart:convert';
import 'dart:io';

import 'package:free_chat/enums.dart';
import 'package:free_chat/protocol/entity/account_protocol_entity.dart';
import 'package:free_chat/protocol/entity/chat_protocol_entity.dart';
import 'package:free_chat/protocol/handler/account_protocol_handler.dart';
import 'package:free_chat/protocol/handler/base_protocol_handler.dart';
import 'package:free_chat/protocol/handler/chat_protocol_handler.dart';
import 'package:free_chat/protocol/sender/chat_protocol_sender.dart';
import 'package:free_chat/protocol/service/base_protocol_service.dart';
import 'package:free_chat/protocol/service/chat_protocol_service.dart';
import 'package:free_chat/protocol/transfer/base_transfer_entity.dart';
import 'package:free_chat/protocol/transfer/message_transfer_entity.dart';
import 'package:observable/observable.dart';

List<ListChangeRecord> getListChangeRecords(
        List<ListChangeRecord> changes, int index) =>
    List.from(changes.where((ListChangeRecord c) => c.indexChanged(index)));

List<PropertyChangeRecord> getPropertyChangeRecords(
        List<ChangeRecord> changes, Symbol property) =>
    List.from(changes.where(
        (ChangeRecord c) => c is PropertyChangeRecord && c.name == property));

main(List<String> arguments) async {
  final socketPool = Map<String, ObservableList<WebSocket>>();
  final servicePool = ObservableMap<int, IProtocolService>();
  final serviceNamePool = <int, String>{};
  final transferPool =
      ObservableMap<String, ObservableList<BaseTransferEntity>>();
  servicePool.changes.listen((records) {
    //clean up dead and empty socket
    final record = getPropertyChangeRecords(records, #length)[0];
    if (record != null && record.newValue > record.oldValue) {
      print('${record.newValue}:${record.oldValue}');
      servicePool.forEach((index, service) async {
        final name = serviceNamePool[index];
        final initResult = await service.init(socketPool[name][0]);
        print('init result: $initResult');
        if (transferPool.containsKey(name)) {
          final pool = transferPool[name];
          pool.forEach((data) {
            final chatEntity = ChatProtocolEntity(
              head: ChatHeadEntity(
                code: ChatProtocolCode.newSend,
                id: 1,
                timestamp: data.timestamp,
                from: data.from,
                to: data.to,
                groupChatFlag: false,
                password: 'password',
              ),
              body: ChatBodyEntity(
                content: data.content,
              ),
            );
            service.setEntity(chatEntity);
            print('sending entity content: ${chatEntity.body.content}');
            final result = service.send();
            print('send result: $result');
          });
          pool.clear();
        }
      });
    }
  });
  transferPool.changes.listen((records) {
    //clean up dead and empty socket
    final record = getPropertyChangeRecords(records, #length)[0];
    if (record != null && record.newValue > record.oldValue) {
      print('${record.newValue}:${record.oldValue}');
    }
  });
  int reqCount = 0;
  SecurityContext securityContext = SecurityContext()
    ..useCertificateChain('/home/y24/wssConfig/cert.pem')
    ..usePrivateKey('/home/y24/wssConfig/cert.key', password: 'yue');
  try {
    var server = await HttpServer.bindSecure(
        InternetAddress.anyIPv4, 2424, securityContext);
    await for (HttpRequest req in server) {
      final serviceIndex = ++reqCount;
      var socket = await WebSocketTransformer.upgrade(req);
      final username = req.uri.pathSegments[1];
      switch (req.uri.pathSegments[0]) {
        case 'account':
          print('Dealing with accout');
          socket.listen((data) async {
            print(
                "接收到来自 ${req.connectionInfo.remoteAddress.address}:${req.connectionInfo.remotePort} 的消息：$data");
            try {
              final request = AccountProtocolEntity.fromJson(json.decode(data));
              IProtocolHandler handler = AccountProtocolHandler(
                username: request.head.id,
                password: request.body.content,
              );
              handler.setEntity(request);
              await handler.handle(socket);
              await handler.dispose();
            } catch (e) {
              print(e);
            }
          });
          break;
        case 'chat':
          print('Dealing with chat');
          print('service index: $serviceIndex');

          socketPool.update(username, (list) {
            list.add(socket);
            return list;
          }, ifAbsent: () {
            var observableList = ObservableList<WebSocket>();
            try {
              observableList.listChanges.listen((records) {
                print('socket pool change: $records');
                records.forEach((record) {
                  if (record.addedCount > 0) {
                    print(
                        'service pool before change: $servicePool index:$serviceIndex');
                    servicePool.putIfAbsent(
                        serviceIndex,
                        () => ChatProtocolService(
                              protocolSender: ChatProtocolSender(id: username),
                              protocolHandler:
                                  ChatProtocolHandler(id: username),
                            ));
                    serviceNamePool.putIfAbsent(
                      serviceIndex,
                      () => username,
                    );
                    print('service pool after change: $servicePool');
                  }
                });
              });
              observableList.add(socket);
            } catch (e) {
              print('error while if: $e');
            }
            return observableList;
          });
          socket.listen((data) async {
            final request = ChatProtocolEntity.fromJson(json.decode(data));
            //print('service index: $serviceIndex data:$data');
            final from = request.head.from;
            final to = request.head.to;
            final content = request.body.content;
            print(
                'Recieve from ${req.connectionInfo.remoteAddress}:${req.connectionInfo.remotePort} data: $data');
            try {
              print('service pool: $servicePool,serviceIndex: $serviceIndex');
              final service = servicePool.putIfAbsent(
                  serviceIndex,
                  () => ChatProtocolService(
                        protocolSender: ChatProtocolSender(id: username),
                        protocolHandler: ChatProtocolHandler(id: username),
                      ));
              serviceNamePool.putIfAbsent(
                serviceIndex,
                () => username,
              );
              final result = await service.init(socket);
              print('chat service init result: $result');
              service.setEntity(request);
              final handleResult = await service.handle(socket);
              switch (handleResult.code as ChatProtocolCode) {
                case ChatProtocolCode.newSend:
                  transferPool.putIfAbsent(to, () {
                    return ObservableList<BaseTransferEntity>();
                  }).add(ChatTransferEntity(
                    content,
                    from: from,
                    to: to,
                    timestamp: DateTime.now(),
                  ));
                  final ack = ChatProtocolEntity(
                      head: ChatHeadEntity(
                          id: request.head.id,
                          code: ChatProtocolCode.accept,
                          timestamp: request.head.timestamp,
                          from: from,
                          to: to,
                          groupChatFlag: request.head.groupChatFlag,
                          password: 'password'),
                      body: ChatBodyEntity(content: 'Free chat'));
                  service.setEntity(ack);
                  await service.send();
                  break;
                case ChatProtocolCode.reSend:
                  // TODO: Handle this case.
                  break;
                case ChatProtocolCode.accept:
                  // TODO: Handle this case.
                  break;
                case ChatProtocolCode.reject:
                  // TODO: Handle this case.
                  break;
              }
            } catch (e) {
              print('error: $e');
            }
          }, onDone: () async {
            print('socket $serviceIndex on done ');
            await servicePool.remove(serviceIndex)?.dispose();
            await serviceNamePool.remove(serviceIndex);
          }, onError: (e) async {
            print('socket $serviceIndex on error ');
            await servicePool.remove(serviceIndex)?.dispose();
            await serviceNamePool.remove(serviceIndex);
          });
      }
    }
  } catch (e) {
    print(e);
  }
}
