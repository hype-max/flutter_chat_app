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
    String path = join(await getDatabasesPath(), 'chat_app11.db');
    print(path);
    return await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        createTable(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // 升级数据库逻辑
        createTable(db);
      },
    );
  }

  static Future createTable(Database db) async {
    // 创建会话记录表
    await db.execute('''
          CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            conversationType INTEGER NOT NULL,
            lastMessage TEXT,
            lastMessageTime INTEGER,
            unreadCount INTEGER DEFAULT 0,
            targetId INTEGER NOT NULL,
            conversationName TEXT,
            conversationAvatar TEXT,
            pinTime INTEGER DEFAULT 0,
            createdAt INTEGER ,
            updatedAt INTEGER
          )
        ''');

    // 创建消息记录缓存表
    await db.execute('''
          CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            senderId INTEGER NOT NULL,
            receiverId INTEGER,
            content TEXT NOT NULL,
            contentType INTEGER NOT NULL,
            groupId INTEGER,
            sendTime INTEGER,
            createTime INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
          )
        ''');

    // 创建用户信息缓存表
    await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL UNIQUE,
            nickname TEXT NOT NULL,
            avatar TEXT,
            status INTEGER,
            signature TEXT,
            gender INTEGER,
            phone TEXT,
            email TEXT,
            lastOnlineTime INTEGER,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL
          )
        ''');

    // 创建好友关系缓存表
    await db.execute('''
          CREATE TABLE IF NOT EXISTS friends (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId integer,
            friendId integer,
            remark TEXT,
            status INTEGER ,
            createdTime INTEGER,
            updatedTime INTEGER
          )
        ''');

    // 创建文件记录缓存表
    await db.execute('''
          CREATE TABLE IF NOT EXISTS files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fileId TEXT NOT NULL UNIQUE,
            fileName TEXT,
            fileSize INTEGER,
            fileType TEXT,
            filePath TEXT,
            uploadProgress INTEGER DEFAULT 0,
            status INTEGER,
            createdAt INTEGER,
            updatedAt INTEGER
          )
        ''');

    // 创建群组信息缓存表
    await db.execute('''
          CREATE TABLE IF NOT EXISTS groups (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            groupId TEXT NOT NULL UNIQUE,
            groupName TEXT NOT NULL,
            groupAvatar TEXT,
            ownerId TEXT NOT NULL,
            notice TEXT,
            memberCount INTEGER DEFAULT 0,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL
          )
        ''');

    // 创建群组成员缓存表
    await db.execute('''
          CREATE TABLE IF NOT EXISTS groupMembers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            groupId TEXT NOT NULL,
            userId TEXT NOT NULL,
            nickname TEXT,
            role INTEGER NOT NULL,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            UNIQUE(groupId, userId)
          )
        ''');

    // 创建索引
    // await db.execute(
    //     'CREATE INDEX idx_conversations_updated_at ON conversations(updatedAt DESC)');
    // await db.execute('CREATE INDEX idx_friends_user_id ON friends(userId)');
    // await db.execute(
    //     'CREATE INDEX idx_group_members_group_id ON groupMembers(groupId)');
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
