package org.example.testest.controller;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GwajeController {

    private final StringRedisTemplate redisTemplate;

    public GwajeController(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @GetMapping("/set")
    public String set() {
        redisTemplate.opsForValue().set("hello", "world");
        return "saved";
    }

    @GetMapping("/get")
    public String get() {
        return redisTemplate.opsForValue().get("hello");
    }
}