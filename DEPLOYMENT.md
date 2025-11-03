# Guide de Déploiement en Production

Ce guide explique comment déployer les modules task-api et task-batch sur des serveurs de production.

## Architecture de Déploiement

Les deux modules sont **totalement indépendants** et peuvent être déployés :
- Sur la même machine
- Sur des machines différentes
- Dans des conteneurs Docker séparés
- Sur des serveurs cloud différents

## Prérequis

### Serveur API
- JDK 21
- Port 8080 disponible (ou configurable)
- Accès réseau pour les clients HTTP

### Serveur Batch
- JDK 21
- Port 8081 disponible (ou configurable)
- Accès réseau vers le serveur API

## Déploiement sur Linux/Unix

### 1. Préparation des Serveurs

```bash
# Créer un utilisateur dédié (recommandé)
sudo useradd -m -s /bin/bash taskapp
sudo su - taskapp

# Créer les répertoires
mkdir -p /opt/task-api
mkdir -p /opt/task-batch
```

### 2. Déploiement de l'API

```bash
# Copier le ZIP sur le serveur
scp task-api-1.0-SNAPSHOT.zip taskapp@server:/opt/task-api/

# Se connecter au serveur
ssh taskapp@server

# Extraire et configurer
cd /opt/task-api
unzip task-api-1.0-SNAPSHOT.zip
cd task-api

# Modifier la configuration pour la production
vi config/application.yml
# Ou utiliser le profil prod
export SPRING_PROFILES_ACTIVE=prod

# Rendre les scripts exécutables
chmod +x bin/*.sh

# Démarrer l'API
./bin/start.sh

# Vérifier le démarrage
tail -f logs/task-api.log
```

### 3. Déploiement du Batch

```bash
# Copier le ZIP sur le serveur (peut être le même ou différent)
scp task-batch-1.0-SNAPSHOT.zip taskapp@server:/opt/task-batch/

# Se connecter au serveur
ssh taskapp@server

# Extraire et configurer
cd /opt/task-batch
unzip task-batch-1.0-SNAPSHOT.zip
cd task-batch

# IMPORTANT: Configurer l'URL de l'API
vi config/application.yml
# Modifier task.api.base-url avec l'URL réelle de l'API
# Exemple: http://api-server:8080 ou http://10.0.1.100:8080

# Utiliser le profil prod
export SPRING_PROFILES_ACTIVE=prod

# Rendre les scripts exécutables
chmod +x bin/*.sh

# Démarrer le batch
./bin/start.sh

# Vérifier le démarrage
tail -f logs/task-batch.log
```

## Configuration en tant que Service Systemd

### Service pour l'API

Créer `/etc/systemd/system/task-api.service` :

```ini
[Unit]
Description=Task API Service
After=network.target

[Service]
Type=forking
User=taskapp
Group=taskapp
WorkingDirectory=/opt/task-api/task-api
ExecStart=/opt/task-api/task-api/bin/start.sh
ExecStop=/opt/task-api/task-api/bin/stop.sh
Restart=on-failure
RestartSec=10
Environment="SPRING_PROFILES_ACTIVE=prod"

[Install]
WantedBy=multi-user.target
```

### Service pour le Batch

Créer `/etc/systemd/system/task-batch.service` :

```ini
[Unit]
Description=Task Batch Service
After=network.target task-api.service
Requires=task-api.service

[Service]
Type=forking
User=taskapp
Group=taskapp
WorkingDirectory=/opt/task-batch/task-batch
ExecStart=/opt/task-batch/task-batch/bin/start.sh
ExecStop=/opt/task-batch/task-batch/bin/stop.sh
Restart=on-failure
RestartSec=10
Environment="SPRING_PROFILES_ACTIVE=prod"

[Install]
WantedBy=multi-user.target
```

### Activer et démarrer les services

```bash
# Recharger systemd
sudo systemctl daemon-reload

# Activer les services au démarrage
sudo systemctl enable task-api
sudo systemctl enable task-batch

# Démarrer les services
sudo systemctl start task-api
sudo systemctl start task-batch

# Vérifier le statut
sudo systemctl status task-api
sudo systemctl status task-batch

# Voir les logs
sudo journalctl -u task-api -f
sudo journalctl -u task-batch -f
```

## Configuration Multi-Environnements

### Utilisation des profils Spring

