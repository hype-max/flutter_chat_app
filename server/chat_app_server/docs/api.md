# Chat App API Documentation

## Base URL
```
http://localhost:8080/api
```

所有需要认证的接口都需要在请求头中携带 `Authorization` token。

## 聊天相关接口

### 1. 获取好友列表
```
GET /chat/friends
```
**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "id": 1,
            "username": "user1",
            "email": "user1@example.com",
            "avatar": "avatar1.jpg"
        }
    ]
}
```

### 2. 获取群聊列表
```
GET /chat/groups
```
**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "id": 1,
            "name": "群聊1",
            "avatar": "group1.jpg",
            "ownerId": 1,
            "announcement": "公告内容"
        }
    ]
}
```

### 3. 获取群聊信息
```
GET /chat/group/{groupId}
```
**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "name": "群聊1",
        "avatar": "group1.jpg",
        "ownerId": 1,
        "announcement": "公告内容"
    }
}
```

### 4. 获取群聊成员
```
GET /chat/group/{groupId}/members
```
**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "id": 1,
            "username": "user1",
            "email": "user1@example.com",
            "avatar": "avatar1.jpg"
        }
    ]
}
```

### 5. 创建群聊
```
POST /chat/group
```
**请求体：**
```json
{
    "name": "新群聊",
    "avatar": "group.jpg",
    "memberIds": [1, 2, 3]
}
```
**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "name": "新群聊",
        "avatar": "group.jpg",
        "ownerId": 1
    }
}
```

### 6. 获取消息历史
```
GET /chat/messages?receiverId={receiverId}&groupId={groupId}
```
**参数说明：**
- receiverId: 私聊时的接收者ID
- groupId: 群聊时的群ID
（两个参数二选一）

**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "id": 1,
            "senderId": 1,
            "receiverId": 2,
            "content": "你好",
            "contentType": 1,
            "groupId": null,
            "createTime": "2025-02-15T10:00:00"
        }
    ]
}
```

### 7. 获取好友申请列表
```
GET /chat/friend-requests
```
**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "id": 1,
            "userId": 1,
            "friendId": 2,
            "status": 0,
            "createTime": "2025-02-15T10:00:00"
        }
    ]
}
```

### 8. 发送好友申请
```
POST /chat/friend-request?friendId={friendId}
```
**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "userId": 1,
        "friendId": 2,
        "status": 0,
        "createTime": "2025-02-15T10:00:00"
    }
}
```

### 9. 上传文件
```
POST /chat/upload
```
**请求参数：**
- file: 文件（multipart/form-data）
- messageId: 消息ID

**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "originalName": "test.jpg",
        "filePath": "/uploads/test.jpg",
        "fileSize": 1024,
        "fileType": "image/jpeg",
        "uploaderId": 1,
        "messageId": 1,
        "createTime": "2025-02-15T10:00:00"
    }
}
```

### 10. 下载文件
```
GET /chat/file/download/{fileId}
```
**请求参数：**
- fileId: 文件ID（路径参数）

**响应：**
- Content-Type: application/octet-stream
- Content-Disposition: attachment; filename="原始文件名"
- 响应体: 文件二进制内容

**错误响应：**
- 404: 文件不存在

### 11. 获取用户信息
```
GET /chat/user/{userId}
```
**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "username": "user1",
        "nickname": "用户1",
        "email": "user1@example.com",
        "phone": "13800138000",
        "avatarUrl": "avatar1.jpg",
        "signature": "个性签名",
        "address": "地址"
    }
}
```

### 12. 处理好友申请
```
PUT /chat/friend-request/{requestId}?accept={true|false}
```
**参数说明：**
- requestId: 好友申请ID（路径参数）
- accept: 是否接受申请（true: 接受, false: 拒绝）

**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "userId": 2,
        "friendId": 1,
        "status": 1,
        "createTime": "2025-02-15T10:00:00"
    }
}
```
**状态说明：**
- status: 0 - 待处理, 1 - 已接受, 2 - 已拒绝

## 用户相关接口

### 1. 搜索用户
```
GET /api/user/search?keyword={keyword}&page={page}&size={size}
```
**请求参数：**
- keyword: 搜索关键字（用户名、昵称、邮箱）
- page: 页码，默认1
- size: 每页大小，默认20

**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "id": 1,
            "username": "user1",
            "nickname": "用户1",
            "email": "user1@example.com",
            "phone": "13800138000",
            "avatarUrl": "avatar1.jpg",
            "signature": "个性签名",
            "address": "地址"
        }
    ]
}
```

### 2. 获取用户信息
```
GET /api/user/{userId}
```
**请求参数：**
- userId: 用户ID（路径参数）

**响应示例：**
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "username": "user1",
        "nickname": "用户1",
        "email": "user1@example.com",
        "phone": "13800138000",
        "avatarUrl": "avatar1.jpg",
        "signature": "个性签名",
        "address": "地址"
    }
}
```

## 错误码说明
- 0: 成功
- 1: 通用错误
- 1001: 未登录
- 1002: 参数错误
- 2001: 群聊不存在
- 2002: 已经是好友
- 2003: 已经发送过好友申请
