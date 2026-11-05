#!/usr/bin/env bash

softwares_infos() {
    local directory file name variable value color icon apt_status github_status flatpak_status row max
    local -a apt_names=() apt_values=() github_names=() github_values=()
    directory="${BASH_SCRIPT_PATH:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}/modules/diu/variables/softwares"
    for file in "$directory"/software_apt_*.sh; do
        [[ -f "$file" ]] || continue
        name="${file##*/software_apt_}"
        name="${name%.sh}"
        variable="SOFTWARES_APT_${name^^}"
        value="${!variable-}"
        name="${name//_/-}"
        if [[ "$name" == codex-cli ]]; then
            github_names+=("$name"); github_values+=("$value")
        else
            apt_names+=("$name"); apt_values+=("$value")
        fi
    done
    apt_status=$'\033[1;31m'
    github_status=$'\033[1;31m'
    flatpak_status=$'\033[1;31m'
    if [[ "${SYSTEM_APT_ENGINE:-1}" == 1 ]] && command -v apt >/dev/null 2>&1 && command -v dpkg-query >/dev/null 2>&1 && [[ "$(dpkg-query -W -f='${db:Status-Status}\n' apt-transport-https apt-utils 2>/dev/null)" == $'installed\ninstalled' ]]; then apt_status=$'\033[1;32m'; fi
    if [[ "${SYSTEM_GITHUB_ENGINE:-0}" == 1 ]] && command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 && command -v tar >/dev/null 2>&1 && command -v gzip >/dev/null 2>&1 && command -v sha256sum >/dev/null 2>&1; then github_status=$'\033[1;32m'; fi
    if [[ "${SYSTEM_FLATPAK_ENGINE:-UNSET}" == 1 ]] && command -v flatpak >/dev/null 2>&1 && flatpak remotes --system --columns=name 2>/dev/null | grep -Fxq flathub; then flatpak_status=$'\033[1;32m'; fi
    printf '\n%s\n' '### SOFTWARES ###'
    printf '%s%-28s\033[0m%s%-28s\033[0m%s%s\033[0m\n\n' "$apt_status" APT "$github_status" GitHub "$flatpak_status" Flatpak
    max=${#apt_names[@]}
    if (( ${#github_names[@]} > max )); then max=${#github_names[@]}; fi
    for ((row=0; row<max; row++)); do
        if (( row < ${#apt_names[@]} )); then
            name=${apt_names[row]}; value=${apt_values[row]}; color=$'\033[0m'; icon='  '
            case "$value" in 1) color=$'\033[32m'; icon=$'\033[32m✓\033[0m ' ;; 0) color=$'\033[33m'; icon=$'\033[31m✗\033[0m ' ;; *) name="$name (?)" ;; esac
            printf '%s%s%-26s\033[0m' "$icon" "$color" "$name"
        else
            printf '%-28s' ''
        fi
        if (( row < ${#github_names[@]} )); then
            name=${github_names[row]}; value=${github_values[row]}; color=$'\033[0m'; icon='  '
            case "$value" in 1) color=$'\033[32m'; icon=$'\033[32m✓\033[0m ' ;; 0) color=$'\033[33m'; icon=$'\033[31m✗\033[0m ' ;; *) name="$name (?)" ;; esac
            printf '%s%s%-26s\033[0m' "$icon" "$color" "$name"
        fi
        printf '\n'
    done
}
