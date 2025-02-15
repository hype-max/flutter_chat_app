package org.example.entity.po;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class GroupMember {
    private Long id;
    private Long groupId;
    private Long userId;
    private Integer role;  // 0:member, 1:admin, 2:owner
    private LocalDateTime joinTime;
}
