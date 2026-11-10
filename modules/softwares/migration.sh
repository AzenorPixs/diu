#!/usr/bin/env bash

software_secure_sensitive_configuration() {
    local file="${1:-}"
    [[ "$-" != *x* ]] || { printf '%s\n' 'Sécurisation sensible refusée avec traçage shell actif.' >&2; return 1; }
    [[ -n "$file" ]] || return 2
    [[ -e "$file" || -L "$file" ]] || return 0
    [[ ! -L "$file" && -f "$file" && -r "$file" ]] || return 1
    if grep -Eq '^[[:space:]]*(export[[:space:]]+)?(SOFTWARES_CROWDSEC_BOUNCER_API_KEY|SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY|SOFTWARE_APT_WAZUH_AGENT_REGISTRATION_PASSWORD)[[:space:]]*=' "$file"; then
        chmod 0600 "$file" || return 1
    else
        local status=$?
        [[ "$status" == 1 ]] || return 1
    fi
}

# Traite une seule correspondance ; ne charge jamais le fichier de configuration.
software_migrate_desired_variable() (
    local file="${1:-}" old="${2:-}" new="${3:-}"
    local line name value old_value='' new_value='' old_seen=0 new_seen=0 temporary='' snapshot=''
    local prefix_re value_re old_re

    if [[ ! "$old" =~ ^SOFTWARES_APT_[A-Z0-9_]+$ || ! "$new" =~ ^SOFTWARE_(APT|GITHUB|FLATPAK)_[A-Z0-9_]+$ || "$old" == "$new" ]]; then
        printf '%s\n' 'Correspondance de migration logicielle invalide.' >&2
        return 2
    fi
    [[ -e "$file" || -L "$file" ]] || return 0
    if [[ -L "$file" || ! -f "$file" || ! -r "$file" ]]; then
        printf '%s\n' 'Configuration logicielle inaccessible ou non régulière.' >&2
        return 1
    fi
    trap '[[ -z "$temporary" ]] || rm -f -- "$temporary"; [[ -z "$snapshot" ]] || rm -f -- "$snapshot"' EXIT
    snapshot="$(mktemp "${file}.snapshot.XXXXXXXX")" || return 1
    if ! cat -- "$file" > "$snapshot"; then
        printf '%s\n' 'Lecture de configuration impossible ; migration interrompue.' >&2
        return 1
    fi
    prefix_re="^[[:space:]]*(export[[:space:]]+)?(${old}|${new})([^a-zA-Z0-9_]|$)"
    value_re="^[[:space:]]*(export[[:space:]]+)?(${old}|${new})[[:space:]]*=[[:space:]]*([01])[[:space:]]*(#.*)?$"
    old_re="^[[:space:]]*(export[[:space:]]+)?${old}([^a-zA-Z0-9_]|$)"
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $prefix_re ]] || continue
        if [[ ! "$line" =~ $value_re ]]; then
            printf '%s\n' 'Valeur logicielle ambiguë ; migration interrompue.' >&2
            return 1
        fi
        name="${BASH_REMATCH[2]}"
        value="${BASH_REMATCH[3]}"
        if [[ "$name" == "$old" ]]; then
            (( old_seen += 1 )); old_value="$value"
        else
            (( new_seen += 1 )); new_value="$value"
        fi
    done < "$snapshot"
    if (( old_seen > 1 || new_seen > 1 )); then
        printf '%s\n' 'Valeur logicielle dupliquée ; migration interrompue.' >&2
        return 1
    fi
    (( old_seen == 1 )) || return 0
    if [[ "$new_seen" == 1 && "$old_value" != "$new_value" ]]; then
        printf 'Valeurs distinctes : priorité à %s.\n' "$new" >&2
    fi
    [[ "$new_seen" == 1 ]] || new_value="$old_value"

    temporary="$(mktemp "${file}.migration.XXXXXXXX")" || return 1
    if ! chmod --reference="$file" "$temporary"; then
        return 1
    fi
    if [[ "$(stat -c '%u:%g' -- "$file")" != "$(stat -c '%u:%g' -- "$temporary")" ]]; then
        printf '%s\n' 'Propriétaire de configuration incompatible ; migration interrompue.' >&2
        return 1
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $old_re ]] && continue
        if ! printf '%s\n' "$line" >> "$temporary"; then
            return 1
        fi
    done < "$snapshot"
    if [[ "$new_seen" == 0 ]] && ! printf 'export %s=%s\n' "$new" "$new_value" >> "$temporary"; then
        return 1
    fi
    if ! cmp -s -- "$snapshot" "$file"; then
        printf '%s\n' 'Configuration modifiée pendant la migration ; opération interrompue.' >&2
        return 1
    fi
    if ! mv -f -- "$temporary" "$file"; then
        return 1
    fi
    temporary=''
)

