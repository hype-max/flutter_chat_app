package org.example.controller;

import org.example.service.RedisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/api/redis")
public class RedisController {
    
    @Autowired
    private RedisService redisService;
    
    @PostMapping("/set")
    public String setValue(@RequestParam String key, @RequestParam String value) {
        redisService.set(key, value);
        return "Value set successfully";
    }
    
    @PostMapping("/set/timeout")
    public String setValueWithTimeout(
            @RequestParam String key,
            @RequestParam String value,
            @RequestParam long timeout) {
        redisService.set(key, value, timeout, TimeUnit.SECONDS);
        return "Value set with timeout successfully";
    }
    
    @GetMapping("/get/{key}")
    public Object getValue(@PathVariable String key) {
        return redisService.get(key);
    }
    
    @DeleteMapping("/delete/{key}")
    public String deleteValue(@PathVariable String key) {
        Boolean deleted = redisService.delete(key);
        return deleted ? "Value deleted successfully" : "Key not found";
    }
    
    @GetMapping("/exists/{key}")
    public Boolean hasKey(@PathVariable String key) {
        return redisService.hasKey(key);
    }
}
