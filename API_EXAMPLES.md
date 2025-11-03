# Exemples d'Utilisation de l'API Task

Ce document contient des exemples pratiques d'utilisation de l'API Task avec curl et d'autres outils.

## Prérequis

L'API doit être démarrée et accessible sur http://localhost:8080

## Exemples avec curl

### 1. Récupérer toutes les tâches (GET)

```bash
curl -X GET http://localhost:8080/api/tasks
```

**Réponse attendue :**
```json
[
  {
    "id": 1,
    "title": "Vérifier les logs système",
    "description": "Tâche générée automatiquement par le batch le 2024-01-01 10:00:00",
    "status": "PENDING",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-01T10:00:00"
  }
]
```

### 2. Récupérer les statistiques (GET)

```bash
curl -X GET http://localhost:8080/api/tasks/stats
```

**Réponse attendue :**
```json
{
  "total": 10,
  "pending": 5,
  "completed": 3,
  "in_progress": 2
}
```

### 3. Créer une nouvelle tâche (POST)

```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Implémenter nouvelle fonctionnalité",
    "description": "Ajouter la gestion des priorités",
    "status": "PENDING"
  }'
```

**Réponse attendue :**
```json
{
  "id": 11,
  "title": "Implémenter nouvelle fonctionnalité",
  "description": "Ajouter la gestion des priorités",
  "status": "PENDING",
  "createdAt": "2024-01-01T14:30:00",
  "updatedAt": "2024-01-01T14:30:00"
}
```

### 4. Récupérer une tâche par ID

```bash
curl -X GET http://localhost:8080/api/tasks/1
```

**Réponse attendue :**
```json
{
  "id": 1,
  "title": "Vérifier les logs système",
  "description": "Tâche générée automatiquement",
  "status": "PENDING",
  "createdAt": "2024-01-01T10:00:00",
  "updatedAt": "2024-01-01T10:00:00"
}
```

### 5. Mettre à jour une tâche

```bash
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Vérifier les logs système",
    "description": "Tâche mise à jour",
    "status": "COMPLETED"
  }'
```

**Réponse attendue :**
```json
{
  "id": 1,
  "title": "Vérifier les logs système",
  "description": "Tâche mise à jour",
  "status": "COMPLETED",
  "createdAt": "2024-01-01T10:00:00",
  "updatedAt": "2024-01-01T14:35:00"
}
```

### 6. Supprimer une tâche

```bash
curl -X DELETE http://localhost:8080/api/tasks/1
```

**Réponse attendue :** HTTP 204 No Content

## Exemples avec HTTPie

