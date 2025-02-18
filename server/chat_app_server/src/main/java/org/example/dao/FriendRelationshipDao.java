package org.example.dao;

import org.apache.ibatis.annotations.Mapper;
import org.example.entity.po.FriendRelationship;
import java.util.List;

@Mapper
public interface FriendRelationshipDao {
    int insert(FriendRelationship relationship);
    int update(FriendRelationship relationship);
    int deleteById(Long id);
    FriendRelationship selectById(Long id);
    List<FriendRelationship> selectByUserId(Long userId);
    List<FriendRelationship> selectByFriendId(Long userId);
    FriendRelationship selectByUserIdAndFriendId(Long userId, Long friendId);
}
