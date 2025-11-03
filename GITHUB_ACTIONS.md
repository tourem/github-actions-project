# GitHub Actions CI/CD

Ce document explique la configuration CI/CD avec GitHub Actions pour ce projet.

## 📋 Vue d'ensemble

Le workflow GitHub Actions automatise :
- ✅ La compilation du projet
- ✅ L'exécution des tests
- ✅ La création des packages (JAR et ZIP)
- ✅ La publication vers GitHub Packages
- ✅ L'archivage des artifacts

## 🔄 Workflow CI/CD

### Déclencheurs

Le workflow se déclenche automatiquement sur :
- **Push** sur les branches `main` et `develop`
- **Pull Request** vers `main` et `develop`
- **Manuellement** via l'interface GitHub (workflow_dispatch)

### Étapes du Workflow

1. **Checkout** - Récupération du code source
2. **Setup JDK 21** - Installation de Java 21 (Temurin)
3. **Cache Maven** - Mise en cache des dépendances Maven
4. **Build** - Compilation avec `mvn clean verify`
5. **Tests** - Exécution des tests avec `mvn test`
6. **Package** - Création des JARs et ZIPs avec `mvn package`
7. **Deploy** - Publication vers GitHub Packages (uniquement sur push vers main/develop)
8. **Upload Artifacts** - Archivage des JARs et ZIPs

## 📦 Artifacts Publiés

### GitHub Packages (Maven Repository)

Les artifacts suivants sont publiés sur `https://maven.pkg.github.com/tourem/github-actions-project` :

#### task-api
- `task-api-1.0-SNAPSHOT.jar` - JAR exécutable Spring Boot
- `task-api-1.0-SNAPSHOT-distribution.zip` - Archive de distribution complète

#### task-batch
- `task-batch-1.0-SNAPSHOT.jar` - JAR exécutable Spring Boot
- `task-batch-1.0-SNAPSHOT-distribution.zip` - Archive de distribution complète

### GitHub Actions Artifacts

Les artifacts sont également disponibles dans l'interface GitHub Actions (rétention : 30 jours) :
- `task-api-jar` - JAR de l'API
- `task-api-distribution` - ZIP de distribution de l'API
- `task-batch-jar` - JAR du Batch
- `task-batch-distribution` - ZIP de distribution du Batch
- `build-info` - Informations sur le build

## 🔧 Configuration

### POM Parent

Le POM parent (`pom.xml`) contient la configuration pour GitHub Packages :

```xml
<distributionManagement>
    <repository>
        <id>github</id>
        <name>GitHub Packages</name>
        <url>https://maven.pkg.github.com/tourem/github-actions-project</url>
    </repository>
</distributionManagement>
```

### Authentification

L'authentification est gérée automatiquement par GitHub Actions via :
- `GITHUB_TOKEN` - Token généré automatiquement par GitHub Actions
- `GITHUB_ACTOR` - Nom d'utilisateur GitHub

Configuration dans le workflow :
```yaml
- name: Set up JDK 21
  uses: actions/setup-java@v4
  with:
    server-id: github
    server-username: GITHUB_ACTOR
    server-password: GITHUB_TOKEN
```

## 📥 Utiliser les Packages

### Depuis un autre projet Maven

Pour utiliser les packages publiés dans un autre projet :

#### 1. Configurer l'authentification

Créer ou modifier `~/.m2/settings.xml` :

```xml
<settings>
  <servers>
    <server>
      <id>github</id>
      <username>VOTRE_USERNAME_GITHUB</username>
      <password>VOTRE_PERSONAL_ACCESS_TOKEN</password>
    </server>
  </servers>
</settings>
```

**Note** : Créez un Personal Access Token avec le scope `read:packages` sur https://github.com/settings/tokens

#### 2. Ajouter le repository dans votre POM

```xml
<repositories>
  <repository>
    <id>github</id>
    <url>https://maven.pkg.github.com/tourem/github-actions-project</url>
  </repository>
</repositories>
```

#### 3. Ajouter les dépendances

```xml
<dependencies>
  <dependency>
    <groupId>com.larbotech</groupId>
    <artifactId>task-api</artifactId>
    <version>1.0-SNAPSHOT</version>
  </dependency>
  
  <dependency>
    <groupId>com.larbotech</groupId>
    <artifactId>task-batch</artifactId>
    <version>1.0-SNAPSHOT</version>
  </dependency>
</dependencies>
```

### Télécharger les ZIPs de distribution

#### Via l'interface GitHub

1. Aller sur https://github.com/tourem/github-actions-project
2. Cliquer sur "Packages" dans la barre latérale
3. Sélectionner le package désiré
4. Télécharger le fichier ZIP

#### Via Maven

```bash
mvn dependency:get \
  -DremoteRepositories=https://maven.pkg.github.com/tourem/github-actions-project \
  -Dartifact=com.larbotech:task-api:1.0-SNAPSHOT:zip:distribution \
  -Ddest=./task-api-distribution.zip
```

#### Via GitHub CLI

