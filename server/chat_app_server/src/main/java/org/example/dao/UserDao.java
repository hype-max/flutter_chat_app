package org.example.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.entity.po.UserPO;
import java.util.List;

/**
 * 用户数据访问接口
 */
@Mapper
public interface UserDao {
    /**
     * 插入新用户
     *
     * @param user 用户信息
     * @return 影响的行数
     */
    int insert(UserPO user);

    /**
     * 根据ID更新用户信息
     *
     * @param user 用户信息
     * @return 影响的行数
     */
    int update(UserPO user);

    /**
     * 更新用户密码
     *
     * @param id 用户ID
     * @param password 新密码（已加密）
     * @return 影响的行数
     */
    int updatePassword(@Param("id") Long id, @Param("password") String password);

    /**
     * 根据ID删除用户
     *
     * @param id 用户ID
     * @return 影响的行数
     */
    int deleteById(Long id);

    /**
     * 根据ID查询用户
     *
     * @param id 用户ID
     * @return 用户信息
     */
    UserPO findById(Long id);

    /**
     * 根据用户名查询用户
     *
     * @param username 用户名
     * @return 用户信息
     */
    UserPO findByUsername(String username);

    /**
     * 根据邮箱查询用户
     *
     * @param email 邮箱
     * @return 用户信息
     */
    UserPO findByEmail(String email);

    /**
     * 根据手机号查询用户
     *
     * @param phone 手机号
     * @return 用户信息
     */
    UserPO findByPhone(String phone);

    /**
     * 更新用户最后登录时间
     *
     * @param id 用户ID
     * @return 影响的行数
     */
    int updateLastLoginTime(Long id);

    /**
     * 分页查询用户列表
     *
     * @param offset 偏移量
     * @param limit 限制数量
     * @return 用户列表
     */
    List<UserPO> findByPage(@Param("offset") int offset, @Param("limit") int limit);

    /**
     * 统计用户总数
     *
     * @return 用户总数
     */
    int count();

    /**
     * 批量更新用户状态
     *
     * @param ids 用户ID列表
     * @param status 状态
     * @return 影响的行数
     */
    int batchUpdateStatus(@Param("ids") List<Long> ids, @Param("status") Integer status);
}
