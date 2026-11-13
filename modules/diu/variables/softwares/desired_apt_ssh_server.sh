#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_ssh_server() {
    local field="${1:-}"
    shift
    set -- ssh-server "$@"
    local software=ssh-server release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' openssh-server
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_SSH_SERVER
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
            printf '%s\n' software_apt_ssh_server_detect
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
            printf '%s\n' software_apt_preflight_ssh_server
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_ssh_server
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_ssh_server
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_ssh_server_configuration
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_convergence_package "${1:-}"
            ;;
        pre_remove_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" debian ;;
        *) return 2 ;;
    esac
}

software_apt_ssh_server_detect() { software_apt_package_state openssh-server; }

software_apt_configure_ssh_server() {
    local helper
    if software_apt_check_ssh_server_configuration; then return 0; fi
    software_apt_preflight_ssh_server / || return 1
    helper="$(software_apt_support_directory)/ssh_configuration.py" || return 1
    python3 "$helper" configure || return 1
    systemctl restart ssh.service
}

software_apt_preflight_ssh_server() {
    local prefix="${1:-/}" key path docker_user record account home
    for key in "${KEY_SSH_ADMIN:-}" "${KEY_SSH_ACME:-}"; do
        [[ "$key" != *$'\n'* && "$key" != *$'\r'* ]] || return 1
    done
    if [[ -z "${KEY_SSH_ADMIN:-}" && -z "${KEY_SSH_ACME:-}" ]]; then
        path="${prefix%/}/root/.ssh/authorized_keys"
        [[ -f "$path" && ! -L "$path" && -s "$path" ]] || {
            printf '%s\n' 'Aucune clé SSH autorisée disponible.' >&2
            return 1
        }
    fi
    case "${ENVIRONMENT_DOCKER:-0}" in
        0) return 0 ;;
        1) ;;
        *) return 1 ;;
    esac
    docker_user="${ENVIRONMENT_DOCKER_USER:-}"
    [[ "$docker_user" =~ ^[a-z_][a-z0-9_-]*$ ]] || return 1
    record="$(getent passwd "$docker_user")" || return 1
    IFS=: read -r account _ _ _ _ home _ <<< "$record"
    [[ "$account" == "$docker_user" && "$home" == /* && "$home/" != *'/../'* ]] || return 1
    path="${prefix%/}${home%/}"
    [[ -d "$path" && ! -L "$path" ]] || return 1
    if [[ -z "${KEY_SSH_ADMIN:-}" && -z "${KEY_SSH_ACME:-}" ]]; then
        path="$path/.ssh/authorized_keys"
        [[ -f "$path" && ! -L "$path" && -s "$path" ]] || return 1
    fi
}

software_apt_check_ssh_server_configuration() {
    local helper status load_state
    helper="$(software_apt_support_directory)/ssh_configuration.py" || return 2
    if python3 "$helper" check; then :; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
    if ! load_state="$(systemctl show --property=LoadState --value ssh.service 2>/dev/null)"; then return 2; fi
    [[ "$load_state" == loaded ]] || return 1
    if systemctl is-active --quiet ssh.service; then return 0; else
        status=$?; [[ "$status" == 3 ]] && return 1; return 2
    fi
}

software_apt_cleanup_ssh_server() { software_apt_cleanup_repository ssh-server; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "ssh-server" || return 1
fi
