package org.example.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.dao.GroupMemberDao;
import org.example.dao.MessageDao;
import org.example.entity.po.GroupMember;
import org.example.entity.po.Message;
import org.example.service.RedisService;
import org.example.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {
    
    // 用sessionId映射WebSocketSession
    private static final ConcurrentHashMap<String, WebSocketSession> SESSIONS = new ConcurrentHashMap<>();
    // 用userId映射sessionId
    private static final ConcurrentHashMap<Long, String> USER_SESSION_MAP = new ConcurrentHashMap<>();
    // 用groupId映射群成员userId列表（缓存）
    private static final ConcurrentHashMap<Long, List<Long>> GROUP_MEMBERS_CACHE = new ConcurrentHashMap<>();
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Autowired
    private RedisService redisService;
    
    @Autowired
    private MessageDao messageDao;
    
    @Autowired
    private GroupMemberDao groupMemberDao;

    private static final String TOKEN_PREFIX = "Bearer ";
    private static final String USER_TOKEN_KEY_PREFIX = "user:token:";

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        // 1. 获取token并验证
        Map<String, Object> attributes = session.getAttributes();
        String token = getTokenFromHandshake(session);
        if (token == null) {
            session.close();
            return;
        }

        // 2. 验证token
        if (!jwtUtil.validateToken(token)) {
            session.close();
            return;
        }

        // 3. 从token中获取用户ID
        Long userId = jwtUtil.getUserIdFromToken(token);

        // 4. 检查Redis中是否存在有效的session
        Object storedToken = redisService.get(USER_TOKEN_KEY_PREFIX + userId);
        if (storedToken == null || !token.equals(storedToken.toString())) {
            session.close();
            return;
        }

        // 5. 保存会话信息
        SESSIONS.put(session.getId(), session);
        USER_SESSION_MAP.put(userId, session.getId());
        
        // 6. 将用户ID存入session属性中
        attributes.put("userId", userId);
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws IOException {
        try {
            // 1. 解析消息为MessagePO对象
            Message messagePO = objectMapper.readValue(message.getPayload(), Message.class);
            
            // 2. 设置发送时间
            messagePO.setCreateTime(LocalDateTime.now());
            
            // 3. 保存消息到数据库并获取生成的ID
            messageDao.insert(messagePO);
            
            // 4. 将消息转换为JSON字符串
            String jsonMessage = objectMapper.writeValueAsString(messagePO);
            TextMessage textMessage = new TextMessage(jsonMessage);
            
            // 5. 转发消息
            if (messagePO.getGroupId() != null) {
                // 群聊消息
                sendGroupMessage(messagePO.getGroupId(), textMessage);
            } else {
                // 私聊消息
                sendPrivateMessage(messagePO.getReceiverId(), textMessage);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        Map<String, Object> attributes = session.getAttributes();
        Long userId = (Long) attributes.get("userId");
        if (userId != null) {
            USER_SESSION_MAP.remove(userId);
        }
        SESSIONS.remove(session.getId());
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        afterConnectionClosed(session, CloseStatus.SERVER_ERROR);
    }
    
    private String getTokenFromHandshake(WebSocketSession session) {
        Map<String, Object> attributes = session.getAttributes();
        String token = (String) attributes.get("token");
        if (token != null && token.startsWith(TOKEN_PREFIX)) {
            return token.substring(TOKEN_PREFIX.length());
        }
        return null;
    }
    
    private void sendPrivateMessage(Long receiverId, TextMessage message) throws IOException {
        String sessionId = USER_SESSION_MAP.get(receiverId);
        if (sessionId != null) {
            WebSocketSession session = SESSIONS.get(sessionId);
            if (session != null && session.isOpen()) {
                session.sendMessage(message);
            }
        }
    }
    
    private void sendGroupMessage(Long groupId, TextMessage message) throws IOException {
        // 1. 从缓存获取群成员
        List<Long> memberIds = GROUP_MEMBERS_CACHE.get(groupId);
        
        // 2. 如果缓存未命中，从数据库查询并更新缓存
        if (memberIds == null) {
            List<GroupMember> members = groupMemberDao.selectByGroupId(groupId);
            memberIds = members.stream()
                    .map(GroupMember::getUserId)
                    .toList();
            GROUP_MEMBERS_CACHE.put(groupId, memberIds);
        }
        
        // 3. 发送消息给所有在线群成员
        for (Long memberId : memberIds) {
            sendPrivateMessage(memberId, message);
        }
    }
    
    // 供外部调用，当群成员变更时更新缓存
    public void updateGroupMembersCache(Long groupId) {
        GROUP_MEMBERS_CACHE.remove(groupId);
    }
}
