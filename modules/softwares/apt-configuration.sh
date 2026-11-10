#!/usr/bin/env bash

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

software_apt_openjdk_major() {
    case "${SYSTEM_DEBIAN_RELEASE:-}" in
        bullseye|bookworm) printf '17\n' ;;
        trixie) printf '21\n' ;;
        *) printf '%s\n' 'Version Debian non prise en charge pour OpenJDK.' >&2; return 1 ;;
    esac
}

software_apt_sed_replacement() {
    local value="${1-}"
    [[ "$value" != *$'\n'* && "$value" != *$'\r'* ]] || return 1
    value="${value//\\/\\\\}"
    value="${value//&/\\&}"
    value="${value//%/\\%}"
    printf '%s' "$value"
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

software_apt_file_has_line() {
    local file="$1" expected="$2" line
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" == "$expected" ]] && return 0
    done < "$file"
    return 1
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

software_apt_configure_postfix() {
    local prefix="${1:-}" configuration relay
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

software_apt_check_wazuh_server_configuration() {
    local package actual
    for package in wazuh-indexer wazuh-manager filebeat wazuh-dashboard; do
        actual="$(software_apt_package_state "$package")" || return 2
        [[ "$actual" == 1 ]] || return 1
    done
}

software_apt_prepare_wazuh_agent_environment() {
    local manager="${SOFTWARE_APT_WAZUH_AGENT_MANAGER:-}"
    local password="${SOFTWARE_APT_WAZUH_AGENT_REGISTRATION_PASSWORD:-}"
    local group="${SOFTWARE_APT_WAZUH_AGENT_GROUP:-Linux}" protocol="${SOFTWARE_APT_WAZUH_AGENT_PROTOCOL:-UDP}"
    if [[ ! "$manager" =~ ^[A-Za-z0-9._:-]+$ || -z "$password" || "$password" == *$'\n'* || "$password" == *$'\r'* ||
          ! "$group" =~ ^[A-Za-z0-9._-]+$ || ( "$protocol" != UDP && "$protocol" != TCP ) ]]; then
        printf '%s\n' "Paramètres sécurisés d'enregistrement Wazuh absents ou invalides." >&2
        return 1
    fi
    export WAZUH_MANAGER="$manager" WAZUH_REGISTRATION_PASSWORD="$password"
    export WAZUH_AGENT_GROUP="$group" WAZUH_PROTOCOL="$protocol"
}

software_apt_configure_wazuh_agent() {
    systemctl enable wazuh-agent.service || return 1
    systemctl start wazuh-agent.service || return 1
}

software_apt_check_wazuh_agent_configuration() {
    local load_state status
    if ! load_state="$(systemctl show --property=LoadState --value wazuh-agent.service 2>/dev/null)"; then return 2; fi
    [[ "$load_state" == loaded ]] || return 1
    if systemctl is-enabled --quiet wazuh-agent.service; then :; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
    if systemctl is-active --quiet wazuh-agent.service; then return 0; else
        status=$?; [[ "$status" == 3 ]] && return 1; return 2
    fi
}

software_apt_configure_ssh_server() {
    local helper
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/ssh_configuration.py" || return 1
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
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/ssh_configuration.py" || return 2
    if python3 "$helper" check; then :; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
    if ! load_state="$(systemctl show --property=LoadState --value ssh.service 2>/dev/null)"; then return 2; fi
    [[ "$load_state" == loaded ]] || return 1
    if systemctl is-active --quiet ssh.service; then return 0; else
        status=$?; [[ "$status" == 3 ]] && return 1; return 2
    fi
}

software_apt_zsh_root_shell() {
    local record shell
    record="$(getent passwd root)" || return 2
    [[ "$record" == root:*:*:*:*:*:* ]] || return 2
    shell="${record##*:}"
    [[ "$shell" == /* ]] || return 2
    printf '%s\n' "$shell"
}

software_apt_zsh_go_inputs() {
    local user="${ENV_DEVOPS_USER:-}" go_binary
    [[ "${GO:-0}" == 0 || "${GO:-0}" == 1 ]] || return 2
    [[ "${GO:-0}" == 1 ]] || return 0
    [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]] || return 2
    [[ -x "/home/$user/go/bin/sesh" ]] && return 0
    go_binary="/home/$user/go/current/bin/go"
    [[ -x "$go_binary" ]] || return 2
}

software_apt_preflight_zsh() {
    local shell
    shell="$(software_apt_zsh_root_shell)" || return 1
    case "$shell" in
        /bin/bash|/usr/bin/bash|*/zsh) ;;
        *) printf '%s\n' 'Shell root personnalisé : configuration Zsh non appliquée.' >&2; return 1 ;;
    esac
    software_apt_zsh_go_inputs
}

software_apt_configure_zsh() {
    local prefix="${1:-/}" shell binary helper user
    software_apt_preflight_zsh || return 1
    shell="$(software_apt_zsh_root_shell)" || return 1
    if [[ "${GO:-0}" == 1 ]]; then
        user="$ENV_DEVOPS_USER"
        if [[ ! -x "/home/$user/go/bin/sesh" ]]; then
            runuser -u "$user" -- env HOME="/home/$user" GOPATH="/home/$user/go" \
                "/home/$user/go/current/bin/go" install github.com/joshmedeski/sesh@latest || return 1
        fi
    fi
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/zsh_configuration.py" || return 1
    python3 "$helper" configure "$prefix" || return 1
    case "$shell" in
        /bin/bash|/usr/bin/bash)
            binary="$(command -v zsh)" || return 1
            [[ "$binary" == /* && -x "$binary" ]] || return 1
            chsh -s "$binary" root || return 1
            ;;
    esac
}

software_apt_check_zsh_configuration() {
    local prefix="${1:-/}" shell helper status user
    shell="$(software_apt_zsh_root_shell)" || return 2
    case "$shell" in
        */zsh) ;;
        /bin/bash|/usr/bin/bash) return 1 ;;
        *) return 2 ;;
    esac
    software_apt_zsh_go_inputs || return 2
    if [[ "${GO:-0}" == 1 ]]; then
        user="$ENV_DEVOPS_USER"
        [[ -x "/home/$user/go/bin/sesh" ]] || return 1
    fi
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/zsh_configuration.py" || return 2
    if python3 "$helper" check "$prefix"; then return 0; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
}

software_apt_prepare_zsh_removal() {
    local records record account shell root_shell='' bash_binary root_seen=0
    records="$(getent passwd)" || return 1
    while IFS= read -r record; do
        account="${record%%:*}"
        shell="${record##*:}"
        if [[ "$account" == root ]]; then (( root_seen += 1 )); fi
        if [[ "$shell" == */zsh ]]; then
            if [[ "$account" == root ]]; then root_shell="$shell"; else
                printf '%s\n' 'Un autre compte utilise Zsh ; retrait automatique refusé.' >&2
                return 1
            fi
        fi
    done <<< "$records"
    [[ "$root_seen" == 1 ]] || return 1
    if [[ -n "$root_shell" ]]; then
        bash_binary="$(command -v bash)" || return 1
        [[ "$bash_binary" == /* && -x "$bash_binary" ]] || return 1
        chsh -s "$bash_binary" root || return 1
        root_shell="$(software_apt_zsh_root_shell)" || return 1
        [[ "$root_shell" == "$bash_binary" ]] || return 1
    fi
}
