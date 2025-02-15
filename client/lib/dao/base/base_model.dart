abstract class BaseModel {
  Map<String, dynamic> toMap();
  
  // 获取主键值
  dynamic getPrimaryKey();
  
  // 获取表名
  String getTableName();
}
