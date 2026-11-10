#!/usr/bin/env bash
# Déclare le dépôt APT CrowdSec dans le scope logiciels.
# shellcheck disable=SC2034

config="STATIC"
state="DISABLE"
scope="softwares"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

software_apt_crowdsec_detect() {
    if grep -RqsE 'crowdsec|packagecloud\.io/crowdsec' \
        /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
        printf '1'
    elif [[ "${SOFTWARES_APT_CROWDSEC_AGENT:-0}" == 1 ||
            "${SOFTWARES_APT_CROWDSEC_BOUNCER:-0}" == 1 ]]; then
        printf '1'
    else
        printf '%s' "$default_value"
    fi
}

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${SOFTWARES_APT_CROWDSEC+x}" ]]; then
        default_value="$(software_apt_crowdsec_detect)"
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SOFTWARES_APT_CROWDSEC : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SOFTWARES_APT_CROWDSEC=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_CROWDSEC : persistance impossible.' >&2
            return 1
        fi
        export SOFTWARES_APT_CROWDSEC="$default_value"
    elif [[ "$SOFTWARES_APT_CROWDSEC" =~ ^[01]$ ]]; then
        export SOFTWARES_APT_CROWDSEC
    else
        printf '%s\n' 'SOFTWARES_APT_CROWDSEC : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SOFTWARES_APT_CROWDSEC
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SOFTWARES_APT_CROWDSEC=/d' "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_CROWDSEC : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi
