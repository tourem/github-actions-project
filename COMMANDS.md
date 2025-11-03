# Commandes Utiles

Ce fichier regroupe toutes les commandes utiles pour travailler avec le projet.

## 🔨 Build et Compilation

### Compiler tout le projet
```bash
mvn clean package
```

### Compiler sans les tests
```bash
mvn clean package -DskipTests
```

### Compiler uniquement l'API
```bash
mvn clean package -pl task-api
```

### Compiler uniquement le Batch
```bash
mvn clean package -pl task-batch
```

### Nettoyer le projet
```bash
mvn clean
```

### Vérifier le projet
```bash
mvn verify
```

## 🚀 Démarrage en Mode Développement

### Démarrer l'API (mode dev)
```bash
cd task-api
mvn spring-boot:run
```

### Démarrer le Batch (mode dev)
```bash
cd task-batch
mvn spring-boot:run
```

### Démarrer avec un profil spécifique
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

### Démarrer sur un port différent
```bash
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=9090
```

## 📦 Déploiement

### Extraire les archives ZIP

**Linux/Mac:**
```bash
# API
cd task-api/target
unzip task-api-1.0-SNAPSHOT.zip

# Batch
cd task-batch/target
unzip task-batch-1.0-SNAPSHOT.zip
```

**Windows (PowerShell):**
```powershell
# API
cd task-api\target
Expand-Archive task-api-1.0-SNAPSHOT.zip -DestinationPath .

# Batch
cd task-batch\target
Expand-Archive task-batch-1.0-SNAPSHOT.zip -DestinationPath .
```

### Démarrer les applications

**Linux/Mac:**
```bash
# API
cd task-api
./bin/start.sh

# Batch
cd task-batch
./bin/start.sh
```

**Windows:**
```cmd
REM API
cd task-api
bin\start.bat

REM Batch
cd task-batch
bin\start.bat
```

### Arrêter les applications

**Linux/Mac:**
```bash
# API
cd task-api
./bin/stop.sh

# Batch
cd task-batch
./bin/stop.sh
```

**Windows:**
```cmd
REM Fermer les fenêtres ou utiliser Ctrl+C
```

## 🧪 Tests de l'API

### Créer une tâche
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Ma tâche",
    "description": "Description de la tâche",
    "status": "PENDING"
  }'
```

### Récupérer toutes les tâches
```bash
curl http://localhost:8080/api/tasks
```

### Récupérer les statistiques
```bash
curl http://localhost:8080/api/tasks/stats
```

### Récupérer une tâche par ID
```bash
curl http://localhost:8080/api/tasks/1
```

### Mettre à jour une tâche
```bash
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Tâche modifiée",
    "description": "Nouvelle description",
    "status": "COMPLETED"
  }'
```

### Supprimer une tâche
```bash
curl -X DELETE http://localhost:8080/api/tasks/1
```

### Avec formatage JSON (jq)
```bash
# Installer jq si nécessaire
# Mac: brew install jq
# Linux: apt-get install jq

curl -s http://localhost:8080/api/tasks | jq .
curl -s http://localhost:8080/api/tasks/stats | jq .
```

## 📊 Monitoring et Logs

### Suivre les logs en temps réel

**Linux/Mac:**
```bash
# API
tail -f task-api/logs/task-api.log

# Batch
tail -f task-batch/logs/task-batch.log
```

**Windows (PowerShell):**
```powershell
# API
Get-Content task-api\logs\task-api.log -Wait -Tail 50

# Batch
Get-Content task-batch\logs\task-batch.log -Wait -Tail 50
```

### Vérifier les processus

**Linux/Mac:**
```bash
# Vérifier si l'API tourne
ps aux | grep task-api

# Vérifier si le Batch tourne
ps aux | grep task-batch

# Vérifier les ports
netstat -tlnp | grep 8080
netstat -tlnp | grep 8081
```

**Mac (alternative):**
```bash
lsof -i :8080
lsof -i :8081
```

### Vérifier les PID

```bash
# API
cat task-api/task-api.pid

# Batch
cat task-batch/task-batch.pid
```

## 🗄️ Base de Données H2

### Accéder aux consoles H2

**API Database:**
```
URL: http://localhost:8080/h2-console
JDBC URL: jdbc:h2:mem:taskdb
Username: sa
Password: (vide)
```

**Batch Database:**
```
URL: http://localhost:8081/h2-console
JDBC URL: jdbc:h2:mem:batchdb
Username: sa
Password: (vide)
```

### Requêtes SQL utiles

```sql
-- Voir toutes les tâches
SELECT * FROM tasks;

-- Compter les tâches par statut
SELECT status, COUNT(*) FROM tasks GROUP BY status;

-- Voir les dernières tâches créées
SELECT * FROM tasks ORDER BY created_at DESC LIMIT 10;

-- Voir l'historique des exécutions du batch
SELECT * FROM batch_executions ORDER BY execution_time DESC;
```

## 🔧 Configuration

### Modifier le port de l'API
```bash
# Éditer task-api/config/application.yml
vi task-api/config/application.yml

# Ou via variable d'environnement
export SERVER_PORT=9090
./bin/start.sh
```

### Modifier l'expression cron du Batch
```bash
# Éditer task-batch/config/application.yml
vi task-batch/config/application.yml

# Modifier la ligne:
# task.batch.cron: "0 0/30 * * * ?"

