#!/bin/bash

###############################################################################
# Script: detect-modules.sh
# Description: Auto-détecte les modules Maven et génère la configuration JSON
###############################################################################

set -e

# Paramètres
POM_FILE="${1:-pom.xml}"
ENVIRONMENT="${2:-dev}"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Auto-détection des modules Maven...${NC}"
echo ""

# Vérifier que le fichier pom.xml existe
if [ ! -f "$POM_FILE" ]; then
    echo -e "${RED}❌ Fichier POM non trouvé: $POM_FILE${NC}"
    exit 1
fi

# Extraire le groupId du parent (en ignorant le bloc <parent>)
GROUP_ID=""
in_parent=false
while IFS= read -r line; do
    if echo "$line" | grep -q "<parent>"; then
        in_parent=true
    elif echo "$line" | grep -q "</parent>"; then
        in_parent=false
    elif echo "$line" | grep -q "<groupId>.*</groupId>" && [ "$in_parent" = false ]; then
        GROUP_ID=$(echo "$line" | sed 's/.*<groupId>\([^<]*\)<\/groupId>.*/\1/' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        break
    fi
done < "$POM_FILE"

if [ -z "$GROUP_ID" ]; then
    echo -e "${RED}❌ Impossible d'extraire le groupId du POM${NC}"
    exit 1
fi

echo -e "${GREEN}✅ GroupId détecté: ${GROUP_ID}${NC}"

# Extraire la liste des modules
MODULES=$(sed -n '/<modules>/,/<\/modules>/p' "$POM_FILE" | grep "<module>" | sed 's/.*<module>\([^<]*\)<\/module>.*/\1/' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

if [ -z "$MODULES" ]; then
    echo -e "${YELLOW}⚠️  Aucun module détecté dans le POM parent${NC}"
    echo -e "${YELLOW}   Ce projet n'est peut-être pas multi-module${NC}"
    exit 0
fi

echo -e "${GREEN}✅ Modules détectés:${NC}"
echo "$MODULES" | while read -r module; do
    echo -e "   - ${module}"
done
echo ""

# Générer le JSON pour les modules Docker
echo -e "${BLUE}📦 Génération de la configuration JSON...${NC}"
echo ""

# Créer un fichier temporaire pour stocker les modules
TEMP_MODULES=$(mktemp)

# Parcourir les modules et construire le JSON
while read -r module; do
    if [ -z "$module" ]; then
        continue
    fi

    # Vérifier si le module a un Dockerfile ou est un module buildable
    MODULE_POM="${module}/pom.xml"

    if [ ! -f "$MODULE_POM" ]; then
        echo -e "${YELLOW}⚠️  POM non trouvé pour le module: ${module}${NC}"
        continue
    fi

    # Extraire le packaging du module (en ignorant le bloc <parent>)
    PACKAGING=""
    in_parent=false
    while IFS= read -r line; do
        if echo "$line" | grep -q "<parent>"; then
            in_parent=true
        elif echo "$line" | grep -q "</parent>"; then
            in_parent=false
        elif echo "$line" | grep -q "<packaging>.*</packaging>" && [ "$in_parent" = false ]; then
            PACKAGING=$(echo "$line" | sed 's/.*<packaging>\([^<]*\)<\/packaging>.*/\1/' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            break
        fi
    done < "$MODULE_POM"
    PACKAGING=${PACKAGING:-jar}

    # Extraire l'artifactId du module (en ignorant le bloc <parent>)
    ARTIFACT_ID=""
    in_parent=false
    while IFS= read -r line; do
        if echo "$line" | grep -q "<parent>"; then
            in_parent=true
        elif echo "$line" | grep -q "</parent>"; then
            in_parent=false
        elif echo "$line" | grep -q "<artifactId>.*</artifactId>" && [ "$in_parent" = false ]; then
            ARTIFACT_ID=$(echo "$line" | sed 's/.*<artifactId>\([^<]*\)<\/artifactId>.*/\1/' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            break
        fi
    done < "$MODULE_POM"
    ARTIFACT_ID=${ARTIFACT_ID:-$module}

    # Vérifier si le module est déployable
    IS_DEPLOYABLE=false
    REASON=""

    # Critère 1: Présence du plugin Spring Boot (application Spring Boot)
    HAS_SPRING_BOOT=$(grep -c "spring-boot-maven-plugin" "$MODULE_POM" 2>/dev/null || echo "0")
    if [ "$HAS_SPRING_BOOT" != "0" ]; then
        IS_DEPLOYABLE=true
        REASON="spring-boot-maven-plugin"
    fi

    # Critère 2: Packaging WAR ou EAR (applications Java EE)
    if [[ "$PACKAGING" == "war" || "$PACKAGING" == "ear" ]]; then
        IS_DEPLOYABLE=true
        REASON="${REASON:+${REASON}, }packaging=${PACKAGING}"
    fi

    # Critère 3: Présence de configurations Vault (indique une application déployable)
    VAULT_DIR="${module}/src/main/vault"
    HAS_VAULT=false
    if [ -d "$VAULT_DIR" ]; then
        HAS_VAULT=true
        # Si Vault est présent avec packaging JAR, c'est probablement déployable
        if [[ "$PACKAGING" == "jar" && "$HAS_SPRING_BOOT" == "0" ]]; then
            IS_DEPLOYABLE=true
        fi
        REASON="${REASON:+${REASON}, }vault-config"
    fi

    # Si le module n'est pas déployable, l'ignorer
    if [ "$IS_DEPLOYABLE" = false ]; then
        echo -e "${YELLOW}⚠️  Module non déployable: ${module} (packaging=${PACKAGING}, pas de critères de déploiement)${NC}"
        continue
    fi

    # Avertissement si pas de configuration Vault pour un module déployable
    if [ "$HAS_VAULT" = false ]; then
        echo -e "${YELLOW}⚠️  Module déployable sans configuration Vault: ${module}${NC}"
    fi

    echo -e "${GREEN}✅ Module déployable détecté: ${module}${NC}"
    echo -e "   - ArtifactId: ${ARTIFACT_ID}"
    echo -e "   - Packaging: ${PACKAGING}"
    echo -e "   - GroupId: ${GROUP_ID}"
    echo -e "   - Critères: ${REASON}"
    echo ""

    # Ajouter le module au fichier temporaire
    echo "${module}|${ARTIFACT_ID}|${PACKAGING}" >> "$TEMP_MODULES"
done <<< "$MODULES"

# Construire le JSON à partir du fichier temporaire
JSON_ARRAY="["
FIRST=true

while IFS='|' read -r module artifact_id packaging; do
    if [ "$FIRST" = false ]; then
        JSON_ARRAY="${JSON_ARRAY},"
    fi
    FIRST=false

    JSON_ARRAY="${JSON_ARRAY}
  {
    \"name\": \"${module}\",
    \"artifact\": \"${GROUP_ID}:${artifact_id}:${packaging}\",
    \"config\": \"${GROUP_ID}:${artifact_id}:zip:conf-${ENVIRONMENT}\"
  }"
done < "$TEMP_MODULES"

JSON_ARRAY="${JSON_ARRAY}
]"

# Nettoyer le fichier temporaire
rm -f "$TEMP_MODULES"

# Afficher le résultat
echo -e "${BLUE}📋 Configuration JSON générée:${NC}"
echo ""
echo "$JSON_ARRAY"
echo ""

# Sauvegarder dans un fichier si demandé
OUTPUT_FILE="${3:-}"
if [ -n "$OUTPUT_FILE" ]; then
    echo "$JSON_ARRAY" > "$OUTPUT_FILE"
    echo -e "${GREEN}✅ Configuration sauvegardée dans: ${OUTPUT_FILE}${NC}"
fi

# Exporter pour GitHub Actions
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    # Échapper les retours à la ligne pour GitHub Actions
    JSON_ESCAPED=$(echo "$JSON_ARRAY" | jq -c .)
    echo "modules=${JSON_ESCAPED}" >> "$GITHUB_OUTPUT"
    echo -e "${GREEN}✅ Configuration exportée vers GITHUB_OUTPUT${NC}"
fi

echo ""
echo -e "${GREEN}✅ Auto-détection terminée avec succès !${NC}"

