package org.example.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.annotation.RequireAuth;
import org.example.common.ApiResponse;
import org.example.entity.po.*;
import org.example.entity.vo.*;
import org.example.service.ChatService;
import org.example.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequireAuth
public class ChatController {
    @Autowired
    private ChatService chatService;

    @Autowired
    private UserService userService;

    @Autowired
    private HttpServletRequest request;
    @Value("${app.upload.dir}")
    private String uploadDir;

    /**
     * 获取好友列表
     */
    @GetMapping("/friends")
    @RequireAuth
    public ApiResponse<List<UserVO>> getFriendList() {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getFriendList(userId);
    }

    /**
     * 获取群聊列表
     */
    @GetMapping("/groups")
    @RequireAuth
    public ApiResponse<List<GroupChat>> getGroupList() {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getGroupList(userId);
    }

    /**
     * 获取群聊信息
     */
    @GetMapping("/group/{groupId}")
    @RequireAuth
    public ApiResponse<GroupChat> getGroupInfo(@PathVariable Long groupId) {
        return chatService.getGroupInfo(groupId);
    }

    /**
     * 获取群聊成员
     */
    @GetMapping("/group/{groupId}/members")
    @RequireAuth
    public ApiResponse<List<UserVO>> getGroupMembers(@PathVariable Long groupId) {
        return chatService.getGroupMembers(groupId);
    }

    /**
     * 创建群聊
     */
    @PostMapping("/group")
    @RequireAuth
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
    @RequireAuth
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
    @RequireAuth
    public ApiResponse<List<FriendRelationship>> getFriendRequests() {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getFriendRequests(userId);
    }

    /**
     * 发送好友申请
     */
    @PostMapping("/friend-request")
    @RequireAuth
    public ApiResponse<FriendRelationship> createFriendRequest(@RequestParam Long friendId) {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.createFriendRequest(userId, friendId);
    }

    /**
     * 处理好友申请
     */
    @PutMapping("/friend-request/{requestId}")
    @RequireAuth
    public ApiResponse<FriendRelationship> handleFriendRequest(
            @PathVariable Long requestId,
            @RequestParam boolean accept) {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.handleFriendRequest(requestId, userId, accept);
    }

    /**
     * 上传文件
     */
    @PostMapping("/upload")
    @RequireAuth
    public ApiResponse<FileRecord> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam("messageId") Long messageId) throws IOException {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.uploadFile(file, userId, messageId);
    }

    /**
     * 下载文件
     */
    @GetMapping("/file/download/{fileId}")
    @RequireAuth
    public void downloadFile(@PathVariable Long fileId, HttpServletResponse response) throws IOException {
        Long userId = (Long) request.getAttribute("userId");
        FileRecord fileRecord = chatService.getFileRecord(fileId);
        if (fileRecord == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        File file = new File(uploadDir,fileRecord.getFilePath());
        if (!file.exists()) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + 
            URLEncoder.encode(fileRecord.getOriginalName(), StandardCharsets.UTF_8.toString()) + "\"");
        response.setContentLength(fileRecord.getFileSize().intValue());

        try (FileInputStream fileInputStream = new FileInputStream(file);
             OutputStream outputStream = response.getOutputStream()) {
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
            outputStream.flush();
        }
    }

    /**
     * 获取用户信息
     */
    @GetMapping("/user/{userId}")
    @RequireAuth
    public ApiResponse<UserVO> getUserInfo(@PathVariable Long userId) {
        return userService.getUserInfo(userId);
    }
}
