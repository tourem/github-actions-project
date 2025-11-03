package com.larbotech.taskbatch.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "batch_executions")
public class BatchExecution {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "execution_time", nullable = false)
    private LocalDateTime executionTime;

    @Column(nullable = false)
    private String status;

    @Column(length = 1000)
    private String message;

    @Column(name = "tasks_created")
    private Integer tasksCreated;

    @PrePersist
    protected void onCreate() {
        executionTime = LocalDateTime.now();
    }

    // Constructeurs
    public BatchExecution() {
    }

    public BatchExecution(String status, String message, Integer tasksCreated) {
        this.status = status;
        this.message = message;
        this.tasksCreated = tasksCreated;
    }

    // Getters et Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getExecutionTime() {
        return executionTime;
    }

    public void setExecutionTime(LocalDateTime executionTime) {
        this.executionTime = executionTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Integer getTasksCreated() {
        return tasksCreated;
    }

    public void setTasksCreated(Integer tasksCreated) {
        this.tasksCreated = tasksCreated;
    }
}

