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
        List<FriendRelationship> requests = friendRelationshipDao.selectByFriendId(userId)
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
            if (existing.getStatus() == 1) {
                return ApiResponse.success(existing);
            } else {
                existing.setStatus(0);
                existing.setUpdateTime(LocalDateTime.now());
                friendRelationshipDao.update(existing);
                return ApiResponse.success(existing);
            }
        }

        FriendRelationship request = new FriendRelationship();
        request.setUserId(userId);
        request.setFriendId(friendId);
        request.setStatus(0); // 待处理
        friendRelationshipDao.insert(request);
        return ApiResponse.success(request);
    }

    /**
     * 处理好友申请
     *
     * @param requestId 好友申请ID
     * @param userId    当前用户ID
     * @param accept    是否接受
     */
    @Transactional
    public ApiResponse<FriendRelationship> handleFriendRequest(Long requestId, Long userId, boolean accept) {
        FriendRelationship request = friendRelationshipDao.selectById(requestId);
        if (request == null) {
            return ApiResponse.error("好友申请不存在");
        }

        // 验证当前用户是否为申请的接收者
        if (!request.getFriendId().equals(userId)) {
            return ApiResponse.error("无权处理该好友申请");
        }

        // 检查申请是否已经被处理
        if (request.getStatus() != 0) {
            return ApiResponse.error("该好友申请已被处理");
        }

        // 更新申请状态
        request.setStatus(accept ? 1 : 2); // 1: 接受, 2: 拒绝
        friendRelationshipDao.update(request);
        // 如果接受申请，创建反向的好友关系
        if (accept) {
            FriendRelationship friendRelationship = friendRelationshipDao.selectByUserIdAndFriendId(request.getFriendId(), request.getUserId());
            if (friendRelationship != null) {
                friendRelationship.setStatus(1);
                friendRelationship.setUpdateTime(LocalDateTime.now());
                friendRelationshipDao.update(friendRelationship);
            } else {
                friendRelationship = new FriendRelationship();
                friendRelationship.setUserId(request.getFriendId());
                friendRelationship.setFriendId(request.getUserId());
                friendRelationship.setStatus(1); // 直接设置为已接受
                friendRelationshipDao.insert(friendRelationship);
            }
        }

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

    /**
     * 获取文件记录
     */
    public FileRecord getFileRecord(Long fileId) {
        return fileRecordDao.selectById(fileId);
    }
}
