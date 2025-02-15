import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBFactory {
  static Database? _database;
  
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_app.db');
    print(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // 创建会话记录表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id TEXT NOT NULL UNIQUE,
            conversation_type INTEGER NOT NULL,
            last_message TEXT,
            last_message_time INTEGER,
            unread_count INTEGER DEFAULT 0,
            target_id TEXT NOT NULL,
            conversation_name TEXT,
            conversation_avatar TEXT,
            pin_time INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // 创建消息记录缓存表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message_id TEXT NOT NULL UNIQUE,
            conversation_id TEXT NOT NULL,
            sender_id TEXT NOT NULL,
            content_type INTEGER NOT NULL,
            content TEXT NOT NULL,
            status INTEGER NOT NULL,
            send_time INTEGER NOT NULL,
            receive_time INTEGER,
            read_time INTEGER,
            extra TEXT,
            created_at INTEGER NOT NULL
          )
        ''');

        // 创建用户信息缓存表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL UNIQUE,
            nickname TEXT NOT NULL,
            avatar TEXT,
            status INTEGER,
            signature TEXT,
            gender INTEGER,
            phone TEXT,
            email TEXT,
            last_online_time INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // 创建好友关系缓存表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS friends (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            friend_id TEXT NOT NULL,
            remark TEXT,
            status INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            UNIQUE(user_id, friend_id)
          )
        ''');

        // 创建文件记录缓存表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_id TEXT NOT NULL UNIQUE,
            file_name TEXT NOT NULL,
            file_path TEXT NOT NULL,
            file_size INTEGER NOT NULL,
            file_type TEXT NOT NULL,
            upload_status INTEGER NOT NULL,
            message_id TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // 创建群聊关系缓存表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS group_members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            group_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            nickname TEXT,
            role INTEGER NOT NULL,
            join_time INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            UNIQUE(group_id, user_id)
          )
        ''');

        // 创建索引
        await db.execute('CREATE INDEX idx_conversations_updated_at ON conversations(updated_at DESC)');
        await db.execute('CREATE INDEX idx_messages_conversation_id ON messages(conversation_id, send_time DESC)');
        await db.execute('CREATE INDEX idx_friends_user_id ON friends(user_id)');
        await db.execute('CREATE INDEX idx_group_members_group_id ON group_members(group_id)');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // 升级数据库逻辑

      },
    );
  }
  
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
