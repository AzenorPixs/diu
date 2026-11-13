#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_openjdk() {
    local field="${1:-}"
    shift
    set -- openjdk "$@"
    local software=openjdk release perl_package version state="${2:-}"
    case "$field" in
        package)
            release="$(software_apt_effective_release /etc/os-release)" || return 1
                        case "$release" in
                            bullseye|bookworm) printf '%s\n' openjdk-17-jre-headless ;;
                            trixie) printf '%s\n' openjdk-21-jre-headless ;;
                            *) printf '%s\n' 'Version Debian non prise en charge pour OpenJDK.' >&2; return 1 ;;
                        esac
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_OPENJDK
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
            printf '%s\n' software_apt_openjdk_detect
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
            printf '%s\n' software_apt_preflight_openjdk
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_openjdk
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_openjdk
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_openjdk_configuration
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_openjdk_installed_packages
            ;;
        pre_remove_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" debian ;;
        *) return 2 ;;
    esac
}

software_apt_openjdk_installed_packages() {
    local rows name state matched=0
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" =~ ^openjdk-[0-9]+-jre-headless(:[a-z0-9][a-z0-9-]*)?$ ]] || continue
        case "$state" in
            installed) printf '%s\n' "$name"; matched=1 ;;
            not-installed|config-files) ;;
            *) printf '%s\n' 'État OpenJDK incomplet.' >&2; return 2 ;;
        esac
    done <<< "$rows"
    [[ "$matched" == 1 ]]
}

software_apt_openjdk_detect() {
    local packages status
    if packages="$(software_apt_openjdk_installed_packages)"; then
        [[ -n "$packages" ]] || return 2
        printf '1\n'
    else
        status=$?
        if [[ "$status" == 1 ]]; then printf '0\n'; else return "$status"; fi
    fi
}

software_apt_openjdk_major() {
    case "${SYSTEM_DEBIAN_RELEASE:-}" in
        bullseye|bookworm) printf '17\n' ;;
        trixie) printf '21\n' ;;
        *) printf '%s\n' 'Version Debian non prise en charge pour OpenJDK.' >&2; return 1 ;;
    esac
}

software_apt_configure_openjdk() {
    local prefix="${1:-}" major base properties enabled host port https_host https_port
    major="$(software_apt_openjdk_major)" || return 1
    base="${prefix%/}/usr/lib/jvm/java-${major}-openjdk-amd64"
    properties="${prefix%/}/etc/java-${major}-openjdk/net.properties"
    [[ -f "$properties" && -r "$properties" ]] || return 1
    if [[ "$major" == 21 ]]; then
        enabled="${PROXY_HTTP:-0}"
    else
        enabled="${SYSTEM_PROXY:-0}"
    fi
    [[ "$enabled" == 0 || "$enabled" == 1 ]] || return 1
    if [[ "$major" == 17 && "$enabled" == 1 ]]; then
        [[ -n "${PROXY_HTTP_HOST:-}" && -n "${PROXY_HTTP_PORT:-}" && -n "${PROXY_HTTPS_HOST:-}" && -n "${PROXY_HTTPS_PORT:-}" ]] || return 1
        host="$(software_apt_sed_replacement "$PROXY_HTTP_HOST")" || return 1
        port="$(software_apt_sed_replacement "$PROXY_HTTP_PORT")" || return 1
        https_host="$(software_apt_sed_replacement "$PROXY_HTTPS_HOST")" || return 1
        https_port="$(software_apt_sed_replacement "$PROXY_HTTPS_PORT")" || return 1
    fi
    mkdir -p -- "$base/lib/amd64" || return 1
    ln -sfn -- "$base/lib/server" "$base/lib/amd64/server" || return 1
    if [[ "$major" == 17 && "$enabled" == 1 ]]; then
        {
            printf '%s\n' 's%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=true%'
            printf 's%%.*http.proxyHost=.*%%http.proxyHost=%s%%\n' "$host"
            printf 's%%.*http.proxyPort=.*%%http.proxyPort=%s%%\n' "$port"
            printf 's%%.*https.proxyHost=.*%%https.proxyHost=%s%%\n' "$https_host"
            printf 's%%.*https.proxyPort=.*%%https.proxyPort=%s%%\n' "$https_port"
            printf '%s\n' 's%.*http.nonProxyHosts=.*%http.nonProxyHosts=localhost|127.0.0.1|127.0.1.1|[::1]%'
        } | sed -i -f - "$properties"
    elif [[ "$major" == 17 ]]; then
        sed -i \
            -e 's%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=false%' \
            -e 's%.*http.proxyHost=.*%# http.proxyHost=%' \
            -e 's%.*http.proxyPort=.*%# http.proxyPort=80%' \
            -e 's%.*https.proxyHost=.*%# https.proxyHost=%' \
            -e 's%.*https.proxyPort=.*%# https.proxyPort=443%' \
            -e 's%.*http.nonProxyHosts=.*%http.nonProxyHosts=localhost|127.*|[::1]%' "$properties"
    else
        if [[ "$enabled" == 1 ]]; then enabled=true; else enabled=false; fi
        sed -i -e "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=$enabled%" "$properties"
    fi
}