software_desired_migration_pairs() {
    local suffix
    for suffix in APACHE2 CHATGPT CROWDSEC CROWDSEC_AGENT CROWDSEC_BOUNCER FASTFETCH JSVC LEMONLDAP \
        MONGODB OMADA OPENJDK OPENVSWITCH POSTFIX POSTGRESQL QEMU_GUEST_AGENT SSH_SERVER \
        SYNCTHING SYSLOG_CLIENT SYSLOG_SERVER WAZUH_AGENT WAZUH_SERVER WEBMIN ZOOM ZSH; do
        printf '%s %s\n' "SOFTWARES_APT_$suffix" "SOFTWARE_APT_$suffix"
    done
    printf '%s %s\n' SOFTWARES_APT_CODEX_CLI SOFTWARE_GITHUB_CODEX_CLI
}

software_migrate_desired_states() {
    local file="${1:-}" old new
    [[ -n "$file" ]] || return 2
    while read -r old new; do
        software_migrate_desired_variable "$file" "$old" "$new" || return $?
    done < <(software_desired_migration_pairs)
}

# Après chargement de la configuration et avant les déclarations DISABLE.
software_migrate_desired_environment() {
    local file="${1:-}" old new old_value new_value
    [[ -n "$file" ]] || return 2
    while read -r old new; do
        [[ -v "$old" ]] || continue
        old_value="${!old}"
        if [[ "$old_value" != 0 && "$old_value" != 1 ]]; then
            printf 'Ancienne variable logicielle invalide : %s.\n' "$old" >&2
            return 1
        fi
        if [[ -v "$new" ]]; then
            new_value="${!new}"
            if [[ "$new_value" != 0 && "$new_value" != 1 ]]; then
                printf 'Nouvelle variable logicielle invalide : %s.\n' "$new" >&2
                return 1
            fi
            if [[ "$new_value" != "$old_value" ]]; then
                printf 'Valeurs distinctes : priorité à %s.\n' "$new" >&2
            fi
            software_write_desired_state "$file" "$new" "$new_value" initialize || return $?
        else
            software_write_desired_state "$file" "$new" "$old_value" initialize || return $?
            printf -v "$new" '%s' "$old_value"
            export "${new?}"
        fi
        unset "$old"
    done < <(software_desired_migration_pairs)
}