Les modules supportent différents profils :

```bash
# Développement (par défaut)
java -jar task-api.jar

# Production
java -jar task-api.jar --spring.profiles.active=prod

# Environnement personnalisé
java -jar task-api.jar --spring.profiles.active=staging
```

### Variables d'environnement

Vous pouvez surcharger la configuration via des variables d'environnement :

```bash
# API
export SERVER_PORT=9090
export SPRING_DATASOURCE_URL=jdbc:h2:file:/data/taskdb
export LOGGING_LEVEL_COM_LARBOTECH_TASKAPI=DEBUG

# Batch
export TASK_API_BASE_URL=http://api-prod.example.com:8080
export TASK_BATCH_CRON="0 0 * * * ?"  # Toutes les heures
```

### Fichier de configuration externe

```bash
# Démarrer avec un fichier de configuration externe
java -jar task-api.jar --spring.config.location=file:/etc/task-api/application.yml
```

## Déploiement sur Plusieurs Machines

### Scénario : API et Batch sur des serveurs séparés

**Serveur 1 (API) - 192.168.1.10:**
```bash
cd /opt/task-api/task-api
# Pas de modification nécessaire
./bin/start.sh
```

**Serveur 2 (Batch) - 192.168.1.20:**
```bash
cd /opt/task-batch/task-batch

# Modifier config/application.yml
vi config/application.yml
# Changer:
# task:
#   api:
#     base-url: http://192.168.1.10:8080

./bin/start.sh
```

## Sécurité

### Recommandations

1. **Utilisateur dédié** : Ne pas exécuter en tant que root
2. **Firewall** : Limiter l'accès aux ports nécessaires
3. **HTTPS** : Utiliser un reverse proxy (nginx, Apache) pour HTTPS
4. **Authentification** : Ajouter Spring Security pour protéger l'API
5. **Logs** : Configurer la rotation des logs

### Exemple de configuration nginx (reverse proxy)

```nginx
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Monitoring et Logs

### Rotation des logs

Créer `/etc/logrotate.d/task-apps` :

```
/opt/task-api/task-api/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 taskapp taskapp
}

/opt/task-batch/task-batch/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 taskapp taskapp
}
```

### Surveillance

```bash
# Vérifier que les processus tournent
ps aux | grep task-api
ps aux | grep task-batch

# Vérifier les ports
netstat -tlnp | grep 8080
netstat -tlnp | grep 8081

# Tester l'API
curl http://localhost:8080/api/tasks/stats
```

## Mise à jour

### Procédure de mise à jour

```bash
# 1. Arrêter l'application
sudo systemctl stop task-api  # ou ./bin/stop.sh

# 2. Sauvegarder l'ancienne version
cd /opt/task-api
mv task-api task-api.backup

# 3. Déployer la nouvelle version
unzip task-api-1.1-SNAPSHOT.zip

# 4. Restaurer la configuration
cp task-api.backup/config/application.yml task-api/config/

# 5. Redémarrer
sudo systemctl start task-api  # ou ./bin/start.sh

# 6. Vérifier
tail -f task-api/logs/task-api.log
```

## Dépannage

### L'API ne démarre pas
```bash
# Vérifier les logs
tail -f /opt/task-api/task-api/logs/task-api.log

# Vérifier le port
netstat -tlnp | grep 8080

# Vérifier les permissions
ls -la /opt/task-api/task-api/bin/start.sh
```

### Le batch ne contacte pas l'API
```bash
# Tester la connectivité
curl http://api-server:8080/api/tasks/stats

# Vérifier la configuration
cat /opt/task-batch/task-batch/config/application.yml | grep base-url

# Vérifier les logs
tail -f /opt/task-batch/task-batch/logs/task-batch.log
```

## Checklist de Déploiement

- [ ] JDK 21 installé sur les serveurs
- [ ] Ports 8080 et 8081 disponibles (ou configurés)
- [ ] Utilisateur dédié créé
- [ ] Fichiers ZIP copiés sur les serveurs
- [ ] Configuration modifiée (URL API pour le batch)
- [ ] Scripts rendus exécutables
- [ ] Services systemd configurés (optionnel)
- [ ] Firewall configuré
- [ ] Rotation des logs configurée
- [ ] Tests de connectivité effectués
- [ ] Documentation mise à jour avec les URLs réelles

