# 📦 Guide de Déploiement

Ce document explique comment déployer les applications task-api et task-batch dans différents environnements.

---

## 📋 Table des Matières

- [Prérequis](#prérequis)
- [Déploiement Local](#déploiement-local)
- [Déploiement Docker](#déploiement-docker)
- [Déploiement avec Descripteurs](#déploiement-avec-descripteurs)
- [Configuration par Environnement](#configuration-par-environnement)
- [Monitoring et Logs](#monitoring-et-logs)

---

## Prérequis

### Pour Déploiement Local

- **JDK 21** installé
- **Maven 3.x** installé (pour le build)
- Ports **8080** (API) et **8081** (Batch) disponibles

### Pour Déploiement Docker

- **Docker** installé et démarré
- **Docker Compose** (optionnel, pour orchestration)
- Accès à **GitHub Container Registry** (GHCR)

---

## Déploiement Local

### Option 1 : Depuis les Sources

#### 1. Compiler le Projet

```bash
# Cloner le repository
git clone https://github.com/tourem/github-actions-project.git
cd github-actions-project

# Compiler tous les modules
mvn clean package

# Ou compiler un module spécifique
mvn clean package -pl task-api
mvn clean package -pl task-batch
```

#### 2. Déployer l'API

```bash
# Extraire le ZIP
cd task-api/target
unzip task-api-1.0-SNAPSHOT.zip
cd task-api

# Démarrer (Linux/Mac)
./bin/start.sh

# Démarrer (Windows)
bin\start.bat

# Vérifier que l'API fonctionne
curl http://localhost:8080/api/tasks
```

#### 3. Déployer le Batch

**Important** : L'API doit être démarrée avant le batch !

```bash
# Extraire le ZIP
cd task-batch/target
unzip task-batch-1.0-SNAPSHOT.zip
cd task-batch

# Démarrer (Linux/Mac)
./bin/start.sh

# Démarrer (Windows)
bin\start.bat

# Vérifier les logs
tail -f logs/task-batch.log
```

#### 4. Arrêter les Services

```bash
# Arrêter l'API
cd task-api
./bin/stop.sh

# Arrêter le Batch
cd task-batch
./bin/stop.sh
```

### Option 2 : Depuis GitHub Packages

#### 1. Configurer Maven

Créer/éditer `~/.m2/settings.xml` :

```xml
<settings>
  <servers>
    <server>
      <id>github</id>
      <username>VOTRE_USERNAME</username>
      <password>VOTRE_GITHUB_TOKEN</password>
    </server>
  </servers>
</settings>
```

#### 2. Télécharger les Packages

```bash
# Créer un projet Maven temporaire
mkdir deploy-temp && cd deploy-temp

# Créer un pom.xml minimal
cat > pom.xml << 'EOF'
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>temp</groupId>
  <artifactId>deploy</artifactId>
  <version>1.0</version>
  
  <repositories>
    <repository>
      <id>github</id>
      <url>https://maven.pkg.github.com/tourem/github-actions-project</url>
    </repository>
  </repositories>
  
  <dependencies>
    <dependency>
      <groupId>com.larbotech</groupId>
      <artifactId>task-api</artifactId>
      <version>1.0-SNAPSHOT</version>
      <type>zip</type>
      <classifier>distribution</classifier>
    </dependency>
  </dependencies>
</project>
EOF

# Télécharger
mvn dependency:copy-dependencies
```

---

## Déploiement Docker

### Option 1 : Docker Compose (Recommandé)

#### 1. Utiliser le docker-compose.yml

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Voir les logs d'un service spécifique
docker-compose logs -f task-api
docker-compose logs -f task-batch

# Arrêter les services
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v
```

#### 2. Vérifier le Déploiement

```bash
# Vérifier que les conteneurs sont démarrés
docker-compose ps

# Tester l'API
curl http://localhost:8080/api/tasks

# Voir les statistiques
curl http://localhost:8080/api/tasks/stats
```

### Option 2 : Docker Run Manuel

#### 1. Créer un Réseau Docker

```bash
docker network create task-network
```

#### 2. Démarrer l'API

```bash
docker run -d \
  --name task-api \
  --network task-network \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=dev \
  ghcr.io/tourem/github-actions-project/task-api:latest
```

#### 3. Démarrer le Batch

```bash
docker run -d \
  --name task-batch \
  --network task-network \
  -p 8081:8081 \
  -e SPRING_PROFILES_ACTIVE=dev \
  -e TASK_API_BASE_URL=http://task-api:8080 \
  ghcr.io/tourem/github-actions-project/task-batch:latest
```

#### 4. Gérer les Conteneurs

```bash
# Voir les logs
docker logs -f task-api
docker logs -f task-batch

# Arrêter
docker stop task-api task-batch

# Supprimer
docker rm task-api task-batch

# Nettoyer le réseau
docker network rm task-network
```

---

## Déploiement avec Descripteurs

Les descripteurs de déploiement contiennent toutes les métadonnées nécessaires.

### 1. Récupérer le Descripteur

```bash
# Depuis le repository
curl -o descriptor.json \
  https://raw.githubusercontent.com/tourem/github-actions-project/main/task-api/deploy/deployment-descriptor-task-api-latest.json
```

### 2. Lire les Informations

```bash
# Extraire l'image Docker
IMAGE=$(jq -r '.docker.image' descriptor.json)
TAG=$(jq -r '.docker.tag' descriptor.json)

# Extraire la version Maven
VERSION=$(jq -r '.version' descriptor.json)

# Extraire l'environnement
ENVIRONMENT=$(jq -r '.environment' descriptor.json)

echo "Déploiement de ${IMAGE}:${TAG} pour l'environnement ${ENVIRONMENT}"
```

### 3. Déployer Automatiquement

```bash
#!/bin/bash
# Script de déploiement automatique

DESCRIPTOR="deployment-descriptor-task-api-latest.json"

# Lire le descripteur
IMAGE=$(jq -r '.docker.image' $DESCRIPTOR)
TAG=$(jq -r '.docker.tag' $DESCRIPTOR)
PORT=$(jq -r '.deployment.port' $DESCRIPTOR)
PROFILES=$(jq -r '.deployment.profiles[]' $DESCRIPTOR)

# Déployer
docker run -d \
  --name task-api \
  -p ${PORT}:${PORT} \
  -e SPRING_PROFILES_ACTIVE=${PROFILES} \
  ${IMAGE}:${TAG}
```

---

## Configuration par Environnement

### Structure des Configurations

Chaque module a des configurations spécifiques par environnement :

```
task-api/src/main/
├── resources/
│   ├── application.yml           # Configuration par défaut
│   ├── application-dev.yml       # Configuration dev
│   ├── application-hml.yml       # Configuration homologation
│   └── application-prd.yml       # Configuration production
└── vault/
    ├── vault-dev.yml             # Secrets dev
    ├── vault-hml.yml             # Secrets homologation
    └── vault-prd.yml             # Secrets production
```

### Environnement DEV

```yaml
# application-dev.yml
spring:
  profiles:
    active: dev
  h2:
    console:
      enabled: true

server:
  port: 8080

logging:
  level:
    root: INFO
    com.larbotech: DEBUG
```

### Environnement HML

```yaml
# application-hml.yml
spring:
  profiles:
    active: hml
  h2:
    console:
      enabled: false

server:
  port: 8080

logging:
  level:
    root: INFO
    com.larbotech: INFO
```

### Environnement PRD

```yaml
# application-prd.yml
spring:
  profiles:
    active: prd
  h2:
    console:
      enabled: false

server:
  port: 8080

logging:
  level:
    root: WARN
    com.larbotech: INFO
```

### Activer un Profil

```bash
# Ligne de commande
java -jar task-api.jar --spring.profiles.active=prd

# Variable d'environnement
export SPRING_PROFILES_ACTIVE=prd
java -jar task-api.jar

# Docker
docker run -e SPRING_PROFILES_ACTIVE=prd task-api:latest
```

---

## Monitoring et Logs

### Logs Locaux

```bash
# Suivre les logs en temps réel
tail -f task-api/logs/task-api.log
tail -f task-batch/logs/task-batch.log

# Rechercher des erreurs
grep ERROR task-api/logs/task-api.log

# Voir les dernières lignes
tail -n 100 task-api/logs/task-api.log
```

### Logs Docker

```bash
# Suivre les logs
docker logs -f task-api
docker logs -f task-batch

# Voir les dernières lignes
docker logs --tail 100 task-api

# Logs avec timestamps
docker logs -t task-api
```

### Health Checks

```bash
# Vérifier que l'API répond
curl http://localhost:8080/api/tasks

# Vérifier les statistiques
curl http://localhost:8080/api/tasks/stats

# Vérifier la console H2 (dev uniquement)
open http://localhost:8080/h2-console
```

### Métriques

Les applications exposent des métriques Spring Boot Actuator (si activé) :

```bash
# Health endpoint
curl http://localhost:8080/actuator/health

# Metrics
curl http://localhost:8080/actuator/metrics

# Info
curl http://localhost:8080/actuator/info
```

---

## Troubleshooting

### L'API ne démarre pas

```bash
# Vérifier que le port 8080 est libre
lsof -i :8080

# Vérifier les logs
tail -f task-api/logs/task-api.log

# Vérifier la version Java
java -version  # Doit être JDK 21
```

### Le Batch ne peut pas contacter l'API

```bash
# Vérifier que l'API est démarrée
curl http://localhost:8080/api/tasks

# Vérifier la configuration du batch
cat task-batch/config/application.yml | grep base-url

# Modifier l'URL si nécessaire
# task.api.base-url: http://localhost:8080
```

### Problèmes Docker

```bash
# Vérifier que Docker est démarré
docker ps

# Vérifier les logs du conteneur
docker logs task-api

# Redémarrer le conteneur
docker restart task-api

# Reconstruire l'image
docker-compose build --no-cache
docker-compose up -d
```

---

## Liens Utiles

- **Repository** : https://github.com/tourem/github-actions-project
- **Packages** : https://github.com/tourem/github-actions-project/packages
- **Docker Images** : https://github.com/tourem/github-actions-project/pkgs/container/github-actions-project

