package org.example.dao;

import org.apache.ibatis.annotations.Mapper;
import org.example.entity.po.GroupMember;
import java.util.List;

@Mapper
public interface GroupMemberDao {
    int insert(GroupMember groupMember);
    int update(GroupMember groupMember);
    int deleteById(Long id);
    int deleteByGroupIdAndUserId(Long groupId, Long userId);
    GroupMember selectById(Long id);
    List<GroupMember> selectByGroupId(Long groupId);
    List<GroupMember> selectByUserId(Long userId);
    GroupMember selectByGroupIdAndUserId(Long groupId, Long userId);
}
