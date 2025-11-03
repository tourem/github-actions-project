# 📦 Configuration Vault par Environnement - Résumé Complet

## 🎯 Objectif

Créer des fichiers de configuration Vault séparés par environnement (DEV, HML, PRD) et générer des zips de configuration distincts pour chaque environnement.

---

## ✅ Changements Effectués

### 1. Structure des Répertoires Créés

```
task-api/
└── src/main/vault/
    ├── vault-dev.yml
    ├── vault-hml.yml
    └── vault-prd.yml

task-batch/
└── src/main/vault/
    ├── vault-dev.yml
    ├── vault-hml.yml
    └── vault-prd.yml
```

### 2. Contenu des Fichiers Vault

Tous les fichiers contiennent actuellement :
```yaml
nameCache: toure-cache
```

**Note** : Vous pouvez ajouter d'autres configurations spécifiques à chaque environnement dans ces fichiers.

---

## 📦 Assemblies de Configuration

### 3. Fichiers Assembly Créés

Pour **task-api** :
```
task-api/src/assembly/
├── distribution.xml    # Distribution complète (existant)
├── conf-dev.xml        # Configuration DEV uniquement
├── conf-hml.xml        # Configuration HML uniquement
└── conf-prd.xml        # Configuration PRD uniquement
```

Pour **task-batch** :
```
task-batch/src/assembly/
├── distribution.xml    # Distribution complète (existant)
├── conf-dev.xml        # Configuration DEV uniquement
├── conf-hml.xml        # Configuration HML uniquement
└── conf-prd.xml        # Configuration PRD uniquement
```

### 4. Contenu des Assemblies de Configuration

Chaque assembly de configuration (conf-dev.xml, conf-hml.xml, conf-prd.xml) :
- Crée un ZIP contenant **uniquement** le fichier Vault correspondant
- Structure du ZIP :
  ```
  task-api-conf-dev/
  └── vault/
      └── vault-dev.yml
  ```

---

## 🔧 Modifications Maven (POM)

### 5. Configuration Maven Assembly Plugin

Les fichiers `pom.xml` de **task-api** et **task-batch** ont été modifiés pour :

1. **Générer 4 ZIPs au lieu d'1** :
   - `task-api-1.0-SNAPSHOT.zip` (distribution complète)
   - `task-api-1.0-SNAPSHOT-conf-dev.zip` (configuration DEV)
   - `task-api-1.0-SNAPSHOT-conf-hml.zip` (configuration HML)
   - `task-api-1.0-SNAPSHOT-conf-prd.zip` (configuration PRD)

2. **Attacher tous les artifacts** avec les classifiers appropriés :
   - `distribution` pour la distribution complète
   - `conf-dev` pour la configuration DEV
   - `conf-hml` pour la configuration HML
   - `conf-prd` pour la configuration PRD

### 6. Exemple de Configuration Maven

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <executions>
        <!-- Distribution complète -->
        <execution>
            <id>make-distribution</id>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
            <configuration>
                <descriptors>
                    <descriptor>src/assembly/distribution.xml</descriptor>
                </descriptors>
                <finalName>task-api-${project.version}</finalName>
                <appendAssemblyId>false</appendAssemblyId>
            </configuration>
        </execution>
        
        <!-- Configuration DEV -->
        <execution>
            <id>make-conf-dev</id>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
            <configuration>
                <descriptors>
                    <descriptor>src/assembly/conf-dev.xml</descriptor>
                </descriptors>
                <finalName>task-api-${project.version}</finalName>
                <appendAssemblyId>true</appendAssemblyId>
            </configuration>
        </execution>
        
        <!-- ... HML et PRD similaires ... -->
    </executions>
