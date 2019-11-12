import 'package:free_chat/protocol/transfer/base_transfer_entity.dart';

class ChatTransferEntity extends BaseTransferEntity {
  @override
  String get type => 'chat';
  ChatTransferEntity(content,
      {String from, String to, DateTime timestamp, DateTime ddl})
      : super(content, from: from, to: to, timestamp: timestamp, ddl: ddl);
}