software_apt_preflight_openjdk() {
    local major enabled value
    major="$(software_apt_openjdk_major)" || return 1
    if [[ "$major" == 21 ]]; then enabled="${PROXY_HTTP:-0}"; else enabled="${SYSTEM_PROXY:-0}"; fi
    [[ "$enabled" == 0 || "$enabled" == 1 ]] || return 1
    if [[ "$major" == 17 && "$enabled" == 1 ]]; then
        for value in "${PROXY_HTTP_HOST:-}" "${PROXY_HTTP_PORT:-}" "${PROXY_HTTPS_HOST:-}" "${PROXY_HTTPS_PORT:-}"; do
            [[ -n "$value" ]] || return 1
            software_apt_sed_replacement "$value" >/dev/null || return 1
        done
    fi
}

software_apt_check_openjdk_configuration() {
    local prefix="${1:-}" major base properties enabled actual expected
    local -a required=()
    major="$(software_apt_openjdk_major)" || return 2
    actual="$(software_apt_package_state "openjdk-${major}-jre-headless")" || return 2
    [[ "$actual" == 1 ]] || return 1
    base="${prefix%/}/usr/lib/jvm/java-${major}-openjdk-amd64"
    properties="${prefix%/}/etc/java-${major}-openjdk/net.properties"
    [[ -L "$base/lib/amd64/server" && -d "$base/lib/server" ]] || return 1
    [[ "$(readlink -- "$base/lib/amd64/server")" == "$base/lib/server" ]] || return 1
    [[ -e "$properties" ]] || return 1
    [[ -f "$properties" && -r "$properties" ]] || return 2
    if [[ "$major" == 21 ]]; then enabled="${PROXY_HTTP:-0}"; else enabled="${SYSTEM_PROXY:-0}"; fi
    [[ "$enabled" == 0 || "$enabled" == 1 ]] || return 2
    if [[ "$enabled" == 1 ]]; then required+=( 'java.net.useSystemProxies=true' ); else required+=( 'java.net.useSystemProxies=false' ); fi
    if [[ "$major" == 17 && "$enabled" == 1 ]]; then
        [[ -n "${PROXY_HTTP_HOST:-}" && -n "${PROXY_HTTP_PORT:-}" && -n "${PROXY_HTTPS_HOST:-}" && -n "${PROXY_HTTPS_PORT:-}" ]] || return 2
        required+=("http.proxyHost=$PROXY_HTTP_HOST" "http.proxyPort=$PROXY_HTTP_PORT"
                   "https.proxyHost=$PROXY_HTTPS_HOST" "https.proxyPort=$PROXY_HTTPS_PORT"
                   'http.nonProxyHosts=localhost|127.0.0.1|127.0.1.1|[::1]')
    elif [[ "$major" == 17 ]]; then
        required+=( '# http.proxyHost=' '# http.proxyPort=80' '# https.proxyHost=' '# https.proxyPort=443'
                    'http.nonProxyHosts=localhost|127.*|[::1]' )
    fi
    for expected in "${required[@]}"; do
        software_apt_file_has_line "$properties" "$expected" || return 1
    done
}

software_apt_cleanup_openjdk() { software_apt_cleanup_repository openjdk; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "openjdk" || return 1
fi
