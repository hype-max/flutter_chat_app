package org.example.service;

import org.example.common.ApiResponse;
import org.example.dao.UserDao;
import org.example.entity.po.UserPO;
import org.example.entity.vo.UserLoginVO;
import org.example.entity.vo.UserRegisterVO;
import org.example.entity.vo.UserVO;
import org.example.util.JwtUtil;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
public class UserService {
    @Autowired
    private UserDao userDao;

    @Autowired
    private RedisService redisService;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${app.upload.dir}")
    private String uploadDir;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    private static final String USER_TOKEN_KEY_PREFIX = "user:token:";
    private static final long TOKEN_EXPIRE_DAYS = 30;

    /**
     * 用户注册
     */
    @Transactional
    public ApiResponse<UserVO> register(UserRegisterVO registerVO) {

        // 检查用户名是否已存在
        if (userDao.findByUsername(registerVO.getUsername()) != null) {
            return ApiResponse.error("用户名已存在");
        }

        // 检查邮箱是否已存在
        if (registerVO.getEmail() != null && userDao.findByEmail(registerVO.getEmail()) != null) {
            return ApiResponse.error("邮箱已被注册");
        }

        // 检查手机号是否已存在
        if (registerVO.getPhone() != null && userDao.findByPhone(registerVO.getPhone()) != null) {
            return ApiResponse.error("手机号已被注册");
        }

        // 创建用户
        UserPO user = new UserPO();
        BeanUtils.copyProperties(registerVO, user);
        user.setPassword(passwordEncoder.encode(registerVO.getPassword()));
        user.setStatus(1); // 设置为正常状态

        userDao.insert(user);

        // 转换为VO对象返回
        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(user, userVO);
        return ApiResponse.success("注册成功", userVO);
    }

    /**
     * 用户登录
     */
    @Transactional
    public ApiResponse<Map<String, Object>> login(UserLoginVO loginVO) {
        UserPO user = userDao.findByUsername(loginVO.getUsername());
        if (user == null) {
            return ApiResponse.error("用户不存在");
        }

        if (!passwordEncoder.matches(loginVO.getPassword(), user.getPassword())) {
            return ApiResponse.error("密码错误");
        }

        if (user.getStatus() != 1) {
            return ApiResponse.error("账号已被禁用");
        }

        // 生成token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername());

        // 将token存入Redis，设置30天过期
        redisService.set(USER_TOKEN_KEY_PREFIX + user.getId(), token, TOKEN_EXPIRE_DAYS, TimeUnit.DAYS);

        // 更新最后登录时间
        userDao.updateLastLoginTime(user.getId());

        // 转换为VO对象
        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(user, userVO);

        // 构建返回结果
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("user", userVO);

        return ApiResponse.success("登录成功", result);
    }

    /**
     * 更新用户信息
     */
    @Transactional
    public ApiResponse<UserVO> updateUserInfo(Long userId, UserVO userVO) {
        UserPO existingUser = userDao.findById(userId);
        if (existingUser == null) {
            return ApiResponse.error("用户不存在");
        }

        // 检查用户名是否已被其他用户使用
        if (userVO.getUsername() != null && !userVO.getUsername().isEmpty()
                && !existingUser.getUsername().equals(userVO.getUsername())) {
            UserPO userWithSameUsername = userDao.findByUsername(userVO.getUsername());
            if (userWithSameUsername != null) {
                return ApiResponse.error("用户名已存在");
            }
        }

        // 只复制非空属性
        if (userVO.getUsername() != null && !userVO.getUsername().isEmpty()) {
            existingUser.setUsername(userVO.getUsername());
        }
        if (userVO.getNickname() != null && !userVO.getNickname().isEmpty()) {
            existingUser.setNickname(userVO.getNickname());
        }
        if (userVO.getSignature() != null && !userVO.getSignature().isEmpty()) {
            existingUser.setSignature(userVO.getSignature());
        }
        if (userVO.getAvatarUrl() != null && !userVO.getAvatarUrl().isEmpty()) {
            existingUser.setAvatarUrl(userVO.getAvatarUrl());
        }
        if (userVO.getAddress() != null && !userVO.getAddress().isEmpty()) {
            existingUser.setAddress(userVO.getAddress());
        }
        if (userVO.getEmail() != null && !userVO.getEmail().isEmpty()) {
            existingUser.setEmail(userVO.getEmail());
        }
        if (userVO.getPhone() != null && !userVO.getPhone().isEmpty()) {
            existingUser.setPhone(userVO.getPhone());
        }

        userDao.update(existingUser);

        // 转换为VO对象返回
        UserVO updatedUserVO = new UserVO();
        BeanUtils.copyProperties(existingUser, updatedUserVO);
        return ApiResponse.success("更新成功", updatedUserVO);
    }

