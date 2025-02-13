package org.example.entity.vo;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户视图对象（用于展示用户信息，不包含敏感信息如密码）
 */
@Data
public class UserVO {
    /**
     * 用户ID
     */
    private Long id;

    /**
     * 用户名
     */
    private String username;

    /**
     * 昵称
     */
    private String nickname;

    /**
     * 个性签名
     */
    private String signature;

    /**
     * 头像URL
     */
    private String avatarUrl;

    /**
     * 地址信息
     */
    private String address;

    /**
     * 邮箱
     */
    private String email;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 用户状态：0-禁用，1-正常
     */
    private Integer status;

    /**
     * 最后登录时间
     */
    private LocalDateTime lastLoginTime;
}
