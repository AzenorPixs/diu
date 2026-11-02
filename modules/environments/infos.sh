#!/usr/bin/env bash

environments_infos() {
    printf '\n%s\n%s\n%s\n%s\n%s\n\n' \
        '######################' '######################' '### ENVIRONNEMENTS ###' '######################' '######################'
    printf '%s=%s\n' 'ENVIRONMENTS_DEVOPS' "${ENVIRONMENTS_DEVOPS-UNSET}"
    printf '%s=%s\n' 'ENVIRONMENT_DOCKER' "${ENVIRONMENT_DOCKER-UNSET}"
    printf '%s=%s\n' 'ENVIRONMENT_IA' "${ENVIRONMENT_IA-UNSET}"
}
