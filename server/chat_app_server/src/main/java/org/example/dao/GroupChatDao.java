package org.example.dao;

import org.apache.ibatis.annotations.Mapper;
import org.example.entity.po.GroupChat;
import java.util.List;

@Mapper
public interface GroupChatDao {
    int insert(GroupChat groupChat);
    int update(GroupChat groupChat);
    int deleteById(Long id);
    GroupChat selectById(Long id);
    List<GroupChat> selectByOwnerId(Long ownerId);
    int updateAnnouncement(Long id, String announcement);
}
