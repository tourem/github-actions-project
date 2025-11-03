#!/bin/bash

# Script d'arrêt du Batch Task

APP_HOME="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="$APP_HOME/task-batch.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "Fichier PID non trouvé. L'application n'est peut-être pas démarrée."
    exit 1
fi

PID=$(cat "$PID_FILE")

if ps -p $PID > /dev/null 2>&1; then
    echo "Arrêt de Task Batch (PID: $PID)..."
    kill $PID
    
    # Attendre que le processus se termine
    for i in {1..30}; do
        if ! ps -p $PID > /dev/null 2>&1; then
            echo "Task Batch arrêté avec succès."
            rm "$PID_FILE"
            exit 0
        fi
        sleep 1
    done
    
    # Si le processus ne s'est pas arrêté, forcer l'arrêt
    echo "Forçage de l'arrêt..."
    kill -9 $PID
    rm "$PID_FILE"
    echo "Task Batch arrêté (forcé)."
else
    echo "Le processus avec PID $PID n'est pas en cours d'exécution."
    rm "$PID_FILE"
fi

