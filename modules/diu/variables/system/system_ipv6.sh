#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=''
variable_config_file="/root/diu/config/${scope}.env"

variable_generator() (
    local disable_ipv6

    if ! disable_ipv6="$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null)"; then
        printf '%s\n' "SYSTEM_IPV6 : lecture de l'état IPv6 par sysctl impossible." >&2
        return 1
    fi

    case "$disable_ipv6" in
        0) printf '%s\n' 1 ;;
        1) printf '%s\n' 0 ;;
        *)
            printf '%s\n' 'SYSTEM_IPV6 : sysctl a retourné une valeur invalide pour disable_ipv6.' >&2
            return 1
            ;;
    esac
)

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_IPV6+x}" ]]; then
        if ! default_value="$(variable_generator)"; then
            printf '%s\n' 'SYSTEM_IPV6 : échec du générateur.' >&2
            return 1
        fi
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_IPV6 : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_IPV6=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_IPV6 : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_IPV6="$default_value"
    elif [[ "$SYSTEM_IPV6" =~ ^[01]$ ]]; then
        export SYSTEM_IPV6
    else
        printf '%s\n' 'SYSTEM_IPV6 : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SYSTEM_IPV6
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_IPV6=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_IPV6 : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi
