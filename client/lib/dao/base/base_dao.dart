import 'package:sqflite/sqflite.dart';
import '../../dao/db_factory.dart';
import 'base_model.dart';

abstract class BaseDao<T extends BaseModel> {
  // 获取数据库实例
  Future<Database> getDatabase() async {
    return await DBFactory.getDatabase();
  }

  // 创建模型实例的抽象方法，子类需要实现
  T createModel(Map<String, dynamic> map);

  // 插入数据
  Future<int> insert(T model) async {
    final Database db = await getDatabase();
    return await db.insert(
      model.getTableName(),
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 批量插入数据
  Future<List<int>> insertBatch(List<T> models) async {
    final Database db = await getDatabase();
    final Batch batch = db.batch();

    for (var model in models) {
      batch.insert(
        model.getTableName(),
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final List<dynamic> results = await batch.commit();
    return results.cast<int>();
  }

  // 更新数据
  Future<int> update(T model) async {
    final Database db = await getDatabase();
    return await db.update(
      model.getTableName(),
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.getPrimaryKey()],
    );
  }

  // 根据条件更新数据
  Future<int> updateWhere(
      T model, String where, List<dynamic> whereArgs) async {
    final Database db = await getDatabase();
    return await db.update(
      model.getTableName(),
      model.toMap(),
      where: where,
      whereArgs: whereArgs,
    );
  }

  // 删除数据
  Future<int> delete(T model) async {
    final Database db = await getDatabase();
    return await db.delete(
      model.getTableName(),
      where: 'id = ?',
      whereArgs: [model.getPrimaryKey()],
    );
  }

  // 根据条件删除数据
  Future<int> deleteWhere(
      T model, String where, List<dynamic> whereArgs) async {
    final Database db = await getDatabase();
    return await db.delete(
      model.getTableName(),
      where: where,
      whereArgs: whereArgs,
    );
  }

  // 查询所有数据
  Future<List<T>> findAll() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      (await getInstance()).getTableName(),
    );
    return maps.map((map) => createModel(map)).toList();
  }

  // 根据ID查询数据
  Future<T?> findById(int id) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      (await getInstance()).getTableName(),
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return createModel(maps.first);
  }

  // 根据条件查询数据
  Future<List<T>> findWhere({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      (await getInstance()).getTableName(),
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => createModel(map)).toList();
  }

  // 获取记录数
  Future<int> count({String? where, List<dynamic>? whereArgs}) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      (await getInstance()).getTableName(),
      columns: ['COUNT(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );
    return Sqflite.firstIntValue(maps) ?? 0;
  }

  // 获取一个空实例，用于获取表名等信息
  Future<T> getInstance();

  // 执行原始SQL查询
  Future<List<T>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, arguments);
    return maps.map((map) => createModel(map)).toList();
  }

  // 执行原始SQL更新
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final Database db = await getDatabase();
    return await db.rawUpdate(sql, arguments);
  }

  // 分页查询
  Future<List<T>> findPage({
    required int page,
    required int pageSize,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    return findWhere(
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: pageSize,
      offset: (page - 1) * pageSize,
    );
  }
}
