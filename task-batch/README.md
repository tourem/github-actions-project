# Task Batch

Batch planifié pour créer automatiquement des tâches via l'API Task toutes les 30 minutes.

## Fonctionnalités

- **Planification automatique** : S'exécute toutes les 30 minutes via une expression cron
- **Appel API REST** : Utilise l'endpoint POST de l'API Task pour créer des tâches
- **Historique des exécutions** : Enregistre chaque exécution dans une base H2
- **Gestion des erreurs** : Capture et enregistre les erreurs d'exécution

## Configuration

### Expression Cron

L'expression cron par défaut est configurée dans `config/application.yml`:

```yaml
task:
  batch:
    cron: "0 0/30 * * * ?"  # Toutes les 30 minutes
```

**Exemples d'expressions cron:**
- `0 0/30 * * * ?` - Toutes les 30 minutes
- `0 0/15 * * * ?` - Toutes les 15 minutes
- `0 0 * * * ?` - Toutes les heures
- `0 0 9-17 * * ?` - Toutes les heures entre 9h et 17h
- `0 0/2 * * * ?` - Toutes les 2 minutes (pour les tests)

### URL de l'API

L'URL de l'API Task est configurée dans `config/application.yml`:

```yaml
task:
  api:
    base-url: http://localhost:8080
```

**Important:** Assurez-vous que l'API Task est démarrée avant de lancer le batch.

## Déploiement

### Prérequis
- JDK 21
- L'API Task doit être démarrée et accessible
- Le fichier ZIP de distribution

### Installation

1. Extraire le fichier ZIP:
```bash
unzip task-batch-1.0-SNAPSHOT.zip
cd task-batch
```

2. Configurer l'URL de l'API (si nécessaire):
```bash
# Éditer config/application.yml
# Modifier task.api.base-url si l'API n'est pas sur localhost:8080
```

3. Démarrer l'application:

**Linux/Mac:**
```bash
./bin/start.sh
```

**Windows:**
```cmd
bin\start.bat
```

4. Arrêter l'application (Linux/Mac):
```bash
./bin/stop.sh
```

## Logs

Les logs sont disponibles dans le répertoire `logs/task-batch.log`.

Pour suivre les logs en temps réel:
```bash
tail -f logs/task-batch.log
```

## Exemple de sortie

```
========================================
Démarrage du batch de création de tâche: 2024-01-01 10:00:00
========================================
Appel de l'API POST http://localhost:8080/api/tasks avec la tâche: Vérifier les logs système
Tâche créée avec succès. ID: 42
✓ Batch terminé avec succès
  - Tâche créée: Vérifier les logs système
  - ID: 42
========================================
```

## Base de données

Le batch utilise une base H2 en mémoire pour enregistrer l'historique des exécutions.

Console H2 accessible à: http://localhost:8081/h2-console

- JDBC URL: `jdbc:h2:mem:batchdb`
- Username: `sa`
- Password: (vide)

## Tests

Pour tester le batch plus rapidement, vous pouvez modifier l'expression cron dans `config/application.yml`:

```yaml
task:
  batch:
    cron: "0 0/2 * * * ?"  # Toutes les 2 minutes
```

Redémarrez ensuite l'application pour que les changements prennent effet.

