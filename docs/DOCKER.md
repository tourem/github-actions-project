# 🐳 Guide Docker

Ce document explique l'utilisation de Docker et la conteneurisation des applications.

---

## 📋 Table des Matières

- [Architecture Docker](#architecture-docker)
- [Dockerfile Commun](#dockerfile-commun)
- [Images Docker](#images-docker)
- [Docker Compose](#docker-compose)
- [Build Local](#build-local)
- [Registry GitHub (GHCR)](#registry-github-ghcr)

---

## Architecture Docker

### Stratégie Multi-Stage Build

Le projet utilise un **Dockerfile commun** hébergé dans un repository séparé :

```
https://github.com/tourem/docker-file-common
```

**Avantages** :
- ✅ Un seul Dockerfile pour tous les modules
- ✅ Réutilisable entre projets
- ✅ Maintenance centralisée
- ✅ Build optimisé avec cache

### Structure des Images

```
Image finale
├── Base: eclipse-temurin:21-jre-alpine
├── Layer 1: Dépendances (rarement modifiées)
├── Layer 2: Application JAR
└── Layer 3: Configuration
```

---

## Dockerfile Commun

### Contenu du Dockerfile

```dockerfile
# Stage 1: Build
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /build

# Copier les fichiers Maven
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .

# Télécharger les dépendances (layer cachée)
RUN ./mvnw dependency:go-offline

# Copier le code source
COPY src src

# Build
RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Créer un utilisateur non-root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copier le JAR depuis le builder
ARG JAR_FILE=target/*.jar
COPY --from=builder /build/${JAR_FILE} app.jar

# Exposer le port
EXPOSE 8080

# Point d'entrée
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Utilisation dans le Workflow

Le workflow GitHub Actions clone le Dockerfile depuis le repository commun :

```yaml
- name: Checkout Dockerfile repository
  uses: actions/checkout@v4
  with:
    repository: tourem/docker-file-common
    path: .dockerfile-repo

- name: Build Docker image
  run: |
    docker build \
      -f .dockerfile-repo/Dockerfile \
      -t ghcr.io/${{ github.repository }}/${{ matrix.module.name }}:${{ needs.build.outputs.version }} \
      ${{ matrix.module.name }}
```

---

## Images Docker

### Nomenclature

Les images suivent cette convention :

```
ghcr.io/{owner}/{repository}/{module}:{tag}
```

**Exemples** :
- `ghcr.io/tourem/github-actions-project/task-api:latest`
- `ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT`
- `ghcr.io/tourem/github-actions-project/task-batch:latest`
- `ghcr.io/tourem/github-actions-project/task-batch:1.0-SNAPSHOT`

### Tags Disponibles

| Tag | Description | Mise à jour |
|-----|-------------|-------------|
| `latest` | Dernière version de la branche main | À chaque push sur main |
| `{version}` | Version spécifique (ex: 1.0-SNAPSHOT) | À chaque build |
| `{sha}` | Commit SHA spécifique | À chaque commit |

### Taille des Images

Les images sont optimisées pour être légères :

```bash
# Vérifier la taille
docker images | grep task-api

# Exemple de sortie
task-api    latest    abc123    2 minutes ago    250MB
```

**Optimisations** :
- ✅ Base Alpine Linux (petite taille)
- ✅ JRE uniquement (pas de JDK)
- ✅ Multi-stage build (pas de dépendances de build)
- ✅ Layers cachées pour les dépendances

---

## Docker Compose

### Fichier docker-compose.yml

```yaml
version: '3.8'

services:
  task-api:
    image: ghcr.io/tourem/github-actions-project/task-api:latest
    container_name: task-api
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=dev
    networks:
      - task-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/api/tasks"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  task-batch:
    image: ghcr.io/tourem/github-actions-project/task-batch:latest
    container_name: task-batch
    ports:
      - "8081:8081"
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - TASK_API_BASE_URL=http://task-api:8080
    networks:
      - task-network
    depends_on:
      task-api:
        condition: service_healthy

networks:
  task-network:
    driver: bridge
```

### Commandes Docker Compose

```bash
# Démarrer tous les services
docker-compose up -d

# Démarrer un service spécifique
docker-compose up -d task-api

# Voir les logs
docker-compose logs -f

# Voir les logs d'un service
docker-compose logs -f task-api

# Arrêter les services
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v

# Reconstruire les images
docker-compose build --no-cache

# Redémarrer un service
docker-compose restart task-api

# Voir l'état des services
docker-compose ps
```

---

## Build Local

### Build Manuel

```bash
# 1. Cloner le Dockerfile
git clone https://github.com/tourem/docker-file-common.git

# 2. Build de l'image task-api
docker build \
  -f docker-file-common/Dockerfile \
  -t task-api:local \
  task-api

# 3. Build de l'image task-batch
docker build \
  -f docker-file-common/Dockerfile \
  -t task-batch:local \
  task-batch

# 4. Lister les images
docker images | grep task
```

### Build avec Arguments

```bash
# Spécifier la version Java
docker build \
  --build-arg JAVA_VERSION=21 \
  -f docker-file-common/Dockerfile \
  -t task-api:local \
  task-api

# Spécifier le profil Spring
docker build \
  --build-arg SPRING_PROFILES_ACTIVE=prd \
  -f docker-file-common/Dockerfile \
  -t task-api:prd \
  task-api
```

### Tester l'Image Localement

```bash
# Démarrer le conteneur
docker run -d \
  --name task-api-test \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=dev \
  task-api:local

# Vérifier les logs
docker logs -f task-api-test

# Tester l'API
curl http://localhost:8080/api/tasks

# Arrêter et supprimer
docker stop task-api-test
docker rm task-api-test
```

---

## Registry GitHub (GHCR)

### Authentification

```bash
# Créer un Personal Access Token (PAT) sur GitHub
# Permissions requises: read:packages, write:packages

# Se connecter à GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Pull des Images

```bash
# Pull de l'image latest
docker pull ghcr.io/tourem/github-actions-project/task-api:latest

# Pull d'une version spécifique
docker pull ghcr.io/tourem/github-actions-project/task-api:1.0-SNAPSHOT

# Lister les images
docker images | grep ghcr.io
```

### Push des Images (Manuel)

```bash
# Tag de l'image
docker tag task-api:local ghcr.io/tourem/github-actions-project/task-api:custom

# Push vers GHCR
docker push ghcr.io/tourem/github-actions-project/task-api:custom
```

### Visibilité des Images

Les images sont **publiques** par défaut. Pour les rendre privées :

1. Aller sur https://github.com/tourem/github-actions-project/packages
2. Sélectionner l'image
3. Package settings → Change visibility → Private

---

## Optimisations

### Cache des Layers

Le Dockerfile utilise le cache Docker pour accélérer les builds :

```dockerfile
# Layer 1: Dépendances (rarement modifiées)
COPY pom.xml .
RUN ./mvnw dependency:go-offline

# Layer 2: Code source (souvent modifié)
COPY src src
RUN ./mvnw clean package
```

**Résultat** :
- Premier build : ~5 minutes
- Builds suivants : ~30 secondes (si seul le code change)

### Multi-Platform Build

Pour supporter plusieurs architectures :

```bash
# Créer un builder multi-platform
docker buildx create --name multiplatform --use

# Build pour AMD64 et ARM64
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -f docker-file-common/Dockerfile \
  -t ghcr.io/tourem/github-actions-project/task-api:latest \
  --push \
  task-api
```

### Réduction de la Taille

**Techniques utilisées** :

1. **Base Alpine** : Image de base légère (~5MB)
2. **JRE uniquement** : Pas de JDK en production
3. **Multi-stage build** : Pas de dépendances de build dans l'image finale
4. **Nettoyage** : Suppression des fichiers temporaires

```dockerfile
# Exemple de nettoyage
RUN apk add --no-cache wget && \
    rm -rf /var/cache/apk/*
```

---

## Troubleshooting

### L'image ne se build pas

```bash
# Vérifier que Docker est démarré
docker ps

# Nettoyer le cache Docker
docker builder prune -a

# Rebuild sans cache
docker build --no-cache -f Dockerfile -t task-api:local task-api
```

### Le conteneur ne démarre pas

```bash
# Voir les logs
docker logs task-api

# Inspecter le conteneur
docker inspect task-api

# Vérifier les variables d'environnement
docker exec task-api env
```

### Problèmes de réseau

```bash
# Lister les réseaux
docker network ls

# Inspecter un réseau
docker network inspect task-network

# Recréer le réseau
docker network rm task-network
docker network create task-network
```

### Problèmes de permissions

```bash
# Vérifier l'utilisateur dans le conteneur
docker exec task-api whoami

# Exécuter en tant que root (debug uniquement)
docker run --user root -it task-api:local sh
```

---

## Bonnes Pratiques

### Sécurité

- ✅ Utiliser un utilisateur non-root
- ✅ Scanner les images pour les vulnérabilités
- ✅ Utiliser des images de base officielles
- ✅ Ne pas inclure de secrets dans l'image

### Performance

- ✅ Utiliser le cache des layers
- ✅ Minimiser le nombre de layers
- ✅ Copier uniquement les fichiers nécessaires
- ✅ Utiliser .dockerignore

### Maintenance

- ✅ Versionner les images
- ✅ Nettoyer les images inutilisées
- ✅ Documenter les Dockerfiles
- ✅ Tester les images avant le push

---

## Liens Utiles

- **Dockerfile Commun** : https://github.com/tourem/docker-file-common
- **Images GHCR** : https://github.com/tourem/github-actions-project/pkgs/container/github-actions-project
- **Docker Hub** : https://hub.docker.com/
- **Documentation Docker** : https://docs.docker.com/

