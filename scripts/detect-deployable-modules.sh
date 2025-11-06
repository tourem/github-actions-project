#!/bin/bash
# detect-deployable-modules.sh v5
# Compatible macOS, Linux, BSD
# Support argument optionnel idAssembly
# Usage: ./detect-deployable-modules.sh [pom.xml] [idAssembly]

set -euo pipefail

# Paramètres
POM_FILE="${1:-pom.xml}"
PREFERRED_ASSEMBLY_ID="${2:-}"  # Nouvel argument optionnel
OUTPUT_FORMAT="${OUTPUT_FORMAT:-json}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" >&2
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

# ============================================================
# Fonction : Extraire valeur du bloc parent
# ============================================================

extract_parent_value() {
    local pom_file=$1
    local tag=$2
    local value=""

    # Lire le fichier ligne par ligne et chercher dans le bloc <parent>
    local in_parent=false
    while IFS= read -r line; do
        if echo "$line" | grep -q "<parent>"; then
            in_parent=true
        elif echo "$line" | grep -q "</parent>"; then
            break
        elif echo "$line" | grep -q "<${tag}>.*</${tag}>" && [ "$in_parent" = true ]; then
            value=$(echo "$line" | sed "s/.*<${tag}>\([^<]*\)<\/${tag}>.*/\1/")
            break
        fi
    done < "$pom_file"

    # Nettoyer les espaces
    value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    echo "$value"
}

# ============================================================
# Fonction : Extraire valeur POM (compatible macOS/BSD)
# ============================================================

extract_pom_value() {
    local pom_file=$1
    local xpath=$2
    local value=""

    # Pour groupId, artifactId, version, packaging : toujours utiliser sed pour ignorer le bloc parent
    case "$xpath" in
        "project.groupId"|"project.artifactId"|"project.version"|"project.packaging")
            # Extraire le tag sans le préfixe "project."
            local tag=$(echo "$xpath" | sed 's/^project\.//')

            # Lire le fichier ligne par ligne et ignorer le bloc <parent>
            local in_parent=false
            while IFS= read -r line; do
                if echo "$line" | grep -q "<parent>"; then
                    in_parent=true
                elif echo "$line" | grep -q "</parent>"; then
                    in_parent=false
                elif echo "$line" | grep -q "<${tag}>.*</${tag}>" && [ "$in_parent" = false ]; then
                    value=$(echo "$line" | sed "s/.*<${tag}>\([^<]*\)<\/${tag}>.*/\1/")
                    break
                fi
            done < "$pom_file"
            ;;
        "mainClass")
            value=$(sed -n 's/.*<mainClass>\([^<]*\)<\/mainClass>.*/\1/p' "$pom_file" | head -1)
            ;;
        *)
            # Pour les autres tags, utiliser sed/grep
            value=$(sed -n "s/.*<${xpath}>\([^<]*\)<\/${xpath}>.*/\1/p" "$pom_file" | head -1)
            ;;
    esac

    # Nettoyer les espaces
    value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Résoudre les propriétés ${...}
    if echo "$value" | grep -q '\${'; then
        local prop_name=$(echo "$value" | sed 's/.*\${\([^}]*\)}.*/\1/')
        local prop_value=$(sed -n "s/.*<$prop_name>\([^<]*\)<\/$prop_name>.*/\1/p" "$pom_file" | head -1)
        value=$(echo "$value" | sed "s/\${$prop_name}/$prop_value/g")
    fi

    echo "$value"
}

# ============================================================
# NOUVELLE FONCTION : Extraire infos Assembly avec ID préféré
# ============================================================

