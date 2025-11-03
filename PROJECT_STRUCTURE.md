# Structure du Projet

Ce document décrit l'organisation complète du projet multi-modules.

## Vue d'ensemble

```
github-actions-project/
├── pom.xml                          # POM parent (multi-modules)
├── README.md                        # Documentation principale
├── QUICKSTART.md                    # Guide de démarrage rapide
├── DEPLOYMENT.md                    # Guide de déploiement
├── API_EXAMPLES.md                  # Exemples d'utilisation de l'API
├── PROJECT_STRUCTURE.md             # Ce fichier
│
├── task-api/                        # Module API REST
│   ├── pom.xml                      # Configuration Maven du module
│   ├── README.md                    # Documentation du module
│   │
│   └── src/
│       ├── main/
│       │   ├── java/com/larbotech/taskapi/
│       │   │   ├── TaskApiApplication.java          # Classe principale
│       │   │   │
│       │   │   ├── controller/
│       │   │   │   └── TaskController.java          # Contrôleur REST (3 endpoints)
│       │   │   │
│       │   │   ├── service/
│       │   │   │   └── TaskService.java             # Logique métier
│       │   │   │
│       │   │   ├── repository/
│       │   │   │   └── TaskRepository.java          # Accès données (JPA)
│       │   │   │
│       │   │   ├── model/
│       │   │   │   └── Task.java                    # Entité JPA
│       │   │   │
│       │   │   └── dto/
│       │   │       └── TaskRequest.java             # DTO pour les requêtes
│       │   │
│       │   ├── resources/
│       │   │   ├── application.yml                  # Configuration par défaut
│       │   │   └── application-prod.yml             # Configuration production
│       │   │
│       │   ├── scripts/
│       │   │   ├── start.sh                         # Script démarrage Linux/Mac
│       │   │   ├── stop.sh                          # Script arrêt Linux/Mac
│       │   │   └── start.bat                        # Script démarrage Windows
│       │   │
│       │   └── assembly/
│       │       └── distribution.xml                 # Configuration assembly (ZIP)
│       │
│       └── test/
│           └── java/                                # Tests unitaires
│
└── task-batch/                      # Module Batch planifié
    ├── pom.xml                      # Configuration Maven du module
    ├── README.md                    # Documentation du module
    │
    └── src/
        ├── main/
        │   ├── java/com/larbotech/taskbatch/
        │   │   ├── TaskBatchApplication.java        # Classe principale
        │   │   │
        │   │   ├── scheduler/
        │   │   │   └── TaskCreationScheduler.java   # Job planifié (cron)
        │   │   │
        │   │   ├── service/
        │   │   │   ├── TaskApiClient.java           # Client HTTP pour l'API
        │   │   │   └── BatchExecutionService.java   # Service métier
        │   │   │
        │   │   ├── repository/
        │   │   │   └── BatchExecutionRepository.java # Accès données
        │   │   │
        │   │   ├── model/
        │   │   │   └── BatchExecution.java          # Entité JPA
        │   │   │
        │   │   ├── dto/
        │   │   │   ├── TaskRequest.java             # DTO requête
        │   │   │   └── TaskResponse.java            # DTO réponse
        │   │   │
        │   │   └── config/
        │   │       └── RestTemplateConfig.java      # Configuration RestTemplate
        │   │
        │   ├── resources/
        │   │   ├── application.yml                  # Configuration par défaut
        │   │   └── application-prod.yml             # Configuration production
        │   │
        │   ├── scripts/
        │   │   ├── start.sh                         # Script démarrage Linux/Mac
        │   │   ├── stop.sh                          # Script arrêt Linux/Mac
        │   │   └── start.bat                        # Script démarrage Windows
        │   │
        │   └── assembly/
        │       └── distribution.xml                 # Configuration assembly (ZIP)
        │
        └── test/
            └── java/                                # Tests unitaires
```

## Détails des Modules

### Module task-api

**Responsabilité** : Exposer une API REST pour la gestion des tâches

**Technologies** :
- Spring Boot 3.2.0
- Spring Web (REST)
- Spring Data JPA
- H2 Database (en mémoire)
- Bean Validation

**Endpoints** :
- `GET /api/tasks` - Récupérer toutes les tâches
- `GET /api/tasks/stats` - Récupérer les statistiques
- `POST /api/tasks` - Créer une nouvelle tâche
- `GET /api/tasks/{id}` - Récupérer une tâche par ID
- `PUT /api/tasks/{id}` - Mettre à jour une tâche
- `DELETE /api/tasks/{id}` - Supprimer une tâche

**Port** : 8080

**Base de données** : H2 en mémoire (`jdbc:h2:mem:taskdb`)

### Module task-batch

**Responsabilité** : Créer automatiquement des tâches via l'API selon un planning

**Technologies** :
- Spring Boot 3.2.0
- Spring Scheduling
- Spring Web (RestTemplate)
- Spring Data JPA
- H2 Database (en mémoire)

**Planification** : Toutes les 30 minutes (configurable via cron)

**Port** : 8081

**Base de données** : H2 en mémoire (`jdbc:h2:mem:batchdb`)

## Architecture des Packages

### task-api

```
com.larbotech.taskapi
├── TaskApiApplication          # Point d'entrée Spring Boot
├── controller/                 # Couche présentation (REST)
├── service/                    # Couche métier
├── repository/                 # Couche accès données
├── model/                      # Entités JPA
└── dto/                        # Objets de transfert
```

