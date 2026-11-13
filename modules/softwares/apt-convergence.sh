#!/usr/bin/env bash

# Les entrées du catalogue sont fournies par les déclarations GLOBAL.
# shellcheck disable=SC1091 source=modules/system/apt-source-state.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/../system/apt-source-state.sh"
# shellcheck disable=SC1091 source=modules/softwares/apt-recipes.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/apt-recipes.sh"
software_apt_load_recipes || return 1
software_apt_convergence_package() { software_apt_recipe "${1:-}" package "${@:2}"; }

software_apt_convergence_variable() { software_apt_recipe "${1:-}" variable "${@:2}"; }

software_apt_convergence_names() { software_apt_recipe_names; }

software_apt_convergence_install_options() { software_apt_recipe "${1:-}" install_options "${@:2}"; }

software_apt_convergence_remove_action() { software_apt_recipe "${1:-}" remove_action "${@:2}"; }

software_apt_convergence_install_packages() { software_apt_recipe "${1:-}" install_packages "${@:2}"; }

software_apt_missing_install_packages() {
    local software="${1:-}" packages rows name state base package
    local -A states=()
    packages="$(software_apt_convergence_install_packages "$software")" || return 2
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ -n "$name" ]] || continue
        if [[ ! "$name" =~ ^[a-z0-9][a-z0-9+.-]+(:[a-z0-9][a-z0-9-]*)?$ ]]; then
            printf '%s\n' 'Nom de paquet Debian non vérifiable.' >&2
            return 2
        fi
        base="${name%%:*}"
        case "$state" in
            installed) [[ "${states[$base]:-}" == partial ]] || states["$base"]=installed ;;
            not-installed|config-files) ;;
            *) states["$base"]=partial ;;
        esac
    done <<< "$rows"
    while IFS= read -r package; do
        [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]+$ ]] || return 2
        if [[ "${states[$package]:-}" == partial ]]; then
            printf 'État Debian incomplet pour %s.\n' "$package" >&2
            return 2
        fi
        [[ "${states[$package]:-}" == installed ]] || printf '%s\n' "$package"
    done <<< "$packages"
}

software_apt_convergence_repository() { software_apt_recipe "${1:-}" repository "${@:2}"; }

software_apt_convergence_repository_variable() { software_apt_recipe "${1:-}" repository_variable "${@:2}"; }


software_apt_convergence_repository_state_valid() { software_apt_recipe "${1:-}" repository_state_valid "${@:2}"; }

software_apt_convergence_repository_expected() { software_apt_recipe "${1:-}" repository_expected "${@:2}"; }

software_apt_convergence_remove_repository() { software_apt_recipe "${1:-}" remove_repository "${@:2}"; }

software_apt_convergence_detector() { software_apt_recipe "${1:-}" detector "${@:2}"; }

software_apt_convergence_detect() {
    local detector
    detector="$(software_apt_convergence_detector "${1:-}")" || return 1
    if [[ ! "$detector" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$detector" >/dev/null; then
        printf '%s\n' 'Détecteur APT indisponible.' >&2
        return 1
    fi
    "$detector"
}

software_apt_convergence_artifact_url() { software_apt_recipe "${1:-}" artifact_url "${@:2}"; }

software_apt_fetch_artifact() {
    local url="${1:-}" expected="${2:-}" directory="${3:-}" actual architecture system_architecture
    [[ "$url" == https://* && "$expected" =~ ^[a-z0-9][a-z0-9+.-]+$ && -d "$directory" ]] || return 2
    curl --fail --silent --show-error --location "$url" -o "$directory/package.deb" || return 1
    actual="$(dpkg-deb -f "$directory/package.deb" Package)" || return 1
    architecture="$(dpkg-deb -f "$directory/package.deb" Architecture)" || return 1
    system_architecture="$(dpkg --print-architecture)" || return 1
    if [[ "$actual" != "$expected" || ( "$architecture" != all && "$architecture" != "$system_architecture" ) ]]; then
        printf '%s\n' 'Paquet téléchargé incompatible ou inattendu.' >&2
        return 1
    fi
    printf '%s\n' "$directory/package.deb"
}

software_apt_install_artifact() (
    local url="${1:-}" expected="${2:-}" environment_hook="${3:-}" sensitive="${4:-0}" temporary='' artifact
    shift 4
    [[ "$sensitive" == 0 || "$sensitive" == 1 ]] || return 2
    temporary="$(mktemp -d)" || return 1
    [[ -n "$temporary" && -d "$temporary" ]] || return 1
    trap 'rm -rf -- "$temporary"' EXIT
    artifact="$(software_apt_fetch_artifact "$url" "$expected" "$temporary")" || return $?
    if [[ -n "$environment_hook" ]]; then
        if [[ ! "$environment_hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$environment_hook" >/dev/null; then return 1; fi
        "$environment_hook" || return 1
    fi
    if [[ "$sensitive" == 1 ]]; then
        if ! apt -y install --no-upgrade "$@" -- "$artifact" >/dev/null 2>&1; then
            printf '%s\n' 'Installation du paquet avec paramètres sensibles échouée.' >&2
            return 1
        fi
    else
        apt -y install --no-upgrade "$@" -- "$artifact"
    fi
)

software_apt_convergence_external_names() {
    local software variant
    while IFS= read -r software; do
        variant="$(software_apt_recipe "$software" variant)" || return 1
        [[ "$variant" != direct ]] || printf '%s\n' "$software"
    done < <(software_apt_recipe_names)
}

software_apt_convergence_environment_hook() { software_apt_recipe "${1:-}" environment_hook "${@:2}"; }

software_apt_convergence_sensitive_install() { software_apt_recipe "${1:-}" sensitive_install "${@:2}"; }

software_apt_convergence_pre_install_hook() { software_apt_recipe "${1:-}" pre_install_hook "${@:2}"; }

software_apt_install() {
    local package package_list option option_list artifact_url environment_hook sensitive missing pre_install
    # Positionné par la préparation si elle a déjà actualisé les index.
    local software_apt_sources_refreshed=0
    local -a packages=() options=()
    package_list="$(software_apt_convergence_install_packages "${1:-}")" || return 1
    while IFS= read -r package; do
        [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]+$ ]] || return 1
        packages+=("$package")
    done <<< "$package_list"
    (( ${#packages[@]} > 0 )) || return 1
    if [[ "${software_convergence_actual:-0}" == 1 ]]; then
        missing="$(software_apt_missing_install_packages "${1:-}")" || return 1
        if [[ -z "$missing" ]]; then
            software_apt_apply_configuration "${1:-}" || return 1
            if [[ -v software_configuration_done ]]; then software_configuration_done=1; fi
            return 0
        fi
    fi
    option_list="$(software_apt_convergence_install_options "${1:-}")" || return 1
    while IFS= read -r option; do
        [[ -n "$option" ]] || continue
        [[ "$option" == --install-recommends ]] || return 1
        options+=("$option")
    done <<< "$option_list"
    artifact_url="$(software_apt_convergence_artifact_url "${1:-}")" || return 1
    environment_hook="$(software_apt_convergence_environment_hook "${1:-}")" || return 1
    sensitive="$(software_apt_convergence_sensitive_install "${1:-}")" || return 1
    pre_install="$(software_apt_convergence_pre_install_hook "${1:-}")" || return 1
    if [[ -n "$pre_install" ]]; then
        if [[ ! "$pre_install" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$pre_install" >/dev/null; then return 1; fi
        "$pre_install" || return 1
    fi
    if [[ -n "$environment_hook" ]]; then
        if [[ ! "$environment_hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$environment_hook" >/dev/null; then return 1; fi
        ( "$environment_hook" ) || return 1
    fi
    software_apt_prepare_sources "${1:-}" || return 1
    if [[ "$software_apt_sources_refreshed" == 0 ]]; then apt -y update || return 1; fi
    if [[ -n "$artifact_url" ]]; then
        [[ "${#packages[@]}" == 1 ]] || return 1
        software_apt_install_artifact "$artifact_url" "${packages[0]}" "$environment_hook" "$sensitive" "${options[@]}" || return 1
    else
        apt -y install --no-upgrade "${options[@]}" -- "${packages[@]}" || return 1
    fi
    software_apt_apply_configuration "${1:-}" || return 1
    if [[ -v software_configuration_done ]]; then software_configuration_done=1; fi
    return 0
}

software_apt_prepare_sources() {
    local software="${1:-}" components component variable expected actual desired repository changed=0
    components="$(software_apt_recipe "$software" components)" || return 1
    repository="$(software_apt_convergence_repository "$software")" || return 1
    while IFS= read -r component; do
        [[ -n "$component" ]] || continue
        case "$component" in
            main) continue ;;
            contrib) variable=SYSTEM_APT_DEBIAN_CONTRIB ;;
            non-free) variable=SYSTEM_APT_DEBIAN_NONFRFEE ;;
            non-free-firmware) variable=SYSTEM_APT_DEBIAN_NONFRFEE_FIRMWARE ;;
            *) printf '%s\n' 'Composant logiciel APT non pris en charge.' >&2; return 1 ;;
        esac
        actual="$(system_apt_source_state "$variable" binary)" || return 1
        desired="${!variable:-0}"
        [[ "$desired" == 0 || "$desired" == 1 ]] || return 1
        if [[ "$desired" != 1 || "$actual" != 1 ]]; then
            system_apt_install_repository "$component" || return 1
            changed=1
            actual="$(system_apt_source_state "$variable" binary)" || return 1
            [[ "$actual" == 1 ]] || { printf '%s\n' 'Composant APT requis toujours absent.' >&2; return 1; }
        fi
    done <<< "$components"
    if [[ -n "$repository" ]]; then
        variable="$(software_apt_convergence_repository_variable "$software")" || return 1
        expected="$(software_apt_convergence_repository_expected "$software")" || return 1
        desired="${!variable:-0}"
        software_apt_convergence_repository_state_valid "$software" "$desired" || return 1
        actual="$(system_apt_source_state "$variable" binary)" || return 1
        if [[ "$desired" != "$expected" || "$actual" != "$expected" ]]; then
            system_apt_install_repository "$repository" || return 1
            changed=1
            actual="$(system_apt_source_state "$variable" binary)" || return 1
            [[ "$actual" == "$expected" ]] || { printf '%s\n' 'Dépôt logiciel requis toujours absent.' >&2; return 1; }
        fi
    fi
    if [[ "$changed" == 1 ]]; then
        apt -y update || return 1
        if [[ -v software_apt_sources_refreshed ]]; then software_apt_sources_refreshed=1; fi
    fi
}

software_apt_apply_configuration() {
    local hook
    hook="$(software_apt_convergence_configuration_hook "${1:-}")" || return 1
    if [[ -n "$hook" ]]; then
        if [[ ! "$hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$hook" >/dev/null; then
            printf '%s\n' 'Configuration logicielle APT indisponible.' >&2
            return 1
        fi
        "$hook" || return 1
    fi
}

software_apt_convergence_configuration_hook() { software_apt_recipe "${1:-}" configuration_hook "${@:2}"; }
software_apt_convergence_cleanup_hook() { software_apt_recipe "${1:-}" cleanup_hook "${@:2}"; }

software_apt_convergence_configuration_check() { software_apt_recipe "${1:-}" configuration_check "${@:2}"; }

software_apt_configuration_conforms() {
    local software="${1:-}" desired="${2:-}" check missing policy
    [[ "$desired" == 1 ]] || return 0
    policy="$(software_apt_convergence_update_configuration_policy "$software")" || return 2
    missing="$(software_apt_missing_install_packages "$software")" || return 2
    [[ -z "$missing" ]] || return 1
    if [[ "${software_management_action:-update}" == update && ! -v software_convergence_actual && "$policy" == explicit ]]; then
        return 0
    fi
    check="$(software_apt_convergence_configuration_check "$software")" || return 2
    [[ -n "$check" ]] || return 0
    if [[ ! "$check" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$check" >/dev/null; then
        return 2
    fi
    "$check"
}

software_apt_convergence_update_configuration_policy() { software_apt_recipe "${1:-}" update_configuration_policy "${@:2}"; }

software_apt_convergence_remove_packages() { software_apt_recipe "${1:-}" remove_packages "${@:2}"; }

software_apt_convergence_pre_remove_hook() { software_apt_recipe "${1:-}" pre_remove_hook "${@:2}"; }

software_apt_remove() {
    local package package_list remove_action simulation line removed candidate matched hook
    # Le callback de rôle sait si le paquet partagé sera retiré.
    # shellcheck disable=SC2034
    local software_remove_packages_present=0
    local -a packages=()
    local -A confirmed=()
    package_list="$(software_apt_convergence_remove_packages "${1:-}")" || return 1
    if [[ -z "$package_list" ]]; then
        hook="$(software_apt_convergence_pre_remove_hook "${1:-}")" || return 1
        if [[ -z "$hook" || ! "$hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$hook" >/dev/null; then
            printf '%s\n' 'Retrait du rôle partagé non vérifiable.' >&2
            return 1
        fi
        "$hook"
        return $?
    fi
    while IFS= read -r package; do
        [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]+(:[a-z0-9][a-z0-9-]*)?$ ]] || return 1
        packages+=("$package")
        confirmed["$package"]=0
    done <<< "$package_list"
    (( ${#packages[@]} > 0 )) || return 1
    remove_action="$(software_apt_convergence_remove_action "${1:-}")" || return 1
    [[ "$remove_action" == remove || "$remove_action" == purge ]] || return 1
    if ! simulation="$(LC_ALL=C apt-get --simulate "$remove_action" -- "${packages[@]}")"; then
        printf '%s\n' 'Simulation de désinstallation APT impossible.' >&2
        return 1
    fi
    while IFS= read -r line; do
        if [[ "$line" =~ ^(Remv|Purg)[[:space:]]+([^[:space:]]+) ]]; then
            removed="${BASH_REMATCH[2]}"
            matched=0
            for candidate in "${packages[@]}"; do
                if [[ "$removed" == "$candidate" || "$removed" == "$candidate:"* || "$candidate" == "$removed:"* ]]; then
                    confirmed["$candidate"]=1
                    matched=1
                    break
                fi
            done
            if [[ "$matched" != 1 ]]; then
                printf 'Désinstallation APT refusée : paquet supplémentaire %s.\n' "$removed" >&2
                return 1
            fi
        fi
    done <<< "$simulation"
    for candidate in "${packages[@]}"; do
        if [[ "${confirmed[$candidate]}" != 1 ]]; then
            printf 'Simulation APT sans retrait confirmé : %s.\n' "$candidate" >&2
            return 1
        fi
    done
    # Le callback de rôle lit cette variable locale par portée dynamique Bash.
    # shellcheck disable=SC2034
    software_remove_packages_present=1
    hook="$(software_apt_convergence_pre_remove_hook "${1:-}")" || return 1
    if [[ -n "$hook" ]]; then
        if [[ ! "$hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$hook" >/dev/null; then return 1; fi
        "$hook" || return 1
    fi
    apt -y "$remove_action" -- "${packages[@]}" || return 1
}

software_apt_converge() {
    software_converge "${1:-}" "${2:-}" software_apt_convergence_detect software_apt_install software_apt_remove software_apt_configuration_conforms software_apt_apply_configuration software_apt_cleanup
}

software_apt_cleanup() {
    local hook
    hook="$(software_apt_convergence_cleanup_hook "${1:-}")" || return 1
    if [[ ! "$hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$hook" >/dev/null; then
        printf '%s\n' 'Nettoyage logiciel APT indisponible.' >&2
        return 1
    fi
    "$hook"
}

software_apt_cleanup_repository() {
    local software="${1:-}" cleanup repository variable state
    cleanup="$(software_apt_convergence_remove_repository "$software")" || return 1
    [[ "$cleanup" == 1 ]] || return 0
    repository="$(software_apt_convergence_repository "$software")" || return 1
    variable="$(software_apt_convergence_repository_variable "$software")" || return 1
    [[ -n "$repository" && -n "$variable" ]] || return 1
    if [[ -v "$variable" ]]; then state="${!variable}"; else state=0; fi
    software_apt_convergence_repository_state_valid "$software" "$state" || return 1
    [[ "$state" == 1 ]] || return 0
    declare -F system_apt_remove_repository >/dev/null || return 1
    system_apt_remove_repository "$repository" || return 1
    apt -y update
}
