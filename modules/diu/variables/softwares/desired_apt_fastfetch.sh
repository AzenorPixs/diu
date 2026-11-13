#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_fastfetch() {
    local field="${1:-}"
    shift
    set -- fastfetch "$@"
    local software=fastfetch release perl_package version state="${2:-}"
    case "$field" in
        package)
            release="$(software_apt_effective_release /etc/os-release)" || return 1
                        case "$release" in
                            bullseye|bookworm) printf '%s\n' neofetch ;;
                            trixie) printf '%s\n' fastfetch ;;
                            *) printf '%s\n' 'Version Debian non prise en charge pour Fastfetch.' >&2; return 1 ;;
                        esac
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_FASTFETCH
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
            printf '%s\n' software_apt_fastfetch_detect
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
            printf '%s\n' software_apt_configure_fastfetch
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_fastfetch
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_fastfetch_configuration
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

software_apt_fastfetch_detect() {
    local release
    release="$(software_apt_effective_release /etc/os-release)" || return 1
    case "$release" in
        bullseye|bookworm) software_apt_package_state neofetch ;;
        trixie) software_apt_package_state fastfetch ;;
        *) printf '%s\n' 'Version Debian non prise en charge pour Fastfetch.' >&2; return 1 ;;
    esac
}

software_apt_configure_fastfetch() {
    local configuration='/root/.config/neofetch/config.conf'
    case "${SYSTEM_DEBIAN_RELEASE:-}" in
        trixie) return 0 ;;
        bullseye|bookworm) ;;
        *) printf '%s\n' 'Version Debian non prise en charge pour Fastfetch.' >&2; return 1 ;;
    esac
    mkdir -p -- "$(dirname -- "$configuration")" || return 1
    neofetch || return 1
    touch -- "$configuration" || return 1
    sed -i \
        -e 's%.*info "CPU Usage" cpu_usage.*%    info "CPU Usage" cpu_usage%' \
        -e 's%.*info "Disk" disk.*%    info "Disk" disk%' \
        -e 's%.*info "Local IP" local_ip.*%    info "Local IP" local_ip%' \
        -e 's%.*memory_percent=.*%memory_percent="on"%' \
        -e 's%.*memory_unit=.*%memory_unit="mib"%' \
        -e 's%.*shell_path=.*%shell_path="on"%' \
        -e 's%.*speed_shorthand=.*%speed_shorthand="on"%' \
        -e 's%.*cpu_brand=.*%cpu_brand="on"%' \
        -e 's%.*cpu_speed=.*%cpu_speed="on"%' \
        -e 's%.*cpu_cores=.*%cpu_cores="logical"%' \
        -e 's%.*cpu_temp=.*%cpu_temp="on"%' \
        -e 's%.*disk_percent=.*%disk_percent="on"%' "$configuration"
}

software_apt_check_fastfetch_configuration() {
    local configuration='/root/.config/neofetch/config.conf' expected status
    local -a required=(
        '    info "CPU Usage" cpu_usage'
        '    info "Disk" disk'
        '    info "Local IP" local_ip'
        'memory_percent="on"' 'memory_unit="mib"' 'shell_path="on"'
        'speed_shorthand="on"' 'cpu_brand="on"' 'cpu_speed="on"'
        'cpu_cores="logical"' 'cpu_temp="on"' 'disk_percent="on"'
    )
    case "${SYSTEM_DEBIAN_RELEASE:-}" in
        trixie) return 0 ;;
        bullseye|bookworm) ;;
        *) return 2 ;;
    esac
    [[ -e "$configuration" ]] || return 1
    [[ -f "$configuration" && -r "$configuration" ]] || return 2
    for expected in "${required[@]}"; do
        if grep -Fxq -- "$expected" "$configuration"; then
            continue
        else
            status=$?
            [[ "$status" == 1 ]] && return 1
            return 2
        fi
    done
}

software_apt_cleanup_fastfetch() { software_apt_cleanup_repository fastfetch; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "fastfetch" || return 1
fi
