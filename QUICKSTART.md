# Guide de Démarrage Rapide

Ce guide vous permet de démarrer rapidement avec le projet Task Management.

## Prérequis

- JDK 21 installé
- Maven 3.x installé
- Terminal (Linux/Mac) ou Command Prompt (Windows)

## Étape 1 : Build du projet

```bash
# Compiler et packager les deux modules
mvn clean package
```

Cette commande génère :
- `task-api/target/task-api-1.0-SNAPSHOT.zip`
- `task-batch/target/task-batch-1.0-SNAPSHOT.zip`

## Étape 2 : Déployer et démarrer l'API

### Linux/Mac

```bash
# Extraire le ZIP
cd task-api/target
unzip task-api-1.0-SNAPSHOT.zip
cd task-api

# Démarrer l'API
./bin/start.sh

# Vérifier que l'API fonctionne
curl http://localhost:8080/api/tasks/stats
```

### Windows

```cmd
REM Extraire le ZIP manuellement ou avec PowerShell
cd task-api\target
powershell Expand-Archive task-api-1.0-SNAPSHOT.zip -DestinationPath .
cd task-api

REM Démarrer l'API
bin\start.bat
```

## Étape 3 : Déployer et démarrer le Batch

**Important** : Attendez que l'API soit complètement démarrée avant de lancer le batch !

### Linux/Mac

```bash
# Depuis la racine du projet
cd task-batch/target
unzip task-batch-1.0-SNAPSHOT.zip
cd task-batch

# Démarrer le batch
./bin/start.sh

# Suivre les logs
tail -f logs/task-batch.log
```

### Windows

```cmd
REM Depuis la racine du projet
cd task-batch\target
powershell Expand-Archive task-batch-1.0-SNAPSHOT.zip -DestinationPath .
cd task-batch

REM Démarrer le batch
bin\start.bat
```

## Étape 4 : Tester le système

### Créer une tâche manuellement

```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Ma première tâche",
    "description": "Ceci est un test",
    "status": "PENDING"
  }'
```

### Récupérer toutes les tâches

```bash
curl http://localhost:8080/api/tasks
```

### Voir les statistiques

```bash
curl http://localhost:8080/api/tasks/stats
```

## Étape 5 : Observer le batch en action

Le batch s'exécute automatiquement toutes les 30 minutes. Pour le tester plus rapidement :

1. Arrêter le batch :
   ```bash
   ./bin/stop.sh  # Linux/Mac
   ```

2. Modifier la configuration dans `config/application.yml` :
   ```yaml
   task:
     batch:
       cron: "0 0/2 * * * ?"  # Toutes les 2 minutes
   ```

3. Redémarrer le batch :
   ```bash
   ./bin/start.sh  # Linux/Mac
   ```

4. Suivre les logs :
   ```bash
   tail -f logs/task-batch.log
   ```

Vous devriez voir une nouvelle tâche créée toutes les 2 minutes !

## Consoles H2

### API Database
- URL : http://localhost:8080/h2-console
- JDBC URL : `jdbc:h2:mem:taskdb`
- Username : `sa`
- Password : (vide)

### Batch Database
- URL : http://localhost:8081/h2-console
- JDBC URL : `jdbc:h2:mem:batchdb`
- Username : `sa`
- Password : (vide)

## Arrêter les applications

### Linux/Mac

```bash
# Arrêter l'API
cd task-api
./bin/stop.sh

# Arrêter le batch
cd task-batch
./bin/stop.sh
```

### Windows

Fermez simplement les fenêtres de commande ou utilisez Ctrl+C.

## Mode Développement

Pour développer sans créer les ZIP :

**Terminal 1 - API :**
```bash
cd task-api
mvn spring-boot:run
```

**Terminal 2 - Batch :**
```bash
cd task-batch
mvn spring-boot:run
```

## Dépannage

### L'API ne démarre pas
- Vérifiez que le port 8080 n'est pas déjà utilisé
- Vérifiez les logs dans `logs/task-api.log`

### Le batch ne peut pas contacter l'API
- Vérifiez que l'API est bien démarrée
- Vérifiez l'URL dans `task-batch/config/application.yml`
- Vérifiez les logs dans `logs/task-batch.log`

### Le batch ne s'exécute pas
- Vérifiez l'expression cron dans `config/application.yml`
- Attendez le prochain intervalle de 30 minutes
- Ou modifiez le cron pour tester plus rapidement

## Prochaines étapes

- Consultez le [README.md](README.md) pour plus de détails
- Consultez [task-api/README.md](task-api/README.md) pour la documentation de l'API
- Consultez [task-batch/README.md](task-batch/README.md) pour la documentation du batch

