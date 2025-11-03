#!/bin/bash

# Script de démarrage du Batch Task

APP_HOME="$(cd "$(dirname "$0")/.." && pwd)"
LIB_DIR="$APP_HOME/lib"
CONFIG_DIR="$APP_HOME/config"
LOG_DIR="$APP_HOME/logs"

# Créer le répertoire de logs s'il n'existe pas
mkdir -p "$LOG_DIR"

# Trouver le JAR
JAR_FILE=$(find "$LIB_DIR" -name "task-batch*.jar" | head -n 1)

if [ -z "$JAR_FILE" ]; then
    echo "Erreur: JAR non trouvé dans $LIB_DIR"
    exit 1
fi

echo "Démarrage de Task Batch..."
echo "JAR: $JAR_FILE"
echo "Config: $CONFIG_DIR"

# Démarrer l'application
java -jar "$JAR_FILE" \
    --spring.config.location="file:$CONFIG_DIR/application.yml" \
    >> "$LOG_DIR/task-batch.log" 2>&1 &

PID=$!
echo $PID > "$APP_HOME/task-batch.pid"

echo "Task Batch démarré avec le PID: $PID"
echo "Logs disponibles dans: $LOG_DIR/task-batch.log"
echo ""
echo "Le batch s'exécutera automatiquement toutes les 30 minutes."
echo "Vous pouvez suivre les logs avec: tail -f $LOG_DIR/task-batch.log"

