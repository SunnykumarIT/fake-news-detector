package com.sunny.fake_news_detector_backend.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api")
public class PredictionController {

    private final RestTemplate restTemplate = new RestTemplate();

    @PostMapping("/predict")
    public ResponseEntity<?> predictFakeNews(@RequestBody Map<String, String> body) {
        String userInput = body.get("text");

        String flaskApiUrl = "http://127.0.0.1:5000/predict";
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, String> payload = new HashMap<>();
        payload.put("text", userInput);

        HttpEntity<Map<String, String>> entity = new HttpEntity<>(payload, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(flaskApiUrl, entity, Map.class);
            return ResponseEntity.ok(response.getBody());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to connect to ML API", "details", e.getMessage()));
        }
    }
}

