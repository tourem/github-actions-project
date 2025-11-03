package com.larbotech.taskbatch.repository;

import com.larbotech.taskbatch.model.BatchExecution;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BatchExecutionRepository extends JpaRepository<BatchExecution, Long> {
}

