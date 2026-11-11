#!/usr/bin/env bash




software_apt_sed_replacement() {
    local value="${1-}"
    [[ "$value" != *$'\n'* && "$value" != *$'\r'* ]] || return 1
    value="${value//\\/\\\\}"
    value="${value//&/\\&}"
    value="${value//%/\\%}"
    printf '%s' "$value"
}



software_apt_file_has_line() {
    local file="$1" expected="$2" line
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" == "$expected" ]] && return 0
    done < "$file"
    return 1
}




















# Les détecteurs et hooks propres aux logiciels appartiennent aux déclarations GLOBAL.
# shellcheck disable=SC1091 source=modules/softwares/apt-recipes.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/apt-recipes.sh"
software_apt_load_recipes || return 1

software_apt_support_directory() { cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd; }
