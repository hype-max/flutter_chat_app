package org.example.entity.po;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Message {
    private Long id;
    private Long senderId;
    private Long receiverId;
    private String content;
    private Integer msgType;
    private Long groupId;
    private LocalDateTime createTime;
}
