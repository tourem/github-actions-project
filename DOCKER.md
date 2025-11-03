# 🐳 Docker Guide

Ce guide explique comment utiliser les images Docker pour les modules `task-api` et `task-batch`.

## 📦 Images Disponibles

Les images Docker sont automatiquement construites et publiées sur GitHub Container Registry (GHCR) lors de chaque push sur `main` ou `develop`.

### task-api
```
ghcr.io/tourem/github-actions-project/task-api:latest
ghcr.io/tourem/github-actions-project/task-api:main
ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT
```

### task-batch
```
ghcr.io/tourem/github-actions-project/task-batch:latest
ghcr.io/tourem/github-actions-project/task-batch:main
ghcr.io/tourem/github-actions-project/task-batch:1.0-SNAPSHOT
```

## 🚀 Utilisation

### 1. Authentification

Pour télécharger les images depuis GHCR, vous devez vous authentifier :

```bash
# Créer un Personal Access Token avec le scope 'read:packages'
# https://github.com/settings/tokens

# Se connecter à GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### 2. Télécharger une image

```bash
# task-api
docker pull ghcr.io/tourem/github-actions-project/task-api:latest

# task-batch
docker pull ghcr.io/tourem/github-actions-project/task-batch:latest
```

### 3. Lancer un conteneur

#### task-api (Port 8080)

```bash
docker run -d \
  --name task-api \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e JAVA_OPTS="-Xmx512m -Xms256m" \
  ghcr.io/tourem/github-actions-project/task-api:latest
```

#### task-batch (Port 8081)

```bash
docker run -d \
  --name task-batch \
  -p 8081:8081 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e JAVA_OPTS="-Xmx512m -Xms256m" \
  -e TASK_API_URL=http://task-api:8080 \
  ghcr.io/tourem/github-actions-project/task-batch:latest
```

### 4. Vérifier les logs

```bash
# task-api
docker logs -f task-api

# task-batch
docker logs -f task-batch
```

### 5. Arrêter et supprimer

```bash
# Arrêter
docker stop task-api task-batch

# Supprimer
docker rm task-api task-batch
```

## 🐳 Docker Compose

Créez un fichier `docker-compose.yml` pour lancer les deux modules ensemble :

```yaml
version: '3.8'

services:
  task-api:
    image: ghcr.io/tourem/github-actions-project/task-api:latest
    container_name: task-api
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - JAVA_OPTS=-Xmx512m -Xms256m
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
    restart: unless-stopped
    networks:
      - app-network

  task-batch:
    image: ghcr.io/tourem/github-actions-project/task-batch:latest
    container_name: task-batch
    ports:
      - "8081:8081"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - JAVA_OPTS=-Xmx512m -Xms256m
      - TASK_API_URL=http://task-api:8080
    depends_on:
      task-api:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

Lancer avec Docker Compose :

```bash
# Démarrer
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter
docker-compose down
```

## 🔧 Build Local

Si vous voulez construire les images localement :

### Prérequis

Vous devez avoir :
- Un Personal Access Token GitHub avec `read:packages`
- Les artifacts publiés sur GitHub Packages

### Build task-api

```bash
docker build \
  --build-arg GITHUB_USER=tourem \
  --build-arg GITHUB_TOKEN=$GITHUB_TOKEN \
  --build-arg APP_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT \
  --build-arg CONF_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT \
  -t task-api:local \
  -f Dockerfile .
```

### Build task-batch

```bash
docker build \
  --build-arg GITHUB_USER=tourem \
  --build-arg GITHUB_TOKEN=$GITHUB_TOKEN \
  --build-arg APP_LOCATION=com.larbotech:task-batch:1.0-SNAPSHOT \
  --build-arg CONF_LOCATION=com.larbotech:task-batch:1.0-SNAPSHOT \
  -t task-batch:local \
  -f Dockerfile .
```

## 📊 Caractéristiques des Images

### Optimisations

- ✅ **Multi-stage build** : Réduction de la taille finale
- ✅ **Alpine Linux** : Image de base minimale (~150 MB par image)
- ✅ **JRE 21** : Pas de JDK dans l'image finale
- ✅ **Non-root user** : Sécurité renforcée
- ✅ **Healthcheck** : Monitoring intégré
- ✅ **Layer caching** : Build plus rapide avec GitHub Actions cache

### Taille des images

- **task-api** : ~200 MB
- **task-batch** : ~200 MB

### Arguments de build

| Argument | Description | Format | Exemple |
|----------|-------------|--------|---------|
| `GITHUB_USER` | Nom d'utilisateur GitHub | string | `tourem` |
| `GITHUB_TOKEN` | Token d'authentification | string | `ghp_xxxxx` |
| `APP_LOCATION` | Localisation du JAR | `groupId:artifactId:version` | `com.larbotech:task-api:1.0-SNAPSHOT` |
| `CONF_LOCATION` | Localisation du ZIP | `groupId:artifactId:version` | `com.larbotech:task-api:1.0-SNAPSHOT` |

### Variables d'environnement

| Variable | Description | Défaut |
|----------|-------------|--------|
| `SPRING_PROFILES_ACTIVE` | Profil Spring Boot | `prod` |
| `JAVA_OPTS` | Options JVM | `-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0` |
| `TASK_API_URL` | URL de l'API (batch uniquement) | - |

## 🔍 Inspection

### Voir les layers

```bash
docker history ghcr.io/tourem/github-actions-project/task-api:latest
```

### Inspecter l'image

```bash
docker inspect ghcr.io/tourem/github-actions-project/task-api:latest
```

### Entrer dans le conteneur

```bash
docker exec -it task-api sh
```

## 🐛 Dépannage

### L'image ne se télécharge pas

```bash
# Vérifier l'authentification
docker login ghcr.io

# Vérifier que l'image existe
docker pull ghcr.io/tourem/github-actions-project/task-api:latest
```

### Le conteneur ne démarre pas

```bash
# Voir les logs
docker logs task-api

# Vérifier les variables d'environnement
docker inspect task-api | grep -A 10 Env
```

### Problème de mémoire

```bash
# Augmenter la mémoire allouée
docker run -d \
  --name task-api \
  -p 8080:8080 \
  -e JAVA_OPTS="-Xmx1g -Xms512m" \
  ghcr.io/tourem/github-actions-project/task-api:latest
```

## 📚 Ressources

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Compose](https://docs.docker.com/compose/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)

## 🔐 Sécurité

### Bonnes pratiques appliquées

- ✅ Utilisateur non-root (`java:java`)
- ✅ Image de base officielle (Eclipse Temurin)
- ✅ Pas de secrets dans l'image
- ✅ Healthcheck configuré
- ✅ Minimal attack surface (Alpine)

### Scanner les vulnérabilités

```bash
# Avec Docker Scout
docker scout cves ghcr.io/tourem/github-actions-project/task-api:latest

# Avec Trivy
trivy image ghcr.io/tourem/github-actions-project/task-api:latest
```

## 🚀 Production

### Recommandations

1. **Utilisez des tags spécifiques** au lieu de `latest`
2. **Configurez les ressources** (CPU, mémoire)
3. **Activez les healthchecks**
4. **Utilisez des secrets** pour les configurations sensibles
5. **Monitorer les logs** avec un système centralisé

### Exemple Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: task-api
  template:
    metadata:
      labels:
        app: task-api
    spec:
      containers:
      - name: task-api
        image: ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 40
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 10
```

---

**Date** : 2025-11-03  
**Version** : 1.0  
**Status** : ✅ Prêt pour la production

