# 📚 Documentation GitHub Actions - Index

Ce répertoire contient une documentation complète sur les concepts GitHub Actions utilisés dans le projet.

---

## 📖 Documents Disponibles

### 1. **GITHUB_ACTIONS_EXPLAINED.md** 📘
**Guide Complet et Détaillé**

Documentation exhaustive qui explique en profondeur :
- ✅ `github.event.inputs.dockerfile_branch` - D'où vient cette valeur et comment l'utiliser
- ✅ `if: success()` - Conditions d'exécution des steps
- ✅ `type=raw,value=latest,enable={{is_default_branch}}` - Règles de tagging Docker
- ✅ Autres concepts importants (needs, matrix, outputs, secrets, etc.)

**Idéal pour** : Comprendre en détail chaque concept avec des exemples pratiques

**Contenu** :
- Explications détaillées avec schémas
- Exemples de code commentés
- Tableaux récapitulatifs
- Cas d'usage pratiques
- Flux de décision illustrés

---

### 2. **GITHUB_ACTIONS_QUICK_REFERENCE.md** 🚀
**Référence Rapide**

Guide de référence condensé pour retrouver rapidement :
- Variables et contextes (`github.*`)
- Conditions d'exécution (`if: success()`, `if: failure()`, etc.)
- Structure des jobs (`needs`, `outputs`, `matrix`)
- Docker metadata action (types de tags)
- Actions courantes (checkout, upload, docker, etc.)
- Opérateurs et fonctions
- Bonnes pratiques

**Idéal pour** : Retrouver rapidement une syntaxe ou un exemple

**Contenu** :
- Syntaxe concise
- Exemples courts et directs
- Tableaux de référence
- Snippets de code prêts à l'emploi

---

### 3. **DOCKERFILE_BRANCH_USAGE.md** 🔀
**Guide d'Utilisation des Branches Dockerfile**

Documentation spécifique sur la fonctionnalité de sélection de branche pour le Dockerfile :
- Configuration de l'input `workflow_dispatch`
- Utilisation de la variable `DOCKERFILE_BRANCH`
- Cas d'usage pratiques (test, rollback, A/B testing)
- Exemples de déclenchement manuel
- Bonnes pratiques

**Idéal pour** : Comprendre comment utiliser différentes versions du Dockerfile

---

### 4. **DOCKER_MIGRATION.md** 🐳
**Guide de Migration du Dockerfile**

Documentation sur la migration du Dockerfile vers le repository distant :
- Étapes de migration
- Configuration du workflow
- Structure du repository distant
- Checklist de migration

**Idéal pour** : Migrer le Dockerfile vers `docker-file-common`

---

## 🎯 Quel Document Lire ?

### Je veux comprendre un concept en détail
→ **GITHUB_ACTIONS_EXPLAINED.md**

### Je cherche une syntaxe rapidement
→ **GITHUB_ACTIONS_QUICK_REFERENCE.md**

### Je veux utiliser différentes branches de Dockerfile
→ **DOCKERFILE_BRANCH_USAGE.md**

### Je veux migrer le Dockerfile vers un repository distant
→ **DOCKER_MIGRATION.md**

---

## 📊 Diagrammes Interactifs

Le document **GITHUB_ACTIONS_EXPLAINED.md** contient des diagrammes Mermaid pour visualiser :

1. **Workflow Input Flow** - Comment les inputs manuels sont traités
2. **if: success() Flow** - Flux de décision des conditions
3. **Docker Tags Logic** - Logique de tagging avec `is_default_branch`

---

## 🔍 Réponses aux Questions Fréquentes

### Q1 : C'est quoi `github.event.inputs.dockerfile_branch` ?

**Réponse Courte** : C'est la valeur saisie par l'utilisateur dans l'interface GitHub Actions lors d'un déclenchement manuel.

**Réponse Détaillée** : Voir **GITHUB_ACTIONS_EXPLAINED.md** - Section 1

---

### Q2 : Que veut dire `if: success()` ?

**Réponse Courte** : La step s'exécute seulement si toutes les steps précédentes ont réussi.

**Réponse Détaillée** : Voir **GITHUB_ACTIONS_EXPLAINED.md** - Section 2

---

### Q3 : À quoi sert `type=raw,value=latest,enable={{is_default_branch}}` ?

**Réponse Courte** : Ajoute le tag `latest` à l'image Docker **seulement** si on est sur la branche par défaut (`main`).

**Réponse Détaillée** : Voir **GITHUB_ACTIONS_EXPLAINED.md** - Section 3

---

### Q4 : Comment utiliser une branche différente pour le Dockerfile ?

**Réponse** : Voir **DOCKERFILE_BRANCH_USAGE.md**

---

### Q5 : Comment migrer le Dockerfile vers un repository distant ?

**Réponse** : Voir **DOCKER_MIGRATION.md**

---

## 📚 Structure de la Documentation

```
docs/
├── GITHUB_ACTIONS_EXPLAINED.md          # Guide complet (détaillé)
├── GITHUB_ACTIONS_QUICK_REFERENCE.md    # Référence rapide
├── DOCKERFILE_BRANCH_USAGE.md           # Guide branches Dockerfile
├── DOCKER_MIGRATION.md                  # Guide migration Dockerfile
├── DOCKER.md                            # Documentation Docker
├── DOCKER_SETUP_SUMMARY.md              # Résumé configuration Docker
└── README_GITHUB_ACTIONS_DOCS.md        # Ce fichier (index)
```

---

## 🎓 Parcours d'Apprentissage Recommandé

### Niveau Débutant

1. Lire **GITHUB_ACTIONS_QUICK_REFERENCE.md** - Sections "Variables et Contextes" et "Conditions d'Exécution"
2. Lire **GITHUB_ACTIONS_EXPLAINED.md** - Section 1 (inputs)
3. Expérimenter avec un workflow simple

### Niveau Intermédiaire

1. Lire **GITHUB_ACTIONS_EXPLAINED.md** - Sections 2 et 3
2. Lire **DOCKERFILE_BRANCH_USAGE.md**
3. Tester le déclenchement manuel avec différentes branches

### Niveau Avancé

1. Lire **GITHUB_ACTIONS_EXPLAINED.md** - Section 4 (concepts avancés)
2. Lire **DOCKER_MIGRATION.md**
3. Implémenter des workflows complexes avec matrix et outputs

---

## 🔗 Liens Utiles

### Documentation Officielle

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Contexts](https://docs.github.com/en/actions/learn-github-actions/contexts)
- [Expressions](https://docs.github.com/en/actions/learn-github-actions/expressions)

### Actions Utilisées dans Notre Workflow

- [actions/checkout](https://github.com/actions/checkout)
- [actions/setup-java](https://github.com/actions/setup-java)
- [actions/upload-artifact](https://github.com/actions/upload-artifact)
- [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action)
- [docker/login-action](https://github.com/docker/login-action)
- [docker/metadata-action](https://github.com/docker/metadata-action)
- [docker/build-push-action](https://github.com/docker/build-push-action)

---

## 💡 Conseils de Lecture

### Pour une Compréhension Rapide
1. Commencer par **GITHUB_ACTIONS_QUICK_REFERENCE.md**
2. Chercher le concept spécifique
3. Si besoin de plus de détails, aller dans **GITHUB_ACTIONS_EXPLAINED.md**

### Pour une Compréhension Approfondie
1. Lire **GITHUB_ACTIONS_EXPLAINED.md** de bout en bout
2. Tester les exemples dans un workflow
3. Utiliser **GITHUB_ACTIONS_QUICK_REFERENCE.md** comme aide-mémoire

---

## 🎯 Exemples Pratiques

### Exemple 1 : Déclencher le Workflow Manuellement

1. Aller sur GitHub → **Actions**
2. Sélectionner **"CI/CD Pipeline"**
3. Cliquer sur **"Run workflow"**
4. Saisir la branche Dockerfile : `develop`
5. Cliquer sur **"Run workflow"**

**Résultat** : Le workflow utilise `docker-file-common@develop`

**Documentation** : Voir **DOCKERFILE_BRANCH_USAGE.md** - Section "Utilisation"

---

### Exemple 2 : Comprendre les Tags Docker Générés

**Scénario** : Push sur la branche `main`

**Tags générés** :
- `main` (nom de la branche)
- `main-abc123d` (branche + SHA)
- `latest` (car `is_default_branch = true`)
- `1.0-SNAPSHOT` (version Maven)

**Documentation** : Voir **GITHUB_ACTIONS_EXPLAINED.md** - Section 3

---

### Exemple 3 : Ajouter une Condition à une Step

```yaml
- name: Deploy to production
  if: success() && github.ref == 'refs/heads/main'
  run: ./deploy.sh
```

**Documentation** : Voir **GITHUB_ACTIONS_QUICK_REFERENCE.md** - Section "Conditions Combinées"

---

## 📝 Contribuer à la Documentation

Si vous trouvez des erreurs ou souhaitez améliorer la documentation :

1. Créer une issue sur GitHub
2. Proposer une Pull Request avec les modifications
3. Documenter les nouveaux concepts ajoutés au workflow

---

## ✅ Checklist de Compréhension

Après avoir lu la documentation, vous devriez être capable de :

- [ ] Expliquer ce qu'est `github.event.inputs.*`
- [ ] Utiliser les conditions `if: success()`, `if: failure()`, `if: always()`
- [ ] Comprendre la logique de tagging Docker avec `is_default_branch`
- [ ] Déclencher manuellement un workflow avec des inputs
- [ ] Utiliser différentes branches pour le Dockerfile
- [ ] Créer des dépendances entre jobs avec `needs`
- [ ] Partager des données entre jobs avec `outputs`
- [ ] Utiliser `matrix` pour l'exécution parallèle

---

**Date de Création** : 2025-11-03  
**Dernière Mise à Jour** : 2025-11-03  
**Version** : 1.0  
**Auteur** : Documentation GitHub Actions Project

