#!/usr/bin/env bash
# Variable déclarative : SYSTEM_DRIVERS_DISPLAY_LINK.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value="UNSET"
variable_config_file="/root/diu/config/${scope}.env"

variable_generator() (
    local package package_status status detected=1

    if ! command -v dpkg-query >/dev/null 2>&1; then
        printf '%s\n' 'SYSTEM_DRIVERS_DISPLAY_LINK : dpkg-query indisponible.' >&2
        printf '%s\n' UNSET
        return 0
    fi

    for package in displaylink-driver evdi-dkms; do
        if package_status="$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null)"; then
            case "$package_status" in
                installed) ;;
                not-installed|config-files|unpacked|half-installed|half-configured|triggers-awaited|triggers-pending)
                    detected=0 ;;
                *)
                    printf 'SYSTEM_DRIVERS_DISPLAY_LINK : état inexploitable du paquet %s.\n' "$package" >&2
                    printf '%s\n' UNSET
                    return 0
                    ;;
            esac
        else
            status=$?
            if [[ "$status" -eq 1 && -z "$package_status" ]]; then
                detected=0
            else
                printf 'SYSTEM_DRIVERS_DISPLAY_LINK : échec de découverte du paquet %s.\n' "$package" >&2
                printf '%s\n' UNSET
                return 0
            fi
        fi
    done

    printf '%s\n' "$detected"
)

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${SYSTEM_DRIVERS_DISPLAY_LINK+x}" ]]; then
        if ! default_value="$(variable_generator)"; then
            printf '%s\n' 'SYSTEM_DRIVERS_DISPLAY_LINK : échec du générateur.' >&2
            return 1
        fi
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_DRIVERS_DISPLAY_LINK : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_DRIVERS_DISPLAY_LINK=%s\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_DRIVERS_DISPLAY_LINK : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_DRIVERS_DISPLAY_LINK="$default_value"
    elif [[ ! "$SYSTEM_DRIVERS_DISPLAY_LINK" =~ ^(0|1|UNSET)$ ]]; then
        printf '%s\n' 'SYSTEM_DRIVERS_DISPLAY_LINK : valeur invalide, attendu 0, 1 ou UNSET.' >&2
        return 1
    else
        export SYSTEM_DRIVERS_DISPLAY_LINK
    fi
else
    unset SYSTEM_DRIVERS_DISPLAY_LINK
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^export SYSTEM_DRIVERS_DISPLAY_LINK=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_DRIVERS_DISPLAY_LINK : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi
