package org.example.entity.po;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class FriendRelationship {
    private Long id;
    private Long userId;
    private Long friendId;
    private Integer status;  // 0:pending, 1:accepted, 2:rejected, 3:blocked
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
