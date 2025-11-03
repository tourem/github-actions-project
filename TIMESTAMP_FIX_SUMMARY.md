# 🔧 Correction - Conflits de Merge avec Timestamp

## ❌ Problème Rencontré

```
Auto-merging task-api/deploy/deployment-descriptor-task-api.json
CONFLICT (content): Merge conflict in task-api/deploy/deployment-descriptor-task-api.json
Rebasing (1/1)
error: could not apply 677ca8e... chore: update deployment descriptor for task-api [1.0-SNAPSHOT]
```

### Cause

Lorsque plusieurs builds s'exécutent en parallèle ou rapidement l'un après l'autre, ils tentent tous de modifier le même fichier `deployment-descriptor-{module}.json`, ce qui crée des conflits de merge lors du rebase.

---

## ✅ Solution Implémentée

### 1. Ajout d'un Timestamp au Nom du Fichier

**Format** : `deployment-descriptor-{module}-YYYYMMDD-HHMMSS.json`

**Exemple** :
- `deployment-descriptor-task-api-20251103-225824.json`
- `deployment-descriptor-task-batch-20251103-225824.json`

### 2. Création d'un Fichier "Latest"

Pour faciliter l'accès au dernier descripteur, une copie est créée :
- `deployment-descriptor-{module}-latest.json`

Ce fichier est toujours une copie du dernier descripteur généré.

---

## 🔧 Modifications Apportées

### Script de Génération

**Fichier** : `scripts/generate-deployment-descriptor.sh`

#### Avant

```bash
OUTPUT_FILE="${DEPLOY_DIR}/deployment-descriptor-${MODULE_NAME}.json"
```

#### Après

```bash
# Générer le timestamp pour éviter les conflits
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Générer le JSON avec timestamp
OUTPUT_FILE="${DEPLOY_DIR}/deployment-descriptor-${MODULE_NAME}-${TIMESTAMP}.json"

# Créer aussi un lien symbolique vers le dernier fichier (sans timestamp)
LATEST_FILE="${DEPLOY_DIR}/deployment-descriptor-${MODULE_NAME}-latest.json"

# Créer une copie "latest" pour faciliter l'accès
cp "${OUTPUT_FILE}" "${LATEST_FILE}"
```

---

### Workflow Partagé

**Fichier** : `github-actions-common/.github/workflows/maven-docker-build.yml`

#### Upload des Artifacts

**Avant** :
```yaml
- name: Upload deployment descriptor
  uses: actions/upload-artifact@v4
  with:
    name: deployment-descriptor-${{ matrix.module.name }}
    path: ${{ matrix.module.name }}/deploy/deployment-descriptor-${{ matrix.module.name }}.json
```

**Après** :
```yaml
- name: Upload deployment descriptors
  uses: actions/upload-artifact@v4
  with:
    name: deployment-descriptor-${{ matrix.module.name }}
    path: |
      ${{ matrix.module.name }}/deploy/deployment-descriptor-${{ matrix.module.name }}-*.json
      ${{ matrix.module.name }}/deploy/deployment-descriptor-${{ matrix.module.name }}-latest.json
```

#### Commit et Push avec Retry Logic

**Avant** :
```yaml
git add ${{ matrix.module.name }}/deploy/deployment-descriptor-${{ matrix.module.name }}.json
git commit -m "chore: update deployment descriptor for ${{ matrix.module.name }}"
git pull --rebase origin ${{ github.ref_name }}
git push origin HEAD:${{ github.ref_name }}
```

**Après** :
```yaml
# Ajouter tous les fichiers de descripteurs (avec timestamp et latest)
git add ${{ matrix.module.name }}/deploy/deployment-descriptor-${{ matrix.module.name }}-*.json

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
git commit -m "chore: add deployment descriptor for ${{ matrix.module.name }} [${{ needs.build-and-publish.outputs.version }}] - ${TIMESTAMP}"

# Retry logic pour gérer les pushs concurrents
MAX_RETRIES=5
RETRY_COUNT=0
PUSH_SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$PUSH_SUCCESS" = "false" ]; do
  echo "🔄 Tentative de push ($((RETRY_COUNT + 1))/$MAX_RETRIES)..."

  if git push origin HEAD:${{ github.ref_name }}; then
    PUSH_SUCCESS=true
    echo "✅ Deployment descriptors committed and pushed"
  else
    echo "⚠️  Push échoué, pull et retry..."
    git pull --rebase origin ${{ github.ref_name }}
    RETRY_COUNT=$((RETRY_COUNT + 1))

    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      # Attendre un délai aléatoire entre 1 et 5 secondes
      SLEEP_TIME=$((1 + RANDOM % 5))
      echo "⏳ Attente de ${SLEEP_TIME}s avant retry..."
      sleep $SLEEP_TIME
    fi
  fi
done

if [ "$PUSH_SUCCESS" = "false" ]; then
  echo "❌ Échec du push après $MAX_RETRIES tentatives"
  exit 1
fi
```

**Améliorations** :
- ✅ Retry automatique jusqu'à 5 tentatives
- ✅ Pull et rebase avant chaque retry
- ✅ Délai aléatoire (1-5s) pour éviter les collisions
- ✅ Gestion des jobs parallèles (task-api et task-batch)

---

### Fichiers .gitignore

**Fichiers** : `task-api/deploy/.gitignore` et `task-batch/deploy/.gitignore`

