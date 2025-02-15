package org.example.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.example.annotation.RequireAuth;
import org.example.common.ApiResponse;
import org.example.entity.po.*;
import org.example.entity.vo.*;
import org.example.service.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequireAuth
public class ChatController {
    @Autowired
    private ChatService chatService;

    @Autowired
    private HttpServletRequest request;

    /**
     * 获取好友列表
     */
    @GetMapping("/friends")
    public ApiResponse<List<UserVO>> getFriendList() {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getFriendList(userId);
    }

    /**
     * 获取群聊列表
     */
    @GetMapping("/groups")
    public ApiResponse<List<GroupChat>> getGroupList() {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getGroupList(userId);
    }

    /**
     * 获取群聊信息
     */
    @GetMapping("/group/{groupId}")
    public ApiResponse<GroupChat> getGroupInfo(@PathVariable Long groupId) {
        return chatService.getGroupInfo(groupId);
    }

    /**
     * 获取群聊成员
     */
    @GetMapping("/group/{groupId}/members")
    public ApiResponse<List<UserVO>> getGroupMembers(@PathVariable Long groupId) {
        return chatService.getGroupMembers(groupId);
    }

    /**
     * 创建群聊
     */
    @PostMapping("/group")
    public ApiResponse<GroupChat> createGroup(@RequestBody CreateGroupRequestVO request) {
        Long userId = (Long) this.request.getAttribute("userId");
        return chatService.createGroup(
                request.getName(),
                request.getAvatar(),
                userId,
                request.getMemberIds()
        );
    }

    /**
     * 获取消息历史
     */
    @GetMapping("/messages")
    public ApiResponse<List<Message>> getMessageHistory(
            @RequestParam(required = false) Long receiverId,
            @RequestParam(required = false) Long groupId) {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getMessageHistory(userId, receiverId, groupId);
    }

    /**
     * 获取好友申请列表
     */
    @GetMapping("/friend-requests")
    public ApiResponse<List<FriendRelationship>> getFriendRequests() {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getFriendRequests(userId);
    }

    /**
     * 发送好友申请
     */
    @PostMapping("/friend-request")
    public ApiResponse<FriendRelationship> createFriendRequest(@RequestParam Long friendId) {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.createFriendRequest(userId, friendId);
    }

    /**
     * 上传文件
     */
    @PostMapping("/upload")
    public ApiResponse<FileRecord> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam("messageId") Long messageId) throws IOException {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.uploadFile(file, userId, messageId);
    }
}


