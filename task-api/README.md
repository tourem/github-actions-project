# Task API

API REST pour la gestion des tâches avec Spring Boot 3 et JDK 21.

## Endpoints disponibles

### GET /api/tasks
Récupère toutes les tâches.

**Réponse:**
```json
[
  {
    "id": 1,
    "title": "Ma tâche",
    "description": "Description de la tâche",
    "status": "PENDING",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-01T10:00:00"
  }
]
```

### GET /api/tasks/stats
Récupère les statistiques des tâches.

**Réponse:**
```json
{
  "total": 10,
  "pending": 5,
  "completed": 3,
  "in_progress": 2
}
```

### POST /api/tasks
Crée une nouvelle tâche.

**Requête:**
```json
{
  "title": "Nouvelle tâche",
  "description": "Description",
  "status": "PENDING"
}
```

**Réponse:**
```json
{
  "id": 1,
  "title": "Nouvelle tâche",
  "description": "Description",
  "status": "PENDING",
  "createdAt": "2024-01-01T10:00:00",
  "updatedAt": "2024-01-01T10:00:00"
}
```

## Déploiement

### Prérequis
- JDK 21
- Le fichier ZIP de distribution

### Installation

1. Extraire le fichier ZIP:
```bash
unzip task-api-1.0-SNAPSHOT.zip
cd task-api
```

2. Démarrer l'application:

**Linux/Mac:**
```bash
./bin/start.sh
```

**Windows:**
```cmd
bin\start.bat
```

3. Arrêter l'application (Linux/Mac):
```bash
./bin/stop.sh
```

### Configuration

Les fichiers de configuration se trouvent dans le répertoire `config/`.
Vous pouvez modifier `application.yml` pour personnaliser:
- Le port du serveur
- La configuration de la base de données
- Les niveaux de logs

### Logs

Les logs sont disponibles dans le répertoire `logs/task-api.log`.

### Console H2

La console H2 est accessible à l'adresse: http://localhost:8080/h2-console

- JDBC URL: `jdbc:h2:mem:taskdb`
- Username: `sa`
- Password: (vide)