### task-batch

```
com.larbotech.taskbatch
├── TaskBatchApplication        # Point d'entrée Spring Boot
├── scheduler/                  # Jobs planifiés
├── service/                    # Couche métier + client API
├── repository/                 # Couche accès données
├── model/                      # Entités JPA
├── dto/                        # Objets de transfert
└── config/                     # Configuration Spring
```

## Fichiers de Configuration

### POM Parent (pom.xml)

- Définit Spring Boot 3.2.0 comme parent
- Configure JDK 21
- Déclare les deux modules
- Configure les plugins communs

### POM des Modules

Chaque module définit :
- Ses dépendances spécifiques
- La configuration du plugin Spring Boot
- La configuration du plugin Assembly

### application.yml

Configuration Spring Boot :
- Port du serveur
- Configuration de la base de données H2
- Configuration JPA/Hibernate
- Niveaux de logs
- Configuration métier (cron, URL API)

### distribution.xml (Assembly)

Définit la structure du ZIP :
```
module-name/
├── bin/           # Scripts de démarrage/arrêt
├── lib/           # JAR exécutable
├── config/        # Fichiers de configuration
└── README.md      # Documentation
```

## Flux de Données

### Création de Tâche via API

```
Client HTTP
    ↓
TaskController.createTask()
    ↓
TaskService.createTask()
    ↓
TaskRepository.save()
    ↓
H2 Database (taskdb)
```

### Création de Tâche via Batch

```
Scheduler (cron)
    ↓
TaskCreationScheduler.createScheduledTask()
    ↓
TaskApiClient.createTask()
    ↓ (HTTP POST)
API REST (localhost:8080)
    ↓
TaskController.createTask()
    ↓
TaskService.createTask()
    ↓
TaskRepository.save()
    ↓
H2 Database (taskdb)
```

### Enregistrement de l'Exécution du Batch

```
TaskCreationScheduler
    ↓
BatchExecutionService.saveBatchExecution()
    ↓
BatchExecutionRepository.save()
    ↓
H2 Database (batchdb)
```

## Cycle de Build

```
mvn clean package
    ↓
Compilation des sources Java
    ↓
Création des JARs
    ↓
Repackaging Spring Boot (JAR exécutable)
    ↓
Assembly Plugin
    ↓
Création des ZIPs de distribution
```

**Résultat** :
- `task-api/target/task-api-1.0-SNAPSHOT.zip`
- `task-batch/target/task-batch-1.0-SNAPSHOT.zip`

## Déploiement

### Structure après extraction du ZIP

```
task-api/
├── bin/
│   ├── start.sh
│   ├── stop.sh
│   └── start.bat
├── lib/
│   └── task-api.jar
├── config/
│   └── application.yml
├── logs/                    # Créé au démarrage
│   └── task-api.log
├── task-api.pid            # Créé au démarrage
└── README.md
```

## Indépendance des Modules

Les modules sont **totalement indépendants** :

1. **Build** : Peuvent être compilés séparément
2. **Déploiement** : Peuvent être déployés sur des machines différentes
3. **Exécution** : Ont leurs propres processus JVM
4. **Base de données** : Chacun a sa propre base H2
5. **Configuration** : Configuration indépendante

**Communication** : Uniquement via HTTP REST (API)

## Évolutions Possibles

### Court terme
- Ajouter des tests unitaires et d'intégration
- Ajouter Spring Security pour l'authentification
- Implémenter la pagination pour GET /api/tasks
- Ajouter des filtres de recherche

### Moyen terme
- Remplacer H2 par PostgreSQL/MySQL
- Ajouter un module frontend (React/Angular)
- Implémenter des webhooks
- Ajouter des métriques (Actuator, Prometheus)

### Long terme
- Containerisation (Docker)
- Orchestration (Kubernetes)
- CI/CD (GitHub Actions, Jenkins)
- Monitoring (Grafana, ELK Stack)

## Conventions de Code

### Nommage
- **Classes** : PascalCase (ex: `TaskController`)
- **Méthodes** : camelCase (ex: `createTask`)
- **Variables** : camelCase (ex: `taskRequest`)
- **Constantes** : UPPER_SNAKE_CASE (ex: `TASK_TEMPLATES`)

### Packages
- `controller` : Contrôleurs REST
- `service` : Logique métier
- `repository` : Accès aux données
- `model` : Entités JPA
- `dto` : Data Transfer Objects
- `config` : Configuration Spring

### Annotations Spring
- `@RestController` : Contrôleurs REST
- `@Service` : Services métier
- `@Repository` : Repositories JPA
- `@Entity` : Entités JPA
- `@Configuration` : Classes de configuration
- `@Component` : Composants génériques
- `@Scheduled` : Méthodes planifiées

## Dépendances Principales

### Communes aux deux modules
- `spring-boot-starter` : Core Spring Boot
- `spring-boot-starter-data-jpa` : JPA/Hibernate
- `h2` : Base de données en mémoire
- `spring-boot-starter-test` : Tests

### Spécifiques à task-api
- `spring-boot-starter-web` : REST API
- `spring-boot-starter-validation` : Validation

### Spécifiques à task-batch
- `spring-boot-starter-web` : RestTemplate

## Versions

- **Java** : 21
- **Spring Boot** : 3.2.0
- **Maven** : 3.x
- **H2** : Géré par Spring Boot
- **Maven Assembly Plugin** : 3.6.0