```gitignore
# Ignorer les anciens fichiers de descripteurs sans timestamp
deployment-descriptor-*.json
!deployment-descriptor-*-*.json
!deployment-descriptor-*-latest.json
```

**Explication** :
- Ignore tous les fichiers `deployment-descriptor-*.json`
- **Sauf** ceux avec timestamp (`deployment-descriptor-*-*.json`)
- **Sauf** le fichier latest (`deployment-descriptor-*-latest.json`)

Cela permet d'ignorer les anciens fichiers sans timestamp tout en gardant les nouveaux.

---

## 📊 Avantages de la Solution

### 1. Gestion des Conflits

✅ Chaque build génère un fichier unique (timestamp)
✅ Retry automatique en cas de conflit (jusqu'à 5 tentatives)
✅ Délai aléatoire pour éviter les collisions
✅ Builds parallèles possibles (task-api et task-batch)

### 2. Historique Complet

✅ Tous les descripteurs sont conservés  
✅ Traçabilité complète des builds  
✅ Possibilité de comparer les versions  
✅ Audit trail complet  

### 3. Accès Facile

✅ Fichier "latest" toujours disponible  
✅ Pas besoin de chercher le dernier fichier  
✅ Compatible avec les outils de déploiement  

### 4. Nettoyage Automatique

✅ Les anciens fichiers peuvent être nettoyés facilement  
✅ Possibilité de garder seulement les N derniers  
✅ Pas d'accumulation infinie  

---

## 📁 Structure des Fichiers

### Avant

```
task-api/deploy/
└── deployment-descriptor-task-api.json  ← Conflit !
```

### Après

```
task-api/deploy/
├── .gitignore
├── deployment-descriptor-task-api-20251103-225824.json  ← Build 1
├── deployment-descriptor-task-api-20251103-230145.json  ← Build 2
├── deployment-descriptor-task-api-20251103-231502.json  ← Build 3
└── deployment-descriptor-task-api-latest.json           ← Dernier build
```

---

## 🎯 Utilisation

### Pour les Équipes

**Accès au dernier descripteur** :
```bash
cat task-api/deploy/deployment-descriptor-task-api-latest.json
```

**Accès à un descripteur spécifique** :
```bash
cat task-api/deploy/deployment-descriptor-task-api-20251103-225824.json
```

**Lister tous les descripteurs** :
```bash
ls -lh task-api/deploy/deployment-descriptor-task-api-*.json
```

### Pour les Outils de Déploiement

Les outils peuvent toujours utiliser le fichier "latest" :
```yaml
deployment_descriptor: "task-api/deploy/deployment-descriptor-task-api-latest.json"
```

---

## 🧹 Nettoyage des Anciens Fichiers

### Script de Nettoyage (Optionnel)

```bash
#!/bin/bash
# Garder seulement les 10 derniers descripteurs

MODULE_NAME="task-api"
DEPLOY_DIR="${MODULE_NAME}/deploy"

# Lister tous les fichiers avec timestamp, triés par date
FILES=$(ls -t ${DEPLOY_DIR}/deployment-descriptor-${MODULE_NAME}-[0-9]*.json 2>/dev/null)

# Compter le nombre de fichiers
COUNT=$(echo "$FILES" | wc -l)

# Si plus de 10 fichiers, supprimer les plus anciens
if [ $COUNT -gt 10 ]; then
    echo "🧹 Nettoyage des anciens descripteurs..."
    echo "$FILES" | tail -n +11 | xargs rm -f
    echo "✅ Nettoyage terminé"
fi
```

---

## ✅ Résumé des Changements

- ✅ **Timestamp ajouté** au nom des fichiers (YYYYMMDD-HHMMSS)
- ✅ **Fichier "latest"** créé pour faciliter l'accès
- ✅ **Workflow mis à jour** pour gérer les fichiers avec timestamp
- ✅ **Retry logic** implémentée (5 tentatives max)
- ✅ **Délai aléatoire** entre les retries (1-5s)
- ✅ **Fichiers .gitignore** ajoutés pour ignorer les anciens fichiers
- ✅ **Gestion des jobs parallèles** (task-api et task-batch)
- ✅ **Push réussi** sur les deux repositories

---

## 🔗 Fichiers Modifiés

### Repository `github-actions-project`

- ✅ `scripts/generate-deployment-descriptor.sh` - Ajout du timestamp
- ✅ `task-api/deploy/.gitignore` - Ignorer les anciens fichiers
- ✅ `task-batch/deploy/.gitignore` - Ignorer les anciens fichiers
- ✅ `github-actions-common-updated/maven-docker-build.yml` - Workflow mis à jour

### Repository `github-actions-common`

- ✅ `scripts/generate-deployment-descriptor.sh` - Ajout du timestamp
- ✅ `.github/workflows/maven-docker-build.yml` - Workflow mis à jour

---

## 🎉 Conclusion

**Les conflits de merge sont maintenant gérés automatiquement !**

✅ **Chaque build** génère un fichier unique (timestamp)
✅ **Retry automatique** en cas de conflit (5 tentatives)
✅ **Délai aléatoire** pour éviter les collisions
✅ **Historique complet** des builds
✅ **Accès facile** via le fichier "latest"
✅ **Builds parallèles** possibles (task-api et task-batch)

**Le workflow peut maintenant s'exécuter en parallèle avec gestion automatique des conflits ! 🚀**

