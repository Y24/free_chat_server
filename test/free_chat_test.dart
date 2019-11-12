import 'package:free_chat/util/db_util.dart';
import 'package:test/test.dart';

void main() {
  test('db test', () async {
    try {
      var dbUtil = DbUtil(dbname: 'yue');
      final db = await dbUtil.db;
      await db.collection('collectionName').insert({
        'yue': 1234,
      }).then((result) {
        print(result);
      });
      await dbUtil.close();
    } catch (e) {
      print(e);
    }
  });
}
