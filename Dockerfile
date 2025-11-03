# ============================================
# STAGE 1: Build stage (Alpine pour réduction maximale)
# ============================================
FROM eclipse-temurin:21-jdk-alpine AS builder

# Variables d'environnement pour l'authentification GitHub
ARG GITHUB_USER
ARG GITHUB_TOKEN

# Variables pour les artefacts Maven (format: groupId:artifactId:version)
ARG APP_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT
ARG CONF_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT

WORKDIR /build

# Installation des outils nécessaires (curl, unzip, bash pour le parsing)
RUN apk add --no-cache curl unzip bash

# Téléchargement de l'application JAR depuis GitHub Packages Maven
RUN set -e && \
    echo "📦 Parsing APP_LOCATION: ${APP_LOCATION}" && \
    GROUP_ID=$(echo "${APP_LOCATION}" | cut -d':' -f1) && \
    ARTIFACT_ID=$(echo "${APP_LOCATION}" | cut -d':' -f2) && \
    VERSION=$(echo "${APP_LOCATION}" | cut -d':' -f3) && \
    GROUP_PATH=$(echo "${GROUP_ID}" | tr '.' '/') && \
    FILENAME="${ARTIFACT_ID}-${VERSION}.jar" && \
    BASE_URL="https://maven.pkg.github.com/${GITHUB_USER}/github-actions-project" && \
    FULL_URL="${BASE_URL}/${GROUP_PATH}/${ARTIFACT_ID}/${VERSION}/${FILENAME}" && \
    echo "📦 Téléchargement de ${FULL_URL}" && \
    mkdir -p /build/app && \
    curl -L -u "${GITHUB_USER}:${GITHUB_TOKEN}" -o "/build/app/app.jar" "${FULL_URL}" && \
    chmod +x /build/app/app.jar && \
    echo "✅ Application téléchargée : ${FILENAME}"

# Téléchargement et extraction de la configuration ZIP depuis GitHub Packages Maven (optionnel)
RUN set -e && \
    echo "📦 Parsing CONF_LOCATION: ${CONF_LOCATION}" && \
    GROUP_ID=$(echo "${CONF_LOCATION}" | cut -d':' -f1) && \
    ARTIFACT_ID=$(echo "${CONF_LOCATION}" | cut -d':' -f2) && \
    VERSION=$(echo "${CONF_LOCATION}" | cut -d':' -f3) && \
    GROUP_PATH=$(echo "${GROUP_ID}" | tr '.' '/') && \
    FILENAME="${ARTIFACT_ID}-${VERSION}-distribution.zip" && \
    BASE_URL="https://maven.pkg.github.com/${GITHUB_USER}/github-actions-project" && \
    FULL_URL="${BASE_URL}/${GROUP_PATH}/${ARTIFACT_ID}/${VERSION}/${FILENAME}" && \
    echo "📦 Téléchargement de ${FULL_URL}" && \
    mkdir -p /build/config && \
    if curl -f -L -u "${GITHUB_USER}:${GITHUB_TOKEN}" -o "/tmp/config.zip" "${FULL_URL}"; then \
        unzip -q "/tmp/config.zip" -d /build/config && \
        rm -f "/tmp/config.zip" && \
        echo "✅ Configuration téléchargée et extraite : ${FILENAME}"; \
    else \
        echo "⚠️  Configuration ZIP non trouvée, création d'un répertoire vide"; \
    fi

# Nettoyage final du builder
RUN rm -rf /var/cache/apk/* /tmp/* /root/.cache

# ============================================
# STAGE 2: Runtime stage - Alpine JRE (Image la plus légère)
# ============================================
FROM eclipse-temurin:21-jre-alpine

ARG APP_LOCATION=com.larbotech:task-api:1.0-SNAPSHOT

LABEL maintainer="devops@larbotech.com" \
      version="optimized-alpine" \
      description="Optimized Java application with minimal footprint" \
      company="Larbotech"

# Création de l'utilisateur java et installation des dépendances runtime minimales
RUN addgroup -g 1000 java && \
    adduser -u 1000 -G java -D -h /home/java java && \
    apk add --no-cache \
        bash \
        curl \
        ca-certificates \
        tzdata && \
    rm -rf /var/cache/apk/* /tmp/*

WORKDIR /app

# Copie depuis le builder
COPY --from=builder --chown=java:java /build/app/app.jar /app/app.jar
COPY --from=builder --chown=java:java /build/config /app/config

# Variables d'environnement optimisées
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError" \
    SPRING_PROFILES_ACTIVE="prod"

# Passage à l'utilisateur non-root
USER java

# Healthcheck (adapté selon le module)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Exposition du port (8080 pour task-api, 8081 pour task-batch)
EXPOSE 8080

# Point d'entrée
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]