```bash
# Installer GitHub CLI si nécessaire
# https://cli.github.com/

# Télécharger les artifacts du dernier workflow
gh run download --repo tourem/github-actions-project
```

## 🚀 Exécuter le Workflow

### Automatiquement

Le workflow s'exécute automatiquement lors d'un push ou d'une pull request.

### Manuellement

1. Aller sur https://github.com/tourem/github-actions-project/actions
2. Sélectionner "CI/CD Pipeline"
3. Cliquer sur "Run workflow"
4. Choisir la branche
5. Cliquer sur "Run workflow"

### Via GitHub CLI

```bash
gh workflow run ci.yml --repo tourem/github-actions-project
```

## 📊 Monitoring

### Voir les Workflows

```bash
# Lister les workflows
gh workflow list --repo tourem/github-actions-project

# Voir les runs récents
gh run list --repo tourem/github-actions-project

# Voir les détails d'un run
gh run view <run-id> --repo tourem/github-actions-project

# Voir les logs
gh run view <run-id> --log --repo tourem/github-actions-project
```

### Interface Web

Accéder à https://github.com/tourem/github-actions-project/actions pour :
- Voir l'historique des builds
- Consulter les logs
- Télécharger les artifacts
- Re-exécuter les workflows

## 🔐 Permissions

Le workflow nécessite les permissions suivantes :
- `contents: read` - Lire le code source
- `packages: write` - Publier vers GitHub Packages

Ces permissions sont configurées dans le workflow :
```yaml
permissions:
  contents: read
  packages: write
```

## 🐛 Dépannage

### Erreur d'authentification

**Problème** : `401 Unauthorized` lors de la publication

**Solution** :
- Vérifier que `GITHUB_TOKEN` est disponible
- Vérifier les permissions du workflow
- S'assurer que le repository est bien `tourem/github-actions-project`

### Build échoue

**Problème** : Le build Maven échoue

**Solution** :
1. Vérifier les logs dans GitHub Actions
2. Tester localement : `mvn clean verify`
3. Vérifier que JDK 21 est utilisé

### Packages non publiés

**Problème** : Les packages n'apparaissent pas dans GitHub Packages

**Solution** :
- Vérifier que le push est sur `main` ou `develop`
- Vérifier les logs de l'étape "Publish to GitHub Packages"
- S'assurer que le build a réussi

### Impossible de télécharger les packages

**Problème** : Erreur lors du téléchargement depuis un autre projet

**Solution** :
1. Vérifier l'authentification dans `~/.m2/settings.xml`
2. Créer un Personal Access Token avec `read:packages`
3. Vérifier l'URL du repository

## 📝 Bonnes Pratiques

### Versioning

Pour une release stable, utilisez des versions sans SNAPSHOT :

```xml
<version>1.0.0</version>
```

Puis créez un tag Git :
```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

### Branches

- `main` - Code stable, prêt pour la production
- `develop` - Code en développement
- `feature/*` - Nouvelles fonctionnalités
- `hotfix/*` - Corrections urgentes

### Secrets

Pour des configurations sensibles, utilisez les GitHub Secrets :

1. Aller dans Settings > Secrets and variables > Actions
2. Ajouter un nouveau secret
3. L'utiliser dans le workflow : `${{ secrets.SECRET_NAME }}`

## 🔄 Workflow Avancé

### Ajouter des tests d'intégration

```yaml
- name: Integration Tests
  run: mvn -B verify -Pintegration-tests
```

### Déploiement automatique

```yaml
- name: Deploy to Production
  if: github.ref == 'refs/heads/main'
  run: |
    # Script de déploiement
    ./deploy.sh
```

### Notifications

```yaml
- name: Notify on Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Packages Documentation](https://docs.github.com/en/packages)
- [Maven Deploy Plugin](https://maven.apache.org/plugins/maven-deploy-plugin/)
- [GitHub CLI](https://cli.github.com/)

## ✅ Checklist de Configuration

- [x] Workflow GitHub Actions créé (`.github/workflows/ci.yml`)
- [x] POM parent configuré avec `distributionManagement`
- [x] Modules configurés pour attacher les ZIPs
- [x] Permissions configurées dans le workflow
- [x] Authentification configurée (GITHUB_TOKEN)
- [ ] Repository créé sur GitHub
- [ ] Premier push effectué
- [ ] Workflow exécuté avec succès
- [ ] Packages visibles dans GitHub Packages

## 🎯 Prochaines Étapes

1. **Pousser le code sur GitHub** :
   ```bash
   git add .
   git commit -m "Add GitHub Actions CI/CD"
   git push origin main
   ```

2. **Vérifier le workflow** :
   - Aller sur https://github.com/tourem/github-actions-project/actions
   - Vérifier que le workflow s'exécute

3. **Vérifier les packages** :
   - Aller sur https://github.com/tourem/github-actions-project/packages
   - Vérifier que les artifacts sont publiés

4. **Tester le téléchargement** :
   - Configurer `~/.m2/settings.xml`
   - Tester le téléchargement depuis un autre projet

Votre pipeline CI/CD est maintenant configuré et prêt à l'emploi ! 🚀

