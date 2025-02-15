package org.example.entity.po;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class FileRecord {
    private Long id;
    private String originalName;
    private String filePath;
    private Long fileSize;
    private String fileType;
    private Long uploaderId;
    private Long messageId;
    private LocalDateTime createTime;
}
