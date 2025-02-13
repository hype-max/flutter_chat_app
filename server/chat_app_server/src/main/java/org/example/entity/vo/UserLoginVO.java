package org.example.entity.vo;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;

/**
 * 用户登录请求对象
 */
@Data
public class UserLoginVO {
    /**
     * 用户名
     */
    @NotBlank(message = "用户名不能为空")
    private String username;

    /**
     * 密码
     */
    @NotBlank(message = "密码不能为空")
    private String password;
}
