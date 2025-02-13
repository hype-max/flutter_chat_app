package org.example;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("org.example.mapper")
public class ChatAppApplication {
    public static void main(String[] args) {
        SpringApplication.run(ChatAppApplication.class, args);
    }
}
