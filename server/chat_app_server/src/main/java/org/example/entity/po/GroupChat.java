package org.example.entity.po;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class GroupChat {
    private Long id;
    private String name;
    private String avatar;
    private Long ownerId;
    private String announcement;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
