package org.example.dao;

import org.apache.ibatis.annotations.Mapper;
import org.example.entity.po.FileRecord;
import java.util.List;

@Mapper
public interface FileRecordDao {
    int insert(FileRecord fileRecord);
    int update(FileRecord fileRecord);
    int deleteById(Long id);
    FileRecord selectById(Long id);
    List<FileRecord> selectByUploaderId(Long uploaderId);
    FileRecord selectByMessageId(Long messageId);
}
