package org.example.entity.vo;

import lombok.Data;

@Data
public class WebSocketMessageVO {
    private Long senderId;
    private Long receiverId;
    private Long groupId;
    private String content;
    private Integer msgType;  // 1:text, 2:image, 3:file, 4:voice
}
