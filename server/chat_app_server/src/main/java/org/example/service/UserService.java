package org.example.service;

import org.example.entity.User;
import org.example.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UserService {
    @Autowired
    private UserMapper userMapper;
    
    public User findByUsername(String username) {
        return userMapper.findByUsername(username);
    }
    
    public List<User> findAll() {
        return userMapper.findAll();
    }
}
