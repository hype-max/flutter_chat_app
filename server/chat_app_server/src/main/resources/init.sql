-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS chat_app DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE chat_app;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码（加密存储）',
    nickname VARCHAR(50) COMMENT '昵称',
    signature VARCHAR(255) COMMENT '个性签名',
    avatar_url VARCHAR(255) COMMENT '头像URL',
    address VARCHAR(255) COMMENT '地址信息',
    email VARCHAR(100) UNIQUE COMMENT '邮箱',
    phone VARCHAR(20) UNIQUE COMMENT '手机号',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '用户状态：0-禁用，1-正常',
    last_login_time DATETIME COMMENT '最后登录时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';

-- 插入测试数据
INSERT INTO users (username, password, nickname, signature, address, email, phone, status) VALUES
('test_user1', '$2a$10$xVWZxkSGYT5JuKRXhzYWQ.4P6dNh/6YuipXvJvuN.Ht4kJg1Zyaem', '测试用户1', '这是我的个性签名', '北京市朝阳区', 'test1@example.com', '13800138001', 1),
('test_user2', '$2a$10$xVWZxkSGYT5JuKRXhzYWQ.4P6dNh/6YuipXvJvuN.Ht4kJg1Zyaem', '测试用户2', 'Hello World!', '上海市浦东新区', 'test2@example.com', '13800138002', 1);
