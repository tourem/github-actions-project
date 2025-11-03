# Projet Multi-Modules Maven - Task Management

Projet Maven multi-modules avec Spring Boot 3 et JDK 21, composé de deux modules indépendants :
- **task-api** : API REST pour la gestion des tâches
- **task-batch** : Batch planifié qui crée automatiquement des tâches

## Architecture

```
github-actions-project/
├── pom.xml                    # POM parent
├── task-api/                  # Module API REST
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   ├── resources/
│   │   │   ├── scripts/       # Scripts de démarrage/arrêt
│   │   │   └── assembly/      # Configuration assembly
│   │   └── test/
│   └── pom.xml
└── task-batch/                # Module Batch
    ├── src/
    │   ├── main/
    │   │   ├── java/
    │   │   ├── resources/
    │   │   ├── scripts/       # Scripts de démarrage/arrêt
    │   │   └── assembly/      # Configuration assembly
    │   └── test/
    └── pom.xml
```

## Technologies

- **Java** : JDK 21
- **Framework** : Spring Boot 3.2.0
- **Base de données** : H2 (en mémoire)
- **Build** : Maven 3.x
- **Packaging** : Maven Assembly Plugin (ZIP)

## Modules

### 1. Task API (Port 8080)

API REST exposant 3 endpoints principaux :

#### Endpoints

**GET /api/tasks**
- Récupère toutes les tâches
- Réponse : Liste de tâches au format JSON

**GET /api/tasks/stats**
- Récupère les statistiques des tâches
- Réponse : Nombre total, pending, completed, in_progress

**POST /api/tasks**
- Crée une nouvelle tâche
- Body : `{"title": "...", "description": "...", "status": "PENDING"}`
- Réponse : Tâche créée avec son ID

#### Base de données
- H2 en mémoire : `jdbc:h2:mem:taskdb`
- Console H2 : http://localhost:8080/h2-console

### 2. Task Batch (Port 8081)

Batch planifié qui s'exécute automatiquement toutes les 30 minutes.

#### Fonctionnalités
- Planification via expression cron : `0 0/30 * * * ?`
- Appelle l'endpoint POST de l'API pour créer une tâche
- Enregistre l'historique des exécutions dans sa propre base H2

#### Base de données
- H2 en mémoire : `jdbc:h2:mem:batchdb`
- Console H2 : http://localhost:8081/h2-console

## Build et Packaging

### Compiler le projet complet

```bash
mvn clean package
```

Cette commande va :
1. Compiler les deux modules
2. Créer les JARs exécutables
3. Générer les archives ZIP de distribution dans `target/` de chaque module

### Compiler un module spécifique

```bash
# API uniquement
mvn clean package -pl task-api

# Batch uniquement
mvn clean package -pl task-batch
```

### Résultat du build

Après le build, vous trouverez :
- `task-api/target/task-api-1.0-SNAPSHOT.zip`
- `task-batch/target/task-batch-1.0-SNAPSHOT.zip`

Chaque ZIP contient :
```
module-name/
├── bin/
│   ├── start.sh       # Script de démarrage Linux/Mac
│   ├── stop.sh        # Script d'arrêt Linux/Mac
│   └── start.bat      # Script de démarrage Windows
├── lib/
│   └── module.jar     # JAR exécutable
├── config/
│   └── application.yml # Configuration
├── logs/              # Créé au démarrage
└── README.md
```

## Déploiement

### 1. Déployer l'API

```bash
# Extraire le ZIP
unzip task-api/target/task-api-1.0-SNAPSHOT.zip
cd task-api

# Démarrer (Linux/Mac)
./bin/start.sh

# Démarrer (Windows)
bin\start.bat

# Arrêter (Linux/Mac)
./bin/stop.sh
```

L'API sera accessible sur http://localhost:8080

### 2. Déployer le Batch

**Important** : L'API doit être démarrée avant le batch !

```bash
# Extraire le ZIP
unzip task-batch/target/task-batch-1.0-SNAPSHOT.zip
cd task-batch

# Configurer l'URL de l'API si nécessaire
# Éditer config/application.yml
# task.api.base-url: http://localhost:8080

# Démarrer (Linux/Mac)
./bin/start.sh

# Démarrer (Windows)
bin\start.bat

# Arrêter (Linux/Mac)
./bin/stop.sh
```

Le batch s'exécutera automatiquement toutes les 30 minutes.

## Configuration

### Modifier l'expression cron du batch

Éditez `task-batch/config/application.yml` :

```yaml
task:
  batch:
    cron: "0 0/30 * * * ?"  # Toutes les 30 minutes
```

Exemples :
- `0 0/15 * * * ?` - Toutes les 15 minutes
- `0 0 * * * ?` - Toutes les heures
- `0 0/2 * * * ?` - Toutes les 2 minutes (pour tests)

### Modifier l'URL de l'API

Éditez `task-batch/config/application.yml` :

```yaml
task:
  api:
    base-url: http://localhost:8080
```

## Tests

### Tester l'API

```bash
# Créer une tâche
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Ma tâche de test","status":"PENDING"}'

# Récupérer toutes les tâches
curl http://localhost:8080/api/tasks

# Récupérer les statistiques
curl http://localhost:8080/api/tasks/stats
```

### Suivre les logs du batch

```bash
tail -f task-batch/logs/task-batch.log
```

## Développement

### Prérequis
- JDK 21
- Maven 3.x

### Lancer en mode développement

**Terminal 1 - API:**
```bash
cd task-api
mvn spring-boot:run
```

**Terminal 2 - Batch:**
```bash
cd task-batch
mvn spring-boot:run
```

### Structure des packages

**task-api:**
- `controller` : Contrôleurs REST
- `service` : Logique métier
- `repository` : Accès aux données
- `model` : Entités JPA
- `dto` : Objets de transfert

**task-batch:**
- `scheduler` : Jobs planifiés
- `service` : Services (API client, batch execution)
- `model` : Entités JPA
- `dto` : Objets de transfert
- `config` : Configuration Spring

## Indépendance des modules

Les deux modules sont **totalement indépendants** en termes de déploiement :
- Chacun a son propre JAR exécutable
- Chacun a sa propre base de données H2
- Chacun peut être déployé sur des machines différentes
- La communication se fait uniquement via HTTP REST

## Licence

Ce projet est un exemple de démonstration.

