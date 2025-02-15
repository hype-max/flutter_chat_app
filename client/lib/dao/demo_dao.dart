import 'base/base_dao.dart';
import 'base/base_model.dart';

class DemoModel implements BaseModel {
  final int? id;
  final String title;
  final String? description;
  final int createdAt;

  DemoModel({
    this.id,
    required this.title,
    this.description,
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt,
    };
  }

  @override
  dynamic getPrimaryKey() => id;

  @override
  String getTableName() => 'demo';

  factory DemoModel.fromMap(Map<String, dynamic> map) {
    return DemoModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: map['created_at'],
    );
  }
}

class DemoDao extends BaseDao<DemoModel> {

  @override
  DemoModel createModel(Map<String, dynamic> map) {
    return DemoModel.fromMap(map);
  }

  @override
  Future<DemoModel> getInstance() async {
    return DemoModel(
      title: '',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