[HTTPie](https://httpie.io/) est un client HTTP plus convivial que curl.

### Installation

```bash
# Mac
brew install httpie

# Linux
apt-get install httpie

# Python
pip install httpie
```

### Exemples

```bash
# GET toutes les tâches
http GET localhost:8080/api/tasks

# GET statistiques
http GET localhost:8080/api/tasks/stats

# POST créer une tâche
http POST localhost:8080/api/tasks \
  title="Nouvelle tâche" \
  description="Description" \
  status="PENDING"

# PUT mettre à jour
http PUT localhost:8080/api/tasks/1 \
  title="Tâche modifiée" \
  description="Nouvelle description" \
  status="IN_PROGRESS"

# DELETE supprimer
http DELETE localhost:8080/api/tasks/1
```

## Exemples avec JavaScript (fetch)

```javascript
// GET toutes les tâches
fetch('http://localhost:8080/api/tasks')
  .then(response => response.json())
  .then(data => console.log(data));

// POST créer une tâche
fetch('http://localhost:8080/api/tasks', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    title: 'Nouvelle tâche',
    description: 'Description de la tâche',
    status: 'PENDING'
  })
})
  .then(response => response.json())
  .then(data => console.log(data));

// PUT mettre à jour une tâche
fetch('http://localhost:8080/api/tasks/1', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    title: 'Tâche modifiée',
    description: 'Description mise à jour',
    status: 'COMPLETED'
  })
})
  .then(response => response.json())
  .then(data => console.log(data));
```

## Exemples avec Python (requests)

```python
import requests
import json

BASE_URL = 'http://localhost:8080/api/tasks'

# GET toutes les tâches
response = requests.get(BASE_URL)
print(response.json())

# GET statistiques
response = requests.get(f'{BASE_URL}/stats')
print(response.json())

# POST créer une tâche
task_data = {
    'title': 'Nouvelle tâche Python',
    'description': 'Créée depuis Python',
    'status': 'PENDING'
}
response = requests.post(BASE_URL, json=task_data)
print(response.json())

# PUT mettre à jour une tâche
task_id = 1
update_data = {
    'title': 'Tâche mise à jour',
    'description': 'Modifiée depuis Python',
    'status': 'IN_PROGRESS'
}
response = requests.put(f'{BASE_URL}/{task_id}', json=update_data)
print(response.json())

# DELETE supprimer une tâche
response = requests.delete(f'{BASE_URL}/{task_id}')
print(f'Status code: {response.status_code}')
```

## Script de Test Complet

Créez un fichier `test_api.sh` :

```bash
#!/bin/bash

API_URL="http://localhost:8080/api/tasks"

echo "=== Test de l'API Task ==="
echo ""

# 1. Vérifier les statistiques initiales
echo "1. Statistiques initiales:"
curl -s "${API_URL}/stats" | jq .
echo ""

# 2. Créer plusieurs tâches
echo "2. Création de 3 tâches:"
for i in {1..3}; do
  curl -s -X POST "${API_URL}" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"Tâche de test $i\",\"description\":\"Description $i\",\"status\":\"PENDING\"}" \
    | jq .
done
echo ""

# 3. Récupérer toutes les tâches
echo "3. Liste de toutes les tâches:"
curl -s "${API_URL}" | jq .
echo ""

# 4. Mettre à jour une tâche
echo "4. Mise à jour de la tâche 1:"
curl -s -X PUT "${API_URL}/1" \
  -H "Content-Type: application/json" \
  -d '{"title":"Tâche modifiée","description":"Mise à jour","status":"COMPLETED"}' \
  | jq .
echo ""

# 5. Statistiques finales
echo "5. Statistiques finales:"
curl -s "${API_URL}/stats" | jq .
echo ""

echo "=== Tests terminés ==="
```

Rendre le script exécutable et l'exécuter :

```bash
chmod +x test_api.sh
./test_api.sh
```

## Scénarios de Test

### Scénario 1 : Workflow complet d'une tâche

```bash
# 1. Créer une tâche
TASK_ID=$(curl -s -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Développer feature X","description":"Nouvelle fonctionnalité","status":"PENDING"}' \
  | jq -r '.id')

echo "Tâche créée avec l'ID: $TASK_ID"

# 2. Passer en IN_PROGRESS
curl -s -X PUT http://localhost:8080/api/tasks/$TASK_ID \
  -H "Content-Type: application/json" \
  -d '{"title":"Développer feature X","description":"En cours de développement","status":"IN_PROGRESS"}' \
  | jq .

# 3. Marquer comme COMPLETED
curl -s -X PUT http://localhost:8080/api/tasks/$TASK_ID \
  -H "Content-Type: application/json" \
  -d '{"title":"Développer feature X","description":"Terminé","status":"COMPLETED"}' \
  | jq .

# 4. Vérifier les stats
curl -s http://localhost:8080/api/tasks/stats | jq .
```

### Scénario 2 : Créer des tâches en masse

```bash
# Créer 10 tâches avec différents statuts
for i in {1..10}; do
  STATUS=$([ $((i % 3)) -eq 0 ] && echo "COMPLETED" || echo "PENDING")
  curl -s -X POST http://localhost:8080/api/tasks \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"Tâche batch $i\",\"description\":\"Tâche numéro $i\",\"status\":\"$STATUS\"}" \
    > /dev/null
  echo "Tâche $i créée avec le statut $STATUS"
done

# Afficher les statistiques
curl -s http://localhost:8080/api/tasks/stats | jq .
```

## Codes de Statut HTTP

| Code | Signification | Quand |
|------|---------------|-------|
| 200 | OK | GET, PUT réussis |
| 201 | Created | POST réussi |
| 204 | No Content | DELETE réussi |
| 400 | Bad Request | Données invalides |
| 404 | Not Found | Ressource non trouvée |
| 500 | Internal Server Error | Erreur serveur |

## Validation des Données

### Champs obligatoires

- `title` : Obligatoire, ne peut pas être vide

### Exemple de requête invalide

```bash
# Titre manquant
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"description":"Sans titre","status":"PENDING"}'
```

**Réponse attendue :** HTTP 400 Bad Request

## Statuts de Tâche Valides

- `PENDING` : En attente
- `IN_PROGRESS` : En cours
- `COMPLETED` : Terminée

Vous pouvez utiliser n'importe quelle valeur, mais ces trois sont utilisées pour les statistiques.

## Monitoring

### Vérifier la santé de l'API

```bash
# Vérifier que l'API répond
curl -I http://localhost:8080/api/tasks/stats

# Devrait retourner HTTP 200
```

### Surveiller les performances

```bash
# Mesurer le temps de réponse
time curl -s http://localhost:8080/api/tasks > /dev/null
```

## Intégration avec le Batch

Le batch appelle automatiquement l'endpoint POST toutes les 30 minutes :

```bash
# Voir les tâches créées par le batch
curl -s http://localhost:8080/api/tasks | jq '.[] | select(.description | contains("batch"))'
```