# Migration littérale dédiée : la valeur ne doit jamais apparaître dans les diagnostics.
software_migrate_crowdsec_secret() (
    local file="${1:-}" line snapshot='' temporary='' old_seen=0 new_seen=0
    local old_value='' new_value='' name value prefix_re value_re old_re
    local old=SOFTWARES_CROWDSEC_BOUNCER_API_KEY new=SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY
    [[ "$-" != *x* ]] || { printf '%s\n' 'Migration sensible refusée avec traçage shell actif.' >&2; return 1; }
    [[ -n "$file" ]] || return 2
    [[ -e "$file" || -L "$file" ]] || return 0
    [[ ! -L "$file" && -f "$file" && -r "$file" ]] || return 1
    trap '[[ -z "$temporary" ]] || rm -f -- "$temporary"; [[ -z "$snapshot" ]] || rm -f -- "$snapshot"' EXIT
    snapshot="$(mktemp "${file}.snapshot.XXXXXXXX")" || return 1
    cat -- "$file" > "$snapshot" || return 1
    prefix_re="^[[:space:]]*(export[[:space:]]+)?(${old}|${new})([^a-zA-Z0-9_]|$)"
    value_re="^[[:space:]]*(export[[:space:]]+)?(${old}|${new})[[:space:]]*=[[:space:]]*([A-Za-z0-9_./:+@=-]*|'')[[:space:]]*(#.*)?$"
    old_re="^[[:space:]]*(export[[:space:]]+)?${old}([^a-zA-Z0-9_]|$)"
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $prefix_re ]] || continue
        if [[ ! "$line" =~ $value_re ]]; then
            printf '%s\n' 'Clé CrowdSec ambiguë ; migration interrompue.' >&2
            return 1
        fi
        name="${BASH_REMATCH[2]}"; value="${BASH_REMATCH[3]}"
        if [[ "$name" == "$old" ]]; then (( old_seen += 1 )); old_value="$value"; else (( new_seen += 1 )); new_value="$value"; fi
    done < "$snapshot"
    if (( old_seen > 1 || new_seen > 1 )); then
        printf '%s\n' 'Clé CrowdSec dupliquée ; migration interrompue.' >&2
        return 1
    fi
    (( old_seen == 1 )) || return 0
    if [[ "$new_seen" == 1 && "$new_value" != "$old_value" ]]; then
        printf '%s\n' 'Clé CrowdSec déjà configurée sous le nouveau nom ; valeur conservée.' >&2
    fi
    [[ "$new_seen" == 1 ]] || new_value="$old_value"
    temporary="$(mktemp "${file}.secret.XXXXXXXX")" || return 1
    if [[ "$new_value" != "''" && -n "$new_value" ]]; then chmod 0600 "$temporary" || return 1
    else chmod --reference="$file" "$temporary" || return 1; fi
    if [[ "$(stat -c '%u:%g' -- "$file")" != "$(stat -c '%u:%g' -- "$temporary")" ]]; then return 1; fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $old_re ]] && continue
        printf '%s\n' "$line" >> "$temporary" || return 1
    done < "$snapshot"
    if [[ "$new_seen" == 0 ]]; then printf 'export %s=%s\n' "$new" "$new_value" >> "$temporary" || return 1; fi
    if ! cmp -s -- "$snapshot" "$file"; then
        printf '%s\n' 'Configuration modifiée pendant la migration de clé.' >&2
        return 1
    fi
    mv -f -- "$temporary" "$file" || return 1
    temporary=''
)

