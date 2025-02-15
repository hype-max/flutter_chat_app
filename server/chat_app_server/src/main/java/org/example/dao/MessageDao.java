package org.example.dao;

import org.apache.ibatis.annotations.Mapper;
import org.example.entity.po.Message;
import java.util.List;

@Mapper
public interface MessageDao {
    int insert(Message message);
    int update(Message message);
    int deleteById(Long id);
    Message selectById(Long id);
    List<Message> selectByGroupId(Long groupId);
    List<Message> selectPrivateMessages(Long senderId, Long receiverId);
}
