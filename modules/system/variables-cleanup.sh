#!/usr/bin/env bash

# Supprime les affectations historiques avant de charger la configuration locale.
config_cleanup_parse_fstab_literal() {
    local raw_value="${1-}" quote='' character remainder value='' closed=0

    while [[ "$raw_value" == [[:blank:]]* ]]; do
        raw_value="${raw_value:1}"
    done

    case "$raw_value" in
        \"*) quote='"'; raw_value="${raw_value:1}" ;;
        \'*) quote="'"; raw_value="${raw_value:1}" ;;
        *)
            if [[ "$raw_value" =~ ^([[:alnum:]_./:=+,-]*)[[:blank:]]*(#.*)?$ ]]; then
                REPLY="${BASH_REMATCH[1]}"
                return 0
            fi
            return 1
            ;;
    esac

    while [[ -n "$raw_value" ]]; do
        character="${raw_value:0:1}"
        raw_value="${raw_value:1}"
        if [[ "$character" == "$quote" ]]; then
            closed=1
            break
        fi
        value+="$character"
    done

    [[ "$closed" == 1 ]] || return 1
    remainder="$raw_value"
    [[ "$remainder" =~ ^[[:blank:]]*(#.*)?$ ]] || return 1
    if [[ "$quote" == '"' ]] &&
        [[ "$value" == *'$'* || "$value" == *'`'* || "$value" == *\\* ]]; then
        return 1
    fi
    REPLY="$value"
}

config_cleanup_parse_secret_literal() {
    local raw_value="${1-}" secret_value
    if [[ "$raw_value" =~ ^[[:blank:]]*\"([[:alnum:]_./:+@=-]+)\"[[:blank:]]*(#.*)?$ ]]; then
        secret_value="${BASH_REMATCH[1]}"
    elif [[ "$raw_value" =~ ^[[:blank:]]*\'([[:alnum:]_./:+@=-]+)\'[[:blank:]]*(#.*)?$ ]]; then
        secret_value="${BASH_REMATCH[1]}"
    elif [[ "$raw_value" =~ ^[[:blank:]]*([[:alnum:]_./:+@=-]+)[[:blank:]]*(#.*)?$ ]]; then
        secret_value="${BASH_REMATCH[1]}"
    else
        return 1
    fi
    [[ "$secret_value" =~ ^[[:alnum:]_./:+@=-]+$ ]] || return 1
    REPLY="$secret_value"
}

config_cleanup() {
    local variables_file="${1:-/root/diu/variables.sh}"
    local system_config_file="${2:-/root/diu/config/system.env}"
    local softwares_config_file="${3:-/root/diu/config/softwares.env}"
    local desktop_config_file="${4:-/root/diu/config/desktop.env}"
    local environnements_config_file="${5:-/root/diu/config/environnements.env}"
    local docker_config_file="${6:-/root/diu/config/docker.env}"
    local legacy_assignment='^[[:blank:]]*(export[[:blank:]]+)?(DEBIAN_RELEASE|DEBIAN_TYPE|DISPLAY_LINK|TIME_ZONE|PROXY_CA|PROXY|DRIVERS_NVIDIA|FSTAB_CONFIG[1-6]|FSTAB|FILES2RAM|GRUB_CONFIG|IPv6|LOG_ROTATE|JOURNALD_MAX_USE|JOURNALD_KEEP_FREE|NO_SLEEP|DESKTOP|ENV_DEVOPS|ENV_DOCKER|ENV_IA|DOCKER_USER|APACHE2|FASTFETCH|JSVC|LEMONLDAP|MONGODB|OPENJDK|OMADA|OPENVSWITCH|POSTGRESQL|CROWDSEC_AGENT|SYSTEM_CROWDSEC_AGENT|CROWDSEC_BOUNCER|CROWDSEC_BOUNCER_API_KEY|SYSTEM_APT_CROWDSEC)='
    local status line proxy_value='' proxy_found=0 system_proxy_declared=0
    local nvidia_value='' nvidia_found=0 system_nvidia_declared=0
    local fstab_value='' fstab_found=0 system_fstab_declared=0
    local files2ram_value='' files2ram_found=0 system_files2ram_declared=0
    local grub_config_value='' grub_config_found=0 system_grub_config_declared=0
    local ipv6_value='' ipv6_found=0 system_ipv6_declared=0
    local log_rotate_value='' log_rotate_found=0 system_log_rotate_declared=0
    local journald_max_use_value='' journald_max_use_found=0 system_journald_max_use_declared=0
    local journald_keep_free_value='' journald_keep_free_found=0 system_journald_keep_free_declared=0
    local no_sleep_value='' no_sleep_found=0 system_no_sleep_declared=0
    local desktop_value='' desktop_found=0 desktop_config_declared=0
    local software_desktop_value='' software_desktop_found=0 software_desktop_lines=''
    local env_devops_value='' env_devops_found=0 environments_devops_declared=0
    local env_devops_config_value='' env_devops_config_found=0 env_devops_config_lines=''
    local env_docker_value='' env_docker_found=0 environment_docker_declared=0
    local env_docker_config_value='' env_docker_config_found=0 env_docker_config_lines=''
    local env_ia_value='' env_ia_found=0 environment_ia_declared=0
    local env_ia_config_value='' env_ia_config_found=0 env_ia_config_lines=''
    local docker_user_value='' docker_user_found=0 environment_docker_user_declared=0
    local old_docker_user_value='' old_docker_user_found=0 old_docker_user_lines=''
    local apache2_value='' apache2_found=0 softwares_apache2_declared=0
    local fastfetch_value='' fastfetch_found=0 softwares_apt_fastfetch_declared=0
    local jsvc_value='' jsvc_found=0 softwares_apt_jsvc_declared=0
    local lemonldap_value='' lemonldap_found=0 softwares_apt_lemonldap_declared=0
    local mongodb_value='' mongodb_found=0 softwares_apt_mongodb_declared=0
    local openjdk_value='' openjdk_found=0 softwares_apt_openjdk_declared=0
    local omada_value='' omada_found=0 softwares_apt_omada_declared=0
    local openvswitch_value='' openvswitch_found=0 softwares_apt_openvswitch_declared=0
    local postgresql_value='' postgresql_found=0 softwares_apt_postgresql_declared=0
    local crowdsec_agent_value='' crowdsec_agent_found=0
    local system_crowdsec_agent_value='' system_crowdsec_agent_found=0
    local softwares_crowdsec_agent_declared=0
    local crowdsec_bouncer_value='' crowdsec_bouncer_found=0 softwares_crowdsec_bouncer_declared=0
    local apt_crowdsec_value='' apt_crowdsec_found=0 softwares_apt_crowdsec_declared=0
    local crowdsec_api_key_value='' crowdsec_api_key_found=0 softwares_crowdsec_api_key_declared=0
    local fstab_config_number fstab_config_value fstab_migration_found=0
    local fstab_config_migration_needed=0
    local REPLY
    local -a fstab_config_values=() fstab_config_found=(0 0 0 0 0 0 0)
    local -a fstab_config_declared=(0 0 0 0 0 0 0)

    if [[ -e "$variables_file" ]]; then
        if [[ ! -f "$variables_file" || ! -r "$variables_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration historique impossible.' >&2
            return 1
        fi

        while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?PROXY= ]]; then
            proxy_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?PROXY=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                proxy_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique PROXY ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DRIVERS_NVIDIA= ]]; then
            nvidia_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DRIVERS_NVIDIA=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                nvidia_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique DRIVERS_NVIDIA ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?FSTAB= ]]; then
            fstab_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?FSTAB=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                fstab_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique FSTAB ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?FILES2RAM= ]]; then
            files2ram_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?FILES2RAM=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                files2ram_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique FILES2RAM ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?GRUB_CONFIG= ]]; then
            grub_config_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?GRUB_CONFIG=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                grub_config_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique GRUB_CONFIG ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?IPv6= ]]; then
            ipv6_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?IPv6=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                ipv6_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique IPv6 ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?LOG_ROTATE= ]]; then
            log_rotate_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?LOG_ROTATE=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                log_rotate_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique LOG_ROTATE ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?JOURNALD_MAX_USE= ]]; then
            journald_max_use_found=1
            if config_cleanup_parse_fstab_literal "${line#*=}" &&
                [[ "$REPLY" =~ ^[0-9]+[KMGTPE]?$ ]]; then
                journald_max_use_value="$REPLY"
            else
                printf '%s\n' 'Erreur : affectation historique JOURNALD_MAX_USE ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?JOURNALD_KEEP_FREE= ]]; then
            journald_keep_free_found=1
            if config_cleanup_parse_fstab_literal "${line#*=}" &&
                [[ "$REPLY" =~ ^[0-9]+[KMGTPE]?$ ]]; then
                journald_keep_free_value="$REPLY"
            else
                printf '%s\n' 'Erreur : affectation historique JOURNALD_KEEP_FREE ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?NO_SLEEP= ]]; then
            no_sleep_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?NO_SLEEP=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                no_sleep_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique NO_SLEEP ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_DEVOPS= ]]; then
            env_devops_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_DEVOPS=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                env_devops_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique ENV_DEVOPS ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_DOCKER= ]]; then
            env_docker_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_DOCKER=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                env_docker_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique ENV_DOCKER ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_IA= ]]; then
            env_ia_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_IA=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                env_ia_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique ENV_IA ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DOCKER_USER= ]]; then
            docker_user_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DOCKER_USER=([[:blank:]]*)([a-z_][a-z0-9_-]*)[[:blank:]]*(#.*)?$ ]]; then
                docker_user_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique DOCKER_USER ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DESKTOP= ]]; then
            desktop_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DESKTOP=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                desktop_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique DESKTOP ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?APACHE2= ]]; then
            apache2_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?APACHE2=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                apache2_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique APACHE2 ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?FASTFETCH= ]]; then
            fastfetch_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?FASTFETCH=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                fastfetch_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique FASTFETCH ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?JSVC= ]]; then
            jsvc_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?JSVC=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                jsvc_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique JSVC ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?LEMONLDAP= ]]; then
            lemonldap_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?LEMONLDAP=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                lemonldap_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique LEMONLDAP ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?MONGODB= ]]; then
            mongodb_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?MONGODB=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                mongodb_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique MONGODB ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?OPENJDK= ]]; then
            openjdk_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?OPENJDK=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                openjdk_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique OPENJDK ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?OMADA= ]]; then
            omada_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?OMADA=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                omada_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique OMADA ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?OPENVSWITCH= ]]; then
            openvswitch_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?OPENVSWITCH=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                openvswitch_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique OPENVSWITCH ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?POSTGRESQL= ]]; then
            postgresql_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?POSTGRESQL=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                postgresql_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique POSTGRESQL ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?(CROWDSEC_AGENT|SYSTEM_CROWDSEC_AGENT)= ]]; then
            crowdsec_agent_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?(CROWDSEC_AGENT|SYSTEM_CROWDSEC_AGENT)=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                crowdsec_agent_value="${BASH_REMATCH[4]}"
            else
                printf '%s\n' 'Erreur : affectation historique CrowdSec agent ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?CROWDSEC_BOUNCER= ]]; then
            crowdsec_bouncer_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?CROWDSEC_BOUNCER=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                crowdsec_bouncer_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique CROWDSEC_BOUNCER ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_APT_CROWDSEC= ]]; then
            apt_crowdsec_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_APT_CROWDSEC=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                apt_crowdsec_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique SYSTEM_APT_CROWDSEC ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?CROWDSEC_BOUNCER_API_KEY= ]]; then
            crowdsec_api_key_found=1
            if config_cleanup_parse_secret_literal "${line#*=}"; then
                crowdsec_api_key_value="$REPLY"
            else
                printf '%s\n' 'Erreur : ancienne clé CrowdSec ambiguë ; nettoyage impossible.' >&2
                return 1
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?FSTAB_CONFIG([1-6])= ]]; then
            fstab_config_number="${BASH_REMATCH[2]}"
            fstab_config_found["$fstab_config_number"]=1
            if config_cleanup_parse_fstab_literal "${line#*=}"; then
                fstab_config_values["$fstab_config_number"]="$REPLY"
            else
                printf 'Erreur : affectation historique FSTAB_CONFIG%s ambiguë ; nettoyage impossible.\n' \
                    "$fstab_config_number" >&2
                return 1
            fi
        fi
        done < "$variables_file"
    fi

    if [[ -e "$system_config_file" ]]; then
        if [[ ! -f "$system_config_file" || ! -r "$system_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
            return 1
        fi
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_CROWDSEC_AGENT= ]]; then
                system_crowdsec_agent_found=1
                if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_CROWDSEC_AGENT=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                    system_crowdsec_agent_value="${BASH_REMATCH[3]}"
                else
                    printf '%s\n' 'Erreur : ancienne déclaration SYSTEM_CROWDSEC_AGENT ambiguë ; nettoyage impossible.' >&2
                    return 1
                fi
            fi
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_APT_CROWDSEC= ]]; then
                apt_crowdsec_found=1
                if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_APT_CROWDSEC=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                    apt_crowdsec_value="${BASH_REMATCH[3]}"
                else
                    printf '%s\n' 'Erreur : ancienne déclaration SYSTEM_APT_CROWDSEC ambiguë ; nettoyage impossible.' >&2
                    return 1
                fi
            fi
        done < "$system_config_file"
    fi
    if [[ "$system_crowdsec_agent_found" == 1 ]]; then
        crowdsec_agent_found=1
        crowdsec_agent_value="$system_crowdsec_agent_value"
    fi

    if [[ -e "$desktop_config_file" ]]; then
        if [[ ! -f "$desktop_config_file" || ! -r "$desktop_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration bureau impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?DESKTOP=' "$desktop_config_file" > /dev/null 2>&1; then
            desktop_config_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration bureau impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if software_desktop_lines="$(grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_DESKTOP=' "$softwares_config_file")"; then
            while IFS= read -r line; do
                software_desktop_found=1
                if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_DESKTOP=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                    software_desktop_value="${BASH_REMATCH[3]}"
                else
                    printf '%s\n' 'Erreur : ancienne déclaration SOFTWARES_APT_DESKTOP ambiguë ; nettoyage impossible.' >&2
                    return 1
                fi
            done <<< "$software_desktop_lines"
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$software_desktop_found" == 1 ]]; then
        desktop_found=1
        desktop_value="$software_desktop_value"
    fi
    if [[ -e "$environnements_config_file" ]]; then
        if [[ ! -f "$environnements_config_file" || ! -r "$environnements_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration environnements impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?ENVIRONMENTS_DEVOPS=' \
            "$environnements_config_file" > /dev/null 2>&1; then
            environments_devops_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration environnements impossible.' >&2
                return 1
            fi
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?ENVIRONMENT_DOCKER=' \
            "$environnements_config_file" > /dev/null 2>&1; then
            environment_docker_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration environnements impossible.' >&2
                return 1
            fi
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?ENVIRONMENT_IA=' \
            "$environnements_config_file" > /dev/null 2>&1; then
            environment_ia_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration environnements impossible.' >&2
                return 1
            fi
        fi
        if env_devops_config_lines="$(grep -E '^[[:blank:]]*(export[[:blank:]]+)?ENV_DEVOPS=' "$environnements_config_file")"; then
            while IFS= read -r line; do
                env_devops_config_found=1
                if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_DEVOPS=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                    env_devops_config_value="${BASH_REMATCH[3]}"
                else
                    printf '%s\n' 'Erreur : ancienne déclaration ENV_DEVOPS ambiguë ; nettoyage impossible.' >&2
                    return 1
                fi
            done <<< "$env_devops_config_lines"
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration environnements impossible.' >&2
                return 1
            fi
        fi
        if env_ia_config_lines="$(grep -E '^[[:blank:]]*(export[[:blank:]]+)?ENV_IA=' "$environnements_config_file")"; then
            while IFS= read -r line; do
                env_ia_config_found=1
                if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_IA=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                    env_ia_config_value="${BASH_REMATCH[3]}"
                else
                    printf '%s\n' 'Erreur : ancienne déclaration ENV_IA ambiguë ; nettoyage impossible.' >&2
                    return 1
                fi
            done <<< "$env_ia_config_lines"
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration environnements impossible.' >&2
                return 1
            fi
        fi
        if env_docker_config_lines="$(grep -E '^[[:blank:]]*(export[[:blank:]]+)?ENV_DOCKER=' "$environnements_config_file")"; then
            while IFS= read -r line; do
                env_docker_config_found=1
                if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_DOCKER=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                    env_docker_config_value="${BASH_REMATCH[3]}"
                else
                    printf '%s\n' 'Erreur : ancienne déclaration ENV_DOCKER ambiguë ; nettoyage impossible.' >&2
                    return 1
                fi
            done <<< "$env_docker_config_lines"
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration environnements impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$env_devops_config_found" == 1 ]]; then
        env_devops_found=1
        env_devops_value="$env_devops_config_value"
    fi
    if [[ "$env_docker_config_found" == 1 ]]; then
        env_docker_found=1
        env_docker_value="$env_docker_config_value"
    fi
    if [[ "$env_ia_config_found" == 1 ]]; then
        env_ia_found=1
        env_ia_value="$env_ia_config_value"
    fi
    if [[ -e "$docker_config_file" ]]; then
        if [[ ! -f "$docker_config_file" || ! -r "$docker_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration Docker impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?ENVIRONMENT_DOCKER_USER=' \
            "$docker_config_file" > /dev/null 2>&1; then
            environment_docker_user_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration Docker impossible.' >&2
                return 1
            fi
        fi
        if old_docker_user_lines="$(grep -E '^[[:blank:]]*(export[[:blank:]]+)?DOCKER_USER=' "$docker_config_file")"; then
            while IFS= read -r line; do
                old_docker_user_found=1
                if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DOCKER_USER=([[:blank:]]*)([a-z_][a-z0-9_-]*)[[:blank:]]*(#.*)?$ ]]; then
                    old_docker_user_value="${BASH_REMATCH[3]}"
                else
                    printf '%s\n' 'Erreur : ancienne déclaration DOCKER_USER ambiguë ; nettoyage impossible.' >&2
                    return 1
                fi
            done <<< "$old_docker_user_lines"
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration Docker impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$old_docker_user_found" == 1 ]]; then
        docker_user_found=1
        docker_user_value="$old_docker_user_value"
    fi

    if [[ "$fstab_found" == 1 ]]; then
        fstab_migration_found=1
    fi
    if [[ "$files2ram_found" == 1 ]]; then
        fstab_migration_found=1
    fi
    for fstab_config_number in 1 2 3 4 5 6; do
        if [[ "${fstab_config_found[$fstab_config_number]}" == 1 ]]; then
            fstab_migration_found=1
        fi
    done

    if [[ ( "$proxy_found" == 1 || "$nvidia_found" == 1 || "$grub_config_found" == 1 || "$ipv6_found" == 1 || "$log_rotate_found" == 1 || "$journald_max_use_found" == 1 || "$journald_keep_free_found" == 1 || "$no_sleep_found" == 1 || "$crowdsec_agent_found" == 1 || "$fstab_migration_found" == 1 ) &&
          -e "$system_config_file" ]]; then
        if [[ ! -f "$system_config_file" || ! -r "$system_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
            return 1
        fi
        if [[ "$proxy_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_PROXY=' "$system_config_file" > /dev/null 2>&1; then
                system_proxy_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$nvidia_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_DRIVERS_NVIDIA=' "$system_config_file" > /dev/null 2>&1; then
                system_nvidia_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$fstab_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_FSTAB=' "$system_config_file" > /dev/null 2>&1; then
                system_fstab_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$files2ram_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_FILES2RAM=' "$system_config_file" > /dev/null 2>&1; then
                system_files2ram_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$grub_config_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_GRUB_CONFIG=' "$system_config_file" > /dev/null 2>&1; then
                system_grub_config_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$ipv6_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_IPV6=' "$system_config_file" > /dev/null 2>&1; then
                system_ipv6_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$log_rotate_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_LOG_ROTATE=' "$system_config_file" > /dev/null 2>&1; then
                system_log_rotate_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$journald_max_use_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_JOURNALD_MAX_USE=' "$system_config_file" > /dev/null 2>&1; then
                system_journald_max_use_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$journald_keep_free_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_JOURNALD_KEEP_FREE=' "$system_config_file" > /dev/null 2>&1; then
                system_journald_keep_free_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        if [[ "$no_sleep_found" == 1 ]]; then
            if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_NO_SLEEP=' "$system_config_file" > /dev/null 2>&1; then
                system_no_sleep_declared=1
            else
                status=$?
                if [[ "$status" -ne 1 ]]; then
                    printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                    return 1
                fi
            fi
        fi
        for fstab_config_number in 1 2 3 4 5 6; do
            if [[ "${fstab_config_found[$fstab_config_number]}" == 1 ]]; then
                if grep -E "^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_FSTAB_CONFIG${fstab_config_number}=" \
                    "$system_config_file" > /dev/null 2>&1; then
                    fstab_config_declared["$fstab_config_number"]=1
                else
                    status=$?
                    if [[ "$status" -ne 1 ]]; then
                        printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                        return 1
                    fi
                fi
            fi
        done
    fi

    if [[ "$apache2_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_APACHE2=' \
            "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apache2_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$fastfetch_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_FASTFETCH=' \
            "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_fastfetch_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$jsvc_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_JSVC=' \
            "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_jsvc_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$lemonldap_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_LEMONLDAP=' "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_lemonldap_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$mongodb_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_MONGODB=' "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_mongodb_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$openjdk_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_OPENJDK=' "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_openjdk_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$omada_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_OMADA=' "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_omada_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$openvswitch_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_OPENVSWITCH=' "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_openvswitch_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$postgresql_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_POSTGRESQL=' "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_postgresql_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$crowdsec_agent_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_CROWDSEC_AGENT=' \
            "$softwares_config_file" > /dev/null 2>&1; then
            softwares_crowdsec_agent_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$crowdsec_bouncer_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_CROWDSEC_BOUNCER=' \
            "$softwares_config_file" > /dev/null 2>&1; then
            softwares_crowdsec_bouncer_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$apt_crowdsec_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_CROWDSEC=' \
            "$softwares_config_file" > /dev/null 2>&1; then
            softwares_apt_crowdsec_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$crowdsec_api_key_found" == 1 && -e "$softwares_config_file" ]]; then
        if [[ ! -f "$softwares_config_file" || ! -r "$softwares_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_CROWDSEC_BOUNCER_API_KEY=' \
            "$softwares_config_file" > /dev/null 2>&1; then
            softwares_crowdsec_api_key_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi

    for fstab_config_number in 1 2 3 4 5 6; do
        if [[ "${fstab_config_found[$fstab_config_number]}" == 1 &&
              "${fstab_config_declared[$fstab_config_number]}" == 0 ]]; then
            fstab_config_migration_needed=1
        fi
    done

    if [[ ( "$proxy_found" == 1 && "$system_proxy_declared" == 0 ) ||
          ( "$nvidia_found" == 1 && "$system_nvidia_declared" == 0 ) ||
          ( "$fstab_found" == 1 && "$system_fstab_declared" == 0 ) ||
          ( "$files2ram_found" == 1 && "$system_files2ram_declared" == 0 ) ||
          ( "$grub_config_found" == 1 && "$system_grub_config_declared" == 0 ) ||
          ( "$ipv6_found" == 1 && "$system_ipv6_declared" == 0 ) ||
          ( "$log_rotate_found" == 1 && "$system_log_rotate_declared" == 0 ) ||
          ( "$journald_max_use_found" == 1 && "$system_journald_max_use_declared" == 0 ) ||
          ( "$journald_keep_free_found" == 1 && "$system_journald_keep_free_declared" == 0 ) ||
          ( "$no_sleep_found" == 1 && "$system_no_sleep_declared" == 0 ) ||
          "$fstab_config_migration_needed" == 1 ]]; then
        if ! install -d -m 0755 "$(dirname "$system_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration système impossible.' >&2
            return 1
        fi
    fi
    if [[ "$apache2_found" == 1 && "$softwares_apache2_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$fastfetch_found" == 1 && "$softwares_apt_fastfetch_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$jsvc_found" == 1 && "$softwares_apt_jsvc_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$desktop_found" == 1 && "$desktop_config_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$desktop_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration bureau impossible.' >&2
            return 1
        fi
    fi
    if [[ "$env_devops_found" == 1 && "$environments_devops_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$environnements_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration environnements impossible.' >&2
            return 1
        fi
    fi
    if [[ "$env_docker_found" == 1 && "$environment_docker_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$environnements_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration environnements impossible.' >&2
            return 1
        fi
    fi
    if [[ "$env_ia_found" == 1 && "$environment_ia_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$environnements_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration environnements impossible.' >&2
            return 1
        fi
    fi
    if [[ "$docker_user_found" == 1 && "$environment_docker_user_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$docker_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration Docker impossible.' >&2
            return 1
        fi
    fi
    if [[ "$crowdsec_bouncer_found" == 1 && "$softwares_crowdsec_bouncer_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$lemonldap_found" == 1 && "$softwares_apt_lemonldap_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$mongodb_found" == 1 && "$softwares_apt_mongodb_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$openjdk_found" == 1 && "$softwares_apt_openjdk_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$omada_found" == 1 && "$softwares_apt_omada_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$openvswitch_found" == 1 && "$softwares_apt_openvswitch_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$postgresql_found" == 1 && "$softwares_apt_postgresql_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$crowdsec_agent_found" == 1 && "$softwares_crowdsec_agent_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$apt_crowdsec_found" == 1 && "$softwares_apt_crowdsec_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
    fi
    if [[ "$crowdsec_api_key_found" == 1 && "$softwares_crowdsec_api_key_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$softwares_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
            return 1
        fi
        if [[ -e "$softwares_config_file" ]]; then
            if ! chmod 0600 "$softwares_config_file"; then
                printf '%s\n' 'Erreur : sécurisation de la configuration logiciels impossible.' >&2
                return 1
            fi
        else
            if ! (umask 077 && : > "$softwares_config_file"); then
                printf '%s\n' 'Erreur : création de la configuration logiciels impossible.' >&2
                return 1
            fi
            if ! chmod 0600 "$softwares_config_file"; then
                printf '%s\n' 'Erreur : sécurisation de la configuration logiciels impossible.' >&2
                return 1
            fi
        fi
    fi
    if [[ "$proxy_found" == 1 && "$system_proxy_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_PROXY=%s\n' "$proxy_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration proxy impossible.' >&2
            return 1
        fi
    fi
    if [[ "$nvidia_found" == 1 && "$system_nvidia_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_DRIVERS_NVIDIA=%s\n' "$nvidia_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration NVIDIA impossible.' >&2
            return 1
        fi
    fi
    if [[ "$fstab_found" == 1 && "$system_fstab_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_FSTAB=%s\n' "$fstab_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration FSTAB impossible.' >&2
            return 1
        fi
    fi
    if [[ "$files2ram_found" == 1 && "$system_files2ram_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_FILES2RAM=%s\n' "$files2ram_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration FILES2RAM impossible.' >&2
            return 1
        fi
    fi
    if [[ "$grub_config_found" == 1 && "$system_grub_config_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_GRUB_CONFIG=%s\n' "$grub_config_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration GRUB impossible.' >&2
            return 1
        fi
    fi
    if [[ "$ipv6_found" == 1 && "$system_ipv6_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_IPV6=%s\n' "$ipv6_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration IPv6 impossible.' >&2
            return 1
        fi
    fi
    if [[ "$log_rotate_found" == 1 && "$system_log_rotate_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_LOG_ROTATE=%s\n' "$log_rotate_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration LOG_ROTATE impossible.' >&2
            return 1
        fi
    fi
    if [[ "$journald_max_use_found" == 1 && "$system_journald_max_use_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_JOURNALD_MAX_USE=%q\n' "$journald_max_use_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration JOURNALD_MAX_USE impossible.' >&2
            return 1
        fi
    fi
    if [[ "$journald_keep_free_found" == 1 && "$system_journald_keep_free_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_JOURNALD_KEEP_FREE=%q\n' "$journald_keep_free_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration JOURNALD_KEEP_FREE impossible.' >&2
            return 1
        fi
    fi
    if [[ "$no_sleep_found" == 1 && "$system_no_sleep_declared" == 0 ]]; then
        if ! printf 'export SYSTEM_NO_SLEEP=%s\n' "$no_sleep_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration NO_SLEEP impossible.' >&2
            return 1
        fi
    fi
    if [[ "$lemonldap_found" == 1 && "$softwares_apt_lemonldap_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_LEMONLDAP=%s\n' "$lemonldap_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration LEMONLDAP impossible.' >&2
            return 1
        fi
    fi
    if [[ "$mongodb_found" == 1 && "$softwares_apt_mongodb_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_MONGODB=%s\n' "$mongodb_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration MONGODB impossible.' >&2
            return 1
        fi
    fi
    if [[ "$openjdk_found" == 1 && "$softwares_apt_openjdk_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_OPENJDK=%s\n' "$openjdk_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration OPENJDK impossible.' >&2
            return 1
        fi
    fi
    if [[ "$omada_found" == 1 && "$softwares_apt_omada_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_OMADA=%s\n' "$omada_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration OMADA impossible.' >&2
            return 1
        fi
    fi
    if [[ "$openvswitch_found" == 1 && "$softwares_apt_openvswitch_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_OPENVSWITCH=%s\n' "$openvswitch_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration OPENVSWITCH impossible.' >&2
            return 1
        fi
    fi
    if [[ "$postgresql_found" == 1 && "$softwares_apt_postgresql_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_POSTGRESQL=%s\n' "$postgresql_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration POSTGRESQL impossible.' >&2
            return 1
        fi
    fi
    if [[ "$crowdsec_agent_found" == 1 && "$softwares_crowdsec_agent_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_CROWDSEC_AGENT=%s\n' "$crowdsec_agent_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration CROWDSEC_AGENT impossible.' >&2
            return 1
        fi
    fi
    if [[ "$apache2_found" == 1 && "$softwares_apache2_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_APACHE2=%s\n' "$apache2_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration APACHE2 impossible.' >&2
            return 1
        fi
    fi
    if [[ "$fastfetch_found" == 1 && "$softwares_apt_fastfetch_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_FASTFETCH=%s\n' "$fastfetch_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration FASTFETCH impossible.' >&2
            return 1
        fi
    fi
    if [[ "$jsvc_found" == 1 && "$softwares_apt_jsvc_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_JSVC=%s\n' "$jsvc_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration JSVC impossible.' >&2
            return 1
        fi
    fi
    if [[ "$desktop_found" == 1 && "$desktop_config_declared" == 0 ]]; then
        if ! printf 'export DESKTOP=%s\n' "$desktop_value" >> "$desktop_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration DESKTOP impossible.' >&2
            return 1
        fi
    fi
    if [[ "$env_devops_found" == 1 && "$environments_devops_declared" == 0 ]]; then
        if ! printf 'export ENVIRONMENTS_DEVOPS=%s\n' "$env_devops_value" >> "$environnements_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration ENV_DEVOPS impossible.' >&2
            return 1
        fi
    fi
    if [[ "$env_docker_found" == 1 && "$environment_docker_declared" == 0 ]]; then
        if ! printf 'export ENVIRONMENT_DOCKER=%s\n' "$env_docker_value" >> "$environnements_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration ENV_DOCKER impossible.' >&2
            return 1
        fi
    fi
    if [[ "$env_ia_found" == 1 && "$environment_ia_declared" == 0 ]]; then
        if ! printf 'export ENVIRONMENT_IA=%s\n' "$env_ia_value" >> "$environnements_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration ENV_IA impossible.' >&2
            return 1
        fi
    fi
    if [[ "$docker_user_found" == 1 && "$environment_docker_user_declared" == 0 ]]; then
        if ! printf 'export ENVIRONMENT_DOCKER_USER=%q\n' "$docker_user_value" >> "$docker_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration DOCKER_USER impossible.' >&2
            return 1
        fi
    fi
    if [[ -f "$docker_config_file" ]] && grep -E \
        '^[[:blank:]]*(export[[:blank:]]+)?DOCKER_USER=' "$docker_config_file" > /dev/null 2>&1; then
        if ! sed -i -E '/^[[:blank:]]*(export[[:blank:]]+)?DOCKER_USER=/d' "$docker_config_file"; then
            printf '%s\n' 'Erreur : suppression de l ancienne declaration DOCKER_USER impossible.' >&2
            return 1
        fi
    fi
    if [[ -f "$environnements_config_file" ]] && grep -E \
        '^[[:blank:]]*(export[[:blank:]]+)?ENV_DEVOPS=' "$environnements_config_file" > /dev/null 2>&1; then
        if ! sed -i -E '/^[[:blank:]]*(export[[:blank:]]+)?ENV_DEVOPS=/d' "$environnements_config_file"; then
            printf '%s\n' 'Erreur : suppression de l ancienne declaration ENV_DEVOPS impossible.' >&2
            return 1
        fi
    fi
    if [[ -f "$environnements_config_file" ]] && grep -E \
        '^[[:blank:]]*(export[[:blank:]]+)?ENV_DOCKER=' "$environnements_config_file" > /dev/null 2>&1; then
        if ! sed -i -E '/^[[:blank:]]*(export[[:blank:]]+)?ENV_DOCKER=/d' "$environnements_config_file"; then
            printf '%s\n' 'Erreur : suppression de l ancienne declaration ENV_DOCKER impossible.' >&2
            return 1
        fi
    fi
    if [[ -f "$environnements_config_file" ]] && grep -E \
        '^[[:blank:]]*(export[[:blank:]]+)?ENV_IA=' "$environnements_config_file" > /dev/null 2>&1; then
        if ! sed -i -E '/^[[:blank:]]*(export[[:blank:]]+)?ENV_IA=/d' "$environnements_config_file"; then
            printf '%s\n' 'Erreur : suppression de l ancienne declaration ENV_IA impossible.' >&2
            return 1
        fi
    fi
    if [[ "$software_desktop_found" == 1 ]]; then
        if ! sed -i -E '/^[[:blank:]]*(export[[:blank:]]+)?SOFTWARES_APT_DESKTOP=/d' "$softwares_config_file"; then
            printf '%s\n' 'Erreur : suppression de l ancienne declaration SOFTWARES_APT_DESKTOP impossible.' >&2
            return 1
        fi
    fi
    if [[ "$crowdsec_bouncer_found" == 1 && "$softwares_crowdsec_bouncer_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_CROWDSEC_BOUNCER=%s\n' "$crowdsec_bouncer_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration CROWDSEC_BOUNCER impossible.' >&2
            return 1
        fi
    fi
    if [[ "$apt_crowdsec_found" == 1 && "$softwares_apt_crowdsec_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_CROWDSEC=%s\n' "$apt_crowdsec_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration SYSTEM_APT_CROWDSEC impossible.' >&2
            return 1
        fi
    fi
    if [[ "$crowdsec_api_key_found" == 1 && "$softwares_crowdsec_api_key_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_CROWDSEC_BOUNCER_API_KEY=%q\n' \
            "$crowdsec_api_key_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la clé CrowdSec impossible.' >&2
            return 1
        fi
    fi
    if [[ "$system_crowdsec_agent_found" == 1 ]]; then
        if ! sed -i -E '/^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_CROWDSEC_AGENT=/d' "$system_config_file"; then
            printf '%s\n' 'Erreur : suppression de l ancienne declaration SYSTEM_CROWDSEC_AGENT impossible.' >&2
            return 1
        fi
    fi
    if [[ -f "$system_config_file" ]]; then
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_APT_CROWDSEC=' "$system_config_file" > /dev/null 2>&1; then
            if ! sed -i -E '/^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_APT_CROWDSEC=/d' "$system_config_file"; then
                printf '%s\n' 'Erreur : suppression de l ancienne declaration SYSTEM_APT_CROWDSEC impossible.' >&2
                return 1
            fi
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                return 1
            fi
        fi
    fi
    for fstab_config_number in 1 2 3 4 5 6; do
        if [[ "${fstab_config_found[$fstab_config_number]}" == 1 &&
              "${fstab_config_declared[$fstab_config_number]}" == 0 ]]; then
            fstab_config_value="${fstab_config_values[$fstab_config_number]}"
            if ! printf 'export SYSTEM_FSTAB_CONFIG%s=%q\n' "$fstab_config_number" \
                "$fstab_config_value" >> "$system_config_file"; then
                printf 'Erreur : migration de SYSTEM_FSTAB_CONFIG%s impossible.\n' \
                    "$fstab_config_number" >&2
                return 1
            fi
        fi
    done

    if [[ -e "$variables_file" ]]; then
        if grep -E "$legacy_assignment" "$variables_file" > /dev/null 2>&1; then
            if ! sed -i -E "/$legacy_assignment/d" "$variables_file"; then
                printf '%s\n' 'Erreur : nettoyage de la configuration historique impossible.' >&2
                return 1
            fi
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration historique impossible.' >&2
                return 1
            fi
        fi
    fi
}


