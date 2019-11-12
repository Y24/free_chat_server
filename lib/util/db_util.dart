import 'package:mongo_dart/mongo_dart.dart';

class DbUtil {
  static final schema = 'mongodb';
  static final hostname = 'localhost';
  static final port = 27017;
  String dbname;
  String username;
  String password;
  Db _db;
  DbUtil({this.dbname, this.username, this.password});
  Future<Db> get db async {
    _db = Db('$schema://$hostname:$port/$dbname');
    await _db.open();
    return _db;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