    /**
     * 修改密码
     */
    @Transactional
    public ApiResponse<Void> changePassword(Long userId, String oldPassword, String newPassword) {
        UserPO user = userDao.findById(userId);
        if (user == null) {
            return ApiResponse.error("用户不存在");
        }

        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            return ApiResponse.error("原密码错误");
        }

        userDao.updatePassword(userId, passwordEncoder.encode(newPassword));
        return ApiResponse.success("密码修改成功", null);
    }

    /**
     * 上传头像
     */
    @Transactional
    public ApiResponse<String> uploadAvatar(Long userId, MultipartFile file) {
        UserPO user = userDao.findById(userId);
        if (user == null) {
            return ApiResponse.error("用户不存在");
        }

        try {
            // 确保上传目录存在
            File uploadDirectory = new File(uploadDir);
            if (!uploadDirectory.exists()) {
                uploadDirectory.mkdirs();
            }

            // 生成文件名
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String filename = UUID.randomUUID().toString() + extension;

            // 保存文件
            Path filePath = Paths.get(uploadDir, filename);
            Files.copy(file.getInputStream(), filePath);

            // 更新用户头像URL
            user.setAvatarUrl("/uploads/" + filename);
            userDao.update(user);

            return ApiResponse.success("头像上传成功", user.getAvatarUrl());
        } catch (IOException e) {
            return ApiResponse.error("头像上传失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户信息
     */
    public ApiResponse<UserVO> getUserInfo(Long userId) {
        UserPO user = userDao.findById(userId);
        if (user == null) {
            return ApiResponse.error("用户不存在");
        }

        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(user, userVO);
        return ApiResponse.success(userVO);
    }

    /**
     * 分页获取用户列表
     */
    public ApiResponse<List<UserVO>> getUserList(int page, int size) {
        int offset = (page - 1) * size;
        List<UserPO> users = userDao.findByPage(offset, size);

        List<UserVO> userVOs = users.stream()
                .map(user -> {
                    UserVO userVO = new UserVO();
                    BeanUtils.copyProperties(user, userVO);
                    return userVO;
                })
                .collect(java.util.stream.Collectors.toList());

        return ApiResponse.success(userVOs);
    }

    /**
     * 禁用用户
     */
    @Transactional
    public ApiResponse<Void> disableUser(Long userId) {
        UserPO user = userDao.findById(userId);
        if (user == null) {
            return ApiResponse.error("用户不存在");
        }

        user.setStatus(0);
        userDao.update(user);
        return ApiResponse.success("用户已禁用", null);
    }

    /**
     * 启用用户
     */
    @Transactional
    public ApiResponse<Void> enableUser(Long userId) {
        UserPO user = userDao.findById(userId);
        if (user == null) {
            return ApiResponse.error("用户不存在");
        }

        user.setStatus(1);
        userDao.update(user);
        return ApiResponse.success("用户已启用", null);
    }

    /**
     * 用户登出
     */
    @Transactional
    public ApiResponse<Void> logout(Long userId) {
        // 从Redis中删除token
        redisService.delete(USER_TOKEN_KEY_PREFIX + userId);
        return ApiResponse.success("登出成功", null);
    }

    /**
     * 获取用户头像路径
     */
    public String getAvatarPath(Long userId) {
        UserPO user = userDao.findById(userId);
        if (user == null || user.getAvatarUrl() == null) {
            return null;
        }
        return user.getAvatarUrl();
    }
}
