abstract class BaseTransferEntity {
  final String from;
  final String to;
  final DateTime timestamp;
  DateTime ddl;
  dynamic content;
  String get type;
  BaseTransferEntity(content, {this.from, this.to, this.timestamp, this.ddl})
      : content = content;
  @override
  String toString() {
    return 'TransferEntity(from: $from,to: $to,content: $content)';
  }
}
