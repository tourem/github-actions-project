package com.larbotech.taskbatch.service;

import com.larbotech.taskbatch.dto.TaskRequest;
import com.larbotech.taskbatch.dto.TaskResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class TaskApiClient {

    private static final Logger logger = LoggerFactory.getLogger(TaskApiClient.class);

    private final RestTemplate restTemplate;
    private final String apiBaseUrl;

    public TaskApiClient(RestTemplate restTemplate, 
                        @Value("${task.api.base-url}") String apiBaseUrl) {
        this.restTemplate = restTemplate;
        this.apiBaseUrl = apiBaseUrl;
    }

    public TaskResponse createTask(TaskRequest taskRequest) {
        try {
            String url = apiBaseUrl + "/api/tasks";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<TaskRequest> request = new HttpEntity<>(taskRequest, headers);
            
            logger.info("Appel de l'API POST {} avec la tâche: {}", url, taskRequest.getTitle());
            
            ResponseEntity<TaskResponse> response = restTemplate.postForEntity(
                url, 
                request, 
                TaskResponse.class
            );
            
            TaskResponse taskResponse = response.getBody();
            logger.info("Tâche créée avec succès. ID: {}", taskResponse != null ? taskResponse.getId() : "null");
            
            return taskResponse;
            
        } catch (Exception e) {
            logger.error("Erreur lors de la création de la tâche via l'API", e);
            throw new RuntimeException("Échec de la création de la tâche: " + e.getMessage(), e);
        }
    }
}

