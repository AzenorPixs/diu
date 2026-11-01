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

config_cleanup() {
    local variables_file="${1:-/root/diu/variables.sh}"
    local system_config_file="${2:-/root/diu/config/system.env}"
    local softwares_config_file="${3:-/root/diu/config/softwares.env}"
    local legacy_assignment='^[[:blank:]]*(export[[:blank:]]+)?(DEBIAN_RELEASE|DEBIAN_TYPE|DISPLAY_LINK|TIME_ZONE|PROXY_CA|PROXY|DRIVERS_NVIDIA|FSTAB_CONFIG[1-6]|FSTAB|FILES2RAM|GRUB_CONFIG|IPv6|LOG_ROTATE|JOURNALD_MAX_USE|JOURNALD_KEEP_FREE|NO_SLEEP|APACHE2)='
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
    local apache2_value='' apache2_found=0 softwares_apache2_declared=0
    local fstab_config_number fstab_config_value fstab_migration_found=0
    local fstab_config_migration_needed=0
    local REPLY
    local -a fstab_config_values=() fstab_config_found=(0 0 0 0 0 0 0)
    local -a fstab_config_declared=(0 0 0 0 0 0 0)

    [[ -e "$variables_file" ]] || return 0

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
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?APACHE2= ]]; then
            apache2_found=1
            if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?APACHE2=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
                apache2_value="${BASH_REMATCH[3]}"
            else
                printf '%s\n' 'Erreur : affectation historique APACHE2 ambiguë ; nettoyage impossible.' >&2
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

    if [[ ( "$proxy_found" == 1 || "$nvidia_found" == 1 || "$grub_config_found" == 1 || "$ipv6_found" == 1 || "$log_rotate_found" == 1 || "$journald_max_use_found" == 1 || "$journald_keep_free_found" == 1 || "$no_sleep_found" == 1 || "$fstab_migration_found" == 1 ) &&
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
    if [[ "$apache2_found" == 1 && "$softwares_apache2_declared" == 0 ]]; then
        if ! printf 'export SOFTWARES_APT_APACHE2=%s\n' "$apache2_value" >> "$softwares_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration APACHE2 impossible.' >&2
            return 1
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
}