extract_assembly_info() {
    local pom_file=$1
    local pom_dir=$(dirname "$pom_file")
    local preferred_id="${PREFERRED_ASSEMBLY_ID}"

    # 1. Vérifier si le plugin maven-assembly-plugin est présent
    if ! grep -q "maven-assembly-plugin" "$pom_file"; then
        echo ""
        return 0
    fi

    log_info "  Found maven-assembly-plugin, searching for assembly descriptors..."

    if [ -n "$preferred_id" ]; then
        log_info "  Looking for preferred assembly ID: $preferred_id"
    fi

    # 2. Trouver le fichier descriptor d'assembly
    local assembly_dir="$pom_dir/src/assembly"

    if [ ! -d "$assembly_dir" ]; then
        log_warning "  Assembly directory not found: $assembly_dir"
        echo ""
        return 0
    fi

    # 3. Collecter TOUS les assemblies disponibles
    declare -a all_assemblies=()
    declare -a all_assembly_ids=()

    while IFS= read -r assembly_file; do
        if [ -f "$assembly_file" ]; then
            # Extraire le <id> du descriptor avec sed/grep uniquement
            local assembly_id=$(sed -n 's/.*<id>\([^<]*\)<\/id>.*/\1/p' "$assembly_file" | head -1)
            assembly_id=$(echo "$assembly_id" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

            if [ -n "$assembly_id" ]; then
                all_assemblies+=("$assembly_file")
                all_assembly_ids+=("$assembly_id")
                log_info "  Found assembly descriptor: $(basename "$assembly_file") with id: $assembly_id"
            fi
        fi
    done < <(find "$assembly_dir" -name "*.xml" -type f 2>/dev/null | sort)

    # 4. Vérifier si on a trouvé des assemblies
    if [ ${#all_assemblies[@]} -eq 0 ]; then
        log_warning "  No assembly descriptors found"
        echo ""
        return 0
    fi

    # 5. Chercher l'assembly préféré OU prendre le premier
    local selected_assembly_id=""
    local found_preferred=false

    if [ -n "$preferred_id" ]; then
        # Chercher l'ID préféré dans la liste
        for i in "${!all_assembly_ids[@]}"; do
            if [ "${all_assembly_ids[$i]}" = "$preferred_id" ]; then
                selected_assembly_id="${all_assembly_ids[$i]}"
                found_preferred=true
                log_success "  ✓ Found preferred assembly ID: $preferred_id"
                break
            fi
        done

        if [ "$found_preferred" = false ]; then
            log_warning "  ⚠ Preferred assembly ID '$preferred_id' not found"
            log_warning "  Available IDs: ${all_assembly_ids[*]}"
            log_warning "  Falling back to first assembly: ${all_assembly_ids[0]}"
            selected_assembly_id="${all_assembly_ids[0]}"
        fi
    else
        # Pas d'ID préféré, prendre le premier
        selected_assembly_id="${all_assembly_ids[0]}"
        log_info "  Using first assembly: $selected_assembly_id"
    fi

    # 6. Retourner l'assembly ID sélectionné
    if [ -n "$selected_assembly_id" ]; then
        log_success "  Selected assembly ID: $selected_assembly_id"
        echo "$selected_assembly_id"
    else
        log_warning "  No assembly id found"
        echo ""
    fi
}

# ============================================================
# Fonction : Construire le path Maven pour Nexus/JFrog
# ============================================================

build_maven_path() {
    local group_id=$1
    local artifact_id=$2
    local version=$3
    local packaging=$4
    local classifier=${5:-}

    # Transformer groupId en path : com.larbotech → com/larbotech
    local group_path=$(echo "$group_id" | tr '.' '/')

    # Construire le nom du fichier
    local filename="${artifact_id}-${version}"
    if [ -n "$classifier" ]; then
        filename="${filename}-${classifier}"
    fi
    filename="${filename}.${packaging}"

    # Path complet : groupId/artifactId/version/filename
    echo "${group_path}/${artifact_id}/${version}/${filename}"
}

# ============================================================
# Fonction : Vérifier si POM est un aggregator
# ============================================================

is_aggregator() {
    local pom_file=$1
    if grep -q "<modules>" "$pom_file" 2>/dev/null; then
        return 0
    fi
    return 1
}

# ============================================================
# Fonction : Vérifier si module est déployable
# ============================================================

is_deployable_module() {
    local pom_file=$1
    local module_dir=$(dirname "$pom_file")
    local module_name=$(basename "$module_dir")

    log_info "Analyzing: $pom_file"

    # 1. Vérifier le packaging
    local packaging=$(extract_pom_value "$pom_file" "project.packaging")
    packaging=${packaging:-jar}

    log_info "  Packaging: $packaging"

    # 2. POM packaging = aggregator/parent
    if [ "$packaging" = "pom" ]; then
        log_info "  → Skipped: POM packaging (parent/aggregator)"
        return 1
    fi

    # 3. Vérifier si c'est un aggregator
    if is_aggregator "$pom_file"; then
        log_info "  → Skipped: Aggregator POM (has <modules>)"
        return 1
    fi

    # 4. WAR et EAR = toujours déployables
    if [ "$packaging" = "war" ] || [ "$packaging" = "ear" ]; then
        log_success "  → Deployable: $packaging application"
        return 0
    fi

    # 5. Pour les JAR
    if [ "$packaging" = "jar" ]; then
        local has_spring_boot=$(grep -c "spring-boot-maven-plugin" "$pom_file" 2>/dev/null || echo "0")
        local has_quarkus=$(grep -c "quarkus-maven-plugin" "$pom_file" 2>/dev/null || echo "0")
        local has_shade=$(grep -c "maven-shade-plugin" "$pom_file" 2>/dev/null || echo "0")
        local has_assembly=$(grep -c "maven-assembly-plugin" "$pom_file" 2>/dev/null || echo "0")
        local has_jib=$(grep -c "jib-maven-plugin" "$pom_file" 2>/dev/null || echo "0")
        local has_docker=$(grep -c "dockerfile-maven-plugin" "$pom_file" 2>/dev/null || echo "0")

        if [ "$has_spring_boot" -gt 0 ]; then
            log_success "  → Deployable: Spring Boot application"
            return 0
        fi

        if [ "$has_quarkus" -gt 0 ]; then
            log_success "  → Deployable: Quarkus application"
            return 0
        fi

        if [ "$has_shade" -gt 0 ]; then
            log_success "  → Deployable: Maven Shade (fat JAR)"
            return 0
        fi

        if [ "$has_assembly" -gt 0 ]; then
            log_success "  → Deployable: Maven Assembly"
            return 0
        fi

        if [ "$has_jib" -gt 0 ] || [ "$has_docker" -gt 0 ]; then
            log_success "  → Deployable: Docker/Jib plugin found"
            return 0
        fi

        local main_class=$(extract_pom_value "$pom_file" "mainClass")
        if [ -n "$main_class" ] && [ "$main_class" != "null" ]; then
            log_success "  → Deployable: Main class found ($main_class)"
            return 0
        fi

        if [ -d "$module_dir/src/main/java" ]; then
            local has_app_class=$(find "$module_dir/src/main/java" -type f \( -name "*Application.java" -o -name "*Main.java" -o -name "*App.java" \) 2>/dev/null | wc -l | tr -d ' ')
            if [ "$has_app_class" -gt 0 ]; then
                log_success "  → Deployable: Application class found"
                return 0
            fi
        fi

        local artifact_id=$(extract_pom_value "$pom_file" "project.artifactId")
        case "$artifact_id" in
            *-common|*-commons|*-utils|*-util|*-core|*-api|*-model|*-models|*-dto|*-entity|*-entities|*-domain|*-shared|*-client|*-lib|*-library)
                log_info "  → Skipped: Looks like a library module ($artifact_id)"
                return 1
                ;;
        esac

        if [ "$module_name" = "." ] || [ "$module_name" = "/" ]; then
            log_info "  → Skipped: Root module"
            return 1
        fi

        log_info "  → Skipped: No deployment indicator found (library)"
        return 1
    fi

    log_warning "  → Unknown packaging: $packaging"
    return 1
}

# ============================================================
# Fonction principale
# ============================================================

detect_deployable_modules() {
    local root_pom="$POM_FILE"

    if [ ! -f "$root_pom" ]; then
        log_error "POM file not found: $root_pom"
        exit 1
    fi

    log_info "Starting detection from: $root_pom"

    if [ -n "$PREFERRED_ASSEMBLY_ID" ]; then
        log_info "Preferred assembly ID: $PREFERRED_ASSEMBLY_ID"
    fi

    log_info "=================================================="
    log_info "Using sed/grep/awk for XML parsing (no external dependencies)"

    declare -a deployable_modules=()

    local root_dir=$(dirname "$root_pom")
    root_dir=$(cd "$root_dir" && pwd)

    log_info "Root directory: $root_dir"
    log_info ""

    local is_root_aggregator=false
    if is_aggregator "$root_pom"; then
        log_info "Root POM is an aggregator (has <modules>)"
        is_root_aggregator=true
    fi

    # Vérifier le POM racine
    if [ "$is_root_aggregator" = false ]; then
        log_info "Checking root POM (not an aggregator)"
        if is_deployable_module "$root_pom"; then
            local group_id=$(extract_pom_value "$root_pom" "project.groupId")
            local artifact_id=$(extract_pom_value "$root_pom" "project.artifactId")
            local version=$(extract_pom_value "$root_pom" "project.version")
            local packaging=$(extract_pom_value "$root_pom" "project.packaging")
            packaging=${packaging:-jar}

            # Construire le path de l'exécutable
            local executable_path=$(build_maven_path "$group_id" "$artifact_id" "$version" "$packaging")

            # Vérifier s'il y a un assembly
            local assembly_id=$(extract_assembly_info "$root_pom")
            local module_json="{\"groupId\":\"$group_id\",\"artifactId\":\"$artifact_id\",\"version\":\"$version\",\"packaging\":\"$packaging\",\"name\":\"$artifact_id\",\"executable\":\"$executable_path\""

            if [ -n "$assembly_id" ]; then
                local assembly_path=$(build_maven_path "$group_id" "$artifact_id" "$version" "zip" "$assembly_id")
                module_json="${module_json},\"assembly\":\"$assembly_path\""
            fi

            module_json="${module_json}}"
            deployable_modules+=("$module_json")
        fi
    else
        log_info "Skipping root POM (it's an aggregator)"
    fi

    log_info ""
    log_info "Scanning for child modules..."
    log_info ""

    while IFS= read -r module_pom; do
        local module_pom_abs=$(cd "$(dirname "$module_pom")" && pwd)/$(basename "$module_pom")
        local root_pom_abs=$(cd "$(dirname "$root_pom")" && pwd)/$(basename "$root_pom")

        if [ "$module_pom_abs" = "$root_pom_abs" ]; then
            continue
        fi

        if is_deployable_module "$module_pom"; then
            # Extraire l'artifactId et le packaging du module (toujours définis dans le module)
            local artifact_id=$(extract_pom_value "$module_pom" "project.artifactId")
            local packaging=$(extract_pom_value "$module_pom" "project.packaging")
            packaging=${packaging:-jar}

            # Pour groupId et version, utiliser le bloc <parent> du module
            # car les modules héritent généralement du parent
            local group_id=$(extract_parent_value "$module_pom" "groupId")
            local version=$(extract_parent_value "$module_pom" "version")

            # Si pas de bloc parent, essayer d'extraire directement
            if [ -z "$group_id" ]; then
                group_id=$(extract_pom_value "$module_pom" "project.groupId")
            fi
            if [ -z "$version" ]; then
                version=$(extract_pom_value "$module_pom" "project.version")
            fi

            # En dernier recours, utiliser les valeurs du root POM
            if [ -z "$group_id" ]; then
                group_id=$(extract_pom_value "$root_pom" "project.groupId")
            fi
            if [ -z "$version" ]; then
                version=$(extract_pom_value "$root_pom" "project.version")
            fi

            local module_dir=$(dirname "$module_pom")

            if command -v realpath &> /dev/null; then
                local rel_path=$(realpath --relative-to="$root_dir" "$module_dir" 2>/dev/null)
            else
                local rel_path=$(python -c "import os.path; print(os.path.relpath('$module_dir', '$root_dir'))" 2>/dev/null || echo "$module_dir")
            fi

            if [ "$rel_path" = "." ] || [ "$rel_path" = "./" ]; then
                continue
            fi

            # Construire le path de l'exécutable
            local executable_path=$(build_maven_path "$group_id" "$artifact_id" "$version" "$packaging")

            # Vérifier s'il y a un assembly
            local assembly_id=$(extract_assembly_info "$module_pom")
            local module_json="{\"groupId\":\"$group_id\",\"artifactId\":\"$artifact_id\",\"version\":\"$version\",\"packaging\":\"$packaging\",\"name\":\"$artifact_id\",\"executable\":\"$executable_path\""

            if [ -n "$assembly_id" ]; then
                local assembly_path=$(build_maven_path "$group_id" "$artifact_id" "$version" "zip" "$assembly_id")
                module_json="${module_json},\"assembly\":\"$assembly_path\""
            fi

            module_json="${module_json}}"
            deployable_modules+=("$module_json")
        fi
    done < <(find "$root_dir" -name "pom.xml" -type f ! -path "*/target/*" ! -path "*/.mvn/*" 2>/dev/null)

    log_info ""
    log_info "=================================================="
    log_info "Detection complete!"

    if [ ${#deployable_modules[@]} -eq 0 ]; then
        log_warning "No deployable modules found"

        if [ "$OUTPUT_FORMAT" = "json" ]; then
            echo "[]"
        else
            echo ""
        fi
        exit 0
    fi

    log_success "Found ${#deployable_modules[@]} deployable module(s)"

    if [ "$OUTPUT_FORMAT" = "json" ]; then
        echo -n "["
        first=true
        for module in "${deployable_modules[@]}"; do
            if [ "$first" = true ]; then
                first=false
            else
                echo -n ","
            fi
            echo -n "$module"
        done
        echo "]"
    else
        log_info ""
        log_info "Deployable modules:"
        for module in "${deployable_modules[@]}"; do
            echo "$module" | jq -r '"\(.artifactId) (\(.groupId):\(.artifactId):\(.version)) - \(.packaging) - \(.path)" + if .assembly then " [Assembly: \(.assembly)]" else "" end' >&2
        done
    fi
}

# Exécution
detect_deployable_modules