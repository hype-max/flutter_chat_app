package org.example.service;

import org.example.common.ApiResponse;
import org.example.dao.*;
import org.example.entity.po.*;
import org.example.entity.vo.*;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ChatService {
    @Autowired
    private MessageDao messageDao;

    @Autowired
    private FriendRelationshipDao friendRelationshipDao;

    @Autowired
    private GroupChatDao groupChatDao;

    @Autowired
    private GroupMemberDao groupMemberDao;

    @Autowired
    private FileRecordDao fileRecordDao;

    @Autowired
    private UserDao userDao;

    @Value("${app.upload.dir}")
    private String uploadDir;

    /**
     * 查询好友列表
     */
    public ApiResponse<List<UserVO>> getFriendList(Long userId) {
        List<FriendRelationship> relationships = friendRelationshipDao.selectByUserId(userId);
        List<UserVO> friends = relationships.stream()
                .filter(r -> r.getStatus() == 1) // 只返回已接受的好友关系
                .map(r -> userDao.findById(r.getFriendId())).map((r -> {
                    UserVO userVO = new UserVO();
                    BeanUtils.copyProperties(r, userVO);
                    return userVO;
                }))
                .collect(Collectors.toList());
        return ApiResponse.success(friends);
    }

    /**
     * 查询群聊列表
     */
    public ApiResponse<List<GroupChat>> getGroupList(Long userId) {
        List<GroupMember> memberships = groupMemberDao.selectByUserId(userId);
        List<GroupChat> groups = memberships.stream()
                .map(m -> groupChatDao.selectById(m.getGroupId()))
                .collect(Collectors.toList());
        return ApiResponse.success(groups);
    }

    /**
     * 查询群聊信息
     */
    public ApiResponse<GroupChat> getGroupInfo(Long groupId) {
        GroupChat groupChat = groupChatDao.selectById(groupId);
        if (groupChat == null) {
            return ApiResponse.error("群聊不存在");
        }
        return ApiResponse.success(groupChat);
    }

    /**
     * 查询群聊成员
     */
    public ApiResponse<List<UserVO>> getGroupMembers(Long groupId) {
        List<GroupMember> members = groupMemberDao.selectByGroupId(groupId);
        List<UserVO> users = members.stream().
                map(r -> userDao.findById(r.getUserId())).map((r -> {
                    UserVO userVO = new UserVO();
                    BeanUtils.copyProperties(r, userVO);
                    return userVO;
                })).collect(Collectors.toList());
        return ApiResponse.success(users);
    }

    /**
     * 创建群聊
     */
    @Transactional
    public ApiResponse<GroupChat> createGroup(String name, String avatar, Long ownerId, List<Long> memberIds) {
        GroupChat groupChat = new GroupChat();
        groupChat.setName(name);
        groupChat.setAvatar(avatar);
        groupChat.setOwnerId(ownerId);
        groupChatDao.insert(groupChat);

        // 添加群主
        GroupMember ownerMember = new GroupMember();
        ownerMember.setGroupId(groupChat.getId());
        ownerMember.setUserId(ownerId);
        ownerMember.setRole(2); // 群主
        groupMemberDao.insert(ownerMember);

        // 添加成员
        for (Long memberId : memberIds) {
            if (!memberId.equals(ownerId)) {
                GroupMember member = new GroupMember();
                member.setGroupId(groupChat.getId());
                member.setUserId(memberId);
                member.setRole(0); // 普通成员
                groupMemberDao.insert(member);
            }
        }

        return ApiResponse.success(groupChat);
    }

    /**
     * 查询消息记录
     */
    public ApiResponse<List<Message>> getMessageHistory(Long senderId, Long receiverId, Long groupId) {
        List<Message> messages;
        if (groupId != null) {
            messages = messageDao.selectByGroupId(groupId);
        } else {
            messages = messageDao.selectPrivateMessages(senderId, receiverId);
        }
        return ApiResponse.success(messages);
    }

    /**
     * 查询好友申请记录
     */
    public ApiResponse<List<FriendRelationship>> getFriendRequests(Long userId) {
        List<FriendRelationship> requests = friendRelationshipDao.selectByUserId(userId)
                .stream()
                .filter(r -> r.getStatus() == 0) // 只返回待处理的申请
                .collect(Collectors.toList());
        return ApiResponse.success(requests);
    }

    /**
     * 创建好友申请
     */
    public ApiResponse<FriendRelationship> createFriendRequest(Long userId, Long friendId) {
        // 检查是否已经是好友
        FriendRelationship existing = friendRelationshipDao.selectByUserIdAndFriendId(userId, friendId);
        if (existing != null) {
            return ApiResponse.error("已经发送过好友申请或已经是好友");
        }

        FriendRelationship request = new FriendRelationship();
        request.setUserId(userId);
        request.setFriendId(friendId);
        request.setStatus(0); // 待处理
        friendRelationshipDao.insert(request);
        return ApiResponse.success(request);
    }

    /**
     * 上传文件
     */
    public ApiResponse<FileRecord> uploadFile(MultipartFile file, Long uploaderId, Long messageId) throws IOException {
        String originalFilename = file.getOriginalFilename();
        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String newFilename = UUID.randomUUID().toString() + fileExtension;

        // 确保上传目录存在
        File uploadPath = new File(uploadDir);
        if (!uploadPath.exists()) {
            uploadPath.mkdirs();
        }

        // 保存文件
        Path filePath = Paths.get(uploadDir, newFilename);
        Files.copy(file.getInputStream(), filePath);

        // 创建文件记录
        FileRecord fileRecord = new FileRecord();
        fileRecord.setOriginalName(originalFilename);
        fileRecord.setFilePath(newFilename);
        fileRecord.setFileSize(file.getSize());
        fileRecord.setFileType(file.getContentType());
        fileRecord.setUploaderId(uploaderId);
        fileRecord.setMessageId(messageId);
        fileRecordDao.insert(fileRecord);

        return ApiResponse.success(fileRecord);
    }
}
