#!/usr/bin/env bash

desktop_infos() {
    printf '\n%s\n%s\n%s\n%s\n%s\n\n' \
        '###############' '###############' '### DESKTOP ###' '###############' '###############'
    printf '%s=%s\n' 'DESKTOP' "${DESKTOP-UNSET}"
}
