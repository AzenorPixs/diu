#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_omada() {
    local field="${1:-}"
    shift
    set -- omada "$@"
    local software=omada release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' omadac
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_OMADA
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
            printf '%s\n' software_apt_omada_detect
            ;;
        artifact_url)
            version="${OMADA_VERSION:-}"
                        [[ "$version" =~ ^[0-9][A-Za-z0-9._+-]*$ ]] || { printf '%s\n' 'Version Omada invalide.' >&2; return 1; }
                        printf 'https://ota-download.tplinkcloud.com/firmware/omada_v%s.deb\n' "$version"
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
            printf '%s\n' software_apt_configure_omada
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_omada
            ;;
        configuration_check)
            printf '\n'
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
        artifact_version) dpkg-deb -f "${2:-}" Version ;;
        components) printf "\n" ;;
        variant) printf "%s\n" direct ;;
        *) return 2 ;;
    esac
}

software_apt_omada_detect() { software_apt_package_state omadac; }

software_apt_configure_omada() { return 0; }

software_apt_cleanup_omada() { software_apt_cleanup_repository omada; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "omada" || return 1
fi
