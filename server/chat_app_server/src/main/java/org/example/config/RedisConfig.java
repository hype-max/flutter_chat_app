package org.example.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import com.fasterxml.jackson.databind.ObjectMapper;

@Configuration
public class RedisConfig {
    
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        
        // 使用Jackson2JsonRedisSerializer作为默认序列化器
        Jackson2JsonRedisSerializer<Object> jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer<>(Object.class);
        
        // 配置ObjectMapper
        ObjectMapper objectMapper = new ObjectMapper();
        jackson2JsonRedisSerializer.setObjectMapper(objectMapper);
        
        // key采用String序列化方式
        template.setKeySerializer(new StringRedisSerializer());
        // hash的key也采用String序列化方式
        template.setHashKeySerializer(new StringRedisSerializer());
        // value采用jackson序列化方式
        template.setValueSerializer(jackson2JsonRedisSerializer);
        // hash的value也采用jackson序列化方式
        template.setHashValueSerializer(jackson2JsonRedisSerializer);
        
        template.afterPropertiesSet();
        return template;
    }
}
