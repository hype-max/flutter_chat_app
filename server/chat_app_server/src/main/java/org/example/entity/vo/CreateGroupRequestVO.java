package org.example.entity.vo;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Setter
@Getter
public class CreateGroupRequestVO {
    // Getters and setters
    private String name;
    private String avatar;
    private List<Long> memberIds;

}
