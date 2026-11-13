#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_mongodb() {
    local field="${1:-}"
    shift
    set -- mongodb "$@"
    local software=mongodb release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' mongodb-org
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_MONGODB
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' remove
            ;;
        install_packages)
            software_apt_convergence_package "$software"
            ;;
        repository)
            version="$(software_apt_mongodb_repository_version)" || return 1; printf 'mongodb-%s\n' "$version"
            ;;
        repository_variable)
            printf '%s\n' SYSTEM_APT_MONGODB
            ;;
        repository_state_valid)
            [[ "$state" =~ ^(0|4|5|6|7|8)$ ]]
            ;;
        repository_expected)
            software_apt_mongodb_repository_version
            ;;
        remove_repository)
            printf '0\n'
            ;;
        detector)
            printf '%s\n' software_apt_mongodb_detect
            ;;
        artifact_url)
            printf '\n'
            ;;
        environment_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        sensitive_install)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '0\n'
            ;;
        pre_install_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_mongodb
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_mongodb
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_mongodb_configuration
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_mongodb_installed_packages
            ;;
        pre_remove_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" repository ;;
        *) return 2 ;;
    esac
}

software_apt_mongodb_installed_packages() {
    local rows name state matched=0
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" =~ ^mongodb-org(-[a-z0-9-]+)?(:[a-z0-9][a-z0-9-]*)?$ ]] || continue
        case "$state" in
            installed) printf '%s\n' "$name"; matched=1 ;;
            not-installed|config-files) ;;
            *) printf '%s\n' 'État MongoDB incomplet.' >&2; return 2 ;;
        esac
    done <<< "$rows"
    [[ "$matched" == 1 ]]
}

software_apt_mongodb_detect() {
    local packages status
    if packages="$(software_apt_mongodb_installed_packages)"; then
        if [[ "$packages" =~ (^|$'\n')mongodb-org-server(:[a-z0-9][a-z0-9-]*)?($|$'\n') ]]; then
            printf '1\n'
        else
            printf '%s\n' 'Composants MongoDB présents sans serveur vérifié.' >&2
            return 1
        fi
    else
        status=$?
        if [[ "$status" == 1 ]]; then printf '0\n'; else return "$status"; fi
    fi
}

software_apt_configure_mongodb() {
    systemctl start mongod || return 1
    systemctl enable mongod || return 1
    if ! mongosh --eval 'db.runCommand({ connectionStatus: 1 })' >/dev/null 2>&1; then
        printf '%s\n' 'Contrôle de connexion MongoDB échoué.' >&2
        return 1
    fi
    mongod --version || return 1
    if ! mongosh --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )' >/dev/null 2>&1; then
        printf '%s\n' 'Contrôle de compatibilité MongoDB échoué.' >&2
        return 1
    fi
}

software_apt_check_mongodb_configuration() {
    local load_state status
    if ! load_state="$(systemctl show --property=LoadState --value mongod 2>/dev/null)"; then
        return 2
    fi
    [[ "$load_state" == loaded ]] || return 1
    if systemctl is-enabled --quiet mongod; then
        :
    else
        status=$?
        [[ "$status" == 1 ]] && return 1
        return 2
    fi
    if systemctl is-active --quiet mongod; then
        return 0
    else
        status=$?
        [[ "$status" == 3 ]] && return 1
        return 2
    fi
}

software_apt_mongodb_repository_version() {
    local version="${SYSTEM_APT_MONGODB:-0}"
    case "$version" in
        4|5|6|7|8) ;;
        0)
            version="${MONGODB_VERSION:-}"
            case "$version" in
                4|4.0|4.4|5|5.0|6|6.0|7|7.0|8|8.0) version="${version%%.*}" ;;
                *) printf '%s\n' 'Version de dépôt MongoDB invalide.' >&2; return 1 ;;
            esac ;;
        *) printf '%s\n' 'État du dépôt MongoDB invalide.' >&2; return 1 ;;
    esac
    printf '%s\n' "$version"
}

software_apt_cleanup_mongodb() { software_apt_cleanup_repository mongodb; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "mongodb" || return 1
fi
