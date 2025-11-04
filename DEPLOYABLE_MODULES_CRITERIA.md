# 📋 Critères de Détection des Modules Déployables

## 🎯 Objectif

Le script `detect-modules.sh` identifie automatiquement les modules Maven qui sont **déployables** (applications) et ignore les modules qui sont de simples **bibliothèques** (libraries).

---

## ✅ Critères de Déploiement

Un module est considéré comme **déployable** s'il remplit **au moins un** des critères suivants :

### 1. 🍃 Présence du Plugin Spring Boot

**Critère** : Le `pom.xml` du module contient le plugin `spring-boot-maven-plugin`

**Exemple** :
```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

**Raison** : Les applications Spring Boot sont des applications exécutables autonomes.

---

### 2. 📦 Packaging WAR ou EAR

**Critère** : Le `pom.xml` du module contient `<packaging>war</packaging>` ou `<packaging>ear</packaging>`

**Exemple** :
```xml
<project>
    <artifactId>my-webapp</artifactId>
    <packaging>war</packaging>
    ...
</project>
```

**Raison** : Les fichiers WAR et EAR sont des applications Java EE déployables sur des serveurs d'applications.

---

### 3. 🔐 Présence de Configuration Vault

**Critère** : Le module contient un répertoire `src/main/vault/` avec des fichiers de configuration

**Structure** :
```
module-name/
└── src/main/vault/
    ├── vault-dev.yml
    ├── vault-hml.yml
    └── vault-prd.yml
```

**Raison** : La présence de configurations Vault indique que le module nécessite des configurations spécifiques par environnement, ce qui est typique des applications déployables.

**Note** : Ce critère seul peut rendre un module JAR déployable, même sans Spring Boot.

---

## ❌ Modules Non Déployables

Les modules suivants sont **ignorés** :

### 1. Bibliothèques JAR Simples

**Caractéristiques** :
- `<packaging>jar</packaging>` (ou pas de packaging spécifié)
- **Pas** de `spring-boot-maven-plugin`
- **Pas** de répertoire `src/main/vault/`

**Exemple** :
```xml
<project>
    <artifactId>common-utils</artifactId>
    <packaging>jar</packaging>
    <!-- Pas de spring-boot-maven-plugin -->
    <!-- Pas de src/main/vault/ -->
</project>
```

**Raison** : Ce sont des bibliothèques réutilisables, pas des applications.

---

### 2. Modules POM

**Caractéristiques** :
- `<packaging>pom</packaging>`

**Exemple** :
```xml
<project>
    <artifactId>parent-pom</artifactId>
    <packaging>pom</packaging>
</project>
```

**Raison** : Les modules POM sont des agrégateurs ou des parents, pas des applications.

---

## 📊 Exemples de Détection

### Exemple 1 : Application Spring Boot (Déployable)

```xml
<project>
    <artifactId>task-api</artifactId>
    <packaging>jar</packaging>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

**Résultat** : ✅ **Déployable** (spring-boot-maven-plugin)

---

### Exemple 2 : Application Web Java EE (Déployable)

```xml
<project>
    <artifactId>legacy-webapp</artifactId>
    <packaging>war</packaging>
</project>
```

**Résultat** : ✅ **Déployable** (packaging=war)

---

### Exemple 3 : Bibliothèque Commune (Non Déployable)

```xml
<project>
    <artifactId>common-utils</artifactId>
    <packaging>jar</packaging>
    
    <dependencies>
        <!-- Dépendances uniquement -->
    </dependencies>
</project>
```

**Résultat** : ❌ **Non déployable** (pas de critères)

---

### Exemple 4 : Module avec Vault (Déployable)

```xml
<project>
    <artifactId>custom-app</artifactId>
    <packaging>jar</packaging>
</project>
```

**Structure** :
```
custom-app/
└── src/main/vault/
    ├── vault-dev.yml
    └── vault-prd.yml
```

**Résultat** : ✅ **Déployable** (vault-config)

---

## 🔍 Sortie du Script

### Modules Déployables

```bash
✅ Module déployable détecté: task-api
   - ArtifactId: task-api
   - Packaging: jar
   - GroupId: com.larbotech
   - Critères: spring-boot-maven-plugin, vault-config
```

### Modules Non Déployables

```bash
⚠️  Module non déployable: common-utils (packaging=jar, pas de critères de déploiement)
```

### Avertissements

```bash
⚠️  Module déployable sans configuration Vault: legacy-webapp
```

---

## 🎯 Configuration JSON Générée

Le script génère un JSON contenant **uniquement les modules déployables** :

```json
[
  {
    "name": "task-api",
    "artifact": "com.larbotech:task-api:jar",
    "config": "com.larbotech:task-api:zip:conf-dev"
  },
  {
    "name": "task-batch",
    "artifact": "com.larbotech:task-batch:jar",
    "config": "com.larbotech:task-batch:zip:conf-dev"
  }
]
```

**Note** : Le module `common-utils` (bibliothèque) n'apparaît pas dans le JSON.

---

## 🔧 Utilisation

### Exécution Locale

```bash
./scripts/detect-modules.sh pom.xml dev
```

### Dans GitHub Actions

Le script est automatiquement exécuté par le workflow partagé :

```yaml
- name: Auto-detect modules
  id: detect
  run: |
    cp .github-actions-common/scripts/detect-modules.sh ./detect-modules.sh
    chmod +x ./detect-modules.sh
    ./detect-modules.sh pom.xml "${{ inputs.environment }}"
```

---

## 📝 Résumé des Critères

| Critère | Description | Priorité |
|---------|-------------|----------|
| **spring-boot-maven-plugin** | Plugin Spring Boot présent | ✅ Haute |
| **packaging=war/ear** | Application Java EE | ✅ Haute |
| **src/main/vault/** | Configuration Vault présente | ⚠️ Moyenne |
| **packaging=jar** seul | Bibliothèque simple | ❌ Ignoré |
| **packaging=pom** | Module parent/agrégateur | ❌ Ignoré |

---

## 🎉 Avantages

✅ **Détection automatique** des modules déployables  
✅ **Ignore les bibliothèques** (pas de build Docker inutile)  
✅ **Flexible** : supporte Spring Boot, Java EE, et configurations custom  
✅ **Avertissements** pour les modules sans Vault  
✅ **Logs clairs** pour le debugging  

---

## 🔗 Fichiers Associés

- **Script** : `scripts/detect-modules.sh`
- **Workflow** : `.github/workflows/ci.yml`
- **Workflow partagé** : `github-actions-common/.github/workflows/maven-docker-build.yml`

---

## 📚 Références

- [Spring Boot Maven Plugin](https://docs.spring.io/spring-boot/docs/current/maven-plugin/reference/htmlsingle/)
- [Maven Packaging Types](https://maven.apache.org/pom.html#packaging)
- [Java EE WAR Files](https://docs.oracle.com/javaee/7/tutorial/packaging001.htm)

