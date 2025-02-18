package org.example.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.example.annotation.RequireAuth;
import org.example.common.ApiResponse;
import org.example.entity.vo.UserLoginVO;
import org.example.entity.vo.UserRegisterVO;
import org.example.entity.vo.UserVO;
import org.example.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {
    @Autowired
    private UserService userService;

    @Autowired
    private HttpServletRequest request;

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public ApiResponse<UserVO> register(@Valid @RequestBody UserRegisterVO registerVO) {
        return userService.register(registerVO);
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public ApiResponse<Map<String, Object>> login(@Valid @RequestBody UserLoginVO loginVO) {
        return userService.login(loginVO);
    }

    /**
     * 用户登出
     */
    @PostMapping("/logout")
    @RequireAuth
    public ApiResponse<Void> logout() {
        Long userId = (Long) request.getAttribute("userId");
        return userService.logout(userId);
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/info")
    @RequireAuth
    public ApiResponse<UserVO> getCurrentUser() {
        Long userId = (Long) request.getAttribute("userId");
        return userService.getUserInfo(userId);
    }

    /**
     * 更新用户信息
     */
    @PutMapping("/info")
    @RequireAuth
    public ApiResponse<UserVO> updateUserInfo(@Valid @RequestBody UserVO userVO) {
        Long userId = (Long) request.getAttribute("userId");
        return userService.updateUserInfo(userId, userVO);
    }

    /**
     * 修改密码
     */
    @PutMapping("/password")
    @RequireAuth
    public ApiResponse<Void> changePassword(@RequestParam String oldPassword,
                                            @RequestParam String newPassword) {
        Long userId = (Long) request.getAttribute("userId");
        return userService.changePassword(userId, oldPassword, newPassword);
    }

    /**
     * 上传头像
     */
    @PostMapping("/avatar")
    @RequireAuth
    public ApiResponse<String> uploadAvatar(@RequestParam("file") MultipartFile file) {
        Long userId = (Long) request.getAttribute("userId");
        return userService.uploadAvatar(userId, file);
    }

    /**
     * 下载头像
     */
    @GetMapping("/avatar/{userId}")
    public void getAvatar(@PathVariable Long userId, HttpServletResponse response) throws IOException {
        String avatarPath = userService.getAvatarPath(userId);
        if (avatarPath == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Avatar not found");
            return;
        }

        File file = new File(avatarPath);
        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Avatar file not found");
            return;
        }

        // 设置响应头
        String contentType = Files.probeContentType(file.toPath());
        response.setContentType(contentType != null ? contentType : "application/octet-stream");
        response.setContentLengthLong(file.length());
        response.setHeader("Cache-Control", "max-age=31536000"); // 缓存1年

        // 复制文件内容到响应流
        Files.copy(file.toPath(), response.getOutputStream());
        response.getOutputStream().flush();
    }

    /**
     * 获取用户列表（管理员接口）
     */
    @GetMapping("/list")
    @RequireAuth
    public ApiResponse<List<UserVO>> getUserList(@RequestParam(defaultValue = "1") int page,
                                                 @RequestParam(defaultValue = "10") int size) {
        return userService.getUserList(page, size);
    }

    /**
     * 禁用用户（管理员接口）
     */
    @PutMapping("/{userId}/disable")
    @RequireAuth
    public ApiResponse<Void> disableUser(@PathVariable Long userId) {
        return userService.disableUser(userId);
    }

    /**
     * 启用用户（管理员接口）
     */
    @PutMapping("/{userId}/enable")
    @RequireAuth
    public ApiResponse<Void> enableUser(@PathVariable Long userId) {
        return userService.enableUser(userId);
    }

    /**
     * 搜索用户
     */
    @GetMapping("/search")
//    @RequireAuth
    public ApiResponse<List<UserVO>> searchUsers(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return userService.searchUsers(keyword, page, size);
    }

    /**
     * 获取指定用户信息
     */
    @GetMapping("/{userId}")
    @RequireAuth
    public ApiResponse<UserVO> getUserInfo(@PathVariable Long userId) {
        return userService.getUserInfo(userId);
    }
}
