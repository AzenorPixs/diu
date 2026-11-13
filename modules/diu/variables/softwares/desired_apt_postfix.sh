#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_postfix() {
    local field="${1:-}"
    shift
    set -- postfix "$@"
    local software=postfix release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' postfix
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_POSTFIX
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
            printf '%s\n' software_apt_postfix_detect
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
            printf '%s\n' software_apt_preflight_postfix
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_postfix
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_postfix
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_postfix_configuration
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

software_apt_postfix_detect() { software_apt_package_state postfix; }

software_apt_configure_postfix() {
    local prefix="${1:-}" configuration relay
    if software_apt_check_postfix_configuration "$prefix"; then return 0; fi
    configuration="${prefix%/}/etc/postfix/main.cf"
    [[ -v POSTFIX_RELAY_HOST ]] || return 1
    [[ -f "$configuration" && -r "$configuration" && ! -L "$configuration" ]] || return 1
    relay="$(software_apt_sed_replacement "$POSTFIX_RELAY_HOST")" || return 1
    printf 's%%.*relayhost.*%%relayhost = %s%%\n' "$relay" | sed -i -f - "$configuration" || return 1
    service postfix restart
}

software_apt_preflight_postfix() {
    [[ -v POSTFIX_RELAY_HOST ]] || return 1
    software_apt_sed_replacement "$POSTFIX_RELAY_HOST" >/dev/null
}

software_apt_check_postfix_configuration() {
    local prefix="${1:-}" configuration load_state status
    configuration="${prefix%/}/etc/postfix/main.cf"
    [[ -v POSTFIX_RELAY_HOST ]] || return 2
    [[ "$POSTFIX_RELAY_HOST" != *$'\n'* && "$POSTFIX_RELAY_HOST" != *$'\r'* ]] || return 2
    [[ -e "$configuration" ]] || return 1
    [[ -f "$configuration" && -r "$configuration" && ! -L "$configuration" ]] || return 2
    software_apt_file_has_line "$configuration" "relayhost = $POSTFIX_RELAY_HOST" || return 1
    if ! load_state="$(systemctl show --property=LoadState --value postfix 2>/dev/null)"; then return 2; fi
    [[ "$load_state" == loaded ]] || return 1
    if systemctl is-active --quiet postfix; then
        return 0
    else
        status=$?
        [[ "$status" == 3 ]] && return 1
        return 2
    fi
}

software_apt_cleanup_postfix() { software_apt_cleanup_repository postfix; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "postfix" || return 1
fi
