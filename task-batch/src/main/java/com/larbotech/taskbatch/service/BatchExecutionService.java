package com.larbotech.taskbatch.service;

import com.larbotech.taskbatch.model.BatchExecution;
import com.larbotech.taskbatch.repository.BatchExecutionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BatchExecutionService {

    private final BatchExecutionRepository batchExecutionRepository;

    public BatchExecutionService(BatchExecutionRepository batchExecutionRepository) {
        this.batchExecutionRepository = batchExecutionRepository;
    }

    @Transactional
    public BatchExecution saveBatchExecution(String status, String message, Integer tasksCreated) {
        BatchExecution execution = new BatchExecution(status, message, tasksCreated);
        return batchExecutionRepository.save(execution);
    }
}