software_write_crowdsec_secret_from_environment() (
    local file="${1:-}" source_name="${2:-}" snapshot='' temporary='' line value='' last='' seen=0 existed=0
    local variable=SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY prefix_re value_re secret
    [[ "$-" != *x* ]] || { printf '%s\n' 'Migration sensible refusée avec traçage shell actif.' >&2; return 1; }
    [[ "$source_name" == SOFTWARES_CROWDSEC_BOUNCER_API_KEY || "$source_name" == SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY ]] || return 2
    [[ -v "$source_name" ]] || return 1
    secret="${!source_name}"
    [[ "$secret" =~ ^[[:alnum:]_./:+@=-]*$ ]] || { printf '%s\n' 'Clé CrowdSec invalide.' >&2; return 1; }
    if [[ -L "$file" || ( -e "$file" && ( ! -f "$file" || ! -r "$file" ) ) ]]; then return 1; fi
    [[ -e "$file" ]] && existed=1
    trap '[[ -z "$temporary" ]] || rm -f -- "$temporary"; [[ -z "$snapshot" ]] || rm -f -- "$snapshot"' EXIT
    snapshot="$(mktemp "${file}.snapshot.XXXXXXXX")" || return 1
    if [[ "$existed" == 1 ]] && ! cat -- "$file" > "$snapshot"; then return 1; fi
    prefix_re="^[[:space:]]*(export[[:space:]]+)?${variable}([^a-zA-Z0-9_]|$)"
    value_re="^[[:space:]]*(export[[:space:]]+)?${variable}[[:space:]]*=[[:space:]]*([A-Za-z0-9_./:+@=-]*|'')[[:space:]]*(#.*)?$"
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $prefix_re ]] || continue
        [[ "$line" =~ $value_re ]] || { printf '%s\n' 'Clé CrowdSec persistée ambiguë.' >&2; return 1; }
        value="${BASH_REMATCH[2]}"
        [[ "$value" == "''" ]] && value=''
        (( seen += 1 ))
    done < "$snapshot"
    (( seen <= 1 )) || { printf '%s\n' 'Clé CrowdSec persistée dupliquée.' >&2; return 1; }
    if [[ "$seen" == 1 && "$value" != "$secret" ]]; then
        printf '%s\n' 'Clé CrowdSec persistée différente ; migration interrompue.' >&2
        return 1
    fi
    temporary="$(mktemp "${file}.secret.XXXXXXXX")" || return 1
    chmod 0600 "$temporary" || return 1
    if [[ "$existed" == 1 && "$(stat -c '%u:%g' -- "$file")" != "$(stat -c '%u:%g' -- "$temporary")" ]]; then return 1; fi
    cat -- "$snapshot" > "$temporary" || return 1
    if [[ "$seen" == 0 ]]; then
        if [[ -s "$snapshot" ]]; then
            last="$(tail -c 1 -- "$snapshot")" || return 1
            [[ -z "$last" ]] || printf '\n' >> "$temporary" || return 1
        fi
        printf 'export %s=%q\n' "$variable" "$secret" >> "$temporary" || return 1
    fi
    if [[ "$existed" == 1 ]]; then
        cmp -s -- "$snapshot" "$file" || return 1
        mv -f -- "$temporary" "$file" || return 1
        temporary=''
    else
        ln -- "$temporary" "$file" || return 1
    fi
)

software_migrate_crowdsec_secret_environment() {
    local file="${1:-}" old=SOFTWARES_CROWDSEC_BOUNCER_API_KEY new=SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY source_name name value
    [[ "$-" != *x* ]] || { printf '%s\n' 'Migration sensible refusée avec traçage shell actif.' >&2; return 1; }
    [[ -v "$old" || -v "$new" ]] || return 0
    for name in "$old" "$new"; do
        if [[ -v "$name" ]]; then
            value="${!name}"
            [[ "$value" =~ ^[[:alnum:]_./:+@=-]*$ ]] || { printf '%s\n' 'Clé CrowdSec invalide.' >&2; return 1; }
        fi
    done
    if [[ -v "$old" && -v "$new" && "${!old}" != "${!new}" ]]; then
        printf '%s\n' 'Clé CrowdSec déjà configurée sous le nouveau nom ; valeur conservée.' >&2
    fi
    if [[ -v "$new" ]]; then source_name="$new"; else source_name="$old"; fi
    software_write_crowdsec_secret_from_environment "$file" "$source_name" || return $?
    if [[ "$source_name" == "$old" ]]; then
        printf -v "$new" '%s' "${!old}"
        export "${new?}"
    fi
    unset "$old"
}

software_prepare_migration() {
    local file="${1:-}"
    [[ -n "$file" ]] || return 2
    software_secure_sensitive_configuration "$file" || return $?
    software_migrate_crowdsec_secret "$file" || return $?
    software_migrate_desired_states "$file" || return $?
    software_secure_sensitive_configuration "$file"
}

software_prepare_loaded_environment() {
    local file="${1:-}"
    [[ -n "$file" ]] || return 2
    software_migrate_desired_environment "$file" || return $?
    software_migrate_crowdsec_secret_environment "$file"
}
