#!/usr/bin/env bash

softwares_infos() {
    printf '\n%s\n%s\n%s\n%s\n%s\n\n' \
        '#################' '#################' '### SOFTWARES ###' '#################' '#################'
    printf '%s=%s\n' 'SOFTWARES_APT_CROWDSEC' "${SOFTWARES_APT_CROWDSEC-UNSET}"
    printf '%s=%s\n' 'SOFTWARES_APT_CROWDSEC_AGENT' "${SOFTWARES_APT_CROWDSEC_AGENT-UNSET}"
    printf '%s=%s\n' 'SOFTWARES_APT_CROWDSEC_BOUNCER' "${SOFTWARES_APT_CROWDSEC_BOUNCER-UNSET}"
}
