#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_postgresql() {
    local field="${1:-}"
    shift
    set -- postgresql "$@"
    local software=postgresql release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' postgresql
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_POSTGRESQL
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
            printf '\n'
            ;;
        repository_variable)
            printf '\n'
            ;;
        repository_state_valid)
            return 1
            ;;
        repository_expected)
            printf '\n'
            ;;
        remove_repository)
            printf '0\n'
            ;;
        detector)
            printf '%s\n' software_apt_postgresql_detect
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
            printf '%s\n' software_apt_configure_postgresql
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_postgresql
            ;;
        configuration_check)
            printf '\n'
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_postgresql_installed_packages
            ;;
        pre_remove_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" debian ;;
        *) return 2 ;;
    esac
}

software_apt_postgresql_installed_packages() {
    local rows name state matched=0
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" =~ ^postgresql(-[0-9]+)?(:[a-z0-9][a-z0-9-]*)?$ ]] || continue
        case "$state" in
            installed) printf '%s\n' "$name"; matched=1 ;;
            not-installed|config-files) ;;
            *) printf '%s\n' 'État PostgreSQL incomplet.' >&2; return 2 ;;
        esac
    done <<< "$rows"
    [[ "$matched" == 1 ]]
}

software_apt_postgresql_detect() {
    local packages status
    if packages="$(software_apt_postgresql_installed_packages)"; then
        if [[ "$packages" =~ (^|$'\n')postgresql-[0-9]+(:[a-z0-9][a-z0-9-]*)?($|$'\n') ]]; then
            printf '1\n'
        else
            printf '%s\n' 'Métapaquet PostgreSQL présent sans serveur vérifié.' >&2
            return 1
        fi
    else
        status=$?
        # Le catalogue vide est distinct d'une erreur dpkg par l'état retourné ci-dessous.
        if [[ "$status" == 1 ]]; then
            printf '0\n'
        else
            return "$status"
        fi
    fi
}

software_apt_configure_postgresql() { return 0; }

software_apt_cleanup_postgresql() { software_apt_cleanup_repository postgresql; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "postgresql" || return 1
fi