# Exemples:
# Toutes les 2 minutes: "0 0/2 * * * ?"
# Toutes les heures: "0 0 * * * ?"
# Tous les jours à 9h: "0 0 9 * * ?"
```

### Modifier l'URL de l'API pour le Batch
```bash
# Éditer task-batch/config/application.yml
vi task-batch/config/application.yml

# Modifier la ligne:
# task.api.base-url: http://localhost:8080

# Exemple pour un serveur distant:
# task.api.base-url: http://192.168.1.100:8080
```

## 🐳 Docker (optionnel)

### Créer une image Docker pour l'API
```dockerfile
# Créer un fichier Dockerfile dans task-api/
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/task-api.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

```bash
# Build
docker build -t task-api:1.0 task-api/

# Run
docker run -d -p 8080:8080 --name task-api task-api:1.0
```

## 🔍 Dépannage

### Vérifier que Java 21 est installé
```bash
java -version
# Devrait afficher: openjdk version "21"
```

### Vérifier que Maven est installé
```bash
mvn -version
```

### Tester la connectivité réseau
```bash
# Tester si l'API répond
curl -I http://localhost:8080/api/tasks/stats

# Tester depuis le serveur du batch vers l'API
curl -I http://api-server:8080/api/tasks/stats
```

### Nettoyer complètement le projet
```bash
mvn clean
rm -rf task-api/target
rm -rf task-batch/target
rm -rf ~/.m2/repository/com/larbotech
```

### Forcer le téléchargement des dépendances
```bash
mvn clean install -U
```

## 📝 Git

### Initialiser le dépôt Git
```bash
git init
git add .
git commit -m "Initial commit: Multi-module Maven project with API and Batch"
```

### Ignorer les fichiers générés
```bash
# Le .gitignore est déjà configuré pour ignorer:
# - target/
# - *.log
# - *.pid
# - IDE files
```

### Créer une branche de développement
```bash
git checkout -b develop
```

## 🚦 Systemd (Linux)

### Créer un service pour l'API
```bash
sudo nano /etc/systemd/system/task-api.service
```

### Gérer le service
```bash
# Recharger systemd
sudo systemctl daemon-reload

# Démarrer
sudo systemctl start task-api

# Arrêter
sudo systemctl stop task-api

# Redémarrer
sudo systemctl restart task-api

# Activer au démarrage
sudo systemctl enable task-api

# Voir le statut
sudo systemctl status task-api

# Voir les logs
sudo journalctl -u task-api -f
```

## 📊 Performance

### Mesurer le temps de réponse
```bash
time curl -s http://localhost:8080/api/tasks > /dev/null
```

### Tester la charge (avec Apache Bench)
```bash
# Installer ab
# Mac: brew install httpd
# Linux: apt-get install apache2-utils

# 1000 requêtes, 10 concurrentes
ab -n 1000 -c 10 http://localhost:8080/api/tasks/stats
```

## 🔐 Sécurité (pour production)

### Générer un mot de passe pour H2
```bash
# Si vous passez à une base persistante
openssl rand -base64 32
```

### Configurer HTTPS avec nginx
```bash
# Installer nginx
sudo apt-get install nginx

# Configurer le reverse proxy
sudo nano /etc/nginx/sites-available/task-api
```

## 📦 Backup

### Sauvegarder la configuration
```bash
# API
tar -czf task-api-config-backup.tar.gz task-api/config/

# Batch
tar -czf task-batch-config-backup.tar.gz task-batch/config/
```

### Restaurer la configuration
```bash
tar -xzf task-api-config-backup.tar.gz
```

## 🎯 Raccourcis Utiles

### Tout compiler et démarrer
```bash
# Terminal 1
mvn clean package && cd task-api/target && unzip -o task-api-1.0-SNAPSHOT.zip && cd task-api && ./bin/start.sh

# Terminal 2
cd task-batch/target && unzip -o task-batch-1.0-SNAPSHOT.zip && cd task-batch && ./bin/start.sh
```

### Tout arrêter
```bash
cd task-api && ./bin/stop.sh
cd task-batch && ./bin/stop.sh
```

### Créer un alias (ajouter à ~/.bashrc ou ~/.zshrc)
```bash
alias task-api-start='cd ~/path/to/task-api && ./bin/start.sh'
alias task-api-stop='cd ~/path/to/task-api && ./bin/stop.sh'
alias task-batch-start='cd ~/path/to/task-batch && ./bin/start.sh'
alias task-batch-stop='cd ~/path/to/task-batch && ./bin/stop.sh'
```

## 📚 Documentation

### Générer la Javadoc
```bash
mvn javadoc:javadoc
```

### Voir la Javadoc
```bash
open task-api/target/site/apidocs/index.html
open task-batch/target/site/apidocs/index.html
```

## ✅ Checklist de Démarrage Rapide

```bash
# 1. Compiler
mvn clean package

# 2. Démarrer l'API
cd task-api/target && unzip task-api-1.0-SNAPSHOT.zip && cd task-api && ./bin/start.sh

# 3. Tester l'API
curl http://localhost:8080/api/tasks/stats

# 4. Démarrer le Batch
cd task-batch/target && unzip task-batch-1.0-SNAPSHOT.zip && cd task-batch && ./bin/start.sh

# 5. Suivre les logs
tail -f task-batch/logs/task-batch.log
```

Voilà ! Vous avez maintenant toutes les commandes nécessaires pour travailler efficacement avec le projet. 🚀

