#!/usr/bin/env bash
# Variable déclarative : SYSTEM_TIME_ZONE.
# shellcheck disable=SC2034

# Configuration
# STATIC / DYNAMIC
config="STATIC"

# État
# ENABLE / DISABLE
state="ENABLE"

# Scope
scope="system"

# Valeur par défaut
# Repli lorsque le fuseau horaire local ne peut pas être récupéré.
default_value="Europe/Paris"
variable_config_file="/root/diu/config/${scope}.env"

variable_generator() (
    local time_zone

    if time_zone="$(timedatectl show --property=Timezone --value 2>/dev/null)" && [[ -n "$time_zone" ]]; then
        printf '%s\n' "$time_zone"
    else
        printf 'SYSTEM_TIME_ZONE : fuseau local indisponible, repli sur %s.\n' "$default_value" >&2
        printf '%s\n' "$default_value"
    fi
)

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${SYSTEM_TIME_ZONE+x}" ]]; then
        if ! default_value="$(variable_generator)"; then
            printf '%s\n' 'SYSTEM_TIME_ZONE : échec du générateur.' >&2
            return 1
        fi
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_TIME_ZONE : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_TIME_ZONE=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_TIME_ZONE : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_TIME_ZONE="$default_value"
    else
        export SYSTEM_TIME_ZONE
    fi
else
    unset SYSTEM_TIME_ZONE
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^export SYSTEM_TIME_ZONE=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_TIME_ZONE : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi
