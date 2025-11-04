#!/bin/bash

###############################################################################
# Script: generate-deployment-descriptor.sh
# Description: Génère un fichier JSON de déploiement pour chaque module
# Usage: ./generate-deployment-descriptor.sh <module-name> <version> <environment> <docker-registry>
###############################################################################

set -e

# Paramètres
MODULE_NAME="${1}"
VERSION="${2}"
ENVIRONMENT="${3:-dev}"
DOCKER_REGISTRY="${4:-ghcr.io}"
GITHUB_REPO="${GITHUB_REPOSITORY:-tourem/github-actions-project}"
MAVEN_REGISTRY="${5:-https://maven.pkg.github.com/${GITHUB_REPO}}"

# Validation des paramètres
if [ -z "$MODULE_NAME" ] || [ -z "$VERSION" ]; then
    echo "❌ Usage: $0 <module-name> <version> [environment] [docker-registry] [maven-registry]"
    echo "   Example: $0 task-api 1.0-SNAPSHOT dev ghcr.io"
    exit 1
fi

echo "📦 Génération du descripteur de déploiement pour ${MODULE_NAME}"
echo "   Version: ${VERSION}"
echo "   Environnement: ${ENVIRONMENT}"
echo "   Docker Registry: ${DOCKER_REGISTRY}"
echo "   Maven Registry: ${MAVEN_REGISTRY}"

# Répertoires
MODULE_DIR="${MODULE_NAME}"
MODULE_POM="${MODULE_DIR}/pom.xml"
RESOURCES_DIR="${MODULE_DIR}/src/main/resources"
DEPLOY_DIR="${MODULE_DIR}/deploy"

# Vérifier que le pom.xml du module existe
if [ ! -f "${MODULE_POM}" ]; then
    echo "❌ Erreur: Le fichier ${MODULE_POM} n'existe pas"
    exit 1
fi

# Créer le répertoire deploy s'il n'existe pas
mkdir -p "${DEPLOY_DIR}"

# Extraire le groupId depuis le pom.xml du module
echo "🔍 Extraction du groupId depuis ${MODULE_POM}..."
GROUP_ID=$(xmllint --xpath "string(//*[local-name()='project']/*[local-name()='groupId'])" "${MODULE_POM}" 2>/dev/null || echo "")

# Si le groupId n'est pas trouvé dans le module, chercher dans le parent
if [ -z "$GROUP_ID" ]; then
    echo "   GroupId non trouvé dans le module, recherche dans le parent..."
    GROUP_ID=$(xmllint --xpath "string(//*[local-name()='project']/*[local-name()='parent']/*[local-name()='groupId'])" "${MODULE_POM}" 2>/dev/null || echo "")
fi

# Vérifier que le groupId a été trouvé
if [ -z "$GROUP_ID" ]; then
    echo "❌ Erreur: Impossible d'extraire le groupId depuis ${MODULE_POM}"
    exit 1
fi

echo "   GroupId détecté: ${GROUP_ID}"

# Fonction pour détecter les profils Spring
detect_spring_profiles() {
    local profiles=()
    
    # Chercher tous les fichiers application-*.yml, application-*.yaml, application-*.properties
    if [ -d "${RESOURCES_DIR}" ]; then
        # Chercher les fichiers .yml
        for file in "${RESOURCES_DIR}"/application-*.yml; do
            if [ -f "$file" ]; then
                # Extraire le nom du profil (entre application- et l'extension)
                local basename=$(basename "$file")
                local profile=$(echo "$basename" | sed -E 's/application-(.+)\.yml/\1/')

                # Mapper les profils vers les environnements
                case "$profile" in
                    dev|development)
                        profiles+=("dev")
                        ;;
                    hml|homolog|homologation|staging)
                        profiles+=("hml")
                        ;;
                    prod|production|prd)
                        profiles+=("prd")
                        ;;
                    *)
                        # Ajouter le profil tel quel s'il ne correspond à aucun mapping
                        profiles+=("$profile")
                        ;;
                esac
            fi
        done

        # Chercher les fichiers .yaml
        for file in "${RESOURCES_DIR}"/application-*.yaml; do
            if [ -f "$file" ]; then
                # Extraire le nom du profil (entre application- et l'extension)
                local basename=$(basename "$file")
                local profile=$(echo "$basename" | sed -E 's/application-(.+)\.yaml/\1/')

                # Mapper les profils vers les environnements
                case "$profile" in
                    dev|development)
                        profiles+=("dev")
                        ;;
                    hml|homolog|homologation|staging)
                        profiles+=("hml")
                        ;;
                    prod|production|prd)
                        profiles+=("prd")
                        ;;
                    *)
                        # Ajouter le profil tel quel s'il ne correspond à aucun mapping
                        profiles+=("$profile")
                        ;;
                esac
            fi
        done

        # Chercher les fichiers .properties
        for file in "${RESOURCES_DIR}"/application-*.properties; do
            if [ -f "$file" ]; then
                # Extraire le nom du profil (entre application- et l'extension)
                local basename=$(basename "$file")
                local profile=$(echo "$basename" | sed -E 's/application-(.+)\.properties/\1/')

                # Mapper les profils vers les environnements
                case "$profile" in
                    dev|development)
                        profiles+=("dev")
                        ;;
                    hml|homolog|homologation|staging)
                        profiles+=("hml")
                        ;;
                    prod|production|prd)
                        profiles+=("prd")
                        ;;
                    *)
                        # Ajouter le profil tel quel s'il ne correspond à aucun mapping
                        profiles+=("$profile")
                        ;;
                esac
            fi
        done
    fi
    
    # Supprimer les doublons et trier
    echo "${profiles[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Fonction pour générer l'URL Maven
generate_maven_url() {
    local artifactId="$1"
    local version="$2"
    local type="$3"
    local classifier="$4"

    # Convertir groupId en chemin (com.larbotech -> com/larbotech)
    local groupPath=$(echo "$GROUP_ID" | tr '.' '/')

    # Construire l'URL
    local url="${MAVEN_REGISTRY}/${groupPath}/${artifactId}/${version}/${artifactId}-${version}"

    if [ -n "$classifier" ]; then
        url="${url}-${classifier}"
    fi

    url="${url}.${type}"

    echo "$url"
}

# Détecter les profils Spring
SPRING_PROFILES=$(detect_spring_profiles)
echo "   Profils Spring détectés: ${SPRING_PROFILES}"

# Générer le timestamp pour éviter les conflits
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Générer le JSON avec timestamp
OUTPUT_FILE="${DEPLOY_DIR}/deployment-descriptor-${MODULE_NAME}-${TIMESTAMP}.json"

# Créer aussi un lien symbolique vers le dernier fichier (sans timestamp)
LATEST_FILE="${DEPLOY_DIR}/deployment-descriptor-${MODULE_NAME}-latest.json"

cat > "${OUTPUT_FILE}" <<EOF
{
  "module": {
    "name": "${MODULE_NAME}",
    "version": "${VERSION}",
    "groupId": "${GROUP_ID}",
    "artifactId": "${MODULE_NAME}"
  },
  "springProfiles": {
EOF

# Ajouter les profils Spring détectés
first=true
for profile in ${SPRING_PROFILES}; do
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "${OUTPUT_FILE}"
    fi
    
    # Mapper le profil vers l'environnement
    case "$profile" in
        dev)
            env="dev"
            ;;
        hml)
            env="hml"
            ;;
        prd|prod)
            env="prd"
            ;;
        *)
            env="$profile"
            ;;
    esac
    
    echo -n "    \"${env}\": \"${profile}\"" >> "${OUTPUT_FILE}"
done

cat >> "${OUTPUT_FILE}" <<EOF

  },
  "artifacts": {
    "jar": {
      "groupId": "${GROUP_ID}",
      "artifactId": "${MODULE_NAME}",
      "version": "${VERSION}",
      "type": "jar",
      "url": "$(generate_maven_url "${MODULE_NAME}" "${VERSION}" "jar" "")"
    },
    "distribution": {
      "groupId": "${GROUP_ID}",
      "artifactId": "${MODULE_NAME}",
      "version": "${VERSION}",
      "type": "zip",
      "classifier": "distribution",
      "url": "$(generate_maven_url "${MODULE_NAME}" "${VERSION}" "zip" "distribution")"
    }
  },
  "configurations": {
    "dev": {
      "groupId": "${GROUP_ID}",
      "artifactId": "${MODULE_NAME}",
      "version": "${VERSION}",
      "type": "zip",
      "classifier": "conf-dev",
      "url": "$(generate_maven_url "${MODULE_NAME}" "${VERSION}" "zip" "conf-dev")",
      "vaultFile": "vault-dev.yml"
    },
    "hml": {
      "groupId": "${GROUP_ID}",
      "artifactId": "${MODULE_NAME}",
      "version": "${VERSION}",
      "type": "zip",
      "classifier": "conf-hml",
      "url": "$(generate_maven_url "${MODULE_NAME}" "${VERSION}" "zip" "conf-hml")",
      "vaultFile": "vault-hml.yml"
    },
    "prd": {
      "groupId": "${GROUP_ID}",
      "artifactId": "${MODULE_NAME}",
      "version": "${VERSION}",
      "type": "zip",
      "classifier": "conf-prd",
      "url": "$(generate_maven_url "${MODULE_NAME}" "${VERSION}" "zip" "conf-prd")",
      "vaultFile": "vault-prd.yml"
    }
  },
  "docker": {
    "registry": "${DOCKER_REGISTRY}",
    "repository": "${GITHUB_REPO}",
    "image": "${DOCKER_REGISTRY}/${GITHUB_REPO}/${MODULE_NAME}",
    "tags": {
      "version": "${VERSION}",
      "latest": "${DOCKER_REGISTRY}/${GITHUB_REPO}/${MODULE_NAME}:latest",
      "versioned": "${DOCKER_REGISTRY}/${GITHUB_REPO}/${MODULE_NAME}:${VERSION}"
    }
  },
  "deployment": {
    "environment": "${ENVIRONMENT}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "buildNumber": "${GITHUB_RUN_NUMBER:-0}",
    "commitSha": "${GITHUB_SHA:-unknown}",
    "branch": "${GITHUB_REF_NAME:-unknown}"
  }
}
EOF

# Créer une copie "latest" pour faciliter l'accès
cp "${OUTPUT_FILE}" "${LATEST_FILE}"

echo "✅ Descripteur de déploiement généré: ${OUTPUT_FILE}"
echo "✅ Copie latest créée: ${LATEST_FILE}"
echo ""
echo "📄 Contenu du fichier:"
cat "${OUTPUT_FILE}"
echo ""

# Afficher un résumé
echo "📊 Résumé:"
echo "   Module: ${MODULE_NAME}"
echo "   Version: ${VERSION}"
echo "   Profils Spring: ${SPRING_PROFILES}"
echo "   Image Docker: ${DOCKER_REGISTRY}/${GITHUB_REPO}/${MODULE_NAME}:${VERSION}"
echo "   Fichier avec timestamp: ${OUTPUT_FILE}"
echo "   Fichier latest: ${LATEST_FILE}"
echo ""
echo "✅ Terminé!"

