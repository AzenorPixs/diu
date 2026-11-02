#!/usr/bin/env bash

environments_infos() {
    printf '\n%s\n%s\n%s\n%s\n%s\n\n' \
        '######################' '######################' '### ENVIRONNEMENTS ###' '######################' '######################'
    printf '%s=%s\n' 'ENVIRONMENTS_DEVOPS' "${ENVIRONMENTS_DEVOPS-UNSET}"
}
