CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    avatar VARCHAR(255),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 插入测试数据
INSERT INTO users (username, password, email, avatar) VALUES
('test1', 'password123', 'test1@example.com', 'https://example.com/avatar1.jpg'),
('test2', 'password123', 'test2@example.com', 'https://example.com/avatar2.jpg');