</plugin>
```

---

## 🚀 GitHub Actions Workflow

### 7. Modifications du Workflow CI/CD

Le fichier `.github/workflows/ci.yml` a été modifié pour :

1. **Ajouter un input pour l'environnement** :
   ```yaml
   workflow_dispatch:
     inputs:
       environment:
         description: 'Environment to deploy (dev, hml, prd)'
         required: false
         default: 'dev'
         type: choice
         options:
           - dev
           - hml
           - prd
   ```

2. **Utiliser la configuration correspondant à l'environnement** :
   ```yaml
   docker-modules: |
     [
       {
         "name": "task-api",
         "artifact": "com.larbotech:task-api:jar",
         "config": "com.larbotech:task-api:zip:conf-${{ github.event.inputs.environment || 'dev' }}"
       },
       {
         "name": "task-batch",
         "artifact": "com.larbotech:task-batch:jar",
         "config": "com.larbotech:task-batch:zip:conf-${{ github.event.inputs.environment || 'dev' }}"
       }
     ]
   ```

### 8. Comportement du Workflow

- **Push automatique** : Utilise la configuration **DEV** par défaut
- **Déclenchement manuel** : Permet de choisir l'environnement (DEV, HML, PRD)

---

## 📊 Résultat du Build

### 9. Artifacts Générés

Après `mvn clean package`, les fichiers suivants sont créés :

#### task-api
```
task-api/target/
├── task-api.jar                              (~48 MB)
├── task-api-1.0-SNAPSHOT.zip                 (~41 MB) - Distribution complète
├── task-api-1.0-SNAPSHOT-conf-dev.zip        (~431 B) - Config DEV
├── task-api-1.0-SNAPSHOT-conf-hml.zip        (~431 B) - Config HML
└── task-api-1.0-SNAPSHOT-conf-prd.zip        (~431 B) - Config PRD
```

#### task-batch
```
task-batch/target/
├── task-batch.jar                            (~47 MB)
├── task-batch-1.0-SNAPSHOT.zip               (~40 MB) - Distribution complète
├── task-batch-1.0-SNAPSHOT-conf-dev.zip      (~443 B) - Config DEV
├── task-batch-1.0-SNAPSHOT-conf-hml.zip      (~443 B) - Config HML
└── task-batch-1.0-SNAPSHOT-conf-prd.zip      (~443 B) - Config PRD
```

### 10. Publication sur GitHub Packages

Tous les artifacts sont publiés avec leurs classifiers :
```
com.larbotech:task-api:jar:1.0-SNAPSHOT
com.larbotech:task-api:zip:distribution:1.0-SNAPSHOT
com.larbotech:task-api:zip:conf-dev:1.0-SNAPSHOT
com.larbotech:task-api:zip:conf-hml:1.0-SNAPSHOT
com.larbotech:task-api:zip:conf-prd:1.0-SNAPSHOT
```

---

## 🐳 Build Docker

### 11. Référence de Configuration dans Docker

Le Dockerfile recevra la référence de configuration correspondant à l'environnement :

**Exemple pour DEV** :
```bash
CONF_LOCATION=com.larbotech:task-api:zip:1.0-SNAPSHOT:conf-dev
```

**Exemple pour PRD** :
```bash
CONF_LOCATION=com.larbotech:task-api:zip:1.0-SNAPSHOT:conf-prd
```

---

## 🎯 Utilisation

### 12. Build Local

```bash
# Build complet avec tous les environnements
mvn clean package

# Vérifier les ZIPs générés
ls -lh task-api/target/*.zip
ls -lh task-batch/target/*.zip

# Vérifier le contenu d'un ZIP de configuration
unzip -l task-api/target/task-api-1.0-SNAPSHOT-conf-dev.zip
```

### 13. Déclenchement Manuel du Workflow

1. Aller sur : https://github.com/tourem/github-actions-project/actions/workflows/ci.yml
2. Cliquer sur **"Run workflow"**
3. Choisir :
   - **Branch** : main ou develop
   - **Dockerfile branch** : main (ou autre)
   - **Environment** : dev, hml ou prd
4. Cliquer sur **"Run workflow"**

### 14. Push Automatique

Lors d'un push sur `main` ou `develop`, le workflow utilise automatiquement l'environnement **DEV**.

---

## 📝 Prochaines Étapes

### 15. Ajouter des Configurations Spécifiques

Vous pouvez maintenant enrichir les fichiers Vault par environnement :

**task-api/src/main/vault/vault-dev.yml** :
```yaml
nameCache: toure-cache
database:
  host: dev-db.example.com
  port: 5432
  name: task_api_dev
redis:
  host: dev-redis.example.com
  port: 6379
```

**task-api/src/main/vault/vault-prd.yml** :
```yaml
nameCache: toure-cache
database:
  host: prd-db.example.com
  port: 5432
  name: task_api_prd
redis:
  host: prd-redis.example.com
  port: 6379
```

### 16. Tester le Workflow

```bash
# Commit et push
git add .
git commit -m "feat: add vault configuration per environment"
git push origin main

# Vérifier le build sur GitHub Actions
# https://github.com/tourem/github-actions-project/actions
```

---

## 📚 Fichiers Modifiés

### 17. Liste Complète

**Nouveaux fichiers** :
- `task-api/src/main/vault/vault-dev.yml`
- `task-api/src/main/vault/vault-hml.yml`
- `task-api/src/main/vault/vault-prd.yml`
- `task-api/src/assembly/conf-dev.xml`
- `task-api/src/assembly/conf-hml.xml`
- `task-api/src/assembly/conf-prd.xml`
- `task-batch/src/main/vault/vault-dev.yml`
- `task-batch/src/main/vault/vault-hml.yml`
- `task-batch/src/main/vault/vault-prd.yml`
- `task-batch/src/assembly/conf-dev.xml`
- `task-batch/src/assembly/conf-hml.xml`
- `task-batch/src/assembly/conf-prd.xml`

**Fichiers modifiés** :
- `task-api/pom.xml`
- `task-batch/pom.xml`
- `.github/workflows/ci.yml`

---

## ✅ Résumé

- ✅ **Fichiers Vault créés** : 3 par module (dev, hml, prd)
- ✅ **Assemblies de configuration** : 3 par module
- ✅ **Build Maven** : Génère 4 ZIPs par module
- ✅ **GitHub Actions** : Supporte le choix de l'environnement
- ✅ **Docker Build** : Utilise la bonne configuration selon l'environnement

**La configuration Vault est maintenant gérée par environnement ! 🎉**

