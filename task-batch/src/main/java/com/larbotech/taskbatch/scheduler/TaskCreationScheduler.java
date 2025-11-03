package com.larbotech.taskbatch.scheduler;

import com.larbotech.taskbatch.dto.TaskRequest;
import com.larbotech.taskbatch.dto.TaskResponse;
import com.larbotech.taskbatch.service.BatchExecutionService;
import com.larbotech.taskbatch.service.TaskApiClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@Component
public class TaskCreationScheduler {

    private static final Logger logger = LoggerFactory.getLogger(TaskCreationScheduler.class);
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private final TaskApiClient taskApiClient;
    private final BatchExecutionService batchExecutionService;
    private final Random random = new Random();

    private static final String[] TASK_TEMPLATES = {
        "Vérifier les logs système",
        "Sauvegarder la base de données",
        "Nettoyer les fichiers temporaires",
        "Générer le rapport quotidien",
        "Synchroniser les données",
        "Archiver les anciens fichiers",
        "Mettre à jour les statistiques",
        "Envoyer les notifications",
        "Valider l'intégrité des données",
        "Optimiser les performances"
    };

    public TaskCreationScheduler(TaskApiClient taskApiClient, 
                                 BatchExecutionService batchExecutionService) {
        this.taskApiClient = taskApiClient;
        this.batchExecutionService = batchExecutionService;
    }

    /**
     * Job planifié qui s'exécute toutes les 30 minutes
     * Expression cron: "0 0/30 * * * ?" = à la minute 0 de chaque 30 minutes
     */
    @Scheduled(cron = "${task.batch.cron:0 0/30 * * * ?}")
    public void createScheduledTask() {
        LocalDateTime now = LocalDateTime.now();
        String timestamp = now.format(formatter);
        
        logger.info("========================================");
        logger.info("Démarrage du batch de création de tâche: {}", timestamp);
        logger.info("========================================");

        try {
            // Créer une tâche avec un titre aléatoire
            String taskTitle = TASK_TEMPLATES[random.nextInt(TASK_TEMPLATES.length)];
            String description = String.format(
                "Tâche générée automatiquement par le batch le %s", 
                timestamp
            );

            TaskRequest taskRequest = new TaskRequest(
                taskTitle,
                description,
                "PENDING"
            );

            // Appeler l'API pour créer la tâche
            TaskResponse response = taskApiClient.createTask(taskRequest);

            // Enregistrer l'exécution du batch
            String message = String.format(
                "Tâche créée avec succès: '%s' (ID: %d)", 
                taskTitle, 
                response.getId()
            );
            batchExecutionService.saveBatchExecution("SUCCESS", message, 1);

            logger.info("✓ Batch terminé avec succès");
            logger.info("  - Tâche créée: {}", taskTitle);
            logger.info("  - ID: {}", response.getId());
            logger.info("========================================");

        } catch (Exception e) {
            logger.error("✗ Erreur lors de l'exécution du batch", e);
            
            // Enregistrer l'échec
            String errorMessage = String.format(
                "Erreur lors de la création de la tâche: %s", 
                e.getMessage()
            );
            batchExecutionService.saveBatchExecution("FAILED", errorMessage, 0);
            
            logger.info("========================================");
        }
    }

    /**
     * Job de test qui s'exécute toutes les 2 minutes (pour les tests)
     * Décommenter pour tester plus rapidement
     */
    // @Scheduled(cron = "0 0/2 * * * ?")
    public void createTestTask() {
        logger.info("Exécution du job de test (toutes les 2 minutes)");
        createScheduledTask();
    }
}

