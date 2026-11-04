#!/usr/bin/env bash

set -Eeuo pipefail

# nano /root/root-install.sh
# chmod +x /root/root-install.sh
# alias --> nri
# alias --> ri
#
# Paquet a supprimer pour les container --> qemu-guest-agent
# Paquet a supprimer pour les Debian Trixie --> neofetch

# Le chemin où je me trouve est
BASH_SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/lib/rid-help.sh"

# Alias limité au packaging ; les autres classes restent inchangées.
if [[ "${1:-}" == proj && "${2:-}" == deb ]]; then
    if [[ $# -lt 3 ]]; then
        printf '%s\n' 'Usage : rid proj deb <ID PROJECT>' >&2
        exit 2
    fi
    shift
    set -- projects "$@"
fi
if [[ "${1:-}:${2:-}" == projects:deb && "${!#}" != help && "${!#}" != "?" ]]; then
    if [[ $# -gt 3 || ( $# -eq 3 && ( ! "${3}" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ||
        "${3}" == . || "${3}" == .. ) ) ]]; then
        printf '%s\n' 'Usage : rid projects deb [ID PROJECT]' >&2
        exit 2
    fi
fi

if [[ "${1:-}:${2:-}" == projects:build && "${!#}" != help && "${!#}" != "?" ]]; then
    if [[ $# -ne 4 || ( "${3:-}" != deb && "${3:-}" != debian ) || ! "${4:-}" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ||
        "${4:-}" == . || "${4:-}" == .. ]]; then
        printf '%s\n' 'Usage : rid projects build debian <ID PROJECT>' >&2
        exit 2
    fi
fi

if [[ "${1:-}" == help || "${1:-}" == "?" ]]; then
    rid_display_help_context
    exit 0
fi

if [[ "${!#}" == help || "${!#}" == "?" ]]; then
    help_arguments=("$@")
    unset 'help_arguments[${#help_arguments[@]} - 1]'
    rid_display_help_context "${help_arguments[@]}"
    exit $?
fi

case "${1:-}" in
    ''|devops|docker|ia|os|projects|install|remove|softwares|system|update|version|infos|desktop|diu|environnements)
        ;;
    *)
        printf "❌ Classe d'actions inconnue : %s\n" "$1"
        rid_display_command_error
        exit 2
        ;;
esac

if [[ "${1:-}" == softwares ]]; then
    case "${2:-}" in
        install|remove|update|apt|flatpak|infos)
            ;;
        *)
            printf "❌ Action inconnue pour la classe 'softwares' : %s\n" "${2:-}"
            rid_display_command_error softwares
            exit 2
            ;;
    esac
fi

# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/system/variables-cleanup.sh"
config_cleanup || exit 1
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "/root/diu/variables.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/lib/logging.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/lib/docker.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/lib/forgejo-auth.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/lib/gitlab-auth.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/lib/github-auth.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/ia/hermes.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/diu/config.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/diu/update.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/diu/update-all.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/environments/update.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/system/apt.sh"
# shellcheck disable=SC1091 source=modules/system/drivers.sh
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/system/drivers.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/softwares/software.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/softwares/deb.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/softwares/apt.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/softwares/github.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/softwares/flatpak.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/docker.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/find.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/git.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/diu-release.sh"
# Publication des paquets Debian dans GitHub Releases.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/github-release.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/diu-packaging.sh"
# Chargement du constructeur déclaratif de projets.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/debian-build.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/projects.sh"
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/template.sh"
# shellcheck disable=SC1091 source=modules/desktop/infos.sh
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/desktop/infos.sh"
# shellcheck disable=SC1091 source=modules/diu/infos.sh
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/diu/infos.sh"
# shellcheck disable=SC1091 source=modules/environments/infos.sh
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/environments/infos.sh"
# shellcheck disable=SC1091 source=modules/ia/infos.sh
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/ia/infos.sh"
# shellcheck disable=SC1091 source=modules/projects/infos.sh
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/projects/infos.sh"
# shellcheck disable=SC1091 source=modules/softwares/infos.sh
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/softwares/infos.sh"
# shellcheck disable=SC1091 source=modules/system/infos.sh
# Chargement externe ; analyse séparée, sans lecture de la configuration privée.
# shellcheck source=/dev/null
. "$BASH_SCRIPT_PATH/modules/system/infos.sh"

# Creer l'arborescence.
mkdir -p "$BASH_SCRIPT_PATH/config"
mkdir -p "$BASH_SCRIPT_PATH/deb"

# Chargement de la configuration et initialisation des variables manquantes
config_load

# Vérifier qu'on est root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en root"
    exit 1
fi

###########################################
###### GESTION DES FONCTIONS DU DIU #######
###########################################

# Appelée par les fonctions Git/projets des modules sourcés.
# shellcheck disable=SC2317
check_devops_user() {
    if ! id "$ENV_DEVOPS_USER" >/dev/null 2>&1; then
        echo "❌ L'utilisateur '$ENV_DEVOPS_USER' n'existe pas."
        exit 1
    fi

    if ! getent group "$DEVOPS_GROUP" >/dev/null 2>&1; then
        echo "❌ Le groupe '$DEVOPS_GROUP' n'existe pas."
        exit 1
    fi
}

configure_environment_sudoers() {
    local scope="${1:-}" target_user label
    local passwd_file="${2:-/etc/passwd}"
    local login_defs="${3:-/etc/login.defs}"
    local sudoers_dir="${4:-/etc/sudoers.d}"
    local uid_limits uid_min uid_max human_accounts candidate human_user human_shell
    local configured_users

    case "$scope" in
        devops) target_user="${ENV_DEVOPS_USER:-}"; label="DevOps" ;;
        docker) target_user="${ENV_DOCKER_USER:-}"; label="Docker" ;;
        *) echo "❌ Sudoers : environnement inconnu." >&2; return 1 ;;
    esac
    if [ -z "$target_user" ] || ! id -u "$target_user" >/dev/null 2>&1; then
        echo "ℹ️ Sudoers $label ignoré : le compte '$target_user' n'existe pas."
        return 0
    fi
    if [[ ! "$target_user" =~ ^[[:alnum:]_][[:alnum:]_.-]*[$]?$ ]]; then
        echo "❌ Sudoers $label : nom du compte cible incompatible avec la génération." >&2
        return 1
    fi
    if ! command -v visudo >/dev/null 2>&1; then
        echo "❌ Sudoers $label : visudo est nécessaire." >&2
        return 1
    fi
    if ! uid_limits=$(awk '
        $1 == "UID_MIN" { minimum = $2 }
        $1 == "UID_MAX" { maximum = $2 }
        END {
            if (minimum !~ /^[0-9]+$/ || maximum !~ /^[0-9]+$/ ||
                minimum + 0 <= 0 || maximum + 0 < minimum + 0) exit 1
            print minimum, maximum
        }
    ' "$login_defs"); then
        echo "❌ Sudoers $label : lecture ou bornes UID_MIN/UID_MAX invalides." >&2
        return 1
    fi
    read -r uid_min uid_max <<< "$uid_limits"
    if ! human_accounts=$(awk -F: -v minimum="$uid_min" -v maximum="$uid_max" \
        -v devops="${ENV_DEVOPS_USER:-}" -v docker="${ENV_DOCKER_USER:-}" -v ia="${ENV_IA_USER:-}" '
        $3 ~ /^[0-9]+$/ && $3 + 0 >= minimum + 0 && $3 + 0 <= maximum + 0 &&
        $1 != "root" && $1 != devops && $1 != docker && $1 != ia && !seen[$1]++ {
            print $1 ":" $7
        }
    ' "$passwd_file"); then
        echo "❌ Sudoers $label : lecture des comptes locaux impossible." >&2
        return 1
    fi
    if [ ! -d "$sudoers_dir" ]; then
        if ! install -d -o root -g root -m 0750 "$sudoers_dir"; then
            echo "❌ Sudoers $label : création du répertoire impossible." >&2
            return 1
        fi
    fi
    # Le point dans le nom exclut le candidat de l'inclusion sudoers.d.
    if ! candidate=$(mktemp "$sudoers_dir/.diu-$scope.XXXXXX"); then
        echo "❌ Sudoers $label : création du candidat impossible." >&2
        return 1
    fi
    if ! (
        printf '# Managed by DIU: local human accounts to %s\n' "$label" || exit 1
        while IFS=: read -r human_user human_shell; do
            [ -n "$human_user" ] && [ -f "$human_shell" ] && [ -x "$human_shell" ] || continue
            case "${human_shell##*/}" in
                nologin|false) continue ;;
            esac
            if [[ ! "$human_user" =~ ^[[:alnum:]_][[:alnum:]_.-]*[$]?$ ]]; then
                echo "❌ Sudoers $label : nom de compte local incompatible avec la génération." >&2
                exit 1
            fi
            printf '%s ALL=(%s) NOPASSWD: ALL\n' "$human_user" "$target_user" || exit 1
        done <<< "$human_accounts"
    ) > "$candidate" || ! configured_users=$(awk '
        NF && $1 !~ /^#/ { printf "%s%s", separator, $1; separator = " " }
    ' "$candidate") || ! visudo -cf "$candidate" \
        || ! chown root:root "$candidate" || ! chmod 0440 "$candidate" \
        || ! mv -fT -- "$candidate" "$sudoers_dir/99-diu-$scope"; then
        echo "❌ Sudoers $label : génération ou publication échouée ; fragment précédent préservé." >&2
        if ! rm -f -- "$candidate"; then
            echo "❌ Sudoers $label : nettoyage du candidat impossible." >&2
        fi
        return 1
    fi
    if [ -n "$configured_users" ]; then
        printf '✅ Sudoers %s configuré pour %s.\n' "$label" "$configured_users"
    else
        printf 'ℹ️ Sudoers %s : aucun compte humain retenu.\n' "$label"
    fi
}

configure_devops_sudoers() {
    configure_environment_sudoers devops "${1:-/etc/passwd}" "${2:-/etc/login.defs}" "${3:-/etc/sudoers.d}"
}

configure_docker_sudoers() {
    configure_environment_sudoers docker "${1:-/etc/passwd}" "${2:-/etc/login.defs}" "${3:-/etc/sudoers.d}"
}

config_host () {

  local hosts_ip=""

  if [[ "${INTERFACE_ETHERNET1_STATE}" == "UP" ]] \
      && [[ "${INTERFACE_ETHERNET1_IP}" != "NONE" ]] \
      && [[ "${INTERFACE_ETHERNET1_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

      hosts_ip="${INTERFACE_ETHERNET1_IP}"

  elif [[ "${INTERFACE_ETHERNET2_STATE}" == "UP" ]] \
      && [[ "${INTERFACE_ETHERNET2_IP}" != "NONE" ]] \
      && [[ "${INTERFACE_ETHERNET2_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

      hosts_ip="${INTERFACE_ETHERNET2_IP}"
  fi

  cat > /etc/hosts <<EOF
127.0.0.1       localhost
EOF

  if [[ -n "${hosts_ip}" ]]; then
      printf '%s\t%s\t%s\n' \
          "${hosts_ip}" \
          "${HOSTNAME_FQDN}" \
          "${HOSTNAME}" >> /etc/hosts
  fi

  cat >> /etc/hosts <<'EOF'

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

  # Ajout des domaines de la Stack Docker Traefik / Dockhand
  if [[ "${DOCKER_STACK_TRAEFIK_DOCKHAND}" == "1" ]]; then
      {
          printf '\n'
          printf '# Stack Docker Traefik / Dockhand\n'
          printf '127.0.0.1\t%s\n' "dockhand.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "dozzle.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "hawser.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "librespeed.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "myspeed.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "traefik.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "traefik-manager.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "whoami.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '130.66.41.80\t%s\n' "dockhand.test.ec-nantes.fr"
          printf '130.66.41.80\t%s\n' "dozzle.test.ec-nantes.fr"
          printf '130.66.41.80\t%s\n' "traefik.test.ec-nantes.fr"
          printf '130.66.41.80\t%s\n' "traefik-manager.test.ec-nantes.fr"
          printf '130.66.41.80\t%s\n' "ost.test.ec-nantes.fr"
          printf '130.66.41.80\t%s\n' "whoami.test.ec-nantes.fr"
          printf '130.66.41.80\t%s\n' "ldap.test.ec-nantes.fr"
          printf '130.66.41.80\t%s\n' "fd.test.ec-nantes.fr"
          printf '130.66.41.80\t%s\n' "pgadmin.test.ec-nantes.fr"
      } >> /etc/hosts
  fi

  # Ajout des domaines de la Stack Docker DevOps
  if [[ "${DOCKER_STACK_DEVOPS}" == "1" ]]; then
      {
          printf '\n'
          printf '# Stack Docker DevOps\n'
          printf '127.0.0.1\t%s\n' "forgejo.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "fd.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "g4f.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "ldap.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "pgadmin.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
      } >> /etc/hosts
  fi

}

devops_info () {

    # Expansion différée dans le shell utilisateur.
    # shellcheck disable=SC2016
    su - "${ENV_DEVOPS_USER}" -c '

        # ==============================================
        # Récupération des versions
        # ==============================================

        PYTHON_VERSION="$(python3 --version 2>/dev/null | awk "{print \$2}")"
        GO_VERSION="$(go version 2>/dev/null | awk "{print \$3}" | sed "s/^go//")"
        NODE_VERSION="$(node --version 2>/dev/null | sed "s/^v//")"
        NPM_VERSION="$(npm --version 2>/dev/null)"
        OPENCODE_VERSION="$(opencode --version 2>/dev/null)"
        OPENSPEC_VERSION="$(openspec --version 2>/dev/null)"

        echo "# =============================================="
        echo "# === PYTHON ${PYTHON_VERSION}                          ==="
        echo "# =============================================="
        command -v python3
        readlink -f "$(command -v python3)"

        echo "# =============================================="
        echo "# === GO ${GO_VERSION}                              ==="
        echo "# =============================================="
        command -v go
        readlink -f "$(command -v go)"

        echo "# =============================================="
        echo "# === NODE.JS ${NODE_VERSION}                       ===="
        echo "# =============================================="
        command -v node
        readlink -f "$(command -v node)"

        echo "# =============================================="
        echo "# === NPM ${NPM_VERSION}                           ===="
        echo "# =============================================="
        command -v npm
        readlink -f "$(command -v npm)"
        echo "Prefix : $(npm config get prefix)"

        echo "# =============================================="
        echo "# === OPENCODE ${OPENCODE_VERSION}                       ==="
        echo "# =============================================="
        command -v opencode
        readlink -f "$(command -v opencode)"

        echo "# =============================================="
        echo "# === OPENSPEC ${OPENSPEC_VERSION}                         ==="
        echo "# =============================================="
        command -v openspec
        readlink -f "$(command -v openspec)"

        echo "# =============================================="
        echo "# === PATH                                   ==="
        echo "# =============================================="
        echo "$PATH"
        echo

    '

}

dispatch_arguments() {

    local argument_class="${1:-}"

    # Aucun argument : poursuite normale du DIU.
    if [[ "$#" -eq 0 ]]; then
        return 0
    fi

    if [[ "$argument_class" == help || "$argument_class" == "?" ]]; then
        display_help_context
        exit 0
    fi

    if [[ "${!#}" == help || "${!#}" == "?" ]]; then
        display_help_context "${@:1:$(($# - 1))}"
        exit 0
    fi

    # Les informations de modules partagent un routage strict et sans récursion.
    case "$argument_class:${2:-}" in
        desktop:infos|diu:infos|environnements:infos|ia:infos|projects:infos|softwares:infos)
            if [[ $# -ne 2 ]]; then
                printf 'Usage : rid %s infos ; voir rid %s infos help\n' "$argument_class" "$argument_class" >&2
                exit 2
            fi
            case "$argument_class" in
                environnements) environments_infos ;;
                *) "${argument_class}_infos" ;;
            esac
            exit $?
            ;;
    esac

    case "$argument_class" in

        infos)
            if [[ $# -ne 1 ]]; then
                printf '%s\n' 'Usage : rid infos ; voir rid infos help' >&2
                exit 2
            fi
            infos
            ;;

        diu)
            if [[ $# -eq 2 && "$2" == update ]]; then
                diu_update
            else
                printf 'Action inconnue : %s ; voir rid diu help\n' "${2:-}" >&2
                exit 2
            fi
            ;;

        desktop|environnements)
            printf 'Action inconnue : %s ; voir rid %s help\n' "${2:-}" "$argument_class" >&2
            exit 2
            ;;

        devops)
            shift
            manage_devops_action "$@"
            ;;

        docker)
            shift
            manage_docker_action "$@"
            ;;

        ia)
            shift
            manage_ia_action "$@"
            ;;

        os)
            shift
            manage_openspec_action "$@"
            ;;

        projects)
            shift
            manage_project_action "$@"
            ;;

        install|remove)
            manage_software_action "$@"
            ;;

        softwares)
            shift
            manage_softwares_action "$@"
            ;;

        update)
            shift
            manage_update_action "$@"
            ;;

        system)
            shift
            manage_system_action "$@"
            ;;

        version)
            diu_version
            ;;

        help|--help|-h)
            display_help_context
            ;;

        *)
            echo "❌ Classe d'actions inconnue : $argument_class"
            rid_display_command_error
            exit 2
            ;;

    esac

    # Une action avec arguments ne doit pas poursuivre
    # l'installation Debian linéaire.
    exit 0
}

display_help_context() {
    rid_display_help_context "$@"
}


# Appelée par le trap ERR déclaré avant le dispatch.
# shellcheck disable=SC2317
error_handler() {
    local exit_code=$?
    local line_number="${BASH_LINENO[0]}"
    local command="${BASH_COMMAND}"

    echo "" >&2
    echo "==============================================" >&2
    echo " ❌ ERREUR DIU" >&2
    echo "==============================================" >&2
    echo "Code     : ${exit_code}" >&2
    echo "Ligne    : ${line_number}" >&2
    echo "Commande : ${command}" >&2
    echo "==============================================" >&2
    echo "" >&2
}

# Appelée par lib/docker.sh pour les conteneurs inspectés.
# shellcheck disable=SC2317
info_docker_analyse_container() {
    local container="$1"
    local pids
    local pid
    local uid
    local gid
    local users

    # ----------------------------------------------------------
    # Vérification du paramètre
    # ----------------------------------------------------------

    if [ -z "$container" ]; then
        printf "?\n"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du conteneur
    # ----------------------------------------------------------

    if ! docker inspect "$container" >/dev/null 2>&1; then
        printf "?\n"
        return 1
    fi

    # ----------------------------------------------------------
    # Récupération des PID des processus du conteneur
    # ----------------------------------------------------------

    pids="$(
        docker top "$container" -eo pid 2>/dev/null |
        awk 'NR > 1 {print $1}'
    )"

    if [ -z "$pids" ]; then
        printf "?\n"
        return 0
    fi

    # ----------------------------------------------------------
    # Récupération des UID:GID de chaque processus
    # ----------------------------------------------------------

    users="$(
        for pid in $pids; do

            if [ -r "/proc/$pid/status" ]; then

                uid="$(
                    awk '/^Uid:/ {print $2}' \
                        "/proc/$pid/status"
                )"

                gid="$(
                    awk '/^Gid:/ {print $2}' \
                        "/proc/$pid/status"
                )"

                if [ -n "$uid" ] && [ -n "$gid" ]; then
                    printf "%s:%s\n" "$uid" "$gid"
                fi

            fi

        done |
        sort -u |
        paste -sd ',' -
    )"

    # ----------------------------------------------------------
    # Résultat
    # ----------------------------------------------------------

    if [ -n "$users" ]; then
        printf "%s\n" "$users"
    else
        printf "?\n"
    fi
}

info_network_detect_interfaces() {
    local -a physical_interfaces=()
    local iface=""
    local index=0
    local ip_cidr=""
    local ip_addr=""
    local gateway=""
    local state=""
    local type=""
    local master=""
    local operstate=""

    # ==========================================================
    # Valeurs par défaut
    # ==========================================================

    export INTERFACE_ETHERNET1="NONE"
    export INTERFACE_ETHERNET1_STATE="DOWN"
    export INTERFACE_ETHERNET1_TYPE="NONE"
    export INTERFACE_ETHERNET1_IP="NONE"
    export INTERFACE_ETHERNET1_IP_CIDR="NONE"
    export INTERFACE_ETHERNET1_GW="NONE"

    export INTERFACE_ETHERNET2="NONE"
    export INTERFACE_ETHERNET2_STATE="DOWN"
    export INTERFACE_ETHERNET2_TYPE="NONE"
    export INTERFACE_ETHERNET2_IP="NONE"
    export INTERFACE_ETHERNET2_IP_CIDR="NONE"
    export INTERFACE_ETHERNET2_GW="NONE"

    # ==========================================================
    # Recherche des interfaces réseau physiques
    #
    # /sys/class/net/<interface>/device permet d'exclure
    # les interfaces virtuelles telles que :
    #
    #   lo
    #   docker0
    #   br-xxxxxxxxxxxx
    #   vmbrX
    #   vethXXXX
    #   ovs-system
    #
    # et de conserver les interfaces physiques :
    #
    #   eno1
    #   enpXsY
    #   ethX
    #   wlanX
    #   wlpXsY
    #   wlxXXXXXXXXXXXX
    # ==========================================================

    while IFS= read -r iface; do

        [[ "${iface}" == "lo" ]] && continue

        if [[ -e "/sys/class/net/${iface}/device" ]]; then
            physical_interfaces+=("${iface}")
        fi

    done < <(
        ip -o link show |
        awk -F': ' '{print $2}' |
        cut -d'@' -f1
    )

    # ==========================================================
    # Analyse des interfaces physiques
    #
    # Maximum : deux interfaces
    # ==========================================================

    for iface in "${physical_interfaces[@]:0:2}"; do

        index=$((index + 1))

        ip_cidr="NONE"
        ip_addr="NONE"
        gateway="NONE"
        state="DOWN"
        type="NONE"
        master="NONE"
        operstate=""

        # ------------------------------------------------------
        # Etat physique de l'interface
        #
        # STATE ne peut avoir que deux valeurs :
        #
        #   UP
        #   DOWN
        # ------------------------------------------------------

        if [[ -r "/sys/class/net/${iface}/operstate" ]]; then
            operstate="$(<"/sys/class/net/${iface}/operstate")"
        fi

        if [[ "${operstate}" == "up" ]]; then
            state="UP"
        else
            state="DOWN"
        fi

        # ------------------------------------------------------
        # Adresse IPv4
        # ------------------------------------------------------

        ip_cidr="$(
            ip -o -4 addr show dev "${iface}" scope global 2>/dev/null |
            awk 'NR == 1 {print $4}'
        )"

        if [[ -n "${ip_cidr}" ]]; then
            ip_addr="${ip_cidr%/*}"
        else
            ip_cidr="NONE"
            ip_addr="NONE"
        fi

        # ------------------------------------------------------
        # Passerelle IPv4
        #
        # Recherche de la route par défaut utilisant
        # directement cette interface.
        # ------------------------------------------------------

        gateway="$(
            ip -4 route show default dev "${iface}" 2>/dev/null |
            awk '
                NR == 1 {
                    for (i = 1; i <= NF; i++) {
                        if ($i == "via") {
                            print $(i + 1)
                            exit
                        }
                    }
                }
            '
        )"

        if [[ -z "${gateway}" ]]; then
            gateway="NONE"
        fi

        # ------------------------------------------------------
        # Recherche du master réseau
        #
        # Exemple :
        #
        #   eno1 master vmbr0
        #
        # Cela permet notamment de déterminer si l'interface
        # physique est rattachée à un bridge Proxmox.
        # ------------------------------------------------------

        master="$(
            ip -o link show dev "${iface}" 2>/dev/null |
            sed -n 's/.* master \([^ ]*\).*/\1/p'
        )"

        if [[ -z "${master}" ]]; then
            master="NONE"
        fi

        # ------------------------------------------------------
        # Détermination du type de configuration
        #
        # TYPE peut avoir les valeurs :
        #
        #   NONE
        #   DHCP
        #   STATIC
        #   PROXMOX
        #   LXC
        # ------------------------------------------------------

        if [[ "${master}" == vmbr* ]]; then

            type="PROXMOX"

        elif [[ "${master}" == lxcbr* ]]; then

            type="LXC"

        elif [[ "${ip_addr}" == "NONE" ]]; then

            type="NONE"

        elif ip -4 addr show dev "${iface}" 2>/dev/null |
             grep -qE '\bdynamic\b'; then

            type="DHCP"

        else

            type="STATIC"

        fi

        # ------------------------------------------------------
        # Création des variables globales
        # ------------------------------------------------------

        printf -v "INTERFACE_ETHERNET${index}" \
            '%s' "${iface}"

        printf -v "INTERFACE_ETHERNET${index}_STATE" \
            '%s' "${state}"

        printf -v "INTERFACE_ETHERNET${index}_TYPE" \
            '%s' "${type}"

        printf -v "INTERFACE_ETHERNET${index}_IP" \
            '%s' "${ip_addr}"

        printf -v "INTERFACE_ETHERNET${index}_IP_CIDR" \
            '%s' "${ip_cidr}"

        printf -v "INTERFACE_ETHERNET${index}_GW" \
            '%s' "${gateway}"

        # ------------------------------------------------------
        # Export des variables
        # ------------------------------------------------------

        export "INTERFACE_ETHERNET${index}"
        export "INTERFACE_ETHERNET${index}_STATE"
        export "INTERFACE_ETHERNET${index}_TYPE"
        export "INTERFACE_ETHERNET${index}_IP"
        export "INTERFACE_ETHERNET${index}_IP_CIDR"
        export "INTERFACE_ETHERNET${index}_GW"

    done
}

launch_oc_shell() {

	local project_id="$1"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"
	su - "${ENV_DEVOPS_USER}" -c "docker exec -it ${project_id}-opencode sh"
}

launch_ocro() {

    local project_id="$1"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"

    if [[ ! -e "$project_path/.opencode/share" ]]; then
        echo "❌ Le projet n'existe pas :"
        echo "   $project_path/.opencode/share"
        exit 1
    fi

    ensure_docker_image \
        "${ENV_DOCKER_IMAGE_OPENCODE}" \
        "${ENV_DOCKER_IMAGE_OPENCODE_UPDATE_POLICY}"  || return 1

    su - "${ENV_DEVOPS_USER}" -c "docker run --rm -it \
      --hostname opencode \
      --name opencode \
      --workdir /workspace \
      --tmpfs /tmp:rw,exec,nosuid,nodev,size=256m,mode=1777 \
      --security-opt no-new-privileges:true \
      --pids-limit 256 \
      --memory 2g \
      --cpus 2 \
      --group-add ${docker_gid} \
      --network=host \
      -e OPENCODE_UID=$(id -u "${ENV_DEVOPS_USER}") \
      -e OPENCODE_GID=$(id -g "${ENV_DEVOPS_USER}") \
      -e HOME=/home/opencode \
      -e XDG_CACHE_HOME=/home/opencode/.cache \
      -e XDG_CONFIG_HOME=/home/opencode/.config \
      -e XDG_DATA_HOME=/home/opencode/.local/share \
      -e XDG_STATE_HOME=/home/opencode/.local/state \
      -e NPM_CONFIG_CACHE=/home/opencode/.cache/opencode/npm \
      -e OPENCODE_CONFIG=/home/opencode/.config/opencode/opencode.json \
      -e OPENCODE_DISABLE_AUTOUPDATE=true \
      -e OPENCODE_DISABLE_DEFAULT_PLUGINS=false \
      -e OPENCODE_DISABLE_LSP_DOWNLOAD=false \
      -e PATH='/opt/devops/npm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
      -p 4096:4096 \
      -v /var/run/docker.sock:/var/run/docker.sock \
	  -v /home/devops/datas/${project_id}:/workspace:ro \
      -v /home/devops/datas/${project_id}/.opencode/cache:/home/opencode/.cache/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/config:/home/opencode/.config/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/share:/home/opencode/.local/share:rw \
      -v /home/devops/datas/${project_id}/.opencode/state:/home/opencode/.local/state/opencode:rw \
      -v /home/devops/.local/npm:/opt/devops/npm:ro \
      --entrypoint /bin/sh \
      ghcr.io/anomalyco/opencode \
      -c 'apk add --no-cache bash git docker docker-cli-compose nodejs npm shellcheck su-exec && \
			exec su-exec \"\$OPENCODE_UID:\$OPENCODE_GID\" opencode --hostname 0.0.0.0 --port 4096'"
}

launch_ocrw() {
    local project_id="$1"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"

    local opencode_uid
    local opencode_gid
    local docker_gid

    opencode_uid="$(id -u "${ENV_DEVOPS_USER}")"
    opencode_gid="$(id -g "${ENV_DEVOPS_USER}")"
    docker_gid="$(stat -c '%g' /var/run/docker.sock)"

    if [[ ! -e "$project_path/.opencode/share" ]]; then
        echo "❌ Le projet n'existe pas :"
        echo "   $project_path/.opencode/share"
        exit 1
    fi

    ensure_docker_image \
        "${ENV_DOCKER_IMAGE_OPENCODE}" \
        "${ENV_DOCKER_IMAGE_OPENCODE_UPDATE_POLICY}" || return 1

    # Psycopg est géré par les projets ; installation conteneur désactivée.
    # /usr/bin/python3 -m pip install --break-system-packages "psycopg>=3.2,<4"
    su - "${ENV_DEVOPS_USER}" -c "docker run --rm -it \
      --hostname ${project_id}-opencode \
      --name ${project_id}-opencode \
      --workdir /workspace \
      --tmpfs /tmp:rw,exec,nosuid,nodev,size=256m,mode=1777 \
      --security-opt no-new-privileges:true \
      --pids-limit 256 \
      --memory 2g \
      --cpus 2 \
      --group-add ${docker_gid} \
      --network=host \
      -e OPENCODE_UID=${opencode_uid} \
      -e OPENCODE_GID=${opencode_gid} \
      -e DOCKER_GID=${docker_gid} \
      -e HOME=/home/opencode \
      -e DOCKER_CONFIG=/tmp/docker-config \
      -e XDG_CACHE_HOME=/home/opencode/.cache \
      -e XDG_CONFIG_HOME=/home/opencode/.config \
      -e XDG_DATA_HOME=/home/opencode/.local/share \
      -e XDG_STATE_HOME=/home/opencode/.local/state \
      -e NPM_CONFIG_CACHE=/home/opencode/.cache/opencode/npm \
      -e OPENCODE_CONFIG=/home/opencode/.config/opencode/opencode.json \
      -e OPENCODE_DISABLE_AUTOUPDATE=true \
      -e OPENCODE_DISABLE_DEFAULT_PLUGINS=false \
      -e OPENCODE_DISABLE_LSP_DOWNLOAD=false \
      -e PATH='/opt/devops/npm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
      -p 4096:4096 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /home/devops/datas/${project_id}:/workspace:rw \
      -v /home/devops/datas/${project_id}/.opencode/cache:/home/opencode/.cache/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/config:/home/opencode/.config/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/share:/home/opencode/.local/share:rw \
      -v /home/devops/datas/${project_id}/.opencode/state:/home/opencode/.local/state/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/broker:/opt/tools/cab:ro \
      -v /home/devops/.local/npm:/opt/devops/npm:ro \
      --entrypoint /bin/sh \
      ghcr.io/anomalyco/opencode \
      -c 'apk add --no-cache bash build-base ca-certificates curl docker docker-cli-compose git go libffi-dev libpq nodejs npm openssl openssl-dev postgresql17-client python3 py3-pip py3-virtualenv py3-pytest ripgrep shellcheck util-linux && \
          exec setpriv \
            --reuid=\"\$OPENCODE_UID\" \
            --regid=\"\$OPENCODE_GID\" \
            --groups=\"\$DOCKER_GID\" \
            -- \
            opencode --hostname 0.0.0.0 --port 4096'"
}

manage_devops_action() {

    local action_1="${1:-}"
    local project_id="${2:-}"
    local action_2="${3:-}"
    local value="${4:-}"

    case "$action_1" in

        info)
            devops_info
            ;;

        os)
            manage_devops_openspec_action \
                "$action_2" \
                "$project_id" \
                "$value"
            ;;

        *)
            echo "❌ Action inconnue pour la classe 'devops' : ${action_1}"
            rid_display_command_error
            exit 2
            ;;

    esac
}

manage_openspec_action() {
    local action="${1:-}"
    local project_id="${2:-}"
    local spec_name="${3:-}"

    case "$action" in
        list)
            devops_openspec_list "$project_id"
            ;;
        show)
            devops_openspec_show "$project_id"
            ;;
        vc)
            devops_openspec_validate_change "$project_id" "$spec_name"
            ;;
        vs)
            devops_openspec_validate_spec "$project_id" "$spec_name"
            ;;
        temp)
            devops_openspec_templates "$project_id"
            ;;
        view)
            devops_openspec_view "$project_id"
            ;;
        *)
            echo "❌ Action inconnue pour la classe 'openspec' : $action"
            rid_display_command_error
            exit 2
            ;;
    esac
}

manage_docker_action() {

    local action="${1:-}"
    local subaction="${2:-}"
    local username="${3:-}"
    shift 3 2>/dev/null || true

    case "$action" in

        root)

            case "$subaction" in

                check-containers)
                    docker_root_check_containers
                    ;;

                test)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_root_test "$username"
                    ;;

                diag)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_root_diag "$username"
                    ;;

                *)

                    echo "❌ Action root inconnue : ${subaction}"
                    rid_display_command_error
                    exit 2
                    ;;

            esac
            ;;

        rootless)

            case "$subaction" in

                analyse)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_analyse "$username"
                    ;;

                configure)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_configure "$username"
                    ;;

                delete-state)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_delete_state "$username"
                    ;;

                diag)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_diag "$username"
                    ;;

                exec)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_exec "$username" "$@"
                    ;;

                inspect)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_inspect "$username" "${1:-}"
                    ;;

                log)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_log "$username" "$@"
                    ;;

                ps)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_ps "$username"
                    ;;

                unconfigure)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_unconfigure "$username"
                    ;;

                restore-state)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_restore_state "$username"
                    ;;

                save-state)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_rootless_save_state "$username"
                    ;;

                test)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        rid_display_command_error
                        exit 2
                    fi

                    docker_test_rootless "$username"
                    ;;

                *)

                    echo "❌ Action rootless inconnue : ${subaction}"
                    rid_display_command_error
                    exit 2
                    ;;

            esac
            ;;

        *)

            echo "❌ Action inconnue pour la classe 'docker' : ${action}"
            rid_display_command_error
            exit 2
            ;;

    esac
}

manage_ia_action() {

    local action="${1:-}"
    local value2="${2:-}"
    shift 3 2>/dev/null || true

    case "$action" in

        configure)
            case "$value2" in
                hm)
                    configure_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    rid_display_command_error
                    exit 2
                    ;;
            esac
            ;;

        install)
            case "$value2" in
                hm)
                    install_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    rid_display_command_error
                    exit 2
                    ;;
            esac
            ;;

        start)
            case "$value2" in
                hm)
                    start_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    rid_display_command_error
                    exit 2
                    ;;
            esac
            ;;

        stop)
            case "$value2" in
                hm)
                    stop_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    rid_display_command_error
                    exit 2
                    ;;
            esac
            ;;

        update)
            case "$value2" in
                hm)
                    update_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    rid_display_command_error
                    exit 2
                    ;;
            esac
            ;;

        uninstall)
            case "$value2" in
                hm)
                    uninstall_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    rid_display_command_error
                    exit 2
                    ;;
            esac
            ;;

        *)
            echo "❌ Action (${action}) inconnue pour la classe 'ia'."
            rid_display_command_error
            exit 2
            ;;

    esac
}

manage_project_action() {

    local action="${1:-}"
    local project_id="${2:-}"
    local project_subaction="${2:-}"
    local commit_name=""
    local commit_tag=""
    local commit_timestamp=""

    case "$action" in

        build)
            if [[ $# -ne 3 || ( "${2:-}" != deb && "${2:-}" != debian ) ]]; then
                print_error 'Usage : rid projects build debian <ID PROJECT>'
                return 2
            fi
            projects_build_deb "$3"
            ;;

        template)
            project_id="${3:-}"
            if [[ "$#" -ne 3 || ( "${2:-}" != openspec && "${2:-}" != devops && "${2:-}" != all ) ||
                ( "${2:-}" == all && "${project_id}" != all ) || -z "${project_id}" ||
                "${project_id}" == */* || "${project_id}" == . || "${project_id}" == .. ||
                "${project_id}" =~ [[:cntrl:]] ]]; then
                echo '❌ Usage : rid projects template openspec <ID PROJECT>, rid projects template devops <ID PROJECT> ou rid projects template all all'
                rid_display_command_error projects template
                return 2
            fi
            if [[ "${2}" == all ]]; then
                projects_template_all_all
            elif [[ "${2}" == openspec ]]; then
                if [[ "${project_id}" == all ]]; then
                    projects_template_openspec_all
                else
                    projects_template_openspec "${project_id}"
                fi
            elif [[ "${project_id}" == all ]]; then
                projects_template_devops_all
            else
                projects_template_devops "${project_id}"
            fi
            ;;

        cicd)
            case "${project_id}" in
                help|?)
                    display_help_context projects cicd
                    ;;
                *)
                    commit_timestamp="$(date '+%Y.%m.%d.%H.%M')"
                    if [[ $# -eq 3 ]]; then
                        if [[ ! "$project_id" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ || "$project_id" == .. ]]; then
                            print_error 'Identifiant de projet invalide.'
                            return 1
                        fi
                        project_version_set "${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}/project.env" "$3" || return 1
                        commit_name="$3"
                        commit_tag="v$3"
                    else
                        commit_name="${3:-${commit_timestamp}}"
                        commit_tag="${4:-v${commit_timestamp}}"
                    fi
                    cicd_project \
                        "${project_id}" \
                        "${commit_name}" \
                        "${commit_tag}"
                    ;;
            esac
            ;;

        cicddiu)
			commit_timestamp="$(date '+%Y.%m.%d.%H.%M')"
            commit_name="${2:-${commit_timestamp}}"
            commit_tag="${3:-v${commit_timestamp}}"
            cicd_project_diu \
				"$commit_name" \
				"$commit_tag"
            ;;


        cicddr)
			commit_timestamp="$(date '+%Y.%m.%d.%H.%M')"
            commit_name="${3:-${commit_timestamp}}"
            commit_tag="${4:-v${commit_timestamp}}"
            cicd_project_docker_release \
				"$project_id" \
				"$commit_name" \
				"$commit_tag"
            ;;

        del)
            delete_project \
                "$project_id"
            ;;

        create)
            case "${project_id}" in
                help|?)
                    display_help_context projects create
                    ;;
                *)
                    create_project \
                        "${project_id}"
                    ;;
            esac
            ;;

        clone)
            case "${project_id}" in
                help|?)
                    display_help_context projects clone
                    ;;
                *)
                    clone_project \
                        "${project_id}" \
                        "${3:-}"
                    ;;
            esac
            ;;

        update)
            if [[ "$#" -eq 1 ]]; then
                projects_update
            elif [[ "$#" -eq 2 && -n "${project_id}" ]]; then
                update_projects "${project_id}"
            else
                echo '❌ Usage : rid projects update ou rid projects update <ID PROJECT>'
                rid_display_command_error projects update
                return 2
            fi
            ;;

        sync)
            case "${project_id}" in
                all)
                    sync_project_all
                    ;;
                help|?)
                    display_help_context projects sync
                    ;;
                *)
                    sync_project \
                        "${project_id}"
                    ;;
            esac
            ;;

        docker)
            case "${project_subaction}" in
                build)
                    projects_docker_build \
                        "${3:-}"
                    ;;
                help|?)
                    display_help_context projects docker
                    ;;
                *)
                    echo "❌ Action inconnue pour la classe 'projects docker' : ${project_subaction}"
                    rid_display_command_error
                    exit 2
                    ;;
            esac
            ;;

        finds)
            proj_find_sync \
                "$project_id"
            ;;

        findads)
            proj_find_and_delete_sync \
                "$project_id"
            ;;


        git)
            project_id="${3:-}"

            case "${project_subaction}" in
                analyse)
                    git_analyse \
                        "$project_id"
                    ;;
                commit)
                    case "${project_id}" in
                        all)
                            commit_timestamp="$(date '+%Y.%m.%d.%H.%M')"
                            commit_name="${commit_timestamp}"
                            commit_tag="v${commit_timestamp}"
                            git_commit_all \
                                "$commit_name" \
                                "$commit_tag"
                            ;;
                        help|?)
                            display_help_context projects git commit
                            ;;
                        *)
                            commit_timestamp="$(date '+%Y.%m.%d.%H.%M')"
                            commit_name="${4:-${commit_timestamp}}"
                            commit_tag="${5:-v${commit_timestamp}}"
                            git_commit \
                                "$project_id" \
                                "$commit_name" \
                                "$commit_tag"
                            ;;
                    esac
                    ;;
                init)
                    git_init \
                        "${project_id}"
                    ;;
                update)
                    git_update \
                        "${project_id}"
                    ;;
                status)
                    git_status \
                        "${project_id}"
                    ;;
                help|?)
                    display_help_context projects git
                    ;;
                *)
                    echo "❌ Action inconnue pour la classe 'projects git' : ${project_subaction}"
                    rid_display_command_error
                    exit 2
                    ;;
            esac
            ;;

        gitic)
            git_init_clone \
                "$project_id"
            ;;

        gitlab)
            if [[ "${project_subaction}" == "help" || "${project_subaction}" == "?" ]]; then
                display_help_context projects gitlab
                exit 0
            fi

            project_id="${3:-}"

            case "${project_subaction}" in
                clone)
                    case "${3:-}" in
                        help|?)
                            display_help_context projects gitlab clone
                            ;;
                        *)
                            gitlab_clone "${3:-}"
                            ;;
                    esac
                    ;;
                update)
                    gitlab_update \
                        "${project_id}"
                    ;;
                push)
                    gitlab_push \
                        "$project_id"
                    ;;
                release)
                    projects_gitlab_release \
                        "${project_id}"
                    ;;
                help|?)
                    display_help_context projects gitlab
                    ;;
                *)
                    echo "❌ Action inconnue pour la classe 'projects gitlab' : ${project_subaction}"
                    rid_display_command_error
                    exit 2
                    ;;
            esac

            ;;

        github)
            if [[ "${project_subaction}" == "help" || "${project_subaction}" == "?" ]]; then
                display_help_context projects github
                exit 0
            fi

            project_id="${3:-}"

            case "${project_subaction}" in
                clone)
                    case "${3:-}" in
                        help|?)
                            display_help_context projects github clone
                            ;;
                        *)
                            github_clone "${3:-}"
                            ;;
                    esac
                    ;;
                update)
                    github_update \
                        "${project_id}"
                    ;;
                push)
                    github_push \
                        "${project_id}"
                    ;;
                release)
                    projects_github_release \
                        "${project_id}"
                    ;;
                help|?)
                    display_help_context projects github push
                    ;;
                *)
                    echo "❌ Action inconnue pour la classe 'projects github' : ${project_subaction}"
                    rid_display_command_error
                    exit 2
                    ;;
            esac

            ;;

        forgejo)
            if [[ "${project_subaction}" == "help" || "${project_subaction}" == "?" ]]; then
                display_help_context projects forgejo
                exit 0
            fi

            project_id="${3:-}"

            case "${project_subaction}" in
                update)
                    forgejo_update \
                        "${project_id}"
                    ;;
                push)
                    if [[ "${project_id}" == "all" ]]; then
                        forgejo_push_all
                    else
                        forgejo_push \
                            "${project_id}"
                    fi
                    ;;
                release)
                    projects_forgejo_release \
                        "${project_id}"
                    ;;
                help|?)
                    display_help_context projects forgejo push
                    ;;
                *)
                    echo "❌ Action inconnue pour la classe 'projects forgejo' : ${project_subaction}"
                    rid_display_command_error
                    exit 2
                    ;;
            esac

            ;;

        gitpdiu)
            publish_release_diu
            ;;

        ocro)
            launch_ocro \
                "$project_id"
            ;;

        ocrw)
            launch_ocrw \
                "$project_id"
            ;;

        ocsh)
            launch_oc_shell \
                "$project_id"
            ;;

        deb)
            if [[ $# -gt 2 ]]; then
                print_error "Usage : rid projects deb [ID PROJECT]"
                return 2
            fi
            build_deb_diu "${project_id:-diu}"
            ;;

        *)
            echo "❌ Action inconnue pour la classe 'proj' : ${action}"
            rid_display_command_error
            exit 2
            ;;

    esac
}

devops_openspec_list() {
    local project_id="$1"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$ENV_DEVOPS_USER" -c "cd '$project_path' && openspec list"

    exit 0
}

devops_openspec_show() {
    local project_id="$1"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$ENV_DEVOPS_USER" -c \
        "cd '$project_path' && openspec spec list"
}

devops_openspec_validate_change() {
    local project_id="$1"
    local spec_name="$2"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$ENV_DEVOPS_USER" -c "cd '$project_path' && openspec validate '$spec_name' --type change --strict"

    exit 0
}

devops_openspec_validate_spec() {
    local project_id="$1"
    local spec_name="$2"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$ENV_DEVOPS_USER" -c "cd '$project_path' && openspec validate '$spec_name' --type spec --strict"

    exit 0
}

devops_openspec_templates() {
    local project_id="$1"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$ENV_DEVOPS_USER" -c "cd '$project_path' && openspec templates"

    exit 0
}

devops_openspec_view() {
    local project_id="$1"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$ENV_DEVOPS_USER" -c "cd '$project_path' && openspec view"

    exit 0
}

# Affichage des erreurs
trap 'error_handler' ERR

# Analyse des Interfaces Physique
info_network_detect_interfaces

# Analyse des arguments transmis au DIU.
dispatch_arguments "$@"

######################
###### ROOT MODE #####
######################

###  PROXY ###

if [[ "${SYSTEM_PROXY_CA:-0}" == "1" ]]
then

	echo "🔧 Configure CA"
	echo "$CA" > /usr/local/share/ca-certificates/CHN.crt
	update-ca-certificates
	find /etc/ssl/certs/ -mindepth 1 -maxdepth 1 -iname '*chn*' -printf '%f\n'
	openssl x509 -in /etc/ssl/certs/CHN.pem -text -noout

fi

if [[ "${SYSTEM_PROXY:-0}" == "1" ]]
then

	echo "🔧 CONFIGURE PROXY HTTP FOR APT"
	echo "Acquire::http::Proxy \"http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT\";" > /etc/apt/apt.conf.d/91proxyhttp

	echo "CONFIGURE PROXY HTTP FOR SYSTEM VIA PROFILE.D"
	echo "export http_proxy=http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT" > /etc/profile.d/proxy.sh
	{
	    echo "export https_proxy=http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT"
	    echo "export HTTP_PROXY=http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT"
	    echo "export HTTPS_PROXY=http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT"
	    echo "export no_proxy=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr"
	    echo "export NO_PROXY=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr"
	} >> /etc/profile.d/proxy.sh

	echo "CONFIGURE PROXY HTTP FOR SYSTEM VIA ENVIRONMENT"
	echo "http_proxy=http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT" > /etc/environment
	{
	    echo "https_proxy=http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT"
	    echo "HTTP_PROXY=http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT"
	    echo "HTTPS_PROXY=http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT"
	    echo "no_proxy=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr"
	    echo "NO_PROXY=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr"
	} >> /etc/environment

	# mkdir -p /etc/environment.d/
	# echo "http_proxy=http://$PROXY_HTTP_HOST" > /etc/environment.d/proxy.conf
	# echo "https_proxy=http://$PROXY_HTTPS_HOST" > /etc/environment.d/proxy.conf
	# echo "HTTP_PROXY=http://$PROXY_HTTP_HOST" >> /etc/environment.d/proxy.conf
	# echo "HTTPS_PROXY=http://$PROXY_HTTPS_HOST" >> /etc/environment.d/proxy.conf
	# echo "no_proxy=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr" >> /etc/environment.d/proxy.conf
	# echo "NO_PROXY=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr" >> /etc/environment.d/proxy.conf

	echo "CONFIGURE PROXY HTTP FOR WGET"
	sed -i "s%.*http_proxy.*%http_proxy = $PROXY_HTTP_HOST:$PROXY_HTTP_PORT%" /etc/wgetrc
	sed -i "s%.*https_proxy.*%http_proxy = $PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT%" /etc/wgetrc

	echo "CHECK PROXY HTTP ON DEBIAN.ORG"
	curl -I http://debian.org
	echo "CHECK PROXY HTTPS ON DEBIAN.ORG"
	curl -I https://debian.org

	if [ "$DOCKER" -eq 1 ]
	then

		mkdir -p /etc/systemd/system/docker.service.d
		echo "CONFIGURE PROXY HTTP FOR DOCKER"
		echo "[Service]" > /etc/systemd/system/docker.service.d/http-proxy.conf
		echo "Environment='HTTP_PROXY'='http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT'" >> /etc/systemd/system/docker.service.d/http-proxy.conf
		echo "Environment='NO_PROXY'='localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr'" >> /etc/systemd/system/docker.service.d/http-proxy.conf

		echo "CONFIGURE PROXY HTTPS FOR DOCKER"
		echo "[Service]" > /etc/systemd/system/docker.service.d/https-proxy.conf
		echo "Environment='HTTPS_PROXY'='http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT'" >> /etc/systemd/system/docker.service.d/https-proxy.conf
		echo "Environment='NO_PROXY'='localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr'" >> /etc/systemd/system/docker.service.d/https-proxy.conf

	fi

else

	if [ -f /etc/apt/apt.conf.d/91proxyhttp ]
	then

		rm -f /etc/apt/apt.conf.d/91proxyhttp

	fi

	if [ -f /etc/profile.d/proxy.sh ]
	then

		rm -f /etc/profile.d/proxy.sh

	fi

	if [ -f /etc/environment ]
	then

		rm -f /etc/environment

	fi

	if [ -f /etc/environment.d/proxy.conf ]
	then

		rm -f /etc/environment.d/proxy.conf

	fi

	sed -i "s%.*http_proxy=.*%#http_proxy = http://proxy.yoyodyne.com:18023/%" /etc/wgetrc

fi


### PREREQUISITES ###

system_install_prerequisites

### APT ###

system_apt_debian_configure

if [ "$SYSTEM_DEBIAN_RELEASE" = "trixie" ]
then

	### TiME ZONE ###
	echo "🔧 CONFIGURE TIME ZONE FOR DEBIAN TRIXIE"
	timedatectl set-timezone "$SYSTEM_TIME_ZONE"
	# unlink /etc/localtime
	# ln -s /usr/share/timezone/$SYSTEM_TIME_ZONE /etc/localtime

	install -d -m 0755 /usr/share/keyrings

	if [ -f /etc/apt/sources.list ]
	then

		rm -f /etc/apt/sources.list

	fi

	install -d -m 0755 /usr/share/keyrings

	# Force IPv4.
	echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

	mkdir -p /etc/crypto-policies/back-ends
	echo '[hash_algorithms]' > /etc/crypto-policies/back-ends/sequoia.config
	{
	    echo 'sha1 = "always"'
	    echo ''
	    echo '[asymmetric_algorithms]'
	    echo 'dsa1024 = "always"'
	} >> /etc/crypto-policies/back-ends/sequoia.config

fi

if [ "$SYSTEM_DEBIAN_RELEASE" = "bookworm" ]
then

	echo "🔧 CONFIGURE APT SOURCES FOR DEBIAN BOOKWORM"
	echo '' > /etc/apt/sources.list
	{
	    echo 'deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware'
	    echo ''
	    echo 'deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware'
	    echo ''
	    echo 'deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware'
	    echo ''
	    echo 'deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware'
	    echo ''
	} >> /etc/apt/sources.list





	echo ""
	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo ""
	echo "🔧 UPDATE & DIST-UPGRADE"
	apt -y update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade

	echo ""
	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo "🔧 TMP MOUNT"
	if [ -e /usr/share/systemd/tmp.mount ]
	then
		mv -f /usr/share/systemd/tmp.mount /etc/systemd/system
		systemctl enable tmp.mount
	fi

fi

if [ "$SYSTEM_DEBIAN_RELEASE" = "bullseye" ]
then

	echo "🔧 CONFIGURE APT SOURCES FOR DEBIAN BULLSEYE"
	echo '' > /etc/apt/sources.list
	{
	    echo 'deb http://deb.debian.org/debian bullseye main contrib non-free'
	    echo ''
	    echo 'deb http://security.debian.org/debian-security bullseye-security main contrib non-free'
	    echo ''
	    echo 'deb http://deb.debian.org/debian bullseye-updates main contrib non-free'
	    echo ''
	} >> /etc/apt/sources.list
	# echo 'deb http://deb.debian.org/debian bullseye-backports main contrib non-free' >> /etc/apt/sources.list
	# echo '' >> /etc/apt/sources.list


	if [[ "${DIU_APT_REPOSITORY_FD:-0}" == "1" ]]; then

		if ! gpg --keyserver keys.openpgp.org --recv-key 0xFE0FEAE5AC483A86 &>/dev/null; then
			echo "⚠️ IMPOSSIBLE DE RÉCUPÉRER LA CLÉ FUSIONDIRECTORY : DÉPÔT APT NON CONFIGURÉ"
		elif ! gpg --export "FusionDirectory Packages Signing Key <contact@fusiondirectory.org>" > /usr/share/keyrings/fd-archive-keyring.gpg; then
			echo "⚠️ IMPOSSIBLE D’EXPORTER LA CLÉ FUSIONDIRECTORY : DÉPÔT APT NON CONFIGURÉ"
		else
			echo "🔧 CONFIGURE APT FUSION DIRECTORY SOURCES FOR DEBIAN BULLSEYE"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/fd-archive-keyring.gpg] https://public.fusiondirectory.org/debian/fusiondirectory-integrator/ bullseye main' > /etc/apt/sources.list.d/fusion-directory.list
			{
			    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/fd-archive-keyring.gpg] https://public.fusiondirectory.org/debian/fusiondirectory-tools/ bullseye main'
			    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/fd-archive-keyring.gpg] https://public.fusiondirectory.org/debian/fusiondirectory-external-libraries/ bullseye main'
			    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/fd-archive-keyring.gpg] https://public.fusiondirectory.org/debian/bullseye-fusiondirectory-release/ bullseye main'
			    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/fd-archive-keyring.gpg] https://public.fusiondirectory.org/debian/bullseye-fusiondirectory-orchestrator-release/ bullseye main'
			} >> /etc/apt/sources.list.d/fusion-directory.list
		fi


	fi



	echo ""
	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo ""
	echo "🔧 UPDATE & DIST-UPGRADE"
	apt -y update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade

	echo ""
	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo "🔧 TMP MOUNT"
	if [ -e /usr/share/systemd/tmp.mount ]
	then
		mv -f /usr/share/systemd/tmp.mount /etc/systemd/system
		systemctl enable tmp.mount
	fi

fi


### DRIVERS ###

if [[ "${SYSTEM_DRIVERS_NVIDIA:-0}" == "1" ]]
then

	# https://wiki.debian.org/NvidiaGraphicsDrivers
	# https://github.com/NVIDIA/cuda-repo-management
	# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#debian-installation
	# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
	# https://nvidia.github.io/libnvidia-container/stable/deb/

	if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "PROXMOX" ]
	then

		if dpkg -s pve-headers &>/dev/null
		then

			echo ""
			echo "PREQUISITES FOR NVIDIA DRIVERS FOR PROXMOX OK"

		else

			echo ""
			echo "INSTALL PREQUISITES FOR NVIDIA DRIVERS FOR PROXMOX"
			apt install dkms pve-headers "pve-headers-$(uname -r)" proxmox-default-headers build-essential make mdevctl -y
			echo ""

		fi

	else

		if dpkg -s linux-headers-amd64 &>/dev/null
		then

			echo ""
			echo "PREQUISITES FOR NVIDIA DRIVERS OK"

		else

			echo ""
			echo "INSTALL PREQUISITES FOR NVIDIA DRIVERS"
			apt install dkms linux-headers-amd64 build-essential make mdevctl -y
			echo ""

		fi

	fi

	if [ "$SECURE_BOOT" == "1" ]
	then

		if test -f /var/lib/dkms/mok.key
		then

			echo "SECURE BOOT IS ALREADY UP TO DATE FOR NVIDIA DRIVERS"		

		else

			echo "CONFIGURE SECURE BOOT FOR NVIDIA DRIVERS"

			if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "PROXMOX" ]
			then

				apt install shim-signed grub-efi-amd64-signed mokutil
				dkms generate_mok
				mokutil --import /var/lib/dkms/mok.pub # prompts for one-time password
				mokutil --list-new # recheck your key will be prompted on next boot
				echo "RESTART COMPUTER NOW..."
				exit

			else

				apt install shim-signed grub-efi-amd64-signed mokutil
				dkms generate_mok
				mokutil --import /var/lib/dkms/mok.pub # prompts for one-time password
				mokutil --list-new # recheck your key will be prompted on next boot
				echo "RESTART COMPUTER NOW..."
				exit

			fi

		fi

	fi

	if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "PROXMOX" ]
	then

		if dpkg -s pve-nvidia-vgpu-helper &>/dev/null
		then

			if [ "$SECURE_BOOT" == "1" ]
			then

				if dpkg -s nvidia-driver &>/dev/null
				then

					echo "NVIDIA DRIVERS FOR PROXMOX WITH SECURE BOOT OK"

				else

					echo "INSTALL NVIDIA DRIVERS FOR PROXMOX WITH SECURE BOOT"
					apt install nvidia-driver cuda nvidia-settings nvtop nvidia-container-toolkit -y
					# chmod +x /root/$DRIVERS_NVIDIA_SETUP
					# /root/$DRIVERS_NVIDIA_SETUP --accept-license --dkms --skip-module-load --sanity
					# dkms build -m nvidia -v $DRIVERS_NVIDIA_VERSION --force
					# dkms install -m nvidia -v $DRIVERS_NVIDIA_VERSION --force

					dkms status
					lspci -d 10de: -nnk
					nvidia-smi
					lsmod | grep nv
					ls -al /dev/nvidia*

					systemctl enable --now pve-nvidia-sriov@ALL.service

					echo "RESTART COMPUTER NOW..."
					exit

				fi

			else

				if dpkg -s nvidia-driver &>/dev/null
				then

					echo "NVIDIA DRIVERS FOR PROXMOX OK"

				else

					echo "INSTALL NVIDIA DRIVERS FOR PROXMOX"
					apt install nvidia-driver cuda nvidia-settings nvtop nvidia-container-toolkit -y
					# chmod +x /root/$DRIVERS_NVIDIA_SETUP
					# /root/$DRIVERS_NVIDIA_SETUP --accept-license --dkms --sanity
					# /root/$DRIVERS_NVIDIA_SETUP --accept-license --dkms --sanity

					dkms status
					lspci -d 10de: -nnk
					nvidia-smi
					lsmod | grep nv
					ls -al /dev/nvidia*

					systemctl enable --now pve-nvidia-sriov@ALL.service

					echo "RESTART COMPUTER NOW..."
					exit
					
				fi

			fi

		else

			echo "PREINSTALL NVIDIA DRIVERS FOR PROXMOX"
			apt install pve-nvidia-vgpu-helper -y
			pve-nvidia-vgpu-helper setup
			echo "RESTART COMPUTER NOW..."
			exit

		fi

	else

		if dpkg -l nvidia-driver &>/dev/null
		then

			echo "NVIDIA DRIVERS OK"

		else

			echo "INSTALL NVIDIA DRIVERS"
			apt install nvidia-driver cuda nvidia-settings nvtop -y
			dkms status
			lspci -d 10de: -nnk
			nvidia-smi
			lsmod | grep nv

			systemctl enable --now pve-nvidia-sriov@ALL.service
			
		fi

	fi

fi


### FSTAB ###

if [[ "${SYSTEM_FSTAB:-0}" == "1" ]]
then

	echo ""
	echo "🔧 CONFIGURATION FSTAB"
	if [[ "${SYSTEM_FSTAB_CONFIG1-NONE}" != "NONE" ]]
	then

		echo "${SYSTEM_FSTAB_CONFIG1-}" > /etc/fstab

	fi

	if [[ "${SYSTEM_FSTAB_CONFIG2-NONE}" != "NONE" ]]
	then

		echo "${SYSTEM_FSTAB_CONFIG2-}" >> /etc/fstab

	fi

	if [[ "${SYSTEM_FSTAB_CONFIG3-NONE}" != "NONE" ]]
	then

		echo "${SYSTEM_FSTAB_CONFIG3-}" >> /etc/fstab

	fi

	if [[ "${SYSTEM_FSTAB_CONFIG4-NONE}" != "NONE" ]]
	then

		echo "${SYSTEM_FSTAB_CONFIG4-}" >> /etc/fstab

	fi

	if [[ "${SYSTEM_FSTAB_CONFIG5-NONE}" != "NONE" ]]
	then

		echo "${SYSTEM_FSTAB_CONFIG5-}" >> /etc/fstab

	fi

	if [[ "${SYSTEM_FSTAB_CONFIG6-NONE}" != "NONE" ]]
	then

		echo "${SYSTEM_FSTAB_CONFIG6-}" >> /etc/fstab

	fi

fi


### FILE2RAM ###

if [[ "${SYSTEM_FILES2RAM:-0}" == "1" ]]
then

	echo ""
	echo "🔧 CONFIGURATION FILES2RAM"

	if [ ! -f /etc/tmpfiles.d/var2log.conf ]
	then

		rm -r -d -f --interactive=never /var/log/*

	fi

	# DIRECTORY
	# echo "D /var/log  0755 root root" > /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/apt  0755 root root" > /etc/tmpfiles.d/var2log.conf
	{
	    echo "D /var/log/chrony  0755 root root"
	    echo "D /var/log/exim4  0755 root root"
	    echo "D /var/log/frr  0755 root root"
	    echo "D /var/log/ifupdown2  0755 root root"
	    echo "D /var/log/installer  0755 root root"
	    echo "D /var/log/installer/cdebconf  0755 root root"
	    echo "D /var/log/journal  0755 root root"
    	# echo "D /var/log/private  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	    echo "D /var/log/runit  0755 root root"
	    echo "D /var/log/runit/ssh  0755 root root"

    	# FILES
	    echo "F /var/log/FILES2RAM_OK  0755 root root"
	    echo "F /var/log/alternatives.log  0755 root root"
	    echo "F /var/log/boot.log  0755 root root"
	    echo "F /var/log/daemon.log  0755 root root"
	    echo "F /var/log/dpkg.log  0755 root root"
    	# echo "F /var/log/exim4/mainlog  0755 Debian-exim adm" >> /etc/tmpfiles.d/var2log.conf
    	# echo "F /var/log/exim4/paniclog  0755 Debian-exim adm" >> /etc/tmpfiles.d/var2log.conf
	    echo "F /var/log/popularity-contest  0755 root root"
	    echo "F /var/log/popularity-contest.gpg  0755 root root"
	} >> /etc/tmpfiles.d/var2log.conf

	if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "PROXMOX" ]
	then

		{
		    echo "D /var/log/ceph  0755 root root"
		    echo "D /var/log/corosync  0755 root root"
		    echo "D /var/log/lxc  0755 root root"
		    echo "D /var/log/pve  0755 root root"
		    echo "D /var/log/pve/tasks  0755 root root"
		    echo "D /var/log/pveproxy  0755 www-data www-data"
		    echo "F /var/log/pveam.log 0755 root root"
		    echo "F /var/log/pve-firewall.log 0755 root root"
		} >> /etc/tmpfiles.d/var2log.conf

	fi

	if [[ "${DESKTOP:-0}" == "1" ]]
	then

		if [ "$DESKTOP_GUI" == "GNOME" ]
		then

			{
			    echo "D /var/log/cups  0755 root root"
			    echo "D /var/log/gdm3  0755 root Debian-gdm"
			    echo "D /var/log/samba  0755 root adm"
			    echo "D /var/log/speech-dispatcher  0755 speech-dispatcher root"
			    echo "F /var/log/fontconfig.log  0755 root root"
			    echo "F /var/log/Xorg.0.log 0755 root root"
			} >> /etc/tmpfiles.d/var2log.conf

		fi

	fi

	if [[ "${SYSTEM_DRIVERS_NVIDIA:-0}" == "1" ]]
	then

		echo "D /var/log/nvidia-mps  0755 root root" >> /etc/tmpfiles.d/var2log.conf
		echo "D /var/log/nvtopps  0755 root root" >> /etc/tmpfiles.d/var2log.conf

	fi

	# Apply now
	systemd-tmpfiles --create

	# systemctl enable systemd-tmpfiles-setup.service
	systemctl start systemd-tmpfiles-setup.service

	if  [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "PHYSICAL" ]
	then

		echo "🔧 CONFIGURATION FSTAB"
		if [[ "${SYSTEM_FSTAB_CONFIG1-NONE}" == "NONE" ]]
		then

			# echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime,mode=1755				0 0" > /etc/fstab
			echo "❌ FSTAB DEVRAIT ETRE CONFIGURER PAR ROOT-INSTALL.SH SUR UNE DEBIAN PHYSICAL"

		else

			# echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime,mode=1755				0 0" >> /etc/fstab
			echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime			0 0" >> /etc/fstab

		fi

	else

					echo "🔧 CONFIGURATION FSTAB"
		if [[ "${SYSTEM_FSTAB_CONFIG1-NONE}" == "NONE" ]]
		then

			# echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime,mode=1755				0 0" > /etc/fstab
			echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime			0 0" > /etc/fstab

		else

			# echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime,mode=1755				0 0" >> /etc/fstab
			echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime			0 0" >> /etc/fstab

		fi


	fi

fi


### GRUB ###

if [[ "${SYSTEM_GRUB_CONFIG:-0}" == "1" ]]
then

	echo ""
	echo "🔧 CONFIGURATION GRUB"
	sed -i "s#GRUB_CMDLINE_LINUX_DEFAULT.*#GRUB_CMDLINE_LINUX_DEFAULT=$GRUB_CMDLINE_LINUX_DEFAULT#" q
	update-grub

fi


### KERNEL ###

echo "🔧 CONFIGURE SYSCTL (KERNEL)"
# SYSTEM_IPV6 est initialisée depuis sysctl si aucune valeur n'est configurée.
if [[ "${SYSTEM_IPV6:-0}" == "1" ]]
then

	if [ -e /etc/sysctl.d/70-disable-ipv6.conf ]
	then

		rm -f /etc/sysctl.d/70-disable-ipv6.conf

	fi

else

	echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/70-disable-ipv6.conf
	echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/70-disable-ipv6.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf

fi

if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "LXC" ]
then

	echo "net.ipv4.conf.all.accept_redirects = 1" > /etc/sysctl.d/tune.conf
	{
	    echo "net.ipv4.conf.all.accept_source_route = 0"
	    echo "net.ipv4.conf.all.secure_redirects = 1"
	    echo "net.ipv4.conf.all.send_redirects = 0"
	    echo "net.ipv4.conf.all.log_martians = 0"
	    echo "net.ipv4.conf.all.rp_filter = 1"
	    echo "net.ipv4.conf.default.accept_redirects = 0"
	    echo "net.ipv4.conf.default.accept_source_route = 0"
	    echo "net.ipv4.conf.default.secure_redirects = 0"
	    echo "net.ipv4.conf.default.send_redirects = 0"
	    echo "net.ipv4.conf.default.log_martians = 0"
	    echo "net.ipv4.conf.default.rp_filter = 1"
	    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1"
	    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1"
	    echo "net.ipv4.ip_forward = 1"
	    echo "net.ipv4.ip_local_port_range = 1025    65535"
	    echo "net.ipv4.ip_no_pmtu_disc = 1"
	    echo "net.ipv4.ipfrag_high_thresh=8388608"
	    echo "net.ipv4.ipfrag_low_thresh=196608"
	    echo "net.ipv4.route.min_pmtu = 536"
	    echo "net.ipv4.tcp_adv_win_scale = 14"
	    echo "net.ipv4.tcp_base_mss = 1460"
	    echo "net.ipv4.tcp_challenge_ack_limit = 9999"
	    echo "net.ipv4.tcp_congestion_control = htcp"
	    echo "net.ipv4.tcp_ecn = 1"
	    echo "net.ipv4.tcp_fastopen=3"
	    echo "net.ipv4.tcp_fin_timeout = 10"
	    echo "net.ipv4.tcp_keepalive_time = 600"
	    echo "net.ipv4.tcp_keepalive_intvl = 15"
	    echo "net.ipv4.tcp_keepalive_probes = 5"
	    echo "net.ipv4.tcp_limit_output_bytes = 65536"
	    echo "net.ipv4.tcp_sack = 1"
	    echo "net.ipv4.tcp_mtu_probing = 1"
	    echo "net.ipv4.tcp_rfc1337 = 1"
	    echo "net.ipv4.tcp_slow_start_after_idle = 0"
	    echo "net.ipv4.tcp_no_metrics_save = 1"
	    echo "net.ipv4.tcp_syncookies = 0"
	    echo "net.ipv4.tcp_syn_retries = 2"
	    echo "net.ipv4.tcp_synack_retries = 2"
	    echo "net.ipv4.tcp_orphan_retries = 2"
	    echo "net.ipv4.tcp_max_syn_backlog = 40000"
	    echo "net.ipv4.tcp_max_tw_buckets = 2000000"
	    echo "net.ipv4.tcp_wmem = 4096        524288   67108864"
	    echo "net.ipv4.tcp_rmem = 4096        524288   67108864"
	    echo "net.ipv4.tcp_timestamps = 1"
	    echo "net.ipv4.tcp_tw_reuse = 1"
	    echo "net.ipv4.tcp_window_scaling = 1"
	    echo "net.ipv4.udp_rmem_min = 8192"
	    echo "net.ipv4.udp_wmem_min = 8192"
	    echo "net.unix.max_dgram_qlen = 4096"
	    echo "net.ipv6.conf.all.autoconf = 0"
	    echo "net.ipv6.conf.all.forwarding = 1"
	    echo "net.ipv6.conf.default.autoconf = 0"
	    echo "net.ipv6.ip6frag_high_thresh=8388608"
	    echo "net.ipv6.ip6frag_low_thresh=196608"
	    echo "net.core.optmem_max = 4194304"
	    echo "net.core.somaxconn = 256000"
	} >> /etc/sysctl.d/tune.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/tune.conf

fi

if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "PHYSICAL" ]
then

	echo "kernel.panic = 90" > /etc/sysctl.d/tune.conf
	{
	    echo "kernel.panic_on_oops = 1"
	    echo "kernel.sched_autogroup_enabled = 0"
	    echo "kernel.unprivileged_bpf_disabled=1"
	    echo "kernel.sysrq = 1"
	    echo "fs.inotify.max_user_instances = 16777216"
	    echo "fs.inotify.max_queued_events = 8388608"
	    echo "fs.inotify.max_user_watches = 4194304"
	    echo "net.ipv4.conf.all.accept_redirects = 1"
	    echo "net.ipv4.conf.all.accept_source_route = 0"
	    echo "net.ipv4.conf.all.secure_redirects = 1"
	    echo "net.ipv4.conf.all.send_redirects = 0"
	    echo "net.ipv4.conf.all.log_martians = 0"
	    echo "net.ipv4.conf.all.rp_filter = 1"
	    echo "net.ipv4.conf.default.accept_redirects = 0"
	    echo "net.ipv4.conf.default.accept_source_route = 0"
	    echo "net.ipv4.conf.default.secure_redirects = 0"
	    echo "net.ipv4.conf.default.send_redirects = 0"
	    echo "net.ipv4.conf.default.log_martians = 0"
	    echo "net.ipv4.conf.default.rp_filter = 1"
	    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1"
	    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1"
	    echo "net.ipv4.ip_forward = 1"
	    echo "net.ipv4.ip_local_port_range = 1025    65535"
	    echo "net.ipv4.ip_no_pmtu_disc = 1"
	    echo "net.ipv4.ipfrag_high_thresh=8388608"
	    echo "net.ipv4.ipfrag_low_thresh=196608"
	    echo "net.ipv4.neigh.default.gc_thresh1 = 1024"
	    echo "net.ipv4.neigh.default.gc_thresh2 = 2048"
	    echo "net.ipv4.neigh.default.gc_thresh3 = 4096"
	    echo "net.ipv4.route.min_pmtu = 536"
	    echo "net.ipv4.tcp_adv_win_scale = 14"
	    echo "net.ipv4.tcp_base_mss = 1460"
	    echo "net.ipv4.tcp_challenge_ack_limit = 9999"
	    echo "net.ipv4.tcp_congestion_control = htcp"
	    echo "net.ipv4.tcp_ecn = 1"
	    echo "net.ipv4.tcp_fastopen=3"
	    echo "net.ipv4.tcp_fin_timeout = 10"
	    echo "net.ipv4.tcp_keepalive_time = 600"
	    echo "net.ipv4.tcp_keepalive_intvl = 15"
	    echo "net.ipv4.tcp_keepalive_probes = 5"
	    echo "net.ipv4.tcp_limit_output_bytes = 65536"
	    echo "net.ipv4.tcp_low_latency = 1"
	    echo "net.ipv4.tcp_sack = 1"
	    echo "net.ipv4.tcp_mtu_probing = 1"
	    echo "net.ipv4.tcp_rfc1337 = 1"
	    echo "net.ipv4.tcp_slow_start_after_idle = 0"
	    echo "net.ipv4.tcp_no_metrics_save = 1"
	    echo "net.ipv4.tcp_syncookies = 0"
	    echo "net.ipv4.tcp_syn_retries = 2"
	    echo "net.ipv4.tcp_synack_retries = 2"
	    echo "net.ipv4.tcp_orphan_retries = 2"
	    echo "net.ipv4.tcp_max_syn_backlog = 40000"
	    echo "net.ipv4.tcp_max_tw_buckets = 2000000"
	    echo "net.ipv4.tcp_mem = 386916		515889	773832"
	    echo "net.ipv4.tcp_wmem = 4096        524288   67108864"
	    echo "net.ipv4.tcp_rmem = 4096        524288   67108864"
	    echo "net.ipv4.tcp_timestamps = 1"
	    echo "net.ipv4.tcp_tw_reuse = 1"
	    echo "net.ipv4.tcp_window_scaling = 1"
	    echo "net.ipv4.udp_mem = 756918	1009225	1513836"
	    echo "net.ipv4.udp_rmem_min = 8192"
	    echo "net.ipv4.udp_wmem_min = 8192"
	    echo "net.unix.max_dgram_qlen = 4096"
	    echo "net.ipv6.conf.all.autoconf = 0"
	    echo "net.ipv6.conf.all.forwarding = 1"
	    echo "net.ipv6.conf.default.autoconf = 0"
	    echo "net.ipv6.ip6frag_high_thresh=8388608"
	    echo "net.ipv6.ip6frag_low_thresh=196608"
	    echo "net.core.default_qdisc = fq_codel"
	    echo "net.core.netdev_budget = 600"
    	# echo "net.core.netdev_budget_usecs = 4000" >> /etc/sysctl.d/tune.conf
	    echo "net.core.netdev_max_backlog = 250000"
	    echo "net.core.rmem_default = 33554432"
	    echo "net.core.wmem_default = 33554432"
	    echo "net.core.rmem_max = 134217728"
	    echo "net.core.wmem_max = 134217728"
	    echo "net.core.optmem_max = 4194304"
	    echo "net.core.somaxconn = 256000"
	} >> /etc/sysctl.d/tune.conf
	# echo "net.netfilter.nf_conntrack_max = 1048576" >> /etc/sysctl.d/tune.conf
	# echo "net.nf_conntrack_max = 1048576" >> /etc/sysctl.d/tune.conf
	# echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 5" >> /etc/sysctl.d/tune.conf
	if [ -f /proc/sys/vm/compaction_proactiveness ]; then
	  echo "vm.compaction_proactiveness = 20" >> /etc/sysctl.d/tune.conf
	fi
	{
	    echo "vm.dirty_background_ratio = 10"
	    echo "vm.dirty_ratio = 40"
	    echo "vm.dirty_expire_centisecs = 42000"
	    echo "vm.dirty_writeback_centisecs = 7000"
	    echo "vm.drop_caches = 3"
	    echo "vm.max_map_count = 262144"
	    echo "vm.nr_hugepages = 4096"
	    echo "vm.overcommit_memory = 1"
	    echo "vm.swappiness = 1"
	    echo "vm.vfs_cache_pressure = 50"
	} >> /etc/sysctl.d/tune.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/tune.conf

	echo "htcp" > /etc/modules-load.d/promox.conf
	{
	    echo "kvmgt"
	    echo "vfio"
	    echo "vfio_iommu_type1"
	    echo "vfio_pci"
	    echo "vfio_pci_core"
	    echo "vfio_virqfd"
	} >> /etc/modules-load.d/promox.conf

		if [[ "${SYSTEM_DRIVERS_NVIDIA:-0}" == "1" ]]
	then

		{
		    echo "nvidia"
		    echo "nvidia_drm"
		    echo "nvidia_modeset"
		    echo "nvidia_uvm"
		} >> /etc/modules-load.d/promox.conf

		echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf

	fi

	if [ "$DRIVERS_LAST" == "1" ]
	then

		cd /tmp
		git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
		cd linux-firmware
		make install

	fi

	if [ "$KERNEL_CURRENT" != "$KERNEL_LAST" ]; then
		
		echo "🔧 CONFIGURATION INITRAMFS ($KERNEL_CURRENT vs $KERNEL_LAST"
		update-initramfs -u -k all
	fi

fi

if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "VM" ]
then

	echo "kernel.panic = 90" > /etc/sysctl.d/tune.conf
	{
	    echo "kernel.panic_on_oops = 1"
	    echo "kernel.sched_autogroup_enabled = 0"
	    echo "kernel.unprivileged_bpf_disabled=1"
	    echo "kernel.sysrq = 1"
	    echo "fs.inotify.max_user_instances = 16777216"
	    echo "fs.inotify.max_queued_events = 8388608"
	    echo "fs.inotify.max_user_watches = 4194304"
	    echo "net.ipv4.conf.all.accept_redirects = 1"
	    echo "net.ipv4.conf.all.accept_source_route = 0"
	    echo "net.ipv4.conf.all.secure_redirects = 1"
	    echo "net.ipv4.conf.all.send_redirects = 0"
	    echo "net.ipv4.conf.all.log_martians = 0"
	    echo "net.ipv4.conf.all.rp_filter = 1"
	    echo "net.ipv4.conf.default.accept_redirects = 0"
	    echo "net.ipv4.conf.default.accept_source_route = 0"
	    echo "net.ipv4.conf.default.secure_redirects = 0"
	    echo "net.ipv4.conf.default.send_redirects = 0"
	    echo "net.ipv4.conf.default.log_martians = 0"
	    echo "net.ipv4.conf.default.rp_filter = 1"
	    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1"
	    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1"
	    echo "net.ipv4.ip_forward = 1"
	    echo "net.ipv4.ip_local_port_range = 1025    65535"
	    echo "net.ipv4.ip_no_pmtu_disc = 1"
	    echo "net.ipv4.ipfrag_high_thresh=8388608"
	    echo "net.ipv4.ipfrag_low_thresh=196608"
	    echo "net.ipv4.neigh.default.gc_thresh1 = 1024"
	    echo "net.ipv4.neigh.default.gc_thresh2 = 2048"
	    echo "net.ipv4.neigh.default.gc_thresh3 = 4096"
	    echo "net.ipv4.route.min_pmtu = 536"
	    echo "net.ipv4.tcp_adv_win_scale = 14"
	    echo "net.ipv4.tcp_base_mss = 1460"
	    echo "net.ipv4.tcp_challenge_ack_limit = 9999"
	    echo "net.ipv4.tcp_congestion_control = htcp"
	    echo "net.ipv4.tcp_ecn = 1"
	    echo "net.ipv4.tcp_fastopen=3"
	    echo "net.ipv4.tcp_fin_timeout = 10"
	    echo "net.ipv4.tcp_keepalive_time = 600"
	    echo "net.ipv4.tcp_keepalive_intvl = 15"
	    echo "net.ipv4.tcp_keepalive_probes = 5"
	    echo "net.ipv4.tcp_limit_output_bytes = 65536"
	    echo "net.ipv4.tcp_low_latency = 1"
	    echo "net.ipv4.tcp_sack = 1"
	    echo "net.ipv4.tcp_mtu_probing = 1"
	    echo "net.ipv4.tcp_rfc1337 = 1"
	    echo "net.ipv4.tcp_slow_start_after_idle = 0"
	    echo "net.ipv4.tcp_no_metrics_save = 1"
	    echo "net.ipv4.tcp_syncookies = 0"
	    echo "net.ipv4.tcp_syn_retries = 2"
	    echo "net.ipv4.tcp_synack_retries = 2"
	    echo "net.ipv4.tcp_orphan_retries = 2"
	    echo "net.ipv4.tcp_max_syn_backlog = 40000"
	    echo "net.ipv4.tcp_max_tw_buckets = 2000000"
	    echo "net.ipv4.tcp_mem = 386916		515889	773832"
	    echo "net.ipv4.tcp_wmem = 4096        524288   67108864"
	    echo "net.ipv4.tcp_rmem = 4096        524288   67108864"
	    echo "net.ipv4.tcp_timestamps = 1"
	    echo "net.ipv4.tcp_tw_reuse = 1"
	    echo "net.ipv4.tcp_window_scaling = 1"
	    echo "net.ipv4.udp_mem = 756918	1009225	1513836"
	    echo "net.ipv4.udp_rmem_min = 8192"
	    echo "net.ipv4.udp_wmem_min = 8192"
	    echo "net.unix.max_dgram_qlen = 4096"
	    echo "net.ipv6.conf.all.autoconf = 0"
	    echo "net.ipv6.conf.all.forwarding = 1"
	    echo "net.ipv6.conf.default.autoconf = 0"
	    echo "net.ipv6.ip6frag_high_thresh=8388608"
	    echo "net.ipv6.ip6frag_low_thresh=196608"
	    echo "net.core.default_qdisc = fq_codel"
	    echo "net.core.netdev_budget = 600"
	    echo "net.core.netdev_budget_usecs = 4000"
	    echo "net.core.netdev_max_backlog = 250000"
	    echo "net.core.rmem_default = 33554432"
	    echo "net.core.wmem_default = 33554432"
	    echo "net.core.rmem_max = 134217728"
	    echo "net.core.wmem_max = 134217728"
	    echo "net.core.optmem_max = 4194304"
	    echo "net.core.somaxconn = 256000"
	    echo "net.netfilter.nf_conntrack_max = 1048576"
	    echo "net.nf_conntrack_max = 1048576"
	    echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 5"
	} >> /etc/sysctl.d/tune.conf
	if [ -f /proc/sys/vm/compaction_proactiveness ]; then
	  echo "vm.compaction_proactiveness = 20" >> /etc/sysctl.d/tune.conf
	fi
	{
	    echo "vm.dirty_background_ratio = 10"
	    echo "vm.dirty_ratio = 40"
	    echo "vm.dirty_expire_centisecs = 42000"
	    echo "vm.dirty_writeback_centisecs = 7000"
	    echo "vm.drop_caches = 3"
	    echo "vm.max_map_count = 262144"
	    echo "vm.nr_hugepages = 4096"
	    echo "vm.overcommit_memory = 1"
	    echo "vm.swappiness = 0"
	    echo "vm.vfs_cache_pressure = 50"
	} >> /etc/sysctl.d/tune.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/tune.conf

	echo "htcp" > /etc/modules-load.d/promox.conf
	{
	    echo "kvmgt"
	    echo "vfio"
	    echo "vfio_iommu_type1"
	    echo "vfio_pci"
	    echo "vfio_pci_core"
	    echo "vfio_virqfd"
	} >> /etc/modules-load.d/promox.conf

	if [[ "${SYSTEM_DRIVERS_NVIDIA:-0}" == "1" ]]
	then

		{
		    echo "nvidia"
		    echo "nvidia_drm"
		    echo "nvidia_modeset"
		    echo "nvidia_uvm"
		} >> /etc/modules-load.d/promox.conf

		echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf

	fi

	if [ "$KERNEL_CURRENT" != "$KERNEL_LAST" ]; then
		
		echo "🔧 CONFIGURATION INITRAMFS ($KERNEL_CURRENT vs $KERNEL_LAST"
		update-initramfs -u -k all
	fi

fi

if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "PROXMOX" ]
then

	echo "kernel.panic = 90" > /etc/sysctl.d/tune.conf
	{
	    echo "kernel.panic_on_oops = 1"
	    echo "kernel.sched_autogroup_enabled = 0"
	    echo "kernel.unprivileged_bpf_disabled=1"
	    echo "kernel.sysrq = 1"
	    echo "fs.inotify.max_user_instances = 16777216"
	    echo "fs.inotify.max_queued_events = 8388608"
	    echo "fs.inotify.max_user_watches = 4194304"
	    echo "net.ipv4.conf.all.accept_redirects = 1"
	    echo "net.ipv4.conf.all.accept_source_route = 0"
	    echo "net.ipv4.conf.all.secure_redirects = 1"
	    echo "net.ipv4.conf.all.send_redirects = 0"
	    echo "net.ipv4.conf.all.log_martians = 0"
	    echo "net.ipv4.conf.all.rp_filter = 1"
	    echo "net.ipv4.conf.default.accept_redirects = 0"
	    echo "net.ipv4.conf.default.accept_source_route = 0"
	    echo "net.ipv4.conf.default.secure_redirects = 0"
	    echo "net.ipv4.conf.default.send_redirects = 0"
	    echo "net.ipv4.conf.default.log_martians = 0"
	    echo "net.ipv4.conf.default.rp_filter = 1"
	    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1"
	    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1"
	    echo "net.ipv4.ip_forward = 1"
	    echo "net.ipv4.ip_local_port_range = 1025    65535"
	    echo "net.ipv4.ip_no_pmtu_disc = 1"
	    echo "net.ipv4.ipfrag_high_thresh=8388608"
	    echo "net.ipv4.ipfrag_low_thresh=196608"
	    echo "net.ipv4.neigh.default.gc_thresh1 = 1024"
	    echo "net.ipv4.neigh.default.gc_thresh2 = 2048"
	    echo "net.ipv4.neigh.default.gc_thresh3 = 4096"
	    echo "net.ipv4.route.min_pmtu = 536"
	    echo "net.ipv4.tcp_adv_win_scale = 14"
	    echo "net.ipv4.tcp_base_mss = 1460"
	    echo "net.ipv4.tcp_challenge_ack_limit = 9999"
	    echo "net.ipv4.tcp_congestion_control = htcp"
	    echo "net.ipv4.tcp_ecn = 1"
	    echo "net.ipv4.tcp_fastopen=3"
	    echo "net.ipv4.tcp_fin_timeout = 10"
	    echo "net.ipv4.tcp_keepalive_time = 600"
	    echo "net.ipv4.tcp_keepalive_intvl = 15"
	    echo "net.ipv4.tcp_keepalive_probes = 5"
	    echo "net.ipv4.tcp_limit_output_bytes = 65536"
	    echo "net.ipv4.tcp_low_latency = 1"
	    echo "net.ipv4.tcp_sack = 1"
	    echo "net.ipv4.tcp_mtu_probing = 1"
	    echo "net.ipv4.tcp_rfc1337 = 1"
	    echo "net.ipv4.tcp_slow_start_after_idle = 0"
	    echo "net.ipv4.tcp_no_metrics_save = 1"
	    echo "net.ipv4.tcp_syncookies = 0"
	    echo "net.ipv4.tcp_syn_retries = 2"
	    echo "net.ipv4.tcp_synack_retries = 2"
	    echo "net.ipv4.tcp_orphan_retries = 2"
	    echo "net.ipv4.tcp_max_syn_backlog = 40000"
	    echo "net.ipv4.tcp_max_tw_buckets = 2000000"
	    echo "net.ipv4.tcp_mem = 386916		515889	773832"
	    echo "net.ipv4.tcp_wmem = 4096        524288    67108864"
	    echo "net.ipv4.tcp_rmem = 4096        524288    67108864"
	    echo "net.ipv4.tcp_timestamps = 1"
	    echo "net.ipv4.tcp_tw_reuse = 1"
	    echo "net.ipv4.tcp_window_scaling = 1"
	    echo "net.ipv4.udp_mem = 756918	1009225	1513836"
	    echo "net.ipv4.udp_rmem_min = 8192"
	    echo "net.ipv4.udp_wmem_min = 8192"
	    echo "net.unix.max_dgram_qlen = 4096"
	    echo "net.ipv6.conf.all.autoconf = 0"
	    echo "net.ipv6.conf.all.forwarding = 1"
	    echo "net.ipv6.conf.default.autoconf = 0"
	    echo "net.ipv6.ip6frag_high_thresh=8388608"
	    echo "net.ipv6.ip6frag_low_thresh=196608"
	    echo "net.core.default_qdisc = fq_codel"
	    echo "net.core.netdev_budget = 600"
	    echo "net.core.netdev_budget_usecs = 4000"
	    echo "net.core.netdev_max_backlog = 250000"
	    echo "net.core.rmem_default = 33554432"
	    echo "net.core.wmem_default = 33554432"
	    echo "net.core.rmem_max = 134217728"
	    echo "net.core.wmem_max = 134217728"
	    echo "net.core.optmem_max = 4194304"
	    echo "net.core.somaxconn = 256000"
	    echo "net.netfilter.nf_conntrack_max = 1048576"
	    echo "net.nf_conntrack_max = 1048576"
	    echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 5"
	} >> /etc/sysctl.d/tune.conf
	if [ -f /proc/sys/vm/compaction_proactiveness ]; then
	  echo "vm.compaction_proactiveness = 20" >> /etc/sysctl.d/tune.conf
	fi
	{
	    echo "vm.dirty_background_ratio = 10"
	    echo "vm.dirty_ratio = 40"
	    echo "vm.dirty_expire_centisecs = 42000"
	    echo "vm.dirty_writeback_centisecs = 7000"
	    echo "vm.drop_caches = 3"
	    echo "vm.max_map_count = 262144"
	    echo "vm.nr_hugepages = 4096"
	    echo "vm.overcommit_memory = 1"
	    echo "vm.swappiness = 1"
	    echo "vm.vfs_cache_pressure = 50"
	} >> /etc/sysctl.d/tune.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/tune.conf

	echo "htcp" > /etc/modules-load.d/promox.conf
	{
	    echo "kvmgt"
	    echo "vfio"
	    echo "vfio_iommu_type1"
	    echo "vfio_pci"
	    echo "vfio_pci_core"
	    echo "vfio_virqfd"
	} >> /etc/modules-load.d/promox.conf

	if [[ "${SYSTEM_DRIVERS_NVIDIA:-0}" == "1" ]]
	then

		{
		    echo "nvidia"
		    echo "nvidia_drm"
		    echo "nvidia_modeset"
		    echo "nvidia_uvm"
		} >> /etc/modules-load.d/promox.conf

		echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf

	fi
  
  if [ "$DRIVERS_LAST" == "1" ]
	then

		cd /tmp
		git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
		cd linux-firmware
		make install

	fi

	if [ "$KERNEL_CURRENT" != "$KERNEL_LAST" ]; then
		
		echo "🔧 CONFIGURATION INITRAMFS ($KERNEL_CURRENT vs $KERNEL_LAST"
		update-initramfs -u -k all
	fi

	# KSM
	systemctl enable ksmtuned
	systemctl start ksmtuned
	echo "CHECK KSM..."
	cat /sys/kernel/mm/ksm/pages_shared
	cat /sys/kernel/mm/ksm/pages_sharing
	grep Huge /proc/meminfo

	# Limits
 	echo "* soft nofile 4194304" | tee /etc/security/limits.d/99-limits.conf
	ulimit -n

  if dpkg -s proxmox-default-kernel &>/dev/null
  then

    if dpkg -s proxmox-ve &>/dev/null
    then

      if dpkg -s os-prober &>/dev/null
      then

        echo "🔧 CLEANING POST-INSTALLATION PROXMOX"
        apt remove linux-image-amd64 'linux-image-6*' os-prober -y				

      else

        echo "PROXMOX OK ✅"

      fi			

    else

      echo "PROXMOX OK ✅"
      apt install -y proxmox-ve ksm-control-daemon locales-all chrony libguestfs-tools -y

    fi

  else

    apt install proxmox-default-headers proxmox-default-kernel -y
    echo "🔧 RESTART COMPUTER NOW..."
    exit

  fi

fi

### LANG ###

# Installation des composants nécessaires
apt-get install -y locales keyboard-configuration console-setup

# Locale française UTF-8
sed -i '/^# *fr_FR.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
locale-gen

# Locale système par défaut
update-locale LANG=fr_FR.UTF-8 LANGUAGE=fr_FR:fr

# Clavier français AZERTY
cat > /etc/default/keyboard <<'EOF'
XKBMODEL="pc105"
XKBLAYOUT="fr"
XKBVARIANT="latin9"
XKBOPTIONS=""
BACKSPACE="guess"
EOF

### LOGROTATE ###

if [[ "${SYSTEM_LOG_ROTATE:-0}" == "1" ]]
then

	echo "🔧 CONFIGURE LOGOROTATE"

cat > /etc/logrotate.conf <<EOF

daily
rotate ${LOG_ROTATE_DAILY}
create
compress
delaycompress
dateext
missingok
notifempty
sharedscripts

include /etc/logrotate.d

/var/log/wtmp {
    missingok
    monthly
    create 0664 root utmp
    rotate 1
}

/var/log/btmp {
    missingok
    monthly
    create 0660 root utmp
    rotate 1
}
EOF

fi


### NETWORK ###

config_host


### SYSTEMD ###

echo "🔧 CONFIGURE SYSTEMD"
sed -i 's%.*Compress=.*%Compress=yes%' /etc/systemd/journald.conf
sed -i 's%.*Storage=.*%Storage=volatile%' /etc/systemd/journald.conf
sed -i -E "s|^[#[:space:]]*SystemMaxUse=.*|SystemMaxUse=${SYSTEM_JOURNALD_MAX_USE}|" /etc/systemd/journald.conf
sed -i -E "s|^[#[:space:]]*SystemKeepFree=.*|SystemKeepFree=${SYSTEM_JOURNALD_KEEP_FREE}|" /etc/systemd/journald.conf
sed -i -E "s|^[#[:space:]]*RuntimeMaxUse=.*|RuntimeMaxUse=${SYSTEM_JOURNALD_MAX_USE}|" /etc/systemd/journald.conf
sed -i -E "s|^[#[:space:]]*RuntimeKeepFree=.*|RuntimeKeepFree=${SYSTEM_JOURNALD_KEEP_FREE}|" /etc/systemd/journald.conf
systemctl restart systemd-journald

if [[ "${SYSTEM_NO_SLEEP:-0}" == "1" ]]
then
	echo "🔧 CONFIGURE NO SLEEP"
	mkdir -p /etc/systemd/sleep.conf.d
	echo "[Sleep]" > /etc/systemd/sleep.conf.d/nosleep.conf
	{
	    echo "AllowSuspend=no"
	    echo "AllowHibernation=no"
	    echo "AllowSuspendThenHibernate=no"
	    echo "AllowHybridSleep=no"
	} >> /etc/systemd/sleep.conf.d/nosleep.conf
fi

#### SOFTWARES ##########################
# Adresser à CGPT :) #
######################

if [ "${ACMESH:-0}" -eq 1 ]; then

    ACMESH_HOME="${ACMESH_HOME:-/root/.acme.sh}"
    ACMESH_BIN="${ACMESH_HOME}/acme.sh"
    ACMESH_REPOSITORY="https://github.com/acmesh-official/acme.sh.git"
    ACMESH_EMAIL="${ACMESH_EMAIL:-}"

    # Vérification de tous les prérequis, et pas seulement de coreutils.
    ACMESH_MISSING_PACKAGES=()

    for ACMESH_PACKAGE in cron coreutils curl git grep sed wget; do
        if ! dpkg-query -W -f='${Status}' "${ACMESH_PACKAGE}" 2>/dev/null |
            grep -q '^install ok installed$'
        then
            ACMESH_MISSING_PACKAGES+=("${ACMESH_PACKAGE}")
        fi
    done

    if [ "${#ACMESH_MISSING_PACKAGES[@]}" -gt 0 ]; then
        echo "🔧 INSTALL PREREQUISITES FOR ACME.SH"

        apt-get update
        apt-get install -y "${ACMESH_MISSING_PACKAGES[@]}"
    fi

	systemctl enable --now cron

    ACMESH_REMOTE_VERSION="$(
        git ls-remote \
            --tags \
            --refs \
            "${ACMESH_REPOSITORY}" 2>/dev/null |
        awk -F'refs/tags/' 'NF == 2 { print $2 }' |
        sed 's/^v//' |
        grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' |
        sort -V |
        tail -n 1
    )"

    if [ -z "${ACMESH_REMOTE_VERSION}" ]; then
        echo "[ERREUR] Impossible de déterminer la dernière version de acme.sh."
        exit 1
    fi

	if [ ! -x "${ACMESH_BIN}" ]; then

		echo "🔧 INSTALL ACME.SH (${ACMESH_REMOTE_VERSION})"

		ACMESH_TMP_DIR="$(mktemp -d)"

		cleanup_acmesh_tmp() {
			rm -rf "${ACMESH_TMP_DIR}"
		}

		trap cleanup_acmesh_tmp EXIT

		if ! git \
			-c advice.detachedHead=false \
			clone \
			--quiet \
			--depth 1 \
			--branch "${ACMESH_REMOTE_VERSION}" \
			"${ACMESH_REPOSITORY}" \
			"${ACMESH_TMP_DIR}/acme.sh"
		then
			echo "[ERREUR] Impossible de télécharger acme.sh ${ACMESH_REMOTE_VERSION}."
			exit 1
		fi

		if [ -n "${ACMESH_EMAIL}" ]; then

			if ! (
				cd "${ACMESH_TMP_DIR}/acme.sh" &&
				./acme.sh \
					--install \
					--home "${ACMESH_HOME}" \
					--accountemail "${ACMESH_EMAIL}"
			); then
				echo "[ERREUR] L'installation de acme.sh a échoué."
				exit 1
			fi

		else

			echo "[AVERTISSEMENT] ACMESH_EMAIL n'est pas défini."

			if ! (
				cd "${ACMESH_TMP_DIR}/acme.sh" &&
				./acme.sh \
					--install \
					--home "${ACMESH_HOME}"
			); then
				echo "[ERREUR] L'installation de acme.sh a échoué."
				exit 1
			fi

		fi

		if [ ! -x "${ACMESH_BIN}" ]; then
			echo "[ERREUR] acme.sh est introuvable après l'installation :"
			echo "         ${ACMESH_BIN}"
			exit 1
		fi

		cleanup_acmesh_tmp
		trap - EXIT

		echo "ACME.SH IS OK ✅ (${ACMESH_REMOTE_VERSION})"

    else

        ACMESH_LOCAL_VERSION="$(
            "${ACMESH_BIN}" --version 2>/dev/null |
            grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+' |
            head -n 1 |
            sed 's/^v//'
        )"

        if [ -z "${ACMESH_LOCAL_VERSION}" ]; then
            echo "[ERREUR] Impossible de déterminer la version locale de acme.sh."
            exit 1
        fi

        if [ "${ACMESH_LOCAL_VERSION}" != "${ACMESH_REMOTE_VERSION}" ]; then

            echo "🔧 UPDATE ACME.SH (${ACMESH_LOCAL_VERSION} TO ${ACMESH_REMOTE_VERSION})"

            if ! "${ACMESH_BIN}" \
                --upgrade \
                --home "${ACMESH_HOME}"
            then
                echo "[ERREUR] La mise à jour de acme.sh a échoué."
                exit 1
            fi

            ACMESH_UPDATED_VERSION="$(
                "${ACMESH_BIN}" --version 2>/dev/null |
                grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+' |
                head -n 1 |
                sed 's/^v//'
            )"

			if [ "${ACMESH_UPDATED_VERSION}" != "${ACMESH_REMOTE_VERSION}" ]; then
				echo "[ERREUR] Version obtenue après mise à jour : ${ACMESH_UPDATED_VERSION:-inconnue}"
				echo "[ERREUR] Version attendue : ${ACMESH_REMOTE_VERSION}"
				exit 1
			fi

			echo "ACME.SH IS OK ✅ (${ACMESH_UPDATED_VERSION})"

        else
            echo "ACME.SH IS OK ✅ (${ACMESH_LOCAL_VERSION})"
        fi
    fi

    export PATH="${ACMESH_HOME}:${PATH}"

	ACMESH_CRON_MARKER="# DIU MANAGED ACME.SH RENEWAL"
	ACMESH_CRON_ENTRY="0 12 1,15 * * \"${ACMESH_BIN}\" --cron --home \"${ACMESH_HOME}\" > /dev/null 2>&1"

	ACMESH_CRON_TMP="$(mktemp)"

	crontab -l 2>/dev/null > "${ACMESH_CRON_TMP}" || true

	sed -i \
		-e '\|# DIU MANAGED ACME\.SH RENEWAL|d' \
		-e '\|[/.]acme\.sh.*--cron.*--home|d' \
		"${ACMESH_CRON_TMP}"

	sed -i ':a;/^[[:space:]]*$/{$d;N;ba;}' "${ACMESH_CRON_TMP}"

	if [ -s "${ACMESH_CRON_TMP}" ]; then
		printf '\n' >> "${ACMESH_CRON_TMP}"
	fi
	printf '%s\n' "${ACMESH_CRON_MARKER}" "${ACMESH_CRON_ENTRY}" >> "${ACMESH_CRON_TMP}"

	ACMESH_CURRENT_CRON="$(crontab -l 2>/dev/null || true)"
	ACMESH_NEW_CRON="$(cat "${ACMESH_CRON_TMP}")"

	if [ "${ACMESH_CURRENT_CRON}" != "${ACMESH_NEW_CRON}" ]; then

		if ! crontab "${ACMESH_CRON_TMP}"; then
			echo "[ERREUR] Impossible de configurer le renouvellement ACME.SH."
			rm -f "${ACMESH_CRON_TMP}"
			exit 1
		fi

		echo "🔧 CONFIGURE ACME.SH RENEWAL CRON"
		echo "ACME.SH RENEWAL CRON IS OK ✅ (1st AND 15th AT 12:00)"

	else
		echo "ACME.SH RENEWAL CRON IS OK ✅ (1st AND 15th AT 12:00)"
	fi

	rm -f "${ACMESH_CRON_TMP}"

	for ACMESH_REQUIRED_VAR in \
		DNS_OVH_ENDPOINT \
		DNS_OVH_APPLICATION_KEY \
		DNS_OVH_APPLICATION_SECRET \
		DNS_OVH_CONSUMER_KEY \
		DNS_OVH_DOMAIN1
	do
		if [ -z "${!ACMESH_REQUIRED_VAR:-}" ]; then
			echo "[ERREUR] La variable ${ACMESH_REQUIRED_VAR} n'est pas définie."
			exit 1
		fi
	done

    export OVH_END_POINT="${DNS_OVH_ENDPOINT}"
    export OVH_AK="${DNS_OVH_APPLICATION_KEY}"
    export OVH_AS="${DNS_OVH_APPLICATION_SECRET}"
    export OVH_CK="${DNS_OVH_CONSUMER_KEY}"

    ACMESH_DOMAIN="${DNS_OVH_DOMAIN1}"
    ACMESH_CERT_DIR="${ACMESH_HOME}/${ACMESH_DOMAIN}_ecc"
    ACMESH_CERT_FILE="${ACMESH_CERT_DIR}/${ACMESH_DOMAIN}.cer"

	ACMESH_CERT_EXISTS=0
	ACMESH_CERT_VALID=0
	ACMESH_CERT_EXPIRED=0

	if [ -s "${ACMESH_CERT_FILE}" ]; then
		ACMESH_CERT_EXISTS=1

		if openssl x509 \
			-in "${ACMESH_CERT_FILE}" \
			-noout \
			-checkend 86400 >/dev/null 2>&1
		then
			ACMESH_CERT_VALID=1
		fi

		# Vérifie si le certificat est déjà expiré.
		if ! openssl x509 \
			-in "${ACMESH_CERT_FILE}" \
			-noout \
			-checkend 0 >/dev/null 2>&1
		then
			ACMESH_CERT_EXPIRED=1
		fi
	fi

	if [ "${ACMESH_CERT_EXISTS}" -eq 0 ]; then

		echo "🔧 REQUEST ACME CERTIFICATE FOR ${ACMESH_DOMAIN}"

		if ! "${ACMESH_BIN}" \
			--issue \
			--home "${ACMESH_HOME}" \
			--server letsencrypt \
			--dns dns_ovh \
			--keylength ec-384 \
			-d "${ACMESH_DOMAIN}" \
			-d "*.${ACMESH_DOMAIN}"
		then
			echo "[ERREUR] Échec de la demande du certificat pour ${ACMESH_DOMAIN}."
			exit 1
		fi

		echo "ACME CERTIFICATE IS OK ✅ (${ACMESH_DOMAIN} + *.${ACMESH_DOMAIN})"

	elif [ "${ACMESH_CERT_EXPIRED}" -eq 1 ]; then

		echo "❌ ACME CERTIFICATE IS EXPIRED (${ACMESH_DOMAIN})"
		echo "🔧 FORCE ACME CERTIFICATE RENEWAL FOR ${ACMESH_DOMAIN}"

		if ! "${ACMESH_BIN}" \
			--renew \
			--home "${ACMESH_HOME}" \
			--server letsencrypt \
			-d "${ACMESH_DOMAIN}" \
			--ecc \
			--force
		then
			echo "[ERREUR] Échec du renouvellement forcé du certificat pour ${ACMESH_DOMAIN}."
			exit 1
		fi

		echo "ACME CERTIFICATE RENEWAL IS OK ✅ (${ACMESH_DOMAIN})"

	elif [ "${ACMESH_CERT_VALID}" -eq 0 ]; then

		echo "⚠️ ACME CERTIFICATE EXPIRES IN LESS THAN 24 HOURS (${ACMESH_DOMAIN})"
		echo "🔧 FORCE ACME CERTIFICATE RENEWAL FOR ${ACMESH_DOMAIN}"

		if ! "${ACMESH_BIN}" \
			--renew \
			--home "${ACMESH_HOME}" \
			--server letsencrypt \
			-d "${ACMESH_DOMAIN}" \
			--ecc \
			--force
		then
			echo "[ERREUR] Échec du renouvellement forcé du certificat pour ${ACMESH_DOMAIN}."
			exit 1
		fi

		echo "ACME CERTIFICATE RENEWAL IS OK ✅ (${ACMESH_DOMAIN})"

	else

		ACMESH_CERT_EXPIRY="$(
			openssl x509 \
				-in "${ACMESH_CERT_FILE}" \
				-noout \
				-enddate |
			cut -d= -f2
		)"

		ACMESH_EXPIRY_DATE="$(
			date -d "${ACMESH_CERT_EXPIRY}" +%Y-%m-%d
		)"

		ACMESH_EXPIRY_TIMESTAMP="$(
			date -d "${ACMESH_CERT_EXPIRY}" +%s
		)"

		ACMESH_NOW_TIMESTAMP="$(date +%s)"

		ACMESH_REMAINING_SECONDS=$(( ACMESH_EXPIRY_TIMESTAMP - ACMESH_NOW_TIMESTAMP ))

		# Arrondi au supérieur pour éviter d'afficher 89 jours
		# lorsqu'il reste en réalité 89 jours et plusieurs heures.
		ACMESH_REMAINING_DAYS=$(( (ACMESH_REMAINING_SECONDS + 86399) / 86400 ))

		if [ "${ACMESH_REMAINING_DAYS}" -gt 30 ]; then
			ACMESH_STATUS="OK"
		elif [ "${ACMESH_REMAINING_DAYS}" -gt 7 ]; then
			ACMESH_STATUS="WARNING"
		else
			ACMESH_STATUS="CRITICAL"
		fi

		case "${ACMESH_STATUS}" in
			OK)
				ACMESH_ICON="✅"
				;;
			WARNING)
				ACMESH_ICON="⚠️"
				;;
			CRITICAL)
				ACMESH_ICON="❌"
				;;
		esac

		echo "	CERTIFICATE ${ACMESH_DOMAIN}"
		echo "	Expires  : ${ACMESH_EXPIRY_DATE}"
		echo "	Remaining: ${ACMESH_REMAINING_DAYS} days"
		echo "	Status   : ${ACMESH_STATUS} ${ACMESH_ICON}"

	fi

fi

if [[ "${SOFTWARES_APT_APACHE2:-0}" == "1" ]]
then

	if [ "$SYSTEM_DEBIAN_RELEASE" = "trixie" ]
	then

		echo ""
		echo "INSTALL APACHE2"
		apt install apache2 libapache2-mod-perl2 libapache2-mod-fcgid libapache-session-perl perl-modules-5.40 libnet-ldap-perl libcache-cache-perl libdbi-perl libwww-perl libxml-simple-perl libsoap-lite-perl libhtml-template-perl libregexp-assemble-perl libregexp-common-perl libjs-jquery libxml-libxml-perl libcrypt-rijndael-perl libio-string-perl libxml-libxslt-perl libconfig-inifiles-perl libjson-perl libstring-random-perl libemail-date-format-perl libmime-lite-perl libcrypt-openssl-rsa-perl libdigest-hmac-perl libdigest-sha-perl libclone-perl libauthen-sasl-perl libnet-cidr-lite-perl libcrypt-openssl-x509-perl libauthcas-perl libtest-pod-perl libtest-mockobject-perl libauthen-captcha-perl libnet-openid-consumer-perl libnet-openid-server-perl libunicode-string-perl libconvert-pem-perl libmoose-perl libplack-perl libapache-session-browseable-perl libdbd-pg-perl libgssapi-perl -y

	fi

	if [ "$SYSTEM_DEBIAN_RELEASE" = "bookworm" ]
	then

		echo ""
		echo "INSTALL APACHE2"
		apt install apache2 libapache2-mod-perl2 libapache2-mod-fcgid libapache-session-perl perl-modules-5.36 libnet-ldap-perl libcache-cache-perl libdbi-perl libwww-perl libxml-simple-perl libsoap-lite-perl libhtml-template-perl libregexp-assemble-perl libregexp-common-perl libjs-jquery libxml-libxml-perl libcrypt-rijndael-perl libio-string-perl libxml-libxslt-perl libconfig-inifiles-perl libjson-perl libstring-random-perl libemail-date-format-perl libmime-lite-perl libcrypt-openssl-rsa-perl libdigest-hmac-perl libdigest-sha-perl libclone-perl libauthen-sasl-perl libnet-cidr-lite-perl libcrypt-openssl-x509-perl libauthcas-perl libtest-pod-perl libtest-mockobject-perl libauthen-captcha-perl libnet-openid-consumer-perl libnet-openid-server-perl libunicode-string-perl libconvert-pem-perl libmoose-perl libplack-perl libapache-session-browseable-perl libdbd-pg-perl libgssapi-perl -y

	fi

	if [ "$SYSTEM_DEBIAN_RELEASE" = "bullseye" ]
	then

		echo ""
		echo "INSTALL APACHE2"
		apt install apache2 libapache2-mod-perl2 libapache2-mod-fcgid libapache-session-perl perl-modules-5.32 libnet-ldap-perl libcache-cache-perl libdbi-perl libwww-perl libxml-simple-perl libsoap-lite-perl libhtml-template-perl libregexp-assemble-perl libregexp-common-perl libjs-jquery libxml-libxml-perl libcrypt-rijndael-perl libio-string-perl libxml-libxslt-perl libconfig-inifiles-perl libjson-perl libstring-random-perl libemail-date-format-perl libmime-lite-perl libcrypt-openssl-rsa-perl libdigest-hmac-perl libdigest-sha-perl libclone-perl libauthen-sasl-perl libnet-cidr-lite-perl libcrypt-openssl-x509-perl libauthcas-perl libtest-pod-perl libtest-mockobject-perl libauthen-captcha-perl libnet-openid-consumer-perl libnet-openid-server-perl libunicode-string-perl libconvert-pem-perl libmoose-perl libplack-perl libapache-session-browseable-perl libdbd-pg-perl libgssapi-perl -y

	fi

fi

crowdsec_bouncer_set_api_key() {
	local config_file="/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml"
	local temporary_file line found=0
	[[ -n "${SOFTWARES_CROWDSEC_BOUNCER_API_KEY:-}" ]] || {
		printf '%s\n' "La clé API du bouncer CrowdSec est absente." >&2
		return 1
	}
	[[ -f "$config_file" && -r "$config_file" ]] || {
		printf '%s\n' "Configuration du bouncer CrowdSec inaccessible." >&2
		return 1
	}
	temporary_file="$(mktemp "${config_file}.XXXXXX")" || {
		printf '%s\n' "Fichier temporaire du bouncer CrowdSec impossible à créer." >&2
		return 1
	}
	if ! chmod 0600 "$temporary_file"; then
		rm -f -- "$temporary_file"
		printf '%s\n' "Sécurisation temporaire de la configuration CrowdSec impossible." >&2
		return 1
	fi
	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ "$line" =~ ^([[:blank:]]*api_key[[:blank:]]*:[[:blank:]]*).*$ ]]; then
			printf '%s%s\n' "${BASH_REMATCH[1]}" "$SOFTWARES_CROWDSEC_BOUNCER_API_KEY" >> "$temporary_file" || {
				rm -f -- "$temporary_file"
				return 1
			}
			found=1
		else
			printf '%s\n' "$line" >> "$temporary_file" || {
				rm -f -- "$temporary_file"
				return 1
			}
		fi
	done < "$config_file"
	if [[ "$found" != 1 ]]; then
		rm -f -- "$temporary_file"
		printf '%s\n' "Clé api_key absente de la configuration CrowdSec." >&2
		return 1
	fi
	if ! mv -f -- "$temporary_file" "$config_file"; then
		rm -f -- "$temporary_file"
		printf '%s\n' "Écriture de la configuration CrowdSec impossible." >&2
		return 1
	fi
}

if [[ "${SOFTWARES_APT_CROWDSEC_AGENT:-0}" == "1" ]]
then

	echo ""
	echo "INSTALL CROWDSEC AGENT (LAPI)"
	apt install crowdsec -y

	# Tune CONFIG.YAML for disable LAPI
	sed -i 's%.*log_dir:.*%  log_dir: /var/log/machines/siem%' /etc/crowdsec/config.yaml
	sed -i 's%.*listen_uri:.*%    listen_uri: 0.0.0.0:8080%' /etc/crowdsec/config.yaml
	# Tune CROWDSEC.SERVICE for diasable LAPI
	sed -i 's%.*ExecStart=/usr/bin/crowdsec -c /etc/crowdsec/config.yaml.*%ExecStart=/usr/bin/crowdsec -c /etc/crowdsec/config.yaml%' /lib/systemd/system/crowdsec.service

	echo "RESTART CROWDSEC AGENT (LAPI)"
	systemctl daemon-reload
	systemctl enable crowdsec.service
	systemctl restart crowdsec.service

	echo "HUB CROWDSEC AGENT UPDATE"
	cscli hub update
	cscli hub upgrade

	echo "CROWDSEC AGENT INSTALL COLLECTIONS"
	cscli collections install crowdsecurity/linux
	cscli collections install crowdsecurity/sshd
	cscli collections install crowdsecurity/iptables

	echo ""
	echo "INSTALL CROWDSEC BOUNCER IPTABLES"
	apt install crowdsec-firewall-bouncer-iptables -y

	echo "CROWDSEC BOUNCER IPTABLES CONFIGURATION"
	sed -i 's%.*log_dir.*%log_dir: /var/log/machines/siem%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	sed -i 's%.*api_url.*%api_url: http://127.0.0.1:8080/%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	crowdsec_bouncer_set_api_key || exit 1
	sed -i 's%.*disable_ipv6.*%disable_ipv6: false%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	systemctl disable crowdsec-firewall-bouncer.service
	service crowdsec-firewall-bouncer restart

fi

if [[ "${SOFTWARES_APT_CROWDSEC_BOUNCER:-0}" == "1" ]]
then

	echo ""
	echo "INSTALL CROWDSEC BOUNCER IPTABLES"
	apt install crowdsec-firewall-bouncer-iptables -y

	echo "CONFIGURE CROWDSEC BOUNCER IPTABLES CONFIGURATION"
	sed -i 's%.*api_url.*%api_url: http://siem.ch-nontron.fr:8080/%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	crowdsec_bouncer_set_api_key || exit 1
	sed -i 's%.*log_mode.*%log_mode: stdout%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	systemctl disable crowdsec-firewall-bouncer.service
	service crowdsec-firewall-bouncer restart

fi

if [[ "${DESKTOP:-0}" == "1" ]]; then

	if dpkg -s mesa-utils &>/dev/null
	then

		echo "PREREQUISITES DESKTOP IS OK ✅"

	else

		echo "🔧 INSTALL PREREQUISITES DESKTOP"
		apt install input-remapper mesa-utils vlc -y

	fi

	if dpkg -s chromium &>/dev/null
	then
		echo "CHROMIUM IS OK ✅"
		tee /etc/chromium.d/hardware-acceleration >/dev/null <<EOF
CHROMIUM_FLAGS="\$CHROMIUM_FLAGS \
--ignore-gpu-blocklist \
--enable-accelerated-video-decode"
EOF
	else
		echo "🔧 INSTALL CHRIMIUM"
		apt install chromium chromium-l10n chromium-driver intel-media-va-driver-non-free libva-drm2 libva-x11-2 -y
		tee /etc/chromium.d/hardware-acceleration >/dev/null <<EOF
CHROMIUM_FLAGS="\$CHROMIUM_FLAGS \
--ignore-gpu-blocklist \
--enable-accelerated-video-decode"
EOF
	fi

	if dpkg -s firefox-esr &>/dev/null
	then

		echo "FIREFOX IS OK ✅"

		echo "🔧 Scan des utilisateurs dans /home..."

		### CONFIGURATION UTILISATEURS DE FIREFOX ###

		# Fonction pour définir ou mettre à jour une préférence
		set_pref () {
			local file="$1"
			local name="$2"
			local value="$3"

			if grep -q "user_pref(\"$name\"" "$file" 2>/dev/null; then
				sed -i "s|user_pref(\"$name\".*|user_pref(\"$name\", $value);|" "$file"
			else
				echo "user_pref(\"$name\", $value);" >> "$file"
			fi
		}

		# Vérifier que Firefox n'est pas lancé
		if pgrep -x firefox > /dev/null; then
			echo "⚠ FIREFOX EST EN COURS D'EXECUTION. MERCI DE LE FERMER AVANT."
			exit 1
		fi

		# Parcours des utilisateurs
		for USER_HOME in /home/*; do

			[ -d "$USER_HOME" ] || continue

			USERNAME=$(basename "$USER_HOME")
			FIREFOX_DIR="$USER_HOME/.mozilla/firefox"

			if [ ! -d "$FIREFOX_DIR" ]; then
				echo "ℹ️ PAS DE PROFIL FIREFOX POUR $USERNAME"
				continue
			fi

			echo "🔧 UTILISATEUR : $USERNAME"

			# Parcours des profils Firefox
			find "$FIREFOX_DIR" -maxdepth 1 -type d | while read -r PROFILE; do

				# Exclure dossiers inutiles
				case "$PROFILE" in
					*Crash\ Reports*|*Pending\ Pings*)
						continue
						;;
				esac

				# Vérifier que c'est bien un profil (présence prefs.js)
				if [ -f "$PROFILE/prefs.js" ]; then

					echo "🔧 Profil : $PROFILE"

					USERJS="$PROFILE/user.js"

					touch "$USERJS"

					# Résolution de l'identité
					USER_UID="$(id -u "$USERNAME" 2>/dev/null || true)"
					USER_GID="$(id -g "$USERNAME" 2>/dev/null || true)"

					if [ -n "$USER_UID" ] && [ -n "$USER_GID" ]; then
						chown "$USER_UID:$USER_GID" "$USERJS"
					else
						echo "⚠️ Utilisateur '$USERNAME' introuvable, droits de $USERJS non modifiés."
					fi

					# Appliquer les préférences
					set_pref "$USERJS" "browser.tabs.loadBookmarksInTabs" "true"
					set_pref "$USERJS" "browser.search.openintab" "true"

					if [ -n "$USER_UID" ] && [ -n "$USER_GID" ]; then
						chown "$USER_UID:$USER_GID" "$USERJS"
					fi

				fi

			done

		done

		echo "✅ CONFIGURATION FIREFOX APPLIQUEE A TOUS LES UTILISATEURS"

		### CONFIGURATION SYSTEME DE FIREFOX ###

		FILE="/usr/lib/firefox-esr/distribution/policies.json"

		# Créer le dossier si nécessaire
		mkdir -p "$(dirname "$FILE")"

		# Si le fichier n'existe pas, on le crée proprement
		if [ ! -f "$FILE" ]; then
			cat <<EOF > "$FILE"
{
  "policies": {
    "Preferences": {}
  }
}
EOF
		fi

		# Vérifier que jq est installé
		if ! command -v jq >/dev/null 2>&1; then
			echo "❌ jq est requis. Installe-le avec : apt install jq"
			exit 1
		fi

		TMP=$(mktemp)

		# Mise à jour du JSON proprement avec jq
		jq '
		.policies = (.policies // {}) |
		.policies.Preferences = (.policies.Preferences // {}) |

		.policies.Preferences["browser.tabs.loadBookmarksInTabs"] = {
		  "Value": true,
		  "Status": "locked"
		} |

		.policies.Preferences["browser.search.openintab"] = {
		  "Value": true,
		  "Status": "locked"
		}
		' "$FILE" > "$TMP"

		# Remplacer proprement
		mv "$TMP" "$FILE"

		# Permissions
		chown root:root "$FILE"
		chmod 644 "$FILE"

		echo "✅ Policies Firefox ESR mises à jour avec succès"

	else

		echo "🔧 INSTALL FIREFOX"
		apt install firefox-esr firefox-esr-l10n-fr -y

	fi

	if dpkg -s geany &>/dev/null
	then

		echo ""
		echo "GEANY IS OK ✅"

	else

		echo "🔧 INSTALL GEANY"
		apt install geany geany-plugin-addons -y

	fi

	if command -v guake >/dev/null 2>&1; then
		echo "GUAKE OK ✅"
		GUAKE_BIN="$(command -v guake)"
		if update-alternatives --list x-terminal-emulator 2>/dev/null | grep -qx "$GUAKE_BIN"; then
			update-alternatives --set x-terminal-emulator "$GUAKE_BIN"
		else
			update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$GUAKE_BIN" 60
			update-alternatives --set x-terminal-emulator "$GUAKE_BIN"
		fi
	else
		echo "🔧 INSTALL GUAKE"
		apt install -y guake
	fi

	if command -v kitty >/dev/null 2>&1; then
		echo "KITTY OK ✅"
		KITTY_BIN="$(command -v kitty)"
		if update-alternatives --list x-terminal-emulator 2>/dev/null | grep -qx "$KITTY_BIN"; then
			update-alternatives --set x-terminal-emulator "$KITTY_BIN"
		else
			update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$KITTY_BIN" 60
			update-alternatives --set x-terminal-emulator "$KITTY_BIN"
		fi
	else
		echo "🔧 INSTALL KITTY"
		apt install -y kitty

	fi

	if dpkg -s nextcloud-desktop &>/dev/null
	then
		echo "NEXTCLOUD DESKTOP IS OK ✅"
	else
		echo "🔧 INSTALL NEXTCLOUD DESKTOP"
		apt install nextcloud-desktop nextcloud-desktop-doc nextcloud-desktop-l10n -y
	fi

	if dpkg -s remmina-plugin-rdp &>/dev/null
	then

		echo "REMMINA DESKTOP IS OK ✅"

	else

		echo "🔧 INSTALL REMMINA"
		apt install remmina-plugin-rdp -y

	fi

  TABBY_VERSION="$(
    curl -fsSL "https://api.github.com/repos/Eugeny/tabby/releases/latest" \
      | awk -F '"' '/"tag_name":/ {sub(/^v/, "", $4); print $4}'
  )"
	if test -f /root/tabby-"${TABBY_VERSION}"-linux-x64.deb; then

		echo "TABBY_VERSION($TABBY_VERSION) IS OK ✅"		

	else

		echo "🔧 INSTALL TABBY ($TABBY_VERSION)"
		curl -fOL "https://github.com/Eugeny/tabby/releases/download/v${TABBY_VERSION}/tabby-${TABBY_VERSION}-linux-x64.deb"
		dpkg -i /root/tabby-"${TABBY_VERSION}"-linux-x64.deb

	fi

	if command -v tabby >/dev/null 2>&1; then
		TABBY_BIN="$(command -v tabby)"
		
		# Vérifie si Tabby est déjà enregistré comme alternative
		if update-alternatives --list x-terminal-emulator 2>/dev/null | grep -qx "$TABBY_BIN"; then
			update-alternatives --set x-terminal-emulator "$TABBY_BIN"
		else
			update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$TABBY_BIN" 70
			update-alternatives --set x-terminal-emulator "$TABBY_BIN"
		fi

	fi

	if [ "$AMULE" -eq 1 ]; then

		if dpkg -s amule-utils-gui &>/dev/null
		then

			echo "AMULE OK ✅"

		else

			echo "🔧 INSTALL AMULE"
			apt install amule amule-utils-gui -y

		fi

  fi

	if [ "$VSCODE" -eq 1 ]; then

		if dpkg -s code &>/dev/null
		then

			echo "VISUAL STUDIO CODE OK ✅"

		else

			echo "🔧 INSTALL VISUAL STUDIO CODE"
			apt install code -y

		fi

		if command -v code >/dev/null 2>&1; then
			CODE_BIN="$(command -v code)"

			# Vérifie si VS Code est déjà enregistré comme alternative
			if update-alternatives --list editor 2>/dev/null | grep -qx "$CODE_BIN"; then
				update-alternatives --set editor "$CODE_BIN"
				xdg-mime default code.desktop text/plain
			else
				update-alternatives --install /usr/bin/editor editor "$CODE_BIN" 70
				update-alternatives --set editor "$CODE_BIN"
				xdg-mime default code.desktop text/plain
			fi

		fi

	fi

	if [ "$DESKTOP_GUI" == "GNOME" ]
	then

		if dpkg -s smbclient &>/dev/null
		then

			echo "SAMBA CLIENT IS OK ✅"

		else

			echo "🔧 INSTALL SAMBA CLIENT"
			apt install cifs-utils smbclient -y

		fi

		if dpkg -s gnome-software-plugin-flatpak &>/dev/null
		then

			echo "GNOME SOFTWARE PLUGIN FLATPAK IS OK ✅"

		else

			echo "🔧 INSTALL GNOME SOFTWARE PLUGIN FLATPAK"
			apt install gnome-software-plugin-flatpak -y

		fi

		if dpkg -s gparted &>/dev/null
		then

			echo "GPARTED IS OK ✅"

		else

			echo "🔧 INSTALL GPARTED"
			apt install gparted -y

		fi

		if dpkg -s nautilus-nextcloud &>/dev/null
		then

			echo "NEXTCLOUD FOR NAUTILUS IS OK ✅"

		else

			echo "🔧 INSTALL NEXTCLOUD FOR NAUTILUS"
			apt install nautilus-nextcloud -y

		fi

		if dpkg -s wmctrl &>/dev/null
		then

			echo "WMCTRL IS OK ✅"

		else

			echo "🔧 INSTALL WMCTRL"
			apt install wmctrl -y

		fi

		if dpkg -s x11-utils &>/dev/null
		then

			echo "X11-UTILS IS OK ✅"

		else

			echo "🔧 INSTALL X11-UTILS"
			apt install x11-utils -y

		fi

		if dpkg -s xdotool &>/dev/null
		then

			echo "XDOTOOL IS OK ✅"

		else

			echo "🔧 INSTALL XDOTOOL"
			apt install xdotool -y

		fi

    if [ "$AMULE" -eq 1 ]; then

      if dpkg -s amule-gnome-support &>/dev/null
      then

        echo "AMULE OK ✅"

      else

        echo "🔧 INSTALL AMULE"
        apt install amule-gnome-support -y

      fi

    fi

	fi

fi

if [ "${ENVIRONMENTS_DEVOPS:-0}" -eq 1 ]
then

	echo ""
	groupadd -f "$ENV_DEVOPS_GROUP"

	if id -u "$ENV_DEVOPS_USER"> /dev/null 2>&1 
	then
	  echo "USER FOR DEVOPS $ENV_DEVOPS_USER IS OK ✅"
	  echo "$ENV_DEVOPS_USER:$ENV_DEVOPS_PASSWORD" | chpasswd
	else
	  useradd -m "$ENV_DEVOPS_USER" --gid "$ENV_DEVOPS_GROUP" -s /bin/bash
	  echo "$ENV_DEVOPS_USER:$ENV_DEVOPS_PASSWORD" | chpasswd
	fi

	usermod -aG "$ENV_DEVOPS_GROUP" "$ENV_DEVOPS_USER"
	usermod -aG "$ENV_DEVOPS_GROUP" "$ENV_HUMAN_USER"

  if [[ "${ENV_DEVOPS_DOCKER_ROOTLESS:-0}" == "1" ]]; then
      # Rootless : l'utilisateur ENV_DEVOPS_USER NE doit PAS être dans le groupe docker
      if id -nG "$ENV_DEVOPS_USER" | grep -qw docker; then
          gpasswd -d "$ENV_DEVOPS_USER" docker
      fi
  else
      # Rootful : l'utilisateur ENV_DEVOPS_USER doit être dans le groupe docker
      if ! id -nG "$ENV_DEVOPS_USER" | grep -qw docker; then
          usermod -aG docker "$ENV_DEVOPS_USER"
      fi
  fi

  if [[ "${ENVIRONMENT_IA:-0}" == "0" ]]; then
      # l'utilisateur ENV_IA_USER NE doit pas être dans le groupe $ENV_DEVOPS_GROUP
      if id -nG "$ENV_IA_USER" | grep -qw "$ENV_DEVOPS_GROUP"; then
          gpasswd -d "$ENV_IA_USER" "$ENV_DEVOPS_GROUP"
      fi
  else
      # L'utilisateur ENV_IA_USER doit être dans le groupe ENV_DEVOPS_GROUP
      if ! id -nG "$ENV_IA_USER" | grep -qw "$ENV_DEVOPS_GROUP"; then
          usermod -aG "$ENV_DEVOPS_GROUP" "$ENV_IA_USER"
      fi
  fi

	echo "🔧 CONFIGURE /home/$ENV_DEVOPS_USER"
	if [ ! -d "/home/$ENV_DEVOPS_USER" ]; then
		mkhomedir_helper "$ENV_DEVOPS_USER"
	fi

	install -d -o "$ENV_DEVOPS_USER" -g "$ENV_DEVOPS_GROUP" -m 2770 "/home/$ENV_DEVOPS_USER/.local/npm" "/home/$ENV_DEVOPS_USER/.local/npm/bin" "/home/$ENV_DEVOPS_USER/.opencode/bin" "/home/$ENV_DEVOPS_USER/datas" "/home/$ENV_DEVOPS_USER/syncthing"
	if dpkg -s direnv &>/dev/null
	then

		echo "PREREQUISITES FOR DEVOPS IS OK ✅"

	else

		echo "🔧 INSTALL PREREQUISITES FOR DEVOPS"
		apt install build-essential curl direnv wget -y

	fi

	if [ "$GO" -eq 1 ]
	then

		GO_BASE="/home/$ENV_DEVOPS_USER/go"
		INSTALL_DIR="$GO_BASE/versions"
		CURRENT_LINK="$GO_BASE/current"
		GO_LATEST=$(git ls-remote --tags https://github.com/golang/go.git | awk -F/ '{print $3}' | sed 's/^go//' | grep -E '^[0-9]+\.[0-9]+(\.[0-9]+)?$' | sort -V | tail -1)
		
		mkdir -p "$INSTALL_DIR"

		if [ -L "$CURRENT_LINK" ]; then
			GO_CURRENT=$(basename "$(readlink -f "$CURRENT_LINK")")
			GO_CURRENT=${GO_CURRENT#go}
		else
			GO_CURRENT="none"
		fi

		TARGET_DIR="$INSTALL_DIR/go$GO_LATEST"

		if [ "$GO_CURRENT" != "$GO_LATEST" ]; then

			echo "🔧 INSTALL / UPDATE GO ($GO_LATEST vs $GO_CURRENT)"

			cd /tmp || exit 1

			ARCH="linux-amd64"
			FILE="go${GO_LATEST}.${ARCH}.tar.gz"
			URL="https://go.dev/dl/$FILE"

			rm -f "$FILE"

			if ! wget -q "$URL" -O "$FILE"; then
				echo "❌ Échec du téléchargement de $URL"
				rm -f "$FILE"
				exit 1
			fi

			if [ ! -s "$FILE" ]; then
				echo "❌ Le fichier téléchargé est vide"
				rm -f "$FILE"
				exit 1
        fi

			rm -rf "$TARGET_DIR"
			mkdir -p "$TARGET_DIR"

			if ! tar -C "$TARGET_DIR" --strip-components=1 -xzf "$FILE"; then
				echo "❌ Échec de l'extraction de Go"
				rm -rf "$TARGET_DIR"
				rm -f "$FILE"
				exit 1
			fi

			rm -f "$FILE"

			ln -sfn "$TARGET_DIR" "$CURRENT_LINK"

			chown -R "$ENV_DEVOPS_USER:$DEVOPS_GROUP" "$GO_BASE"

		else

			echo "GO OK ✅ ($GO_CURRENT)"

		fi

		cat > /etc/profile.d/go.sh <<'EOF'
# Go environment (managed by DIU)
export GOPATH="$HOME/go"
EOF

    chmod 644 /etc/profile.d/go.sh

    if [ "$TGPT" -eq 1 ]
    then

        REPO="https://github.com/aandrew-me/tgpt.git"
        BINARY="/home/$ENV_DEVOPS_USER/go/bin/tgpt"
        GO_BIN="/home/$ENV_DEVOPS_USER/go/current/bin/go"

        LATEST=$(
            git ls-remote --tags --refs "$REPO" |
            awk -F/ '{print $3}' |
            grep -E '^v?[0-9]+\.[0-9]+' |
            sort -V |
            tail -n 1 |
            sed -e 's/v//'
        )

        if [ -x "$BINARY" ]; then
            LOCAL=$("$BINARY" --version 2>/dev/null | awk '{print $NF}')
        else
            LOCAL="none"
        fi

        if [ "$LOCAL" != "$LATEST" ]; then

            echo "🔧 INSTALL / UPDATE TGPT"

            apt install libx11-dev libxmu-dev libxtst-dev -y

            if su - "$ENV_DEVOPS_USER" -c \
                "\"$GO_BIN\" install github.com/aandrew-me/tgpt/v2@latest"
            then
                echo "✅ TGPT mis à jour avec succès ($LATEST)"
            else
                echo "❌ Erreur lors de la mise à jour"
            fi

        else

            echo "TGPT OK ✅ ($LATEST)"

        fi

    fi

	fi

  if [ "$NODEJS" -eq 1 ]
  then

    NODE_BASE="/home/$ENV_DEVOPS_USER/node"
    INSTALL_DIR="$NODE_BASE/versions"
    CURRENT_LINK="$NODE_BASE/current"

    #
    # Recherche de la dernière version Node.js disponible
    # dans la série définie par NODEJS_SERIES.
    #
    # Exemple :
    # NODEJS_SERIES="24"
    #

    NODE_INDEX="https://nodejs.org/dist/index.tab"

    if NODE_INDEX_CONTENT="$(curl -fsSL --connect-timeout 10 --max-time 60 "$NODE_INDEX")"
    then

        :

    else

        NODE_INDEX_STATUS=$?
        printf '❌ Node.js : échec de lecture de %s (curl=%s).\n' "$NODE_INDEX" "$NODE_INDEX_STATUS" >&2
        exit "$NODE_INDEX_STATUS"

    fi

    NODE_LATEST="$(
        printf '%s\n' "$NODE_INDEX_CONTENT" |
        awk -v series="v${NODEJS_SERIES}." '
            NR > 1 && index($1, series) == 1 {
                version=$1
                sub(/^v/, "", version)
                print version
            }
        ' |
        sort -V |
        tail -n 1
    )"

    if [ -z "$NODE_LATEST" ]
    then

        echo "❌ Impossible de déterminer la dernière version Node.js ${NODEJS_SERIES}.x"
        exit 1

    fi

    mkdir -p "$INSTALL_DIR"

    #
    # Détection de la version DevOps actuellement active
    #

    if [ -x "$CURRENT_LINK/bin/node" ]
    then

        NODE_CURRENT="$(
            "$CURRENT_LINK/bin/node" --version 2>/dev/null |
            sed 's/^v//'
        )"

    else

        NODE_CURRENT="none"

    fi

    TARGET_DIR="$INSTALL_DIR/node-v${NODE_LATEST}"

    #
    # Installation / mise à jour
    #

    if [ "$NODE_CURRENT" != "$NODE_LATEST" ]
    then

        echo "🔧 INSTALL / UPDATE NODE.JS ($NODE_LATEST vs $NODE_CURRENT)"

        cd /tmp || exit 1

        ARCH="linux-x64"
        FILE="node-v${NODE_LATEST}-${ARCH}.tar.xz"
        URL="https://nodejs.org/dist/v${NODE_LATEST}/${FILE}"

        rm -f "$FILE"

        if ! wget -q "$URL" -O "$FILE"
        then

            echo "❌ Échec du téléchargement de $URL"
            rm -f "$FILE"
            exit 1

        fi

        if [ ! -s "$FILE" ]
        then

            echo "❌ Le fichier téléchargé est vide"
            rm -f "$FILE"
            exit 1

        fi

        rm -rf "$TARGET_DIR"
        mkdir -p "$TARGET_DIR"

        if ! tar \
            -C "$TARGET_DIR" \
            --strip-components=1 \
            -xJf "$FILE"
        then

            echo "❌ Échec de l'extraction de Node.js"
            rm -rf "$TARGET_DIR"
            rm -f "$FILE"
            exit 1

        fi

        rm -f "$FILE"

        ln -sfn "$TARGET_DIR" "$CURRENT_LINK"

        chown -R "$ENV_DEVOPS_USER:$DEVOPS_GROUP" "$NODE_BASE"

    else

        echo "NODE.JS OK ✅ ($NODE_CURRENT)"

    fi

    #
    # Binaires Node.js / npm DevOps
    #

    NODE_BIN="$CURRENT_LINK/bin/node"
    NPM_BIN="$CURRENT_LINK/bin/npm"

    if [ ! -x "$NODE_BIN" ]
    then

        echo "❌ ERREUR : Node.js DevOps est introuvable ($NODE_BIN)"
        exit 1

    fi

    if [ ! -x "$NPM_BIN" ]
    then

        echo "❌ ERREUR : npm DevOps est introuvable ($NPM_BIN)"
        exit 1

    fi

    #
    # Configuration du préfixe npm propre à devops
    #

    install -d \
        -o "$ENV_DEVOPS_USER" \
        -g "$DEVOPS_GROUP" \
        -m 2770 \
        "/home/$ENV_DEVOPS_USER/.local/npm" \
        "/home/$ENV_DEVOPS_USER/.local/npm/bin"

    if ! su - "$ENV_DEVOPS_USER" -c \
        "PATH=\"/home/$ENV_DEVOPS_USER/node/current/bin:\$PATH\" \
        \"$NPM_BIN\" config set prefix \"\$HOME/.local/npm\" --location=user"
    then

        echo "❌ ERREUR : configuration du préfixe npm échouée"
        exit 1

    fi

    #
    # Configuration npm
    #

      cat > /etc/profile.d/npm.sh <<'EOF'
# NPM environment (managed by DIU)
export NPM_CONFIG_PREFIX="$HOME/.local/npm"
EOF

      chmod 644 /etc/profile.d/npm.sh

      #
      # Vérification finale
      #

      NODE_VERSION="$("$NODE_BIN" --version)"
      NPM_VERSION="$("$NPM_BIN" --version)"
      NPM_PREFIX="$(
          su - "$ENV_DEVOPS_USER" -c \
          "PATH=\"/home/$ENV_DEVOPS_USER/node/current/bin:\$PATH\" \
          \"$NPM_BIN\" config get prefix"
      )"

      echo "NODE.JS OK ✅ ($NODE_VERSION)"
      echo "NPM OK ✅ ($NPM_VERSION)"
      echo "NPM PREFIX OK ✅ ($NPM_PREFIX)"

  fi

	if [ "$OPENCODE" -eq 1 ]
	then

		OPENCODE_USER=$ENV_DEVOPS_USER
		INSTALL_DIR="/home/${OPENCODE_USER}/.opencode/bin"
		API="https://api.github.com/repos/anomalyco/opencode/releases?per_page=100&page="
		INSTALLER="https://opencode.ai/v2/install"

		if [ -f "${INSTALL_DIR}/opencode" ]; then
			chmod +x "${INSTALL_DIR}/opencode"
		fi

		# Version installée
		if [ -x "${INSTALL_DIR}/opencode" ]; then
			if ! INSTALLED_OUTPUT=$("${INSTALL_DIR}/opencode" --version 2>/dev/null); then
				echo "❌ OpenCode : impossible de lire la version installée, mise à jour annulée." >&2
				exit 1
			fi
			if ! INSTALLED=$(printf '%s\n' "$INSTALLED_OUTPUT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sed -n '1p') ||
				[[ ! "$INSTALLED" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
				echo "❌ OpenCode : version installée illisible, mise à jour annulée." >&2
				exit 1
			fi
		else
			INSTALLED=""
		fi

		# Récupération de la dernière release stable V2
		LATEST=""
		RELEASE_PAGE=1
		while [[ -z "$LATEST" ]]; do
			RELEASE_URL="${API}${RELEASE_PAGE}"
			if RELEASES=$(curl -fsSL --connect-timeout 10 --max-time 60 "$RELEASE_URL"); then
				LATEST=$(printf '%s\n' "$RELEASES" | sed -nE 's/^[[:space:]]*"tag_name":[[:space:]]*"v(2\.[0-9]+\.[0-9]+)",?$/\1/p' | sort -V | tail -n 1)
			else
				CURL_STATUS=$?
				echo "❌ OpenCode : échec de lecture des releases GitHub (curl=${CURL_STATUS})." >&2
				exit "$CURL_STATUS"
			fi

			if [[ -z "$LATEST" ]]; then
				if [[ "$RELEASES" == "[]" ]]; then
					echo "❌ OpenCode : aucune release stable V2 trouvée sur GitHub." >&2
					exit 1
				fi
				RELEASE_PAGE=$((RELEASE_PAGE + 1))
			fi
		done

		if [[ -z "$INSTALLED" ]] ||
			[[ "$(printf '%s\n%s\n' "$INSTALLED" "$LATEST" | sort -V | tail -n 1)" != "$INSTALLED" ]]; then

			echo "🔧 INSTALL/UPGRADE OPENCODE"
			su - "${OPENCODE_USER}" -c "curl -fsSL ${INSTALLER} | bash -s -- --version ${LATEST} --no-modify-path"
			chmod +x "${INSTALL_DIR}/opencode"

		else

			echo "OPENCODE OK ✅ ($INSTALLED)"

		fi

    # Nettoyage de l'ancien PATH
    rm -f /etc/profile.d/opencode.sh

	fi

  if [ "$OPENSPEC" -eq 1 ]
  then

      OPENSPEC_PACKAGE="@fission-ai/openspec"
      OPENSPEC_BIN="/home/$ENV_DEVOPS_USER/.local/npm/bin/openspec"

      # Vérification de npm
      NPM_BIN="/home/$ENV_DEVOPS_USER/node/current/bin/npm"

      if [ -z "$NPM_BIN" ] || [ ! -x "$NPM_BIN" ]
      then

          echo "❌ ERREUR : npm est introuvable pour l'utilisateur $ENV_DEVOPS_USER"
          exit 1

      fi

      # Recherche de la dernière version disponible d'OpenSpec
      OPENSPEC_LATEST="$(
          su - "$ENV_DEVOPS_USER" -c \
          "PATH=\"/home/$ENV_DEVOPS_USER/node/current/bin:\$PATH\" \
          \"$NPM_BIN\" view '$OPENSPEC_PACKAGE' version" 2>/dev/null
      )"

      if [ -z "$OPENSPEC_LATEST" ]
      then

        echo "❌ ERREUR : impossible de récupérer la dernière version d'OpenSpec"
        exit 1

      fi

      # Détection de la version actuellement installée
      if [ -x "$OPENSPEC_BIN" ]
      then

        OPENSPEC_CURRENT="$(
            PATH="/home/$ENV_DEVOPS_USER/node/current/bin:$PATH" \
            "$OPENSPEC_BIN" --version 2>/dev/null |
            grep -oE '[0-9]+\.[0-9]+\.[0-9]+' |
            head -n 1
        )"

      else

        OPENSPEC_CURRENT="none"

      fi

      # Installation / mise à jour
      if [ "$OPENSPEC_CURRENT" != "$OPENSPEC_LATEST" ]
      then

        echo "🔧 INSTALL/UPDATE OPENSPEC ($OPENSPEC_CURRENT → $OPENSPEC_LATEST)"

        if ! su - "$ENV_DEVOPS_USER" -c \
            "PATH=\"/home/$ENV_DEVOPS_USER/node/current/bin:\$PATH\" \
            \"$NPM_BIN\" install -g '$OPENSPEC_PACKAGE@$OPENSPEC_LATEST' \
            --allow-scripts='$OPENSPEC_PACKAGE' \
            --no-fund \
            --no-audit"
        then
            echo "❌ ERREUR : installation d'OpenSpec échouée"
            exit 1
        fi

      fi

      # Vérification finale d'OpenSpec
      if [ -x "$OPENSPEC_BIN" ]
      then

          # Création de la configuration OpenSpec
          su - "$ENV_DEVOPS_USER" -c \
              "mkdir -p /home/$ENV_DEVOPS_USER/.config/openspec"

          cat > "/home/$ENV_DEVOPS_USER/.config/openspec/config.json" <<'EOF'
{
  "featureFlags": {},
  "profile": "custom",
  "delivery": "both",
  "telemetry": {
    "enabled": true,
    "noticeSeen": true
  },
  "workflows": [
    "explore",
    "propose",
    "new",
    "continue",
    "apply",
    "verify",
    "update",
    "sync",
    "archive"
  ]
}
EOF

          chown "$ENV_DEVOPS_USER:$DEVOPS_GROUP" \
              "/home/$ENV_DEVOPS_USER/.config/openspec/config.json"

          chmod 660 \
              "/home/$ENV_DEVOPS_USER/.config/openspec/config.json"

          OPENSPEC_VERSION="$(
              PATH="/home/$ENV_DEVOPS_USER/node/current/bin:$PATH" \
              "$OPENSPEC_BIN" --version
          )"

          echo "OPENSPEC OK ✅ ($OPENSPEC_VERSION)"

      else

          echo "❌ ERREUR : commande openspec introuvable"
          exit 1

      fi

      # Initialisation ou mise à jour des commandes OpenSpec du domicile DevOps
      OPENSPEC_HOME="/home/$ENV_DEVOPS_USER"
      OPENSPEC_OPENCODE="${OPENCODE:-}"

      if ! su - "$ENV_DEVOPS_USER" -c "
          cd '${OPENSPEC_HOME//\'/\'\\\'\'}' || exit 1
          export PATH='${OPENSPEC_HOME//\'/\'\\\'\'}/node/current/bin:${OPENSPEC_HOME//\'/\'\\\'\'}/.local/npm/bin':\"\$PATH\"
          if [ -d openspec ]; then
              openspec update
          else
              case '${OPENSPEC_OPENCODE//\'/\'\\\'\'}' in
                  1) openspec init --tools opencode --profile custom ;;
                  0) openspec init --profile custom ;;
                  *) echo '❌ ERREUR : OPENCODE doit valoir 0 ou 1 pour initialiser OpenSpec.' >&2; exit 1 ;;
              esac
          fi"
      then
          echo "❌ ERREUR : préparation OpenSpec échouée dans $OPENSPEC_HOME" >&2
          exit 1
      fi

      echo "Commandes OpenSpec préparées ✅ ($OPENSPEC_HOME)"

  fi

	if [ "$PYTHON" -eq 1 ]
	then

		if ! command -v /usr/bin/python3 >/dev/null 2>&1; then
			echo "🔧 INSTALL PYTHON 3 SYSTEM"
			sudo apt update
			sudo apt install -y python3 python3-pip python3-venv
		else
			PYTHON_SYSTEM_VERSION=$(/usr/bin/python3 --version | awk '{print $2}')
			echo "PYTHON 3 SYSTEM OK ✅ ($PYTHON_SYSTEM_VERSION)"
		fi

		INSTALL_PYTHON_ROOT="/home/$ENV_DEVOPS_USER/python"
		BUILD_DIR="/usr/local/src/python-build"

		mkdir -p "$INSTALL_PYTHON_ROOT" "$BUILD_DIR"

		#
		# Recherche de la dernière version de la série demandée.
		# Exemple : PYTHON_SERIES=3.14
		# https://www.python.org/downloads/
		#
		PYTHON_SERIES_REGEX="${PYTHON_SERIES//./\\.}"
		PYTHON_LATEST="$(curl -fsSL "https://www.python.org/ftp/python/" | grep -oE "${PYTHON_SERIES_REGEX}\.[0-9]+/" |	tr -d '/' |	sort -V | tail -n 1)"

		if [ -z "$PYTHON_LATEST" ]; then
			echo "❌ Impossible de déterminer la dernière version Python ${PYTHON_SERIES}.x"
			exit 1
		fi

		PY_SHORT="$(printf '%s' "$PYTHON_LATEST" | cut -d. -f1,2)"
		PYTHON_CURRENT=""

		if [ -x "$INSTALL_PYTHON_ROOT/current/bin/python3" ]; then
			PYTHON_CURRENT="$(
				"$INSTALL_PYTHON_ROOT/current/bin/python3" --version |
				awk '{print $2}'
			)"
		fi


		if [ "$PYTHON_CURRENT" != "$PYTHON_LATEST" ]; then

			echo "🔧 INSTALL/UPDATE PYTHON 3 DEV ($PYTHON_LATEST vs $PYTHON_CURRENT)"

			apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

			cd "$BUILD_DIR"

			rm -rf "Python-${PYTHON_LATEST}"*
			wget -q "https://www.python.org/ftp/python/${PYTHON_LATEST}/Python-${PYTHON_LATEST}.tgz"

			tar -xf "Python-${PYTHON_LATEST}.tgz"
			cd "Python-${PYTHON_LATEST}"

			./configure --prefix="${INSTALL_PYTHON_ROOT}/${PYTHON_LATEST}" --enable-optimizations --with-ensurepip=install

			make -j"$(nproc)"

			env PATH="${INSTALL_PYTHON_ROOT}/${PYTHON_LATEST}/bin:${PATH}" PIP_ROOT_USER_ACTION=ignore make altinstall

			ln -sfn "${INSTALL_PYTHON_ROOT}/${PYTHON_LATEST}" "${INSTALL_PYTHON_ROOT}/current"

			rm -rf "$BUILD_DIR/Python-${PYTHON_LATEST}"

		else

			echo "PYTHON 3 DEV OK ✅ ($PYTHON_CURRENT)"

		fi

		ln -sf "${INSTALL_PYTHON_ROOT}/current/bin/python${PY_SHORT}" "${INSTALL_PYTHON_ROOT}/current/bin/python3"
		ln -sf "${INSTALL_PYTHON_ROOT}/current/bin/pip${PY_SHORT}" "${INSTALL_PYTHON_ROOT}/current/bin/pip3"

		# Psycopg est géré par les projets ; gestion DIU temporairement désactivée.
# 		if ! PYTHON_PSYCOPG_PREVIOUS_VERSION="$(
# 			"/home/$ENV_DEVOPS_USER/python/current/bin/python3" -I -B -c '
# from importlib.metadata import PackageNotFoundError, version
# try:
#     print(version("psycopg"))
# except PackageNotFoundError:
#     print("")
# '
# 		)"; then
# 			echo "❌ Échec de la lecture de la version installée de Psycopg dans le Python DevOps" >&2
# 			exit 1
# 		fi
#
# 		if ! "/home/$ENV_DEVOPS_USER/python/current/bin/python3" \
# 			-m pip install --upgrade --no-user --quiet "psycopg[binary]>=3.2,<4"; then
# 			echo "❌ Échec de l'installation ou mise à jour de Psycopg dans le Python DevOps" >&2
# 			exit 1
# 		fi
#
# 		if ! PYTHON_PSYCOPG_VERSION="$(
# 			"/home/$ENV_DEVOPS_USER/python/current/bin/python3" \
# 				-I -B -c 'import psycopg; print(psycopg.__version__)'
# 		)"; then
# 			echo "❌ Échec du contrôle de Psycopg dans le Python DevOps" >&2
# 			exit 1
# 		fi
# 		if [ "$PYTHON_PSYCOPG_PREVIOUS_VERSION" != "$PYTHON_PSYCOPG_VERSION" ]; then
# 			if [ -n "$PYTHON_PSYCOPG_PREVIOUS_VERSION" ]; then
# 				echo "🔧 UPDATE PSYCOPG DEVOPS ($PYTHON_PSYCOPG_PREVIOUS_VERSION → $PYTHON_PSYCOPG_VERSION)"
# 			else
# 				echo "🔧 INSTALL PSYCOPG DEVOPS ($PYTHON_PSYCOPG_VERSION)"
# 			fi
# 		fi
# 		echo "PSYCOPG DEVOPS OK ✅ ($PYTHON_PSYCOPG_VERSION)"

    cat > /etc/profile.d/python-dev.sh <<EOF
# Python Dev environment (managed by DIU)
export PYTHON_DEV_HOME="${INSTALL_PYTHON_ROOT}/current"
export PIP_ROOT_USER_ACTION=ignore
EOF

    chmod 644 /etc/profile.d/python-dev.sh

	fi

  chown -R "$ENV_DEVOPS_USER":"$ENV_DEVOPS_GROUP" /home/"$ENV_DEVOPS_USER"
  find /home/"$ENV_DEVOPS_USER" -type d -exec chmod 2775 {} +
  find /home/"$ENV_DEVOPS_USER" -type f ! -name '.env*' ! -name '*.token' ! -name '*.username' -exec chmod 0775 {} +
  find /home/"$ENV_DEVOPS_USER" -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0660 {} +

  ############################################################
  # DEVOPS PATH
  ############################################################

  DEVOPS_PROFILE="/etc/profile.d/zz-devops-path.sh"

  cat > "$DEVOPS_PROFILE" <<EOF
# DevOps environment PATH
# Managed by DIU

if [ "\$USER" = "$ENV_DEVOPS_USER" ]; then

    DEVOPS_PATH=""

EOF

  if [ "${PYTHON:-0}" -eq 1 ]; then
      cat >> "$DEVOPS_PROFILE" <<'EOF'
  DEVOPS_PATH="$HOME/python/current/bin"
EOF
  fi

  if [ "${GO:-0}" -eq 1 ]; then
      cat >> "$DEVOPS_PROFILE" <<'EOF'
  export GOPATH="$HOME/go"

  if [ -n "$DEVOPS_PATH" ]; then
      DEVOPS_PATH="$DEVOPS_PATH:$HOME/go/current/bin"
  else
      DEVOPS_PATH="$HOME/go/current/bin"
  fi
EOF
  fi

  if [ "${NODEJS:-0}" -eq 1 ]; then
      cat >> "$DEVOPS_PROFILE" <<'EOF'
  if [ -n "$DEVOPS_PATH" ]; then
      DEVOPS_PATH="$DEVOPS_PATH:$HOME/node/current/bin"
  else
      DEVOPS_PATH="$HOME/node/current/bin"
  fi
EOF
  fi

  cat >> "$DEVOPS_PROFILE" <<'EOF'

  # Outils communs DevOps
  if [ -n "$DEVOPS_PATH" ]; then
      DEVOPS_PATH="$DEVOPS_PATH:$HOME/.opencode/bin:$HOME/.local/npm/bin"
  else
      DEVOPS_PATH="$HOME/.opencode/bin:$HOME/.local/npm/bin"
  fi

  # PATH système
  export PATH="$DEVOPS_PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
EOF

  if [ "${GO:-0}" -eq 1 ]; then
      cat >> "$DEVOPS_PROFILE" <<'EOF'

  # Binaires installés avec "go install"
  export PATH="$PATH:$GOPATH/bin"
EOF
  fi

  cat >> "$DEVOPS_PROFILE" <<'EOF'

  unset DEVOPS_PATH

fi
EOF

  chmod 644 "$DEVOPS_PROFILE"

  configure_devops_sudoers /etc/passwd /etc/login.defs /etc/sudoers.d

fi

if [ "${ENVIRONMENT_DOCKER:-0}" -eq 1 ]
then

  groupadd -f "$ENV_DOCKER_GROUP"

  if id -u "$ENV_DOCKER_USER"> /dev/null 2>&1 
  then
    echo "USER FOR DOCKER $ENV_DOCKER_USER IS OK ✅"
    echo "$ENV_DOCKER_USER:$ENV_DOCKER_PASSWORD" | chpasswd
  else
    useradd -m "$ENV_DOCKER_USER" --gid "$ENV_DOCKER_GROUP" -s /bin/bash
    echo "$ENV_DOCKER_USER:$ENV_DOCKER_PASSWORD" | chpasswd
  fi

  usermod -aG "$ENV_DOCKER_GROUP" "$ENV_DOCKER_USER"
  usermod -aG "$ENV_DOCKER_GROUP" "$ENV_HUMAN_USER"

  if [[ "${ENV_DOCKER_DOCKER_ROOTLESS:-0}" == "1" ]]; then
      # Rootless : l'utilisateur ENV_DOCKER_USER NE doit PAS être dans le groupe docker
      if id -nG "$ENV_DOCKER_USER" | grep -qw docker; then
          gpasswd -d "$ENV_DOCKER_USER" docker
      fi
  else
      # Rootful : l'utilisateur ENV_DOCKER_USER DOIT être dans le groupe docker
      if ! id -nG "$ENV_DOCKER_USER" | grep -qw docker; then
          usermod -aG docker "$ENV_DOCKER_USER"
      fi
  fi

  echo "🔧 CONFIGURE /home/$ENV_DOCKER_USER"
  if [ ! -d "/home/$ENV_DOCKER_USER" ]; then
    mkhomedir_helper "$ENV_DOCKER_USER"
  fi

  install -d -o "$ENV_DOCKER_USER" -g "$ENV_DOCKER_GROUP" -m 2770 "/home/$ENV_DOCKER_USER/datas" "/home/$ENV_DOCKER_USER/proxy"

  su -c "mkdir -p proxy/dockhand-data" - "$ENV_DOCKER_USER"
  su -c "mkdir -p proxy/hawser-data" - "$ENV_DOCKER_USER"
  su -c "mkdir -p proxy/librespeed-data" - "$ENV_DOCKER_USER"
  su -c "mkdir -p proxy/myspeed-data" - "$ENV_DOCKER_USER"
  su -c "mkdir -p proxy/traefik-data/configurations" - "$ENV_DOCKER_USER"
  su -c "mkdir -p proxy/traefik-manager/backups" - "$ENV_DOCKER_USER"

  su -c "mkdir -p datas" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/camofox" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/forgejo" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/g4f-cookies" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/g4f-medias" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/ldap/db" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/ldap/config" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/meilisearch" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/pgadmin" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/postgres" - "$ENV_DOCKER_USER"
  su -c "mkdir -p datas/redis" - "$ENV_DOCKER_USER"
  su -c "mkdir -p inits/postgres" - "$ENV_DOCKER_USER"
  su -c "mkdir -p proxy/letsencrypt" - "$ENV_DOCKER_USER"
  su -c "touch proxy/.env" - "$ENV_DOCKER_USER"
  su -c "touch proxy/letsencrypt/acme.json" - "$ENV_DOCKER_USER"

  chown -R "$ENV_DOCKER_USER":"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"
  find /home/"$ENV_DOCKER_USER" -type d -exec chmod 2775 {} +
  find /home/"$ENV_DOCKER_USER" -type f ! -name '.env*' ! -name '*.token' ! -name '*.username' -exec chmod 0775 {} +
  find /home/"$ENV_DOCKER_USER" -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0660 {} +

  chown -R 1000:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/proxy/librespeed-data
  chmod 2770 /home/"$ENV_DOCKER_USER"
  chmod 2775 /home/"$ENV_DOCKER_USER"/datas
  chmod 2770 /home/"$ENV_DOCKER_USER"/proxy
  chmod 2770 /home/"$ENV_DOCKER_USER"/proxy/letsencrypt
  chmod 600 /home/"$ENV_DOCKER_USER"/proxy/.env
  chmod 600 /home/"$ENV_DOCKER_USER"/proxy/letsencrypt/acme.json
  chown -R 0:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/datas/camofox
  chown -R 0:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/datas/meilisearch
  chown -R 999:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/datas/redis
  chown -R 999:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/datas/postgres
  chown -R 999:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/inits/postgres
  chown -R 1000:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/datas/forgejo
  chown -R 1200:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/datas/g4f-cookies
  chown -R 1200:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/datas/g4f-medias
  chown -R 5050:"$ENV_DOCKER_GROUP" /home/"$ENV_DOCKER_USER"/datas/pgadmin

  if [[ "${ACMESH:-0}" -eq 1 ]]; then

    CERT_DIR="${ACMESH_HOME}/${DNS_OVH_DOMAIN1}_ecc"
    DEST_DIR="/home/docker/proxy/letsencrypt"

    if [[ -d "${CERT_DIR}" ]]; then

      # Vérifie la présence des fichiers indispensables
      if [[ -f "${CERT_DIR}/fullchain.cer" && \
          -f "${CERT_DIR}/${DNS_OVH_DOMAIN1}.key" ]]; then

        mkdir -p "${DEST_DIR}/${DNS_OVH_DOMAIN1}"

        cp -f "${CERT_DIR}/fullchain.cer" "${DEST_DIR}/${DNS_OVH_DOMAIN1}/fullchain.pem"
        cp -f "${CERT_DIR}/${DNS_OVH_DOMAIN1}.key" "${DEST_DIR}/${DNS_OVH_DOMAIN1}/privkey.pem"
        cp -f "${CERT_DIR}/${DNS_OVH_DOMAIN1}.cer" "${DEST_DIR}/${DNS_OVH_DOMAIN1}/cert.pem"
        DEST_DIR="/home/docker/proxy/letsencrypt/${DNS_OVH_DOMAIN1}"
        chmod 2750 "${DEST_DIR}"
        setfacl -m u:101:rx "${DEST_DIR}"
        setfacl -m u:101:r "${DEST_DIR}/cert.pem"
        setfacl -m u:101:r "${DEST_DIR}/fullchain.pem"
        setfacl -m u:101:r "${DEST_DIR}/privkey.pem"
        echo "Certificats copiés vers ${DEST_DIR} ✅"

      else
        echo "❌ Les certificats du domaine ${DNS_OVH_DOMAIN1} sont incomplets dans ${CERT_DIR}"
      fi

    else
      echo "❌ Répertoire ACME.SH introuvable : ${CERT_DIR}"
    fi

  fi
  

	# En cas de de bug de mise à jour sur containerd.io faire un un Rollback.
	# Liste des version disponibles de containerd.io --> apt list -a containerd.io
	# Réinstaller une version plus ancienne --> apt install containerd.io=1.7.28-2~debian.13~trixie && apt-mark hold containerd.io
	# Réinstaller une version plus ancienne --> apt install containerd.io=1.7.28-1~debian.13~trixie && apt-mark hold containerd.io
	# Réinstaller une version plus ancienne --> apt install containerd.io=1.7.28-0~debian.13~trixie && apt-mark hold containerd.io
	# Réinstaller une version plus ancienne --> apt install containerd.io=1.7.27-1 && apt-mark hold containerd.io
	# Puis fixer le paquet containerd.io --> apt-mark hold containerd.io
	# Vérifier les paquets fixés --> apt-mark showhold
	# Quand le problème sera résolue Défixer le paquet containerd.io --> apt-mark unhold containerd.io

	if dpkg -s containerd.io &>/dev/null
	then

		echo "DOCKER IS OK ✅"

		if [ "$DOCKER_CONTAINERDIO_FIXED" = 0 ]
		then

			apt-mark showhold | grep -q containerd.io && apt-mark unhold containerd.io

		else

			echo "🔧 INSTALL DOCKER FIXED VERSION"
			apt install containerd.io="$DOCKER_CONTAINERDIO_FIXED_VERSION" -y --allow-downgrades && apt-mark hold containerd.io
			apt install docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin uidmap -y

		fi

	else

		if [ "$DOCKER_CONTAINERDIO_FIXED" = 0 ]
		then

			echo "🔧 INSTALL DOCKER"
			apt-mark unhold containerd.io
			apt install containerd.io docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin uidmap -y
		else

			echo "🔧 INSTALL DOCKER FIXED VERSION"
			apt install containerd.io="$DOCKER_CONTAINERDIO_FIXED_VERSION" -y --allow-downgrades && apt-mark hold containerd.io
			apt install docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin uidmap -y
		fi

	fi

	echo '{' > /etc/docker/daemon.json
	{
	    echo '  "insecure-registries": ['
	    echo '    "0.0.0.0/0"'
	    echo '  ],'
	    echo '  "log-driver": "syslog",'
	    echo '  "log-opts": {'
	    echo '    "tag": "docker-{{.Name}}",'
	    echo '    "mode": "non-blocking"'
	} >> /etc/docker/daemon.json
	if [[ "${SYSTEM_DRIVERS_NVIDIA:-0}" == "1" ]]
	then
		{
		    echo '  },'
		    echo '  "runtimes": {'
		    echo '    "nvidia": {'
		    echo '      "args": [],'
		    echo '      "path": "nvidia-container-runtime"'
		    echo '    }'
		    echo '  }'
		} >> /etc/docker/daemon.json
	else
		echo '  }' >> /etc/docker/daemon.json
	fi
	echo '}' >> /etc/docker/daemon.json
	echo "DOCKER CONFIGURED ✅"

	DOCKER_COMPOSE_LAST_VERSION=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/docker/compose.git | sed -r '/v2|v5\.5|\{\}/d' | tail --lines=1 | cut --delimiter='/' --fields=3)
	if test -f /usr/local/bin/docker-compose ; then DOCKER_COMPOSE_VERSION=$(docker-compose --version | sed -e 's/.* //') ; else DOCKER_COMPOSE_VERSION=0 ; fi

	if [ "$DOCKER_COMPOSE_VERSION" = "$DOCKER_COMPOSE_LAST_VERSION" ]
	then

		echo "DOCKER-COMPOSE ($DOCKER_COMPOSE_LAST_VERSION) is OK ✅"

	else

		echo "🔧 INSTALL DOCKER-COMPOSE"
		# CHECK RELEASE NOTE --> https://github.com/docker/compose/releases
		curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_LAST_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		chmod +x /usr/local/bin/docker-compose
		ln -f -s /usr/local/bin/docker-compose /usr/bin/docker-compose
		docker-compose --version

	fi
	
	# DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
	DIVE_VERSION=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/wagoodman/dive.git | tail --lines=1 | sed -e 's/.*v//')

	if test -f /root/dive_"${DIVE_VERSION}"_linux_amd64.deb
	then

		echo "DIVE ($DIVE_VERSION) is OK ✅"		

	else

		echo "🔧 INSTALL DIVE"
		curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb"
		dpkg -i /root/dive_"${DIVE_VERSION}"_linux_amd64.deb

	fi

	if [ "$DOCKER_STACK_BUNKERWEB" -eq 1 ]
	then
		echo "🔧 CONFIGURE /home/$ENVIRONMENT_DOCKER_USER FOR BUNKERWEB DOCKHAND"
		if [ ! -d "/home/$ENVIRONMENT_DOCKER_USER" ]; then
			mkhomedir_helper "$ENVIRONMENT_DOCKER_USER"
		fi	
		su -c "mkdir -p proxy/bw-data" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/bw-data-cache/bunkernet" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/bw-data-cache/bunkerweb" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/bw-data-cache/crowdsec" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/bw-data-cache/jinja_cache" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/bw-data-cache/misc" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/bw-data-cache/realip" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/bw-db" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/nginx-data/conf.d" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/nginx-data/ssl" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/dockhand-data" - "$ENVIRONMENT_DOCKER_USER"
		su -c "mkdir -p proxy/hawser-data" - "$ENVIRONMENT_DOCKER_USER"
		chown -R "$ENVIRONMENT_DOCKER_USER":"$ENVIRONMENT_DOCKER_USER" /home/"$ENVIRONMENT_DOCKER_USER"
		chmod -R 0777 /home/"$ENVIRONMENT_DOCKER_USER"/datas
		chmod -R 0777 /home/"$ENVIRONMENT_DOCKER_USER"/inits
		chown -R 101:101 /home/"$ENVIRONMENT_DOCKER_USER"/proxy/bw-data
		chown -R 101:101 /home/"$ENVIRONMENT_DOCKER_USER"/proxy/bw-data-cache
		chmod -R 0775 /home/"$ENVIRONMENT_DOCKER_USER"/proxy/bw-data
		chmod -R 0775 /home/"$ENVIRONMENT_DOCKER_USER"/proxy/bw-data-cache
		chmod 0775 -R /home/"$ENVIRONMENT_DOCKER_USER"/proxy/letsencrypt
		chmod 600 /home/"$ENVIRONMENT_DOCKER_USER"/proxy/letsencrypt/acme.json
	fi

	if [[ "${SOFTWARES_APT_SSH_SERVER:-0}" -eq 1 ]]
	then

		echo "🔧 CONFIGURE /home/$ENVIRONMENT_DOCKER_USER FOR OPENSSH SERVER"
		su -c "mkdir -p .ssh" - "$ENVIRONMENT_DOCKER_USER"
		su -c " touch .ssh/authorized_keys" - "$ENVIRONMENT_DOCKER_USER"
		su -c "echo $KEY_SSH_ADMIN > .ssh/authorized_keys" - "$ENVIRONMENT_DOCKER_USER"
		su -c "echo $KEY_SSH_ACME >> .ssh/authorized_keys" - "$ENVIRONMENT_DOCKER_USER"
		su -c "chmod 0700 .ssh/authorized_keys" - "$ENVIRONMENT_DOCKER_USER"

	fi

	if test "$DOCKER_TREE_HOME" -eq 1
	then

		if [ "$DOCKER_STACK_BUNKERWEB" -eq 1 ]
		then

			echo ""
			su -c "tree" - "$ENVIRONMENT_DOCKER_USER"

		fi

		if [ "$DOCKER_STACK_TRAEFIK_DOCKHAND" -eq 1 ]
		then

			echo ""
			su -c "tree -I \"datas|proxy\" /home/$ENVIRONMENT_DOCKER_USER && tree -L 2 -I \"nits|proxy\" /home/$ENVIRONMENT_DOCKER_USER && tree -L 4 -I \"inits|datas\" /home/$ENVIRONMENT_DOCKER_USER" - "$ENVIRONMENT_DOCKER_USER"

		fi

	fi

	if [ "$DOCKER_STACK_BUNKERWEB" -eq 1 ]
	then

		if [[ "${DOCKER_STACK_BUNKERWEB_UPDATE:-0}" -eq 1 ]]
		then

			if [ "$DOCKER_STACK_BUNKERWEB_AUTO_UPDATE" -eq 1 ]
			then
				DOCKER_BUNKERWEB=$(git ls-remote --tags --sort='v:refname' https://github.com/bunkerity/bunkerweb.git | sed -r '/-rc|\^/d' | tail --lines=1 | sed -e 's/.*v//')
				DOCKER_BUNKERWEB_SCHEDULER=$DOCKER_BUNKERWEB
				DOCKER_BUNKERWEB_UI=$DOCKER_BUNKERWEB
			else
				DOCKER_BUNKERWEB=$DOCKER_STACK_BUNKERWEB_VERSION
				DOCKER_BUNKERWEB_SCHEDULER=$DOCKER_STACK_BUNKERWEB_VERSION
				DOCKER_BUNKERWEB_UI=$DOCKER_STACK_BUNKERWEB_VERSION
			fi
			DOCKER_DOZZLE=$(git ls-remote --tags --sort='v:refname' https://github.com/amir20/dozzle.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//')
			DOCKER_OST=$(git ls-remote --tags --sort='v:refname' https://github.com/openspeedtest/Docker-Image.git | tail --lines=1 | cut --delimiter='/' --fields=3)
			DOCKER_PORTAINER=$(git ls-remote --tags --sort='v:refname' https://github.com/portainer/portainer.git | sed -r '/edge|internal|v/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//')
			DOCKER_POSTGRESQL=$(git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_15_|REL_16_|REL_17_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./')
			# DOCKER_POSTGRESQL=`git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_14_|REL_16_|REL_17_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./'`
			# DOCKER_POSTGRESQL=`git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_14_|REL_15_|REL_17_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./'`
			# DOCKER_POSTGRESQL=`git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_14_|REL_15_|REL_16_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./'`
			DOCKER_WHOAMI=$(git ls-remote --tags --sort='v:refname' https://github.com/traefik/whoami.git | tail --lines=1 | cut --delimiter='/' --fields=3)

			if [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml" ]
			then

				echo ""
				echo "STOP THE STACK PROXY BUNKERWEB"
				su -c "docker-compose -f /home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml down" - "$ENVIRONMENT_DOCKER_USER"

				echo ""
				echo "CONFIGURE THE STACK PROXY BUNKERWEB"
				sed -i "s%.*image: bunkerity/bunkerweb:.*%    image: bunkerity/bunkerweb:$DOCKER_BUNKERWEB%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: bunkerity/bunkerweb-scheduler:.*%    image: bunkerity/bunkerweb-scheduler:$DOCKER_BUNKERWEB_SCHEDULER%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: bunkerity/bunkerweb-ui:.*%    image: bunkerity/bunkerweb-ui:$DOCKER_BUNKERWEB_UI%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: amir20/dozzle:.*%    image: amir20/dozzle:$DOCKER_DOZZLE%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: openspeedtest/latest:.*%    image: openspeedtest/latest:$DOCKER_OST%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: portainer/portainer-ce:.*%    image: portainer/portainer-ce:$DOCKER_PORTAINER%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: postgres:.*%    image: postgres:$DOCKER_POSTGRESQL%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: traefik/whoami:.*%    image: traefik/whoami:$DOCKER_WHOAMI%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml

				if [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/letsencrypt/ch-nontron.fr/cert.pem" ] || [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/letsencrypt/hl-nontron.fr/cert.pem" ]
				then

					echo ""
					echo "START THE STACK PROXY BUNKERWEB"
					su -c "docker-compose -f /home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml up -d" - "$ENVIRONMENT_DOCKER_USER"
					echo "..."
					# sleep 7

				else

					echo ""
					echo "###############################################"
					echo "# NO CERTIFICAT LET'S ENCRYPT ON THIS MACHINE #"
					echo "###############################################"
					exit 0

				fi

			else

				echo ""
				echo "MISSING STACK PROXY FILES (docker-compose.yml)"

			fi

		fi

	fi

	if [ "$DOCKER_STACK_TRAEFIK_DOCKHAND" -eq 1 ]
	then

		if [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml" ] && [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/traefik-data/static.yml" ] && [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/traefik-data/configurations/dynamic.yml" ]
		then

			if [[ "${DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE:-0}" -eq 1 ]]
			then

				echo "🔧 CHECK DOCKER IMAGE STACK PROXY TRAEFIK FOR UPGRADE"
				DOCKER_DOCKHAND=$(git ls-remote --tags --sort='v:refname' https://github.com/Finsys/dockhand.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//')
				DOCKER_DOZZLE=$(git ls-remote --tags --sort='v:refname' https://github.com/amir20/dozzle.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//')
				DOCKER_HAWSER=$(git ls-remote --tags --sort='v:refname' https://github.com/Finsys/hawser.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//' | sed -e 's/\^{}//')
				DOCKER_LIBRESPEED=$(git ls-remote --tags --sort='v:refname' https://github.com/linuxserver/docker-librespeed.git | tail --lines=1 | cut --delimiter='/' --fields=3)
				DOCKER_MYSPEED=$(git ls-remote --tags --sort='v:refname' https://github.com/gnmyt/myspeed.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//')
				# DOCKER_OST=`git ls-remote --tags --sort='v:refname' https://github.com/openspeedtest/Docker-Image.git | tail --lines=1 | cut --delimiter='/' --fields=3`
        DOCKER_SOCKET_PROXY=$(git ls-remote --tags --sort='v:refname' https://github.com/tecnativa/docker-socket-proxy.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//')
				DOCKER_TRAEFIK3=$(git ls-remote --tags --sort='v:refname' https://github.com/traefik/traefik.git | sed -r '/v2/d' | sed -r '/-rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3)
				DOCKER_TRAEFIK_MANAGER=$(git ls-remote --tags --sort='v:refname' https://github.com/chr0nzz/traefik-manager.git | sed -r '/-rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//')
				DOCKER_WHOAMI=$(git ls-remote --tags --sort='v:refname' https://github.com/traefik/whoami.git | tail --lines=1 | cut --delimiter='/' --fields=3)

				echo "🔧 STOP THE STACK PROXY TRAEFIK DOCKHAND"
				su -c "docker-compose -f /home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml down" - docker

				echo "🔧 CONFIGURE THE STACK PROXY TRAEFIK DOCKHAND"
				sed -i "s%.*image: fnsys/dockhand:.*%    image: fnsys/dockhand:$DOCKER_DOCKHAND%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: amir20/dozzle:.*%    image: amir20/dozzle:$DOCKER_DOZZLE%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: ghcr.io/finsys/hawser:.*%    image: ghcr.io/finsys/hawser:$DOCKER_HAWSER%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: linuxserver/librespeed:.*%    image: linuxserver/librespeed:$DOCKER_LIBRESPEED%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: germannewsmaker/myspeed:.*%    image: germannewsmaker/myspeed:$DOCKER_MYSPEED%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				# sed -i "s%.*image: openspeedtest/latest:.*%    image: openspeedtest/latest:$DOCKER_OST%" /home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: tecnativa/docker-socket-proxy:.*%    image: tecnativa/docker-socket-proxy:$DOCKER_SOCKET_PROXY%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: traefik:.*%    image: traefik:$DOCKER_TRAEFIK3%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: ghcr.io/chr0nzz/traefik-manager:.*%    image: ghcr.io/chr0nzz/traefik-manager:$DOCKER_TRAEFIK_MANAGER%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: traefik/whoami:.*%    image: traefik/whoami:$DOCKER_WHOAMI%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml


        if [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/letsencrypt/$DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN/cert.pem" ]
        then

          echo "🔧 START THE STACK PROXY TRAEFIK DOCKHAND"
          su -c "docker-compose -f /home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml up -d" - docker
          echo "..."

        else

          echo "❌ NO CERTIFICAT LET'S ENCRYPT ON THIS MACHINE IN /home/$ENVIRONMENT_DOCKER_USER/proxy/letsencrypt/$DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN"
          exit 0

        fi

      else

				echo "🔧 CONFIGURE THE STACK PROXY TRAEFIK DOCKHAND"
				sed -i "s%.*image: fnsys/dockhand:.*%    image: fnsys/dockhand:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: amir20/dozzle:.*%    image: amir20/dozzle:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: ghcr.io/finsys/hawser:.*%    image: ghcr.io/finsys/hawser:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: linuxserver/librespeed:.*%    image: linuxserver/librespeed:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: germannewsmaker/myspeed:.*%    image: germannewsmaker/myspeed:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				#sed -i "s%.*image: openspeedtest/latest:.*%    image: openspeedtest/latest:latest%" /home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: tecnativa/docker-socket-proxy:.*%    image: tecnativa/docker-socket-proxy:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: traefik:.*%    image: traefik:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: ghcr.io/chr0nzz/traefik-manager:.*%    image: ghcr.io/chr0nzz/traefik-manager:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml
				sed -i "s%.*image: traefik/whoami:.*%    image: traefik/whoami:latest%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/docker-compose.yml

			fi

		else

			echo "❌ MISSING FILES STACK PROXY TRAEFIK DOCKHAND (docker-compose.yml/static.yml/dynamic.yml)"

		fi

	fi

	if [ "$DOCKER_PORTAINER_STACK_ELK" -eq 1 ]
	then

		if [ "$DOCKER_PORTAINER_STACK_ELK_UPGRADE" -eq 1 ]
		then

			echo "STOP STACK ELK"
			sleep 11
			curl --request POST --insecure --write-out "%{http_code}" --url "https://localhost:9443/api/stacks/$DOCKER_PORTAINER_STACK_ELK_DC_ID/stop?endpointId=$DOCKER_PORTAINER_STACK_ELK_ENDPOINT_ID" --header "x-api-key:$DOCKER_PORTAINER_API_KEY"
			echo "..."
			echo ""
			sleep 11

			echo ""
			echo "CONFIGURE THE STACK ELK"
			echo ""
			DOCKER_ELASTICSEARCH=$(git ls-remote --tags --sort='v:refname' https://github.com/elastic/elasticsearch.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//')
			DOCKER_KIBANA=$(git ls-remote --tags --sort='v:refname' https://github.com/elastic/kibana.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//')
			sed -i "s%.*image: elasticsearch:.*%    image: elasticsearch:$DOCKER_ELASTICSEARCH%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/portainer-data/compose/"$DOCKER_PORTAINER_STACK_ELK_DC_ID"/docker-compose.yml
			sed -i "s%.*image: kibana:.*%    image: kibana:$DOCKER_KIBANA%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/portainer-data/compose/"$DOCKER_PORTAINER_STACK_ELK_DC_ID"/docker-compose.yml

			echo "START STACK ELK"
			curl --request POST --insecure --write-out "%{http_code}" --url "https://localhost:9443/api/stacks/$DOCKER_PORTAINER_STACK_ELK_DC_ID/start?endpointId=$DOCKER_PORTAINER_STACK_ELK_ENDPOINT_ID" --header "x-api-key:$DOCKER_PORTAINER_API_KEY"
			echo "..."
			echo ""
			sleep 11

		fi

	fi

	if [ "$DOCKER_PORTAINER_STACK_NEXTCLOUD" -eq 1 ]
	then

		if [ "$DOCKER_PORTAINER_STACK_NEXTCLOUD_UPGRADE" -eq 1 ]
		then

			echo "STOP STACK NEXTCLOUD"
			sleep 11
			curl --request POST --insecure --write-out "%{http_code}" --url "https://localhost:9443/api/stacks/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/stop?endpointId=$DOCKER_PORTAINER_STACK_NEXTCLOUD_ENDPOINT_ID" --header "x-api-key:$DOCKER_PORTAINER_API_KEY"
			echo "..."
			echo ""
			sleep 11

			echo ""
			echo "CONFIGURE THE STACK NEXTCLOUD"
			echo ""

			DOCKER_POSTGRESQL=$(git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_15_|REL_16_|REL_17_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./')
			DOCKER_REDIS=$(git ls-remote --tags --sort='v:refname' https://github.com/redis/redis.git | sed -r '/-beta|-deprecated|-int|-m|-playpen|-rc|-watch|twitter|v1|v2/d' | tail --lines=1 | cut --delimiter='/' --fields=3)
			DOCKER_NEXTCLOUD=$(git ls-remote --tags --sort='v:refname' https://github.com/nextcloud/server.git | grep "v$DOCKER_PORTAINER_STACK_NEXTCLOUD_BRANCH" | sed -r '/\^\{\}|beta|rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//')
			DOCKER_NGINX=$(git ls-remote --tags --sort='v:refname' https://github.com/nginx/nginx.git | sed -r '/\^\{\}|beta|rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/release-//')
			DOCKER_PGADMIN=$(git ls-remote --tags --sort='v:refname' https://github.com/pgadmin-org/pgadmin4.git | sed -r '/\^\{\}|beta|rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL-//' | sed -e 's/_/./')
			DOCKER_COLLABORA=$(git ls-remote --tags --sort='v:refname' https://github.com/CollaboraOnline/online.git | grep "cp-" | sed -r '/\^\{\}|android|beta|rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/cp-//' | sed -e 's/-/./')
			sed -i "s%.*image: postgres:.*%    image: postgres:$DOCKER_POSTGRESQL%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/portainer-data/compose/"$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID"/docker-compose.yml
			sed -i "s%.*image: redis:.*%    image: redis:$DOCKER_REDIS%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/portainer-data/compose/"$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID"/docker-compose.yml
			sed -i "s%.*image: nextcloud:.*%    image: nextcloud:$DOCKER_NEXTCLOUD-fpm%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/portainer-data/compose/"$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID"/docker-compose.yml
			sed -i "s%.*image: nginx:.*%    image: nginx:$DOCKER_NGINX%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/portainer-data/compose/"$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID"/docker-compose.yml
			sed -i "s%.*image: dpage/pgadmin4:.*%    image: dpage/pgadmin4:$DOCKER_PGADMIN%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/portainer-data/compose/"$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID"/docker-compose.yml
			sed -i "s%.*image: collabora/code:.*%    image: collabora/code:$DOCKER_COLLABORA.1%" /home/"$ENVIRONMENT_DOCKER_USER"/proxy/portainer-data/compose/"$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID"/docker-compose.yml

			echo "START STACK NEXTCLOUD"
			curl --request POST --insecure --write-out "%{http_code}" --url "https://localhost:9443/api/stacks/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/start?endpointId=$DOCKER_PORTAINER_STACK_NEXTCLOUD_ENDPOINT_ID" --header "x-api-key:$DOCKER_PORTAINER_API_KEY"
			echo "..."
			echo ""
			sleep 11

		fi

	fi

	if [ "$DOCKER_CLEAN" -eq 1 ]
	then

		# echo ""
		# echo "DOCKER NETWORK PRUNE"
		# su -c "docker network prune -f" - docker

		echo ""
		echo "DOCKER SYSTEM DF BEFORE PRUNE"
		docker system df

		echo ""
		echo "DOCKER SYSTEM PRUNE"
		docker system prune -f -a --volumes

		echo ""
		echo "DOCKER SYSTEM DF AFTER PRUNE"
		docker system df

		echo ""
		echo "DOCKER PS"
		su -c "docker ps" - "$ENVIRONMENT_DOCKER_USER"

		# echo ""
		# echo 'DOCKER RMI $(DOCKER IMAGE -f "dangling=true"'
		# docker rmi $(docker images -f "dangling=true")

		echo ""
		echo "DOCKER IMAGE LS"
		su -c "docker image ls" - "$ENVIRONMENT_DOCKER_USER"

		echo ""
		echo "DOCKER NETWORK LS"
		su -c "docker network ls" - "$ENVIRONMENT_DOCKER_USER"

		echo ""
		echo "DOCKER VOLUME LS"
		su -c "docker volume ls" - "$ENVIRONMENT_DOCKER_USER"

	fi

	if [ "$DOCKER_STACK_BUNKERWEB" -eq 1 ]
	then

		if [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml" ]
		then

			if [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/letsencrypt/ch-nontron.fr/cert.pem" ] || [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/letsencrypt/hl-nontron.fr/cert.pem" ]
			then

				if [[ "${DOCKER_STACK_BUNKERWEB_UPDATE:-0}" -eq 1 ]]
				then

					echo ""
					echo "🔧 STOP DOCKER DOZZZLE/OST/PORTAINER/WHOAMI FOR PRODUCTION"
					su -c "docker stop dozzle && docker stop ost && docker stop portainer && docker stop whoami" - "$ENVIRONMENT_DOCKER_USER"

				fi

			fi

		fi

	fi

	if [ "$DOCKER_STACK_TRAEFIK_DOCKHAND" -eq 1 ]
	then

		if [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml" ] && [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/traefik-data/static.yml" ] && [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/traefik-data/configurations/dynamic.yml" ]
		then

			if [ -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/letsencrypt/$DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN/cert.pem" ]
			then

        if [[ "${DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE:-0}" -eq 1 ]]
        then

          echo ""
          echo "🔧 STOP DOCKER DOCKHAND/DOZZZLE/HAWSER/LIBRESPEED/MYSPEED/SOCKET-PROXY/TRAEFIK-MANAGER/WHOAMI FOR PRODUCTION"
          su -c "docker stop dockhand && docker stop dozzle && docker stop hawser && docker stop librespeed && docker stop myspeed && docker stop socket-proxy && docker stop traefik-manager && docker stop whoami" - "$ENVIRONMENT_DOCKER_USER"

        fi

			else

        echo "❌ NO CERTIFICAT LET'S ENCRYPT ON THIS MACHINE IN /home/$ENVIRONMENT_DOCKER_USER/proxy/letsencrypt/$DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN"
				exit 0

			fi

		fi

	fi

  configure_docker_sudoers /etc/passwd /etc/login.defs /etc/sudoers.d

else

	if test -f "/home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml"
	then

		if test -f /usr/bin/dockerd
		then

			echo ""
			echo "🔧 STOP THE STACK PROXY"
			su -c "docker-compose -f /home/$ENVIRONMENT_DOCKER_USER/proxy/docker-compose.yml down" - "$ENVIRONMENT_DOCKER_USER"

		fi

		DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
		if test -f /root/dive_"${DIVE_VERSION}"_linux_amd64.deb
		then

			echo ""
			echo "🔧 UNINSTALL DIVE"
			apt purge dive -y
			rm -f /root/dive_"${DIVE_VERSION}"_linux_amd64.deb

		fi

		if test -f /usr/bin/dockerd
		then

			echo ""
			echo "🔧 REMOVE CONTAINER STOPPED"
			docker container prune

			echo ""
			echo "🔧 REMOVE IMAGE DOCKER"
			if ! DOCKER_IMAGE_IDS="$(docker images -q)"; then
				printf '%s\n' 'Erreur : découverte des images Docker impossible.' >&2
				exit 1
			fi
			if [[ -n "$DOCKER_IMAGE_IDS" ]]; then
				mapfile -t DOCKER_IMAGES_TO_REMOVE <<< "$DOCKER_IMAGE_IDS"
				docker rmi "${DOCKER_IMAGES_TO_REMOVE[@]}"
			fi

			echo ""
			echo "🔧 REMOVE SYSTEM DOCKER"
			docker system prune

			echo ""
			echo "🔧 UNINSTALL DOCKER"
			if test -f /etc/docker/daemon.json
			then

				rm -f /etc/docker/daemon.json

			fi
			apt purge containerd.io docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin -y

		fi

		if test -f /usr/local/bin/docker-compose
		then

			echo ""
			echo "🔧 UNINSTALL DOCKER-COMPOSE"
			rm -f /usr/local/bin/docker-compose
			rm -f /usr/bin/docker-compose

		fi

		echo ""
		echo "🔧 UNINSTALL STACK PROXY"
		rm -R -f /home/docker/proxy

	fi

fi

if [ "${ENVIRONMENT_IA:-0}" -eq 1 ]
then

  groupadd -f "$ENV_IA_GROUP"
	if id -u "$ENV_IA_USER"> /dev/null 2>&1 
	then
	  echo "USER FOR IA $ENV_IA_USER IS OK ✅"
	  echo "$ENV_IA_USER:$ENV_IA_PASSWORD" | chpasswd
	else
	  useradd -m "$ENV_IA_USER" --gid "$ENV_IA_GROUP" -s /bin/bash
	  echo "$ENV_IA_USER:$ENV_IA_PASSWORD" | chpasswd
	fi

	usermod -aG "$ENV_IA_GROUP" "$ENV_IA_USER"
	usermod -aG "$ENV_IA_GROUP" "$ENV_HUMAN_USER"

  if [[ "${ENV_IA_DOCKER_ROOTLESS:-0}" == "1" ]]; then
      if ! id -nG "$ENV_IA_USER" | grep -qw docker; then
          usermod -aG docker "$ENV_IA_USER"
      fi
  else
      if id -nG "$ENV_IA_USER" | grep -qw docker; then
          gpasswd -d "$ENV_IA_USER" docker
      fi
  fi

	echo "🔧 CONFIGURE /home/$ENV_IA_USER"
	if [ ! -d "/home/$ENV_IA_USER" ]; then
		mkhomedir_helper "$ENV_IA_USER"
	fi

	install -d -o "$ENV_IA_USER" -g "$ENV_IA_GROUP" -m 2770 "/home/$ENV_IA_USER/download" "/home/$ENV_IA_USER/tools"

  chown -R "$ENV_IA_USER":"$ENV_IA_GROUP" /home/"$ENV_IA_USER"
  chmod 2770 /home/"$ENV_IA_USER"
  find /home/"$ENV_IA_USER" -type f ! -name '.env*' ! -name '*.token'  ! -name '*.username' -exec chmod 0770 {} +
  find /home/"$ENV_IA_USER" -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0660 {} +
  chown -R "$ENV_IA_USER":"$ENV_IA_GROUP" /home/"$ENV_IA_USER"/hermes
  find /home/"$ENV_IA_USER"/hermes -type d -exec chmod 2770 {} + 
  find /home/"$ENV_IA_USER"/hermes -type f ! -name '.env*' ! -name '*.token'  ! -name '*.username' -exec chmod 0770 {} +
  find /home/"$ENV_IA_USER"/hermes -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0666 {} +
  chown -R "$ENV_IA_USER":"$ENV_IA_GROUP" /home/"$ENV_IA_USER"/download
  find /home/"$ENV_IA_USER"/download -type d -exec chmod 2770 {} + 
  find /home/"$ENV_IA_USER"/download -type f ! -name '.env*' ! -name '*.token'  ! -name '*.username' -exec chmod 0770 {} +
  find /home/"$ENV_IA_USER"/download -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0666 {} +
  chown -R "$ENV_IA_USER":"$ENV_IA_GROUP" /home/"$ENV_IA_USER"/tools
  find /home/"$ENV_IA_USER"/tools -type d -exec chmod 2770 {} + 
  find /home/"$ENV_IA_USER"/tools -type f ! -name '.env*' ! -name '*.token'  ! -name '*.username' -exec chmod 0770 {} +
  find /home/"$ENV_IA_USER"/tools -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0666 {} +

  chmod 2770 /home/"$ENV_IA_USER"

fi

if [[ "${SOFTWARES_APT_FASTFETCH:-0}" -eq 1 ]]
then

	if [ "$SYSTEM_DEBIAN_RELEASE" = "bookworm" ] || [ "$SYSTEM_DEBIAN_RELEASE" = "bullseye" ]
	then

		echo "INSTALL NEOFETCH"
		mkdir -p /root/.config/neofetch
		apt install neofetch -y

		echo "CONFIGURE NEOFETCH"
		neofetch
		touch /root/.config/neofetch/config.conf
		sed -i 's%.*info "CPU Usage" cpu_usage.*%    info "CPU Usage" cpu_usage%' /root/.config/neofetch/config.conf
		sed -i 's%.*info "Disk" disk.*%    info "Disk" disk%' /root/.config/neofetch/config.conf
		sed -i 's%.*info "Local IP" local_ip.*%    info "Local IP" local_ip%' /root/.config/neofetch/config.conf
		sed -i 's%.*memory_percent=.*%memory_percent="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*memory_unit=.*%memory_unit="mib"%' /root/.config/neofetch/config.conf
		sed -i 's%.*shell_path=.*%shell_path="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*speed_shorthand=.*%speed_shorthand="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*cpu_brand=.*%cpu_brand="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*cpu_speed=.*%cpu_speed="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*cpu_cores=.*%cpu_cores="logical"%' /root/.config/neofetch/config.conf
		sed -i 's%.*cpu_temp=.*%cpu_temp="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*disk_percent=.*%disk_percent="on"%' /root/.config/neofetch/config.conf

	fi

	if [ "$SYSTEM_DEBIAN_RELEASE" = "trixie" ]
	then

		if dpkg -s fastfetch &>/dev/null
		then

			echo "FASTFETCH OK ✅"

		else

			echo "🔧 INSTALL FASTFETCH"
			apt install fastfetch -y

		fi

	fi

fi

if [[ "${SOFTWARES_APT_JSVC:-0}" -eq 1 ]]
then

	echo ""
	echo "🔧 INSTALL JSVC"
	apt install jsvc -y

fi

if [[ "${SOFTWARES_APT_LEMONLDAP:-0}" -eq 1 ]]
then

	echo ""
	echo "🔧 INSTALL LEMONLDAP-NG"
	apt install lemonldap-ng lemonldap-ng-doc liblasso-perl krb5-user -y

fi

if [[ "${SOFTWARES_APT_MONGODB:-0}" -eq 1 ]]
then

	echo ""
	echo "🔧 INSTALL MONGODB"
	apt install mongodb-org -y
	systemctl start mongod
	systemctl enable mongod
	mongosh --eval 'db.runCommand({ connectionStatus: 1 })'
	mongod --version
	mongosh --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
	# mongosh --eval 'db.adminCommand( { setFeatureCompatibilityVersion: "7.0", confirm: true } )'

fi

if [[ "${SOFTWARES_APT_OPENJDK:-0}" -eq 1 ]]
then

	if [ "$SYSTEM_DEBIAN_RELEASE" = "bookworm" ] || [ "$SYSTEM_DEBIAN_RELEASE" = "bullseye" ]
	then

		echo ""
		echo "🔧 INSTALL OPENJDK"
		apt install openjdk-17-jre-headless -y
		mkdir -p /usr/lib/jvm/java-17-openjdk-amd64/lib/amd64
		ln -s -f /usr/lib/jvm/java-17-openjdk-amd64/lib/server /usr/lib/jvm/java-17-openjdk-amd64/lib/amd64/

		# CONFIGURE OPENJDK PROXY
		if [[ "${SYSTEM_PROXY:-0}" == "1" ]]
		then

			sed -i "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=true%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.proxyHost=.*%http.proxyHost=$PROXY_HTTP_HOST%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.proxyPort=.*%http.proxyPort=$PROXY_HTTP_PORT%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*https.proxyHost=.*%https.proxyHost=$PROXY_HTTPS_HOST%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*https.proxyPort=.*%https.proxyPort=$PROXY_HTTPS_PORT%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.nonProxyHosts=.*%http.nonProxyHosts=localhost|127.0.0.1|127.0.1.1|[::1]%" /etc/java-17-openjdk/net.properties

		else

			sed -i "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=false%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.proxyHost=.*%# http.proxyHost=%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.proxyPort=.*%# http.proxyPort=80%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*https.proxyHost=.*%# https.proxyHost=%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*https.proxyPort=.*%# https.proxyPort=443%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.nonProxyHosts=.*%http.nonProxyHosts=localhost|127.*|[::1]%" /etc/java-17-openjdk/net.properties


		fi

	fi

	if [ "$SYSTEM_DEBIAN_RELEASE" = "trixie" ]
	then


		echo ""
		echo "🔧 INSTALL OPENJDK"
		apt install openjdk-21-jre-headless -y
		mkdir -p /usr/lib/jvm/java-21-openjdk-amd64/lib/amd64
		ln -s -f /usr/lib/jvm/java-21-openjdk-amd64/lib/server /usr/lib/jvm/java-21-openjdk-amd64/lib/amd64/

		if [ "$PROXY_HTTP" -eq 1 ]
		then

			sed -i "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=true%" /etc/java-21-openjdk/net.properties

		else

			sed -i "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=false%" /etc/java-21-openjdk/net.properties

		fi

	fi

fi

if [[ "${SOFTWARES_APT_OMADA:-0}" -eq 1 ]]
then

	if [ -f /root/omada_v"${OMADA_VERSION}".deb ]
	then

		echo ""
		echo "OMADA OK ✅"

	else

		echo ""
		echo "🔧 INSTALL OMADA"
		wget https://ota-download.tplinkcloud.com/firmware/omada_v"${OMADA_VERSION}".deb &&  dpkg -i /root/omada_v"${OMADA_VERSION}".deb

	fi

fi

if [[ "${SOFTWARES_APT_OPENVSWITCH:-0}" -eq 1 ]]
then

	if dpkg -s openvswitch-switch &>/dev/null
	then

		echo "OPENVSWITCH OK ✅"

	else

		echo "🔧 INSTALL OPENVSWITCH"
		apt install openvswitch-switch -y

	
	fi

fi

if [[ "${SOFTWARES_APT_POSTGRESQL:-0}" -eq 1 ]]
then

	echo ""
	echo "🔧 INSTALL POSTGRESQL"
	apt install postgresql -y

fi

if [[ "${SOFTWARES_APT_POSTFIX:-0}" -eq 1 ]]
then

	echo ""
	echo "🔧 INSTALL POSTFIX"
	apt install postfix -y
	sed -i "s%.*relayhost.*%relayhost = $POSTFIX_RELAY_HOST%" /etc/postfix/main.cf
	service postfix restart

fi

if [[ "${SOFTWARES_APT_QEMU_GUEST_AGENT:-0}" -eq 1 ]]
then

	echo ""
	echo "🔧INSTALL QEMU GUEST AGENT"
	apt install qemu-guest-agent -y

fi

if [[ "${SOFTWARES_APT_SYSLOG_CLIENT:-0}" -eq 1 ]]
then

	if dpkg -s rsyslog &>/dev/null
	then

		echo "RSYSLOG OK ✅"

	else

		echo "🔧INSTALL RSYSLOG"
		apt install rsyslog -y

	fi

	echo '' > /etc/rsyslog.conf
	{
	    echo '# MODULES'
	    echo 'module(load="imuxsock")'
	    echo ''
	    echo '# RIGHTS'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$FileOwner root'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$FileGroup adm'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$FileCreateMode 0640'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$DirCreateMode 0755'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$Umask 0022'
	    echo ''
	    echo '# WORKING DIRECTORY'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$WorkDirectory /tmp'
	    echo ''
	    echo '# SPECIFIC CONFIGURATIONS'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$IncludeConfig /etc/rsyslog.d/*.conf'
	    echo ''
	    echo '# DEFAULT QUEUES TUNNING'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionQueueFileName siem'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionQueueMaxDiskSpace 1g'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionQueueSaveOnShutdown off'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionQueueType LinkedList'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionResumeRetryCount -1'
	    echo ''
	    echo '# DEFAULT ACTIONS'
	    echo "*.*	@$SYSLOG_CLIENT_SERVER:514"
	    echo 'stop'
	    echo ''
	} >> /etc/rsyslog.conf

	rm -f /etc/rsyslog.d/*

	# if [ $SYSTEM_DEBIAN_ENVIRONNEMENT == "LXC" ]
	# then

	echo '' > /etc/rsyslog.d/kernel.conf
	{
	    echo '# TEMPLATE'
	    printf '%s\n' 'template (name="ulogd" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% kernel:%msg%\\n")'
	    echo ''
	    echo '# RULESET'
	    echo 'ruleset(name="ulogd") {'
	    echo "	action(type=\"omfwd\" target=\"$SYSLOG_CLIENT_SERVER\" port=\"514\" protocol=\"udp\" template=\"ulogd\")"
	    echo '}'
	    echo ''
	    echo '# SPECIFIC ACTION'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo 'if($programname == "ulogd")  then {'
	    echo '	# KERNEL QUEUES TUNNING'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionQueueFileName kernel'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionQueueMaxDiskSpace 1g'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionQueueSaveOnShutdown off'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionQueueType LinkedList'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionResumeRetryCount -1'
	    echo '	# CALL RULESET'
	    echo '	call ulogd'
	    echo '	stop'
	    echo '}'
	    echo ''
	    echo ''
	    echo ''
	    echo '# TEMPLATE'
	    printf '%s\n' 'template (name="iptables" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% kernel:%msg%\\n")'
	    echo ''
	    echo '# RULESET'
	    echo 'ruleset(name="iptables") {'
	    echo "	action(type=\"omfwd\" target=\"$SYSLOG_CLIENT_SERVER\" port=\"514\" protocol=\"udp\" template=\"iptables\")"
	    echo '}'
	    echo ''
	    echo '# SPECIFIC ACTION'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo 'if($msg contains "REJECT")  then {'
	    echo '	# KERNEL QUEUES TUNNING'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionQueueFileName kernel'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionQueueMaxDiskSpace 1g'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionQueueSaveOnShutdown off'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionQueueType LinkedList'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	$ActionResumeRetryCount -1'
	    echo '	# CALL RULESET'
	    echo '	call iptables'
	    echo '	stop'
	    echo '}'
	    echo ''
	} >> /etc/rsyslog.d/kernel.conf

	# fi

	service rsyslog restart

	if dpkg -s ulogd2 &>/dev/null
	then

		echo "ULOGD2 OK ✅"

	else

		echo "🔧INSTALL ULOGD2"
		apt install ulogd2 -y

	fi

	sed -i 's%.*stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU.*%#stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU%' /etc/ulogd.conf
	sed -i 's%.*stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG.*%stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG%' /etc/ulogd.conf
	# sed -i 's%.*stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG.*%stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG%' /etc/ulogd.conf
	sed -i 's%.*\[sys2].*%[sys1]%' /etc/ulogd.conf
	sed -i 's%.*facility=.*%facility=LOG_LOCAL0%' /etc/ulogd.conf

	service ulogd2 restart

fi

if [[ "${SOFTWARES_APT_SYSLOG_SERVER:-0}" -eq 1 ]]
then

	if dpkg -s rsyslog &>/dev/null
	then

		echo "RSYSLOG OK ✅"

	else

		echo "🔧INSTALL RSYSLOG"
		apt install rsyslog -y

	fi


	mkdir -p /var/log/machines
		
	echo '#' > /etc/rsyslog.conf
	{
	    echo '# nano /etc/rsyslog.conf'
	    echo '#'
	    echo ''
	    echo '### MODULES ###'
	    echo 'module(load="imuxsock") # provides support for local system logging'
	    echo ''
	    echo 'module(load="imudp")'
	    echo 'input(type="imudp" port="514")'
	    echo ''
	    echo 'module(load="imtcp")'
	    echo 'input(type="imtcp" port="514")'
	    echo ''
	    echo '### RIGHTS ###'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$FileOwner root'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$FileGroup adm'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$FileCreateMode 0640'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$DirCreateMode 0755'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$Umask 0022'
	    echo ''
	    echo '### WORKING DIRECTORY ###'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$WorkDirectory /tmp'
	    echo ''
	    echo '### DEFAULT QUEUE ###'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionQueueFileName siem'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionQueueMaxDiskSpace 1g'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionQueueSaveOnShutdown off'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionQueueType LinkedList'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$ActionResumeRetryCount -1'
	    echo ''
	    echo '### SPECIFIC CONFIGURATIONS ###'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$IncludeConfig /etc/rsyslog.d/*.conf'
	} >> /etc/rsyslog.conf

	if [ "$SYSLOG_SERVER_SKIL_KERNEL" -eq 1 ]
	then

		echo '#'  > /etc/rsyslog.d/1-kernel.conf
		{
		    echo '# nano /etc/rsyslog.d/1-kernel.conf' 
		    echo '#' 
		    echo '' 
		    echo '# TEMPLATE' 
		    printf '%s\n' 'template (name="ulogd" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% kernel:%msg%\n")' 
		    echo '' 
		    echo '# RULESET' 
		    echo 'ruleset(name="ulogd") {' 
		    echo "        action(type=\"omfile\" File=\"/var/log/machines/$HOSTNAME/kernel.log\" template=\"ulogd\")" 
		    echo '}' 
		    echo '' 
		    echo '# ACTION' 
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if($programname == "ulogd")  then {' 
		    echo '        # CALL RULESET' 
		    echo '        call ulogd' 
		    echo '        stop' 
		    echo '}' 
		    echo '' 
		} >> /etc/rsyslog.d/1-kernel.conf

	else

		if test -f /etc/rsyslog.d/1-kernel.conf
		then

			rm -f /etc/rsyslog.d/1-kernel.conf

		fi

	fi

	if [ "$SYSLOG_SERVER_SKIL_OMADA" -eq 1 ]
	then

		echo '#'  > /etc/rsyslog.d/2-omada.conf
		{
		    echo '# nano /etc/rsyslog.d/2-omada.conf' 
		    echo '#' 
		    echo '' 
		    echo '# TEMPLATE' 
		    printf '%s\n' 'template (name="omada" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% omada:%msg%\n")' 
		    echo '' 
		    echo '# RULESET' 
		    echo 'ruleset(name="omada") {' 
		    echo '		action(type="omfile" File="/var/log/machines/omada/omada.log" template="omada")' 
		    echo '}' 
		    echo '' 
		    echo '# ACTION' 
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if($programname == "-")  then {' 
		    echo '        # CALL RULESET' 
		    echo '        call omada' 
		    echo '        stop' 
		    echo '}' 
		    echo '' 
		} >> /etc/rsyslog.d/2-omada.conf

	else

		if test -f /etc/rsyslog.d/2-omada.conf
		then

			rm -f /etc/rsyslog.d/2-omada.conf

		fi

	fi

	if [ "$SYSLOG_SERVER_SKIL_SSO" -eq 1 ]
	then

		echo '#' > /etc/rsyslog.d/3-sso.conf
		{
		    echo '# nano /etc/rsyslog.d/3-sso.conf'
		    echo '#'
		    echo ''
		    echo '# TEMPLATE'
		    echo ''
		    printf '%s\n' 'template (name="sso" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% lemonldap-ng:%msg%\n")'
		    echo ''
		    echo '# RULESET'
		    echo 'ruleset(name="sso") {'
		    echo '        action(type="omfile" File="/var/log/machines/sso/lemonldap-ng.log" template="sso")'
		    echo '}'
		    echo ''
		    echo '# ACTION'
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if($msg contains "[LLNG:")  then {'
		    echo '        # CALL RULESET'
		    echo '        call sso'
		    echo '        stop'
		    echo '}'
		    echo ''
		} >> /etc/rsyslog.d/3-sso.conf

	else

		if test -f /etc/rsyslog.d/3-sso.conf
		then

			rm -f /etc/rsyslog.d/3-sso.conf

		fi

	fi

	if [ "$SYSLOG_SERVER_SKIL_SURICATA" -eq 1 ]
	then

		echo '#' > /etc/rsyslog.d/4-suricata.conf
		{
		    echo '# nano /etc/rsyslog.d/4-suricata.conf'
		    echo '#'
		    echo ''
		    echo '# TEMPLATES'
		    printf '%s\n' 'template (name="fw-chn-suricata" type="string" string="fw-chn %SYSLOGTAG% %msg%\n")'
		    printf '%s\n' 'template (name="fw-dmz-suricata" type="string" string="fw-dmz %SYSLOGTAG% %msg%\n")'
		    printf '%s\n' 'template (name="fw-online-suricata" type="string" string="fw-online %SYSLOGTAG% %msg%\n")'
		    printf '%s\n' 'template (name="fw-pln-suricata" type="string" string="fw-pln %SYSLOGTAG% %msg%\n")'
		    printf '%s\n' 'template (name="fw-stp-suricata" type="string" string="fw-stp %SYSLOGTAG% %msg%\n")'
		    echo ''
		    echo '# RULESETS'
		    echo 'ruleset(name="fw-chn-suricata") {'
		    echo '		action(type="omfile" File="/var/log/machines/fw-chn/suricata.log" template="fw-chn-suricata")'
		    echo '}'
		    echo ''
		    echo 'ruleset(name="fw-dmz-suricata") {'
		    echo '		action(type="omfile" File="/var/log/machines/fw-dmz/suricata.log" template="fw-dmz-suricata")'
		    echo '}'
		    echo ''
		    echo 'ruleset(name="fw-online-suricata") {'
		    echo '		action(type="omfile" File="/var/log/machines/fw-online/suricata.log" template="fw-online-suricata")'
		    echo '}'
		    echo ''
		    echo 'ruleset(name="fw-pln-suricata") {'
		    echo '		action(type="omfile" File="/var/log/machines/fw-pln/suricata.log" template="fw-pln-suricata")'
		    echo '}'
		    echo ''
		    echo 'ruleset(name="fw-stp-suricata") {'
		    echo '		action(type="omfile" File="/var/log/machines/fw-stp/suricata.log" template="fw-stp-suricata")'
		    echo '}'
		    echo ''
		    echo '# ACTIONS'
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if(($hostname == "fw-chn.ch-nontron.fr") and ($programname == "suricata"))  then {'
		    echo '        # CALL RULESET'
		    echo '        call fw-chn-suricata'
		    echo '        stop'
		    echo '}'
		    echo ''
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if(($hostname == "fw-dmz.ch-nontron.fr") and ($programname == "suricata"))  then {'
		    echo '        # CALL RULESET'
		    echo '        call fw-dmz-suricata'
		    echo '        stop'
		    echo '}'
		    echo ''
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if(($hostname == "fw-online.ch-nontron.fr") and ($programname == "suricata"))  then {'
		    echo '        # CALL RULESET'
		    echo '        call fw-online-suricata'
		    echo '        stop'
		    echo '}'
		    echo ''
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if(($hostname == "fw-online-int.ch-nontron.fr") and ($programname == "suricata"))  then {'
		    echo '        # CALL RULESET'
		    echo '        call fw-online-suricata'
		    echo '        stop'
		    echo '}'
		    echo ''
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if(($hostname == "fw-pln.ch-nontron.fr") and ($programname == "suricata"))  then {'
		    echo '        # CALL RULESET'
		    echo '        call fw-pln-suricata'
		    echo '        stop'
		    echo '}'
		    echo ''
		    echo ''
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if(($hostname == "fw-pln-int.ch-nontron.fr") and ($programname == "suricata"))  then {'
		    echo '        # CALL RULESET'
		    echo '        call fw-pln-suricata'
		    echo '        stop'
		    echo '}'
		    echo ''
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if(($hostname == "fw-stp.ch-nontron.fr") and ($programname == "suricata"))  then {'
		    echo '        # CALL RULESET'
		    echo '        call fw-stp-suricata'
		    echo '        stop'
		    echo '}'
		    echo ''
		    # Dollars littéraux destinés au fichier généré, sans expansion ici.
		    # shellcheck disable=SC2016
		    echo 'if(($hostname == "fw-stp-int.ch-nontron.fr") and ($programname == "suricata"))  then {'
		    echo '        # CALL RULESET'
		    echo '        call fw-stp-suricata'
		    echo '        stop'
		    echo '}'
		    echo ''
		} >> /etc/rsyslog.d/4-suricata.conf

	else

		if test -f /etc/rsyslog.d/4-suricata.conf
		then

			rm -f /etc/rsyslog.d/4-suricata.conf

		fi

	fi

	echo '#' > /etc/rsyslog.d/default.conf
	{
	    echo '# nano /etc/rsyslog.d/default.conf'
	    echo '#'
	    echo ''
	    echo '# DEFAULT ACTION'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '$template remote-incoming-all-logs,"/var/log/machines/%HOSTNAME%/%PROGRAMNAME%.log"'
	    echo '*.*		?remote-incoming-all-logs'
	} >> /etc/rsyslog.d/default.conf

	service rsyslog restart

	if dpkg -s ulogd2 &>/dev/null
	then

		echo "ULOGD2 OK ✅"

	else

		echo "🔧 INSTALL ULOGD2"
		apt install ulogd2 -y

	fi

	sed -i 's%.*stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU.*%#stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU%' /etc/ulogd.conf
	sed -i 's%.*stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG.*%stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG%' /etc/ulogd.conf
	# sed -i 's%.*stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG.*%stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG%' /etc/ulogd.conf
	sed -i 's%.*\[sys2].*%[sys1]%' /etc/ulogd.conf
	sed -i 's%.*facility=.*%facility=LOG_LOCAL0%' /etc/ulogd.conf

	service ulogd2 restart

	# echo "RESTART LOGROTATE"
	# service logrotate restart

fi

if [[ "${SOFTWARES_APT_SSH_SERVER:-0}" -eq 1 ]]
then

	if dpkg -s openssh-server &>/dev/null
	then

		echo "OPENSSH SERVER OK ✅"

	else

		echo "🔧 INSTALL OPENSSH SERVER"
		apt install openssh-server -y

	fi

	touch /root/.ssh/authorized_keys
	echo "$KEY_SSH_ADMIN" > /root/.ssh/authorized_keys
	echo "$KEY_SSH_ACME" >> /root/.ssh/authorized_keys
	sed -i 's%.*AuthorizedKeysFile.*%%' /etc/ssh/sshd_config
	sed -i 's%.*PermitRootLogin.*%PermitRootLogin yes%' /etc/ssh/sshd_config
	sed -i 's%.*UsePAM.*%UsePAM yes%' /etc/ssh/sshd_config
	sed -i 's%.*X11Forwarding.*%X11Forwarding no%' /etc/ssh/sshd_config
	systemctl restart ssh.service

fi

if [[ "${SOFTWARES_APT_SYNCTHING:-0}" -eq 1 ]]; then

    if dpkg -s syncthing >/dev/null 2>&1; then
        echo "SYNCTHING OK ✅"
    else
        echo "🔧 INSTALL SYNCTHING"
        apt-get install -y syncthing
    fi

fi

if [[ "${SOFTWARES_APT_WEBMIN:-0}" -eq 1 ]]
then

	echo "🔧 INSTALL WEBMIN"
	apt install webmin --install-recommends -y

else

	if [ -e /usr/share/webmin/miniserv.pl ]
	then

		echo "🔧 REMOVE WEBMIN"	
		apt purge webmin -y

	fi

fi

if [[ "${SOFTWARES_APT_WAZUH_AGENT:-0}" -eq 1 ]]
then

	if [ -f /root/wazuh-agent_"${WAZUH_CLIENT_VERSION}"_amd64.deb ]
	then

		echo ""
		echo "WAZUH-AGENT OK ✅"

	else

		echo ""
		echo "🔧 INSTALL WAZUH-AGENT"
		wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_"${WAZUH_CLIENT_VERSION}"_amd64.deb && sudo WAZUH_MANAGER='10.25.106.1' WAZUH_REGISTRATION_PASSWORD='A.JKPIS}x,hck$|;X3(L6ZCO?R,3o@aX' WAZUH_AGENT_GROUP='Linux' WAZUH_PROTOCOL='UDP' dpkg -i /root/wazuh-agent_"${WAZUH_CLIENT_VERSION}"_amd64.deb
		systemctl enable wazuh-agent.service
		systemctl start wazuh-agent.service

	fi

else

	if [ -d /var/ossec ]
	then

		echo ""	
		echo "🔧  REMOVE WAZUH-AGENT"
		apt purge wazuh-agent -y

	fi

fi

if [[ "${SOFTWARES_APT_WAZUH_SERVER:-0}" -eq 1 ]]
then

	if [ "$WAZUH_SERVER_UPGRADE" -eq 1 ]
	then

		echo ""
		echo "🔧 UPGRADE WAZUH-SERVER"
		apt -y install debhelper tar curl libcap2-bin
		apt -y install wazuh-indexer
		apt -y install wazuh-manager
		apt -y install filebeat
		apt -y install wazuh-dashboard

	fi

fi

if [[ "${SOFTWARES_APT_ZOOM:-0}" -eq 1 ]]
then

	DEB_URL="https://zoom.us/client/latest/zoom_amd64.deb"
	ROOT_DEB="/root/zoom_latest.deb"
	TMP_DEB="/tmp/zoom_latest.deb"

	# -------------------------
	# 1. Version installée
	# -------------------------
	if test -f ${ROOT_DEB}
	then
		INSTALLED_VERSION=$(dpkg-deb -f "$ROOT_DEB" Version)

	else

		INSTALLED_VERSION="none"

	fi

	# -------------------------
	# 2 - Télécharger le .deb temporairement pour lire sa version
	# -------------------------
	DEB_VERSION=$(curl -fsSI ${DEB_URL} | grep -i '^location:' | cut -d/ -f5)

	# -------------------------
	# 3 - Installation / update
	# -------------------------
	if [ "$INSTALLED_VERSION" = "none" ] || [ "$INSTALLED_VERSION" != "$DEB_VERSION" ]; then
		echo "🔧 INSTALL/UPDATE ZOOM"
		wget -q -O "$TMP_DEB" "$DEB_URL"
		apt install -y "$TMP_DEB"
	else
		echo "ZOOM OK ✅"
	fi

	if test -f ${TMP_DEB}
	then

		mv -f $TMP_DEB $ROOT_DEB

	fi

fi

if [[ "${SOFTWARES_APT_ZSH:-0}" -eq 1 ]]
then
	
	if dpkg -s fish &>/dev/null
	then

		echo "ZSH & FISH OK ✅"

	else

		echo "🔧 INSTALL ZSH"
		apt install zsh zsh-autosuggestions zsh-syntax-highlighting -y
		chsh -s "$(command -v zsh)"

		echo "🔧 INSTALL FISH"
		apt install -y fish

	fi

	if dpkg -s fzf &>/dev/null
	then

		echo "	FZF OK ✅"

	else

		echo "	🔧 INSTALL FZF"
		apt install -y fzf

	fi

	if dpkg -s tmux &>/dev/null
	then

		echo "	TMUX OK ✅"

	else

		echo "	🔧 INSTALL TMUX"
		apt install -y tmux
		tmux new -s test

	fi

  if [ "$GO" -eq 1 ]
  then

      GO_BIN="/home/$ENV_DEVOPS_USER/go/current/bin/go"
      SESH_BIN="/home/$ENV_DEVOPS_USER/go/bin/sesh"

      if [ -x "$SESH_BIN" ]
      then

          echo "	SESH OK ✅"

      else

          if [ ! -x "$GO_BIN" ]
          then

              echo "	💥 Go n'est pas installé pour $ENV_DEVOPS_USER. Abandon."
              exit 1

          fi

          echo "	🔧 INSTALL SESH"

          runuser -u "$ENV_DEVOPS_USER" -- \
              env \
                  HOME="/home/$ENV_DEVOPS_USER" \
                  GOPATH="/home/$ENV_DEVOPS_USER/go" \
                  "$GO_BIN" install github.com/joshmedeski/sesh@latest

      fi

  fi

	if dpkg -s zoxide &>/dev/null
	then

		echo "	ZOXIDE OK ✅"

	else

		echo "	🔧 INSTALL ZOXIDE"
		apt install -y zoxide

	fi

	echo "🔧 CONFIGURE ZSH FOR USER ROOT"
	sed -i 's#root:x:0:0:root:/root:/bin/bash#root:x:0:0:root:/root:/bin/zsh#' /etc/passwd
	if [ -e /root/.zshrc ]
	then
		rm /root/.zshrc
		cp /etc/zsh/newuser.zshrc.recommended /root/.zshrc
	fi
	{
	    echo ""
	    echo "# GLOBAL VARIABLES #"
	    echo "export API_DEEPSEEK_KEY=$API_DEEPSEEK_KEY"
	    echo "export API_GEMINI_KEY=$API_GEMINI_KEY"
	    echo "export API_OPENROUTER_KEY=$API_OPENROUTER_KEY"
	    echo "export EDITOR=nano"
	    echo "export LANG=fr_FR.UTF-8"

	    echo ""
	echo "# CLEAN PATH #"		
	echo 'typeset -U path PATH'

	echo ""
	echo "# SOURCES #"	
	    echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
	    echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

	    echo ""
	    echo "# HISTORY #"
	    echo "HISTSIZE=10000"
	    echo "SAVEHIST=10000"
	    echo "setopt inc_append_history"
	    echo "setopt share_history"
	    echo "setopt hist_ignore_dups"
	    echo "setopt hist_reduce_blanks"

	    echo ""
	    echo "# GLOBAL ALIAS #"
	    echo "alias -g G='| grep --color'"
	    echo "alias -g H='| head'"
	    echo "alias -g L='| less'"
	    echo "alias -g M='| more'"
	    echo "alias -g W='| wc -l'"

	    echo ""
	    echo "# APT APTITUDE#"
	    echo "alias acd='apt-cache depends'"
	    echo "alias acp='apt-cache policy'"
	    echo "alias acr='apt-cache rdepends -i --no-pre-depends'"
	    echo "alias agd='apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade'"
	    echo "alias agi='apt --show-progress install'"
	    echo "alias agif='apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress install'"
	    echo "alias agp='apt --show-progress purge'"
	    echo "alias agpf='apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress purge'"
	    echo "alias agu='apt update'"
	    echo "alias agud='apt update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade'"
	    echo "alias alu='apt list --upgradable'"
	    echo "alias ama='apt-mark auto'"
	    echo "alias amm='apt-mark manual'"
	    echo "alias aps='aptitude search'"

	    echo ""
	    echo "# CAT #"
	    echo "alias c='cat '"
	    echo "alias cdv='cat /etc/debian_version'"
	    echo "alias ceh='cat /etc/hosts'"
	    echo "alias cehc='cat /etc/host.conf'"
	    echo "alias cel='cat /etc/localtime'"
	    echo "alias ci='cat /home/devops/datas/prompts/INDEX.md'"
	    echo "alias cm='cat /home/monero/monero.log'"
	    echo "alias cpmh='cat /proc/meminfo | grep Huge'"
	    echo "alias cer='cat /etc/rsyslog.conf'"
	    echo "alias cer1='cat /etc/rsyslog.d/1-kernel.conf'"
	    echo "alias cerd='cat /etc/rsyslog.d/default.conf'"
	    echo "alias cerp='cat /etc/rsyslog.d/postfix.conf'"
	    echo "alias cetv='cat /etc/tmpfiles.d/var2log.conf'"
	    echo "alias ceu='cat /etc/ulogd.conf'"
	    echo "alias chda='cat /home/docker/.ssh/authorized_keys'"
	    echo "alias cp2='cat /home/monero/p2pool.log'"
	    echo "alias cra='cat /root/.ssh/authorized_keys'"
	    echo "alias cvll='cat /var/log/letsencrypt.log'"
	    echo "alias cx='cat /home/monero/xmrig.log'"

	    echo ""
	    echo "# CD CP MV RM #"
	    echo "alias ..='cd ..'"
	    echo "alias ...='cd ../..'"
    	# echo "alias cd='z'" >> /root/.zshrc
	    echo "alias cde='cd /etc'"
	    echo "alias cdea='cd /etc/apache2'"
	    echo "alias cdeapt='cd /etc/apt'"
	    echo "alias cdeaptconf='cd /etc/apt/apt.conf.d'"
	    echo "alias cdeaptpref='cd /etc/apt/preferences.d'"
	    echo "alias cdeaptsl='cd /etc/apt/sources.list.d'"
	    echo "alias cdeapttrust='cd /etc/apt/trusted.gpg.d'"
	    echo "alias cdeaca='cd /etc/apache2/conf-available'"
	    echo "alias cdeace='cd /etc/apache2/conf-enabled'"
	    echo "alias cdeama='cd /etc/apache2/mods-available'"
	    echo "alias cdeame='cd /etc/apache2/mods-enabled'"
	    echo "alias cdeasa='cd /etc/apache2/sites-available'"
	    echo "alias cdease='cd /etc/apache2/sites-enabled'"
	    echo "alias cded='cd /etc/default'"
	    echo "alias cdeg='cd ~/.local/share/gnome-shell/extensions/'"
	    echo "alias cdel='cd /etc/ldap'"
	    echo "alias cdels='cd /etc/ldap/slapd.d'"
	    echo "alias cdelsc='cd /etc/ldap/slapd.d/cn=config'"
	    echo "alias cden='cd /etc/network'"
	    echo "alias cdeni='cd /etc/network/interfaces.d'"
	    echo "alias cdenm='cd /etc/NetworkManager/system-connections'"
	    echo "alias cdenm='cd /etc/NetworkManager/system-connections'"
	    echo "alias cdeovpn='cd /etc/openvpn'"
	    echo "alias cder='cd /etc/rsyslog.d'"
	    echo "alias cdepf='cd /etc/postfix'"
	    echo "alias cdes='cd /etc/systemd'"
	    echo "alias cdesn='cd /etc/systemd/network'"
	    echo "alias cdess='cd /etc/systemd/system'"
	    echo "alias cdessh='cd /etc/ssh'"
	    echo "alias cdessl='cd /etc/ssl'"
	    echo "alias cdesu='cd /etc/systemd/user'"
	    echo "alias cdh='cd /home'"
	    echo "alias cdhde='cd /home/devops'"
	    echo "alias cdhded='cd /home/devops/datas'"
	    echo "alias cdhdo='cd /home/docker'"
	    echo "alias cdhdod='cd /home/docker/datas'"
	    echo "alias cdhdos='cd /home/docker/.ssh'"
	    echo "alias cdhdop='cd /home/docker/proxy'"
	    echo "alias cdhi='cd /home/ia'"
	    echo "alias cdhid='cd /home/ia/download'"
	    echo "alias cdhih='cd /home/ia/hermes'"
	    echo "alias cdhit='cd /home/ia/tools'"
	    echo "alias cdm='cd /home/monero'"
	    echo "alias cdr='cd /root'"
	    echo "alias cdt='cd /tmp'"
	    echo "alias cdub='cd /usr/bin'"
	    echo "alias cdv='cd /var'"
	    echo "alias cdvc='cd /var/cache'"
	    echo "alias cdvl='cd /var/log'"
	    echo "alias cdvlm='cd /var/log/machines'"
	    echo "alias cdvlib='cd /var/lib'"
	    echo "alias cdvlibl='cd /var/lib/ldap'"
	    echo "alias cdvm='cd /var/mail'"
	    echo "alias cdvs='cd /var/spool'"
	    echo "alias cdvt='cd /var/tmp'"
	    echo "alias cp='cp -i'"
	    echo "alias mv='mv -i'"
	    echo "alias rm='rm -i'"

	    echo ""
	    echo "# CODEX #"

	    echo ""
	    echo "# COMMAND #"
	    echo "alias co='command -v '"

	    echo ""
	    echo "# DIFF #"
	    echo "alias diffu='diff -u --suppress-common-lines'"
	    echo "alias diffy='diff -y --suppress-common-lines'"

	    echo ""
	    echo "# DIU #"
	    echo "alias rcicddiu='ridt projects cicddiu'"
	    echo "alias rcicddr='ridt projects cicddr'"
	    echo "alias rido='rid projects ocrw'"
	    echo "alias rid='/root/diu/root-install-debian.sh'"
	    echo "alias ridt='/home/devops/datas/diu/root-install-debian.sh'"
	    echo "alias ridu='rid update'"

	    echo ""
	    echo "# DF #"
	    echo "alias dfh='df -h'"

	    echo ""
	    echo "# DOCKER #"
	    echo "alias d0='docker stop'"
	    echo "alias d0d='docker stop dockhand'"
	    echo "alias d0dz='docker stop dozzle'"
	    echo "alias d0h='docker stop hawser'"
	    echo "alias d0o='docker stop ost'"
	    echo "alias d0t='docker stop traefik'"
	    echo "alias d0w='docker stop whoami'"
	    echo "alias d01d='docker restart dockhand'"
	    echo "alias d01dz='docker restart dozzle'"
	    echo "alias d01h='docker restart hawser'"
	    echo "alias d01o='docker restart ost'"
	    echo "alias d01t='docker restart traefik'"
	    echo "alias d01w='docker restart whoami'"
	    echo "alias d1='docker start'"
	    echo "alias d1d='docker start dockhand'"
	    echo "alias d1dz='docker start dozzle'"
	    echo "alias d1h='docker start hawser'"
	    echo "alias d1o='docker start ost'"
	    echo "alias d1t='docker start traefik'"
	    echo "alias d1w='docker start whoami'"
	    echo "alias dc='docker-compose --version'"
	    echo "alias ddp='su -c \"docker-compose -f /home/docker/proxy/docker-compose.yml down\" - docker'"
	    echo "alias dii='docker image inspect'"
	    echo "alias dils='docker image ls'"
	    echo "alias dl='docker logs'"
	    echo "alias dp='docker ps'"
	    echo "alias dlb='docker logs bunkerweb'"
	    echo "alias dlbbd='docker logs bw-bd'"
	    echo "alias dlbs='docker logs bw-scheduler'"
	    echo "alias dlbui='docker logs bw-ui'"
	    echo "alias dld='docker logs dozzle'"
	    echo "alias dlo='docker logs ost'"
	    echo "alias dlp='docker logs portainer'"
	    echo "alias dlt='docker logs traefik'"
	    echo "alias dlw='docker logs whoami'"
	    echo "alias dnls='docker network ls'"
	    echo "alias dpp='su -c \"docker stop dockhand && docker stop dozzle && docker stop hawser && docker stop librespeed && docker stop myspeed && docker stop traefik-manager && docker stop socket-proxy && docker stop whoami\" - docker'"
	    echo "alias drid='docker run --rm --entrypoint id'"
	    echo "alias dspa='docker system prune -f -a --volumes'"
	    echo "alias dup='su -c \"docker-compose -f /home/docker/proxy/docker-compose.yml up -d\" - docker'"
	    echo "alias dvls='docker volume ls'"

	    echo ""
	    echo "# EXIT #"
	    echo "alias e='exit'"

	    echo ""
	    echo "# FIND #"
	    echo "alias f=\"find / \( ! -regex '\/dev\|\/lost.*\|\/sys\|\/proc' -o -prune \) -type f -name\""
	    echo "alias f1=\"find / \( ! -regex '\/dev\|\/lost.*\|\/sys\|\/proc' -o -prune \) -mmin -1 -type f -name\""
	    echo "alias f7=\"find / \( ! -regex '\/dev\|\/lost.*\|\/sys\|\/proc' -o -prune \) -mmin -7 -type f -name\""
	    echo "alias f70=\"find / \( ! -regex '\/dev\|\/lost.*\|\/sys\|\/proc' -o -prune \) -mmin -70 -type f -name\""
	    echo "alias feg=\"find ~/.local/share/gnome-shell/extensions -maxdepth 2 -type f -name metadata.json -print\""
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo 'alias fsync="find \"$(pwd)\" -type f -name '\''*sync-conflict*'\''"'

	    echo ""
	    echo "# FREE #"
	    echo "alias mem='free -h'"

	    echo ""
	    echo "# GIT #"
	    echo "alias ga='git add .'"
	    echo "alias gb='git branch'"
	    echo "alias gbmain='git branch -M main'"
	    echo "alias gcll='git config --list --local'"
	    echo "alias gcoa='git commit -a '"
	    echo "alias gco1='git commit -m '"
	    echo "alias gcue='git config user.email'"
	    echo "alias gcun='git config user.name'"
	    echo "alias gd='git diff --cached --name-status'"
	    echo "alias gi='git init'"
	    echo "alias gls='git ls-files'"
	    echo "alias glog='git log --oneline --graph --decorate --all'"
	    echo "alias gp='git push -u origin main'"
	    echo "alias gr='git remote -v'"
	    echo "alias gra='git remote add origin'"
	    echo "alias grs='git remote show origin'"
	    echo "alias gs='git status'"
	    echo "alias gsi='git status --ignored'"

	    echo ""
	    echo "# Hermes #"
	    echo "alias hermes='docker exec -it hermes /opt/hermes/.venv/bin/hermes --tui'"

	    echo ""
	    echo "# IP #"
	    echo "alias ipr='ip route'"

	    echo ""
	    echo "# IPTABLES #"
	    echo "alias ipt0='/root/fwoff.sh'"
	    echo "alias ipt1='/root/fwon.sh'"
	    echo "alias iptd='iptables -L DOCKER -nvx'"
	    echo "alias ipti='iptables -L INPUT -nvx'"
	    echo "alias iptf='iptables -L FORWARD -nvx'"
	    echo "alias ipto='iptables -L OUTPUT -nvx'"

	    echo "# IPSET #"
	    echo "alias isd='ipset destroy'"
	    echo "alias isf='ipset flush'"
	    echo "alias isl='ipset -name list'"

	    echo ""
	    echo "# JOURNALCTL #"
	    echo "alias j='journalctl -f'"
	    echo "alias jf='journalctl -feu'"
	    echo "alias jx='journalctl -xeu'"

	    echo ""
	    echo "# LOCATE #"
	    echo "alias lo='locate'"

	    echo ""
	    echo "# LS #"
	    echo "alias la='ls -lA --color'"
	    echo "alias ll='ls -lah --color'"
	    echo "alias lll='ls -las --color'"
	    echo "alias ls='ls --color'"

	    echo ""
	    echo "# MORE #"
	    echo "alias logs='more /var/log/syslog'"

	    echo ""
	    echo "# NANO #"
	    echo "alias n='nano'"
	    echo "alias ndc='nano /home/docker/proxy/docker-compose.yml'"
	    echo "alias ndipb='nano /home/docker/inits/postgres/bases.sql'"
	    echo "alias nedd='nano /etc/docker/daemon.json'"
	    echo "alias nedns='nano /etc/resolv.conf'"
	    echo "alias neni='nano /etc/network/interfaces'"
	    echo "alias nef='nano /etc/fstab'"
	    echo "alias neg='nano /etc/group'"
	    echo "alias neh='nano /etc/hosts'"
	    echo "alias nehc='nano /etc/host.conf'"
	    echo "alias nep='nano /etc/passwd'"
	    echo "alias ner='nano /etc/rsyslog.conf'"
	    echo "alias ner1='nano /etc/rsyslog.d/1-kernel.conf'"
	    echo "alias nerc='nano /etc/rc.local'"
	    echo "alias nerd='nano /etc/rsyslog.d/default.conf'"
	    echo "alias nerp='nano /etc/rsyslog.d/postfix.conf'"
	    echo "alias nesj='nano /etc/systemd/journald.conf'"
	    echo "alias nesshd='nano /etc/ssh/sshd_config'"
	    echo "alias netv='nano /etc/tmpfiles.d/var2log.conf'"
	    echo "alias neu='nano /etc/ulogd.conf'"
	    echo "alias ng='nano /etc/group'"
	    echo "alias nm='nano /etc/monero/monerod.conf'"
	} >> /root/.zshrc
	echo "alias np='nano /etc/passwd'" >> /root/.zschrc
	{
	    echo "alias nrid='nano /root/diu/root-install-debian.sh'"
	    echo "alias nriv='nano /root/diu/variables.sh'"
	    echo "alias nriidjd='nano /root/root-install-init-django-dev.sh'"
	    echo "alias nriidjp='nano /root/root-install-init-django-prod.sh'"
	    echo "alias nriim='nano /root/root-install-init-monero.sh'"
	    echo "alias nriip='nano /root/root-install-init-p2pool.sh'"
	    echo "alias nriix='nano /root/root-install-init-xmrig.sh'"
	    echo "alias nriw='nano root-install-wazuh-step-by-step-single-node.sh'"
	    echo "alias nt='nano /etc/tor/torrc'"
	    echo "alias ntd='nano /home/docker/proxy/traefik-data/configurations/dynamic.yml'"
	    echo "alias ntdpixs='nano /home/docker/proxy/traefik-data/configurations/1-stack-pixs.yml'"
	    echo "alias nts='nano /home/docker/proxy/traefik-data/static.yml'"
	    echo "alias nulfdp='nano /usr/lib/firefox-esr/distribution/policies.json'"
	    echo "alias nz='nano /root/.zshrc'"

	    echo ""
	    echo "# Commande NETSTAT #"
	    echo "alias net='netstat -plantu'"

	    echo ""
	    echo "# Commande OPENCODE #"
		cat <<'EOF'
alias oc='if [ ! -f project.env ] || [ ! -r project.env ]; then echo "oc : project.env absent ou illisible, démarrage de la TUI seule."; opencode --standalone; else OPENCODE_PASSWORD="$(python3 -c '\''import shlex; print(shlex.split(next(l.split("=",1)[1] for l in open("project.env") if l.startswith("OPENCODE_PASSWORD=")), comments=True)[0])'\'')" bash -c '\'': "${OPENCODE_PASSWORD:?Mot de passe absent}"; opencode serve --hostname 0.0.0.0 --port 4096 >/dev/null & p=$!; trap "kill $p 2>/dev/null" EXIT; until curl -fsS -u "opencode:$OPENCODE_PASSWORD" http://127.0.0.1:4096/api/info >/dev/null 2>&1; do kill -0 "$p" 2>/dev/null || exit 1; sleep 0.2; done; opencode --server http://127.0.0.1:4096'\''; fi'
EOF
	    echo "alias ocv='opencode --version'"
	} >> /root/.zshrc
	{
	    echo "alias oca='/opsx:apply'"
	    echo "alias ocar='/opsx:archive'"
	    echo "alias occ='/opsx:continue'"
	    echo "alias oce='/opsx:explore'"
	    echo "alias ocp='/opsx:propose'"
	    echo "alias ocs='/opsx:sync'"
	    echo "alias ocv='/opsx:verify'"
	} >> /root/.zshrcd

	{
	    echo ""
	    echo "# Commande OPENSPEC #"
	    echo "alias os='openspec --version'"
	    echo "alias osi='openspec init --tools opencode --profile custom'"
	    echo "alias oscl='openspec config list'"
	    echo "alias oscp='openspec config path'"
	    echo "alias oscpr='openspec config profile'"
	    echo "alias oscpr='openspec config schema'"
	    echo "alias oscgd='oopenspec config get delivery'"
	    echo "alias oscgp='oopenspec config get profile'"
	    echo "alias oscgt='oopenspec config get telemetry.enabled'"
	    echo "alias osl='openspec list'"
	    echo "alias osnc='openspec new change'"
	    echo "alias oss='openspec status'"
	    echo "alias osshe='openspec schemas'"
	    echo "alias ossho='openspec show'"
	    echo "alias osu='openspec update'"
	    echo "alias osv='openspec validate'"

	    echo ""
	    echo "# Commande OVS-VSCTL #"
	    echo "alias ovs='ovs-vsctl'"
	    echo "alias ovss='ovs-vsctl show'"

	    echo ""
	    echo "# Commande P2POOL #"
	    echo "alias p2pb='echo \"bans\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"
	    echo "alias p2pe='echo \"exit\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"
	    echo "alias p2ph='echo \"hosts\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"
	    echo "alias p2phelp='echo \"help\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"
	    echo "alias p2plog0='echo \"loglevel 0\" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'"
	    echo "alias p2plog1='echo \"loglevel 1\" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'"
	    echo "alias p2plog2='echo \"loglevel 2\" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'"
	    echo "alias p2plog3='echo \"loglevel 3\" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'"
	    echo "alias p2pp='echo \"peers\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"
	    echo "alias p2ps='echo \"status\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"
	    echo "alias p2pv='echo \"version\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"
	    echo "alias p2pw='echo \"workers\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"

	    echo ""
	    echo "# Commande PING #"
	    echo "alias p='ping -4'"

	    echo ""
	    echo "# Commande PS #"
	    echo "alias psc='ps xawf -eo pid,user,cgroup,args'"
	    echo "alias psf='ps faux'"

	    echo ""
	    echo "# Commande PYTHON #"
	    echo "alias pv=' python3 -m pip --version'"

	    echo ""
	    echo "# Commande SESH #"
	    echo "alias sl='sesh list'"

	    echo ""
	    echo "# Commande SOURCE #"
	    echo "alias sa='zsh -n ~/.zshrc && source ~/.zshrc && hash -r'"

	    echo ""
	    echo "# Commande SS #"
	    echo "alias ss='ss -tulpn'"

	    echo ""
	    echo "# Commande SU #"
	    echo "alias s='su -'"
	    echo "alias sudev='su - devops'"
	    echo "alias sudoc='su - docker'"
	    echo "alias suia='su - ia'"

	    echo ""
	    echo "# Commande SYSTEMCTL #"
	    echo "alias sd='systemctl disable'"
	    echo "alias sdr='systemctl daemon-reload'"
	    echo "alias se='systemctl enable'"
	    echo "alias sss='systemctl status'"
	    echo "alias ssrc='systemctl status rc-local.service'"
	    echo "alias s0='systemctl stop'"
	    echo "alias s0rc='systemctl stop rc-local.service'"
	    echo "alias s1='systemctl start'"
	    echo "alias s1rc='systemctl start rc-local.service'"
	    echo "alias s01='systemctl restart'"
	    echo "alias s11='systemctl reload'"
	    echo "alias sser='systemctl -t service'"

	    echo ""
	    echo "# Commande SYSTEMD-ANALYSE #"
	    echo "alias sdana='systemd-analyze'"
	    echo "alias sdanab='systemd-analyze blame'"

	    echo ""
	    echo "# Commande SYSTEMD-CGLS #"
	    echo "alias syscg='systemd-cgls'"

	    echo ""
	    echo "# Commande TAIL #"
	    echo "alias ta='tail -f -n 100'"
	    echo "alias tam='tail -f -n 100 /home/monero/monero.log'"
	    echo "alias tap='tail -f -n 100 /home/monero/p2pool.log'"
	    echo "alias tax='tail -f -n 100 /home/monero/xmrig.log'"

	    echo ""
	    echo "# Commande TMUX SESH #"
	    echo "alias tm='tmux'"
	    echo "alias tma='tmux attach'"
	    echo "alias tmk='tmux kill-session -t'"
	    echo "alias tml='tmux ls'"

	    echo ""
	    echo "# Commande TREE #"
	    echo 'alias t0="tree -a"'
	    echo 'alias t1="tree -a -L 1"'
	    echo 'alias t2="tree -a -L 2"'
	    echo 'alias t3="tree -a -L 3"'
	    echo 'alias t4="tree -a -L 4"'
	    echo 'alias thde0="tree -a /home/devops"'
	    echo 'alias thde1="tree -a -L 1 /home/devops"'
	    echo 'alias thde2="tree -a -L 2 /home/devops"'
	    echo 'alias thde3="tree -a -L 3 /home/devops"'
	    echo 'alias thde4="tree -a -L 4 /home/devops"'
	    echo 'alias thded0="tree -a /home/devops/datas"'
	    echo 'alias thded1="tree -a -L 1 /home/devops/datas"'
	    echo 'alias thded2="tree -a -L 2 /home/devops/datas"'
	    echo 'alias thded3="tree -a -L 3 /home/devops/datas"'
	    echo 'alias thded4="tree -a -L 4 /home/devops/datas"'
	    echo 'alias thdo="tree -a -I \"datas|proxy\" /home/docker && tree -a -L 2 -I \"inits|proxy\" /home/docker && tree -a -L 4 -I \"inits|datas\" /home/docker"'
	    echo 'alias thdo1="tree -a -L 1 /home/docker"'
	    echo 'alias thdo2="tree -a -L 2 /home/docker"'
	    echo 'alias thdo3="tree -a -L 3 /home/docker"'
	    echo 'alias thdo4="tree -a -L 4 /home/docker"'
	    echo "alias tvl='tree /var/log'"

	    echo ""
	    echo "# Commande UNAME #"
	    echo 'alias u="uname -r"'

	    echo ""
	    echo "# Commande WHICH #"
	    echo 'alias wh="which "'

	    echo ""
	    echo "# Commande ZOXIDE #"
	    echo "alias ze='zoxide edit'"
	    echo "alias zl='zoxide query -l'"
	    echo "alias zq='zoxide query'"

	    echo ""
	    echo "# Commande ZSH #"
	    echo "alias zshc='zsh -n ~/.zshrc'"

	    echo ""
	    echo "# Commands on loading #"

	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo 'eval "$(zoxide init zsh)"'
	} >> /root/.zshrc

	# echo 'if command -v tmux >/dev/null && [ -z "$TMUX" ]; then' >> /root/.zshrc
	# echo '  tmux attach -t main || tmux new -s main' >> /root/.zshrc
	# echo 'fi' >> /root/.zshrc

	if [ "$SYSTEM_DEBIAN_RELEASE" = "bookworm" ] || [ "$SYSTEM_DEBIAN_RELEASE" = "bullseye" ]
	then

		echo "neofetch" >> /root/.zshrc

	fi

	if [ "$SYSTEM_DEBIAN_RELEASE" = "trixie" ]
	then

		echo "fastfetch" >> /root/.zshrc

	fi

	{
	    cat <<'EOF'

sc() {
  [[ -t 1 ]] || return

  local session

  session=$(sesh list | fzf \
    --prompt="Session > " \
    --preview="sesh connect {} --dry-run 2>/dev/null") || return

  # 1. tmux prioritaire
  if command -v tmux >/dev/null 2>&1; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session"
    else
      tmux attach -t "$session" 2>/dev/null || tmux new -s "$session"
    fi
    return
  fi

  # 2. zellij fallback
  if command -v zellij >/dev/null 2>&1; then
    if [ -n "$ZELLIJ" ]; then
      zellij action switch-session "$session" 2>/dev/null || zellij attach -c "$session"
    else
      zellij attach "$session" 2>/dev/null || zellij attach -c "$session"
    fi
    return
  fi

  # 3. fallback sesh pur
  sesh connect "$session"
}

EOF
	    cat <<'EOF'

ai() {
  echo "aid		-->		deepseek-v4-flash"
  echo "aidc		-->		deepseek-v4-pro"
  echo "aig		-->		gemini-3-flash-preview"
  echo "aiod		-->		deepseek/deepseek-v4-flash"
  echo "aiodc		-->		deepseek/deepseek-v4-pro"
  echo "aiog		-->		z-ai/glm-5.1"
  echo "aiok		-->		moonshotai/kimi-k2.6"
  echo "aiol		-->		inclusionai/ling-2.6-1t:free"
  echo "aiom5		-->		minimax/minimax-m2.5:free"
  echo "aiom7		-->		minimax/minimax-m2.7"
  echo "aioq		-->		qwen/qwen3.6-plus"
  echo "aip		-->		Perplexity"
}

EOF
	    cat <<'EOF'

aid() {
  local MODEL="deepseek-v4-flash"   # deepseek-v4-flash / deepseek-v4-pro
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    --arg model "$MODEL" \
    '{
      model: $model,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  # Appel API DeepSeek
  curl -sk \
    https://api.deepseek.com/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_DEEPSEEK_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aidc() {
  local MODEL="deepseek-v4-pro"   # deepseek-v4-flash / deepseek-v4-pro
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    --arg model "$MODEL" \
    '{
      model: $model,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  # Appel API DeepSeek
  curl -sk \
    https://api.deepseek.com/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_DEEPSEEK_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aig() {
  local MODEL="gemini-3-flash-preview" # gemini-2.5-flash / gemini-2.5-pro / gemini-3.1-pro-preview / gemma-4-31b-it
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."
  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    '{
      system_instruction: {
        parts: [
          {
            text: $rules
          }
        ]
      },
      contents: [
        {
          parts: [
            {
              text: $text
            }
          ]
        }
      ],
      generationConfig: {
		  maxOutputTokens: 1024,
		  temperature: 0.5,
		  topP: 0.9
      }
    }')
  # Appel API Google
  curl -sk \
    "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_GEMINI_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload" | jq -r '.candidates[0].content.parts[0].text'
}

EOF
	    cat <<'EOF'

aiod() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "deepseek/deepseek-v4-flash",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aiodc() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "deepseek/deepseek-v4-pro",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aiog() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "z-ai/glm-5.1",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aiok() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "moonshotai/kimi-k2.6",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aiol() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "inclusionai/ling-2.6-1t:free",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aiom5() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "minimax/minimax-m2.5:free",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aiom7() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "minimax/minimax-m2.7",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aioq() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "qwen/qwen3.6-plus",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	    cat <<'EOF'

aip() {
  local MODEL="auto"
  local PROVIDER="Perplexity"

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  payload=$(jq -n \
    --arg model "$MODEL" \
    --arg provider "$PROVIDER" \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    '{
      model: $model,
      provider: $provider,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  curl -sk \
    https://g4f.pixs.fr/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Accept-Encoding: identity" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message' | sed '/^> \[[0-9]\+\]/,$d'
}

EOF
	} >> /root/.zshrc

	ZPROFILE="/root/.zprofile"

	if ! grep -q "/etc/profile" "$ZPROFILE" 2>/dev/null; then

		cat <<'EOF' >>"$ZPROFILE"
# Load system environment
if [ -f /etc/profile ]; then
	source /etc/profile
fi

EOF

	fi

	SOURCE_ZSHRC="/root/.zshrc"
	HOME_BASE="/home"
	SKEL_ZSHRC="/etc/skel/.zshrc"

	if [[ ! -f "$SOURCE_ZSHRC" ]]; then
		echo "❌ Erreur : fichier source introuvable : $SOURCE_ZSHRC"
		exit 1
	fi

	echo "🔧 CONFIGURE ZSH RC FOR /ETC/SKEL"
	cp "$SOURCE_ZSHRC" "$SKEL_ZSHRC"
	chmod 644 "$SKEL_ZSHRC"

	echo "🔧 CONFIGURE ZSH RC FOR ALL USERS IN HOME"

	for user_home in "$HOME_BASE"/*; do
		[[ -d "$user_home" ]] || continue

		username="$(basename "$user_home")"
		target_zshrc="$user_home/.zshrc"

		# Vérifie que l'utilisateur système existe
		if id "$username" &>/dev/null; then
			echo "	→ $username"
			cp "$SOURCE_ZSHRC" "$target_zshrc"
			chown "$username" "$target_zshrc"
			chmod 644 "$target_zshrc"
		fi
	done

	SOURCE_ZPROFILE="/root/.zprofile"
	HOME_BASE="/home"
	SKEL_ZPROFILE="/etc/skel/.zprofile"

	if [[ ! -f "$SOURCE_ZPROFILE" ]]; then
		echo "❌ Erreur : fichier source introuvable : $SOURCE_ZPROFILE"
		exit 1
	fi

	echo "🔧 CONFIGURE ZSH PROFILE FOR /ETC/SKEL"
	cp "$SOURCE_ZPROFILE" "$SKEL_ZPROFILE"
	chmod 644 "$SKEL_ZPROFILE"

	echo "🔧 CONFIGURE ZSH AS DEFAULT SHELL"

	ZSH_PATH="$(command -v zsh)"

	if [[ -z "$ZSH_PATH" ]]; then
		echo "❌ Erreur : Zsh n'est pas installé"
		exit 1
	fi

	for user_home in /home/*; do
		[[ -d "$user_home" ]] || continue

		username="$(basename "$user_home")"

		if ! id "$username" &>/dev/null; then
			continue
		fi

		current_shell="$(getent passwd "$username" | cut -d: -f7)"

		if [[ "$current_shell" != "$ZSH_PATH" ]]; then
			echo "    → $username : $current_shell → $ZSH_PATH"
			echo "    → 🔧 PROPAGATE .ZSHRC .ZPROFILE& FOR $username : $current_shell → $ZSH_PATH"
			usermod --shell "$ZSH_PATH" "$username"
		else
			echo "    → $username  ZSH OK ✅"
		fi
	done

	echo "🔧 CONFIGURE TMUX FOR USER ROOT"
	echo "" > /root/.tmux.conf
	{
	    echo "# BASE #"
	    echo ""
	    echo "set -g mouse on"
	    echo "set -g history-limit 20000"
	    echo "set -g base-index 1"
	    echo "setw -g pane-base-index 1"
	    echo ""
	    echo "# PREFIX #"
	    echo "unbind C-b"
	    echo "set -g prefix C-a"
	    echo "bind C-a send-prefix"
	    echo ""
	    echo "# RELOADING CONFIG #"
	    echo "bind r source-file ~/.tmux.conf \; display-message "Reloaded!""
	    echo ""
	    echo "# SPLITS #"
	    echo "bind | split-window -h"
	    echo "bind - split-window -v"
	    echo ""

	    echo "# NAVIGATION #"
	    echo "bind h select-pane -L"
	    echo "bind l select-pane -R"
	    echo "bind k select-pane -U"
	    echo "bind j select-pane -D"
	    echo ""
	    echo "# COPY MODE #"
	    echo "setw -g mode-keys vi"
	    echo ""
	    echo "# STATUS BAR #"
	    echo "set -g status-bg colour235"
	    echo "set -g status-fg white"
	    echo "set -g status-left " DEVOPS ""
	    echo "set -g status-right '#(hostname) | %H:%M'"
	    echo ""
	    echo ""
	} >> /root/.tmux.conf

	echo "🔧 CONFIGURE SESH FOR USER ROOT"
	mkdir -p /root/.config/sesh
	echo "" > /root/.config/sesh/config.yaml
	{
	    echo "# DOCKER #"
	    echo "projects:"
	    echo "  docker:"
	    echo "    path: ~/docker"
	    echo "    command: tmux new-session -A -s docker"
	    echo ""
	    echo "  infra:"
	    echo "    path: ~/infra"
	    echo "    command: tmux new-session -A -s infra"
	    echo ""
	    echo "  homelab:"
	    echo "    path: ~/homelab"
	    echo "    command: tmux new-session -A -s homelab"
	    echo ""
	} >> /root/.config/sesh/config.yaml

	# echo 'zoxide init fish | source' >> ~/.config/fish/config.fish

fi

### RC.LOCAL ###

if [[ "${SYSTEM_RC_LOCAL:-0}" -eq 1 ]]
then

	echo "🔧 CONFIGURE RC.LOCAL"
	echo ""
	touch /etc/rc.local
	chmod +x /etc/rc.local
	echo '#!/bin/bash -e' > /etc/rc.local
	{
	    echo ''
	    echo ''
	    echo ''

	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo 'case "$1" in'
	    echo '	start)'
	    echo '		echo "rc.local Start..."'
	    echo ''
	    echo ''
	    echo ''
	} >> /etc/rc.local

	if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == "PROXMOX" ]
	then

		if [ "$BRIDGE_ETHERNET1_CONFIG_IP" == "PROXMOX" ]
		then

			{
			    echo '# CONFIGURE FILE HOST'
			    echo "HOSTNAME=$HOSTNAME" 
			    echo "HOSTNAME_FQDN=$HOSTNAME_FQDN" 
			    echo "BRIDGE_ETHERNET1_IP=\`ip a show $BRIDGE_ETHERNET1 | grep inet | sed -e 's/^.*inet[[:space:]]//' | sed -e 's/[[:space:]]brd.*//' | sed -e 's/\/.*//'\`" 
			    echo 'echo "127.0.0.1       localhost" > /etc/hosts'
			    # Dollars littéraux destinés au fichier généré, sans expansion ici.
			    # shellcheck disable=SC2016
			    echo 'echo "$BRIDGE_ETHERNET1_IP	$HOSTNAME_FQDN	$HOSTNAME" >> /etc/hosts'
			    echo 'echo "" >> /etc/hosts'
			    echo 'echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts'
			    echo 'echo "::1     localhost ip6-localhost ip6-loopback" >> /etc/hosts'
			    echo 'echo "ff02::1 ip6-allnodes" >> /etc/hosts'
			    echo 'echo "ff02::2 ip6-allrouters" >> /etc/hosts'
			    echo ""
			    echo ""
			    echo ""
			} >> /etc/rc.local

		fi

	fi

	echo '# IPTABLES INIT' >> /etc/rc.local
	echo '# IPTABLES INIT' > /root/fwon.sh
	if test "$DOCKER" -eq 1
	then
		echo 'if iptables -L | grep -q "^Chain DOCKER"' >> /etc/rc.local
		echo 'if iptables -L | grep -q "^Chain DOCKER"' >>  /root/fwon.sh
		echo 'then' >> /etc/rc.local
		echo 'then' >> /root/fwon.sh
			echo '	echo "Chain DOCKER OK"' >> /etc/rc.local
			echo '	echo "Chain DOCKER OK"' >> /root/fwon.sh
		echo 'else' >> /etc/rc.local
		echo 'else' >> /root/fwon.sh
			echo '	iptables -N DOCKER' >> /etc/rc.local
			echo '	iptables -N DOCKER' >> /root/fwon.sh
		echo 'fi' >> /etc/rc.local
		echo 'fi' >> /root/fwon.sh
	fi
	echo 'iptables -t filter -F' >> /etc/rc.local
	echo 'iptables -t filter -F' >> /root/fwon.sh
	echo 'iptables -t filter -X' >> /etc/rc.local
	echo 'iptables -t filter -X' >> /root/fwon.sh
	{
	    echo ''
	    echo ''
	    echo ''

	    echo '# IPTABLES STATES RELATED AND ESTABLISHED'
	} >> /etc/rc.local
	echo '# IPTABLES STATES RELATED AND ESTABLISHED' >> /root/fwon.sh
	echo 'iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT' >> /etc/rc.local
	echo 'iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT' >> /root/fwon.sh
	{
	    echo ''
	    echo ''
	    echo ''

	    echo '# IPTABLES FILTER LOCALHOST'
	} >> /etc/rc.local
	echo '# IPTABLES FILTER LOCALHOST' >> /root/fwon.sh
	echo 'iptables -A INPUT -i lo -j ACCEPT' >> /etc/rc.local
	echo 'iptables -A INPUT -i lo -j ACCEPT' >> /root/fwon.sh
	{
	    echo ''
	    echo ''
	    echo ''

	    echo '# IPTABLES FILTER ICMP'
	} >> /etc/rc.local
	echo '# IPTABLES FILTER ICMP' >> /root/fwon.sh
	echo 'iptables -A INPUT -p icmp -j ACCEPT' >> /etc/rc.local
	echo 'iptables -A INPUT -p icmp -j ACCEPT' >> /root/fwon.sh
	{
	    echo ''
	    echo ''
	    echo ''
	} >> /etc/rc.local

	if [ "$DOCKER" -eq 1 ]
	then

		DOCKER_BRIDGE=$(ip a | grep docker | grep 1500 | grep -v "veth" | sed -e 's/[[:digit:]]*:[[:space:]]//' | sed -e 's/:[[:space:]].*//')
		[[ "$DOCKER_BRIDGE" == *"docker"* ]] && echo "Bridge DOCKER OK --> $DOCKER_BRIDGE" || echo "Bridge DOCKER KO"

		if [[ "$DOCKER_BRIDGE" == *"docker"* ]]
		then

			echo '# IPTABLES FILTER FOR DOCKER BRIDGE' >> /etc/rc.local
			echo '# IPTABLES FILTER FOR DOCKER BRIDGE' >> /root/fwon.sh
			echo "iptables -A INPUT -s 192.168.100.0/24 -j ACCEPT" >> /etc/rc.local
			echo "iptables -A INPUT -s 192.168.100.0/24 -j ACCEPT" >> /root/fwon.sh
			{
			    echo ''
			    echo ''
			    echo ''
			} >> /etc/rc.local

		fi

	fi

	if [ "$ADMIN_NETWORK1" != "NONE" ]
	then

		echo "# IPTABLES FILTER ADMIN NETWORK 1" >> /etc/rc.local
		echo "# IPTABLES FILTER ADMIN NETWORK 1" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -s $ADMIN_NETWORK1 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -s $ADMIN_NETWORK1 -j ACCEPT" >> /root/fwon.sh
		{
		    echo ""
		    echo ""
		    echo ""
		} >> /etc/rc.local

	fi

	if [ "$ADMIN_NETWORK2" != "NONE" ]
	then

		echo "# IPTABLES FILTER ADMIN NETWORK 2" >> /etc/rc.local
		echo "# IPTABLES FILTER ADMIN NETWORK 2" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -s $ADMIN_NETWORK2 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -s $ADMIN_NETWORK2 -j ACCEPT" >> /root/fwon.sh
		{
		    echo ""
		    echo ""
		    echo ""
		} >> /etc/rc.local

	fi

	if [ "$ACME" != "NONE" ]
	then

		echo "# IPTABLES FILTER ACME" >> /etc/rc.local
		echo "# IPTABLES FILTER ACME" >> /root/fwon.sh
		echo "iptables -A INPUT -s $ACME -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -s $ACME -j ACCEPT" >> /root/fwon.sh
		{
		    echo ""
		    echo ""
		    echo ""
		} >> /etc/rc.local

	fi

	echo "# IPTABLES FILTER TCP/UDP PORT(S)" >> /etc/rc.local
	echo "# IPTABLES FILTER TCP/UDP PORT(S)" >> /root/fwon.sh
	if [ "$OPEN_22_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 22 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 22 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_53_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 53 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 53 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_53_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 53 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 53 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_80_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 80 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 80 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_88_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 88 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 88 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_88_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 88 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 88 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_123_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 123 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 123 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_389_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 389 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 389 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_443_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 443 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 443 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_443_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 443 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 443 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_464_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 464 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 464 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_464_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 464 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 464 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_514_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 514 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 514 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_514_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 514 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 514 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_636_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 636 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 636 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_1514_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 1514 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 1514 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_1515_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 1515 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 1515 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_2222_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 2222 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 2222 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_3001_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 3001 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 3001 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_4443_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 4443 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 4443 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_4662_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -p tcp --dport 4662 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p tcp --dport 4662 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_4662_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -p tcp --dport 4662 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p tcp --dport 4662 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_4665_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -p udp --dport 4665 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p udp --dport 4665 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_4672_UDP" -eq 1 ]
	then
		echo "iptables -A INPUT -p udp --dport 4672 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p udp --dport 4672 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_7389_TCP" -eq 1 ]
	
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 7389 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 7389 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_7422_TCP" -eq 1 ]
	
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 7422 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 7422 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_8006_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8006 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8006 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_8043_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8043 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8043 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_8080_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8080 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8080 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_8088_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8088 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8088 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_8843_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8843 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8843 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_9000_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9000 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9000 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_9443_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9443 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9443 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_9444_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9444 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9444 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_9445_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9445 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9445 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_9200_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9200 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9200 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_10000_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 10000 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 10000 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ "$OPEN_50000_TCP" -eq 1 ]
	then
		echo "iptables -A INPUT -p tcp --dport 50000 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p tcp --dport 50000 -j ACCEPT" >> /root/fwon.sh
	fi
	if [[ "${SOFTWARES_APT_OMADA:-0}" -eq 1 ]]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 19810 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 19810 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 27001 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 27001 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 27002 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 27002 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 29723 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 29723 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 29810 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 29810 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29811 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29811 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29812 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29812 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29813 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29813 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29814 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29814 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29815 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29815 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29816 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29816 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29817 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29817 -j ACCEPT" >> /root/fwon.sh
	fi

	{
	    echo ""
	    echo ""
	    echo ""

	    echo '# IPITABLES LOG'
	} >> /etc/rc.local
	echo '# IPITABLES LOG' >> /root/fwon.sh
	echo 'iptables -A INPUT -m state --state NEW -j NFLOG --nflog-group 2 --nflog-prefix "REJECT"' >> /etc/rc.local
	echo 'iptables -A INPUT -m state --state NEW -j NFLOG --nflog-group 2 --nflog-prefix "REJECT"' >> /root/fwon.sh
	{
	    echo ''
	    echo ''
	    echo ''

	    echo '# IPITABLES POLICY'
	} >> /etc/rc.local
	echo '# IPITABLES POLICY' >> /root/fwon.sh
	echo 'iptables -t filter -P INPUT DROP' >> /etc/rc.local
	echo 'iptables -t filter -P INPUT DROP' >> /root/fwon.sh
	echo 'iptables -t filter -P FORWARD ACCEPT' >> /etc/rc.local
	echo 'iptables -t filter -P FORWARD ACCEPT' >> /root/fwon.sh
	echo 'iptables -t filter -P OUTPUT ACCEPT' >> /etc/rc.local
	echo 'iptables -t filter -P OUTPUT ACCEPT' >> /root/fwon.sh
	{
	    echo ''
	    echo ''
	    echo ''

	    echo 'TIMEOUT=30'
	    echo 'COUNT=0'

    	# GATEWAY est une entrée de la configuration historique, distincte des variables locales.
    	# shellcheck disable=SC2153
	    echo "until ping -c1 -W1 $GATEWAY >/dev/null 2>&1"
	    echo 'do'
	    echo '	sleep 1'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	COUNT=$((COUNT+1))'

	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '	if [ $COUNT -ge $TIMEOUT ]; then'
	    echo '		echo "Network Timeout"'
	    echo '		exit 1'
	    echo '	fi'
	    echo 'done'

	    echo ''
	    echo 'echo "Nextwork OK"'
	    echo ''
	} >> /etc/rc.local

	if [ $INTERFACE_ETHERNET1 != "NONE" ]
	then

		if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "LXC" ]
		then
			{
				echo "# DISABLE MULTICAST FOR ETHERNET1"
				echo "ip link set $INTERFACE_ETHERNET1 multicast off"
				echo ""
				echo ""
				echo ""

				echo "# ENABLE HARDWARE OFFLOAD"
				echo "ethtool -K $INTERFACE_ETHERNET1 gso on gro on tso on"
				echo ""
				echo ""
				echo ""

				echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
				echo "# SET TX QUEUE LEN"
				echo "ip link set $INTERFACE_ETHERNET1 txqueuelen 250000"
				echo ""
				echo ""
				echo ""
				} >> /etc/rc.local
		fi

		if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "PHYSICAL" ] || [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "PROXMOX" ]
		then
			{
				echo "# DISABLE MULTICAST FOR ETHERNET1"
				echo "ip link set $INTERFACE_ETHERNET1 multicast off"
				echo ""
				echo ""
				echo ""

				echo "# ENABLE HARDWARE OFFLOAD"
				echo "ethtool -K $INTERFACE_ETHERNET1 gso on gro on tso on"
				echo ""
				echo ""
				echo ""

				echo "# SET RING BUFFER"
				echo "ethtool -G $INTERFACE_ETHERNET1 rx 4096 tx 4096"
				echo ""
				echo ""
				echo ""

				echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
				echo "# SET TX QUEUE LEN"
				echo "ip link set $INTERFACE_ETHERNET1 txqueuelen 250000"
				echo ""
				echo ""
				echo ""
				} >> /etc/rc.local
		fi

		{
		    echo "# SET UP INTERFACE"
		    echo "ip link set $INTERFACE_ETHERNET1 up"
		    echo ""
		    echo ""
		    echo ""
		} >> /etc/rc.local

	fi

	if [ $INTERFACE_ETHERNET2 != "NONE" ]
	then

		if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "LXC" ]
		then
			{
				echo "# DISABLE MULTICAST FOR INTERFACE_ETHERNET2"
				echo "ip link set $INTERFACE_ETHERNET2 multicast off"
				echo ""
				echo ""
				echo ""

				echo "# ENABLE HARDWARE OFFLOAD"
				echo "ethtool -K $INTERFACE_ETHERNET2 gso on gro on tso on"
				echo ""
				echo ""
				echo ""

				echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
				echo "# SET TX QUEUE LEN"
				echo "ip link set $INTERFACE_ETHERNET2 txqueuelen 250000"
				echo ""
				echo ""
				echo ""
				} >> /etc/rc.local
		fi

		if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "PHYSICAL" ] || [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "PROXMOX" ] || [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "VM" ]
		then
			{
				echo "# DISABLE MULTICAST FOR INTERFACE_ETHERNET2"
				echo "ip link set $INTERFACE_ETHERNET2 multicast off"
				echo ""
				echo ""
				echo ""

				echo "# ENABLE HARDWARE OFFLOAD"
				echo "ethtool -K $INTERFACE_ETHERNET2 gso on gro on tso on"
				echo ""
				echo ""
				echo ""

				echo "# SET RING BUFFER"
				echo "ethtool -G $INTERFACE_ETHERNET2 rx 4096 tx 4096"
				echo ""
				echo ""
				echo ""

				echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
				echo "# SET TX QUEUE LEN"
				echo "ip link set $INTERFACE_ETHERNET2 txqueuelen 250000"
				echo ""
				echo ""
				echo ""
			} >> /etc/rc.local
		fi

		{
		    echo "# SET UP INTERFACE"
		    echo "ip link set $INTERFACE_ETHERNET2 up"
		    echo ""
		    echo ""
		    echo ""
		} >> /etc/rc.local

	fi

	if [ "$BRIDGE_ETHERNET1" != "NONE" ]
	then

		if [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "PHYSICAL" ] || [ "$SYSTEM_DEBIAN_ENVIRONNEMENT" = "PROXMOX" ]
		then
			{
			echo "# DISABLE MULTICAST FOR BRIDGE_ETHERNET1"
			echo "ip link set $BRIDGE_ETHERNET1 multicast off"
			echo ""
			echo ""
			echo ""

			echo "# ENABLE HARDWARE OFFLOAD"
			echo "ethtool -K $BRIDGE_ETHERNET1 gso on gro on tso on"
			echo ""
			echo ""
			echo ""

			echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
			echo "# SET TX QUEUE LEN"
			echo "ip link set $BRIDGE_ETHERNET1 txqueuelen 250000"
			echo ""
			echo ""
			echo ""
			} >> /etc/rc.local
		fi

	fi

	if [[ "${SOFTWARES_APT_CROWDSEC_BOUNCER:-0}" == "1" ]]
	then
		{
		    echo '# RESTART CROWDSEC FIREWALL BOUNCER'
		    echo 'systemctl restart crowdsec-firewall-bouncer.service'
		    echo ''
		    echo ''
		    echo ''
		} >> /etc/rc.local
	fi

	echo '# TUNING ROUTE' >> /etc/rc.local
	echo "ip route change default via $GATEWAY dev $GATEWAY_INTERFACE proto kernel onlink initcwnd 44 initrwnd 44" >> /etc/rc.local
	if [ "$ROUTE1" -eq 1 ]
	then

		echo "$ROUTE1_DATA" >> /etc/rc.local

	fi
	if [ "$ROUTE2" -eq 1 ]
	then

		echo "$ROUTE2_DATA" >> /etc/rc.local

	fi
	if [ "$ROUTE3" -eq 1 ]
	then

		echo "$ROUTE3_DATA" >> /etc/rc.local

	fi
	{
	    echo ''
	    echo ''
	    echo ''

	    echo '		exit 0'
	    echo '	;;'
	    echo '	stop)'
	    echo '		echo "rc.local Stop..."'
	    echo '		exit 0'
	    echo '	;;'
	    echo '	*)'
	    # Dollars littéraux destinés au fichier généré, sans expansion ici.
	    # shellcheck disable=SC2016
	    echo '		echo "Usage: $0 {start|stop}"'
	    echo '		exit 1'
	    echo '	;;'
	    echo 'esac'
	} >> /etc/rc.local

	# FW OFF
	echo '#!/bin/sh -e' > /root/fwoff.sh
	{
	    echo ''
	    echo ''
	    echo ''
	    echo '# IPTABLES OFF'
	    echo 'iptables -t filter -P INPUT ACCEPT'
	    echo 'iptables -t filter -P FORWARD ACCEPT'
	    echo 'iptables -t filter -P OUTPUT ACCEPT'
	    echo 'iptables -t filter -F'
	    echo 'iptables -t filter -X'
	} >> /root/fwoff.sh
	if [ "$DOCKER" -eq 1 ]
	then
		echo 'iptables -X DOCKER' >> /root/fwoff.sh
	fi

	chmod +x /root/fwon.sh
	chmod +x /root/fwoff.sh

	chmod +x /etc/rc.local
	systemctl daemon-reload
	# systemctl status rc-local

	echo ""

fi

if [[ "${DOCKER_STACK_BUNKERWEB_UPDATE:-0}" -eq 1 ]]
then

	echo "###############################################"
	echo "#        STACK PROXY DOCKER_BUNKERWEB         #"
	echo "###############################################"
	echo "   DOCKER-COMPOSE	: $DOCKER_COMPOSE_LAST_VERSION"
	echo ""
	echo "   BUNKERWEB    	: $DOCKER_BUNKERWEB"
	echo "   DOCKHAND    	: $DOCKER_DOCKHAND"
	echo "   DOZZLE 		: $DOCKER_DOZZLE"
	echo "   HAWSER    	: $DOCKER_HAWSER"
	echo "   LIBRESPEED    		    : $DOCKER_LIBRESPEED"
	echo "   MYSPEED    		: $DOCKER_MYSPEED"
	echo "   SOCKET-PROXY    		: $DOCKER_SOCKET_PROXY"
	echo "   POSTGESQL    	: $DOCKER_POSTGRESQL"
	echo "   WHOAMI 		: $DOCKER_WHOAMI"
	echo "###############################################"

fi

if [[ "${DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE:-0}" -eq 1 ]]
then

	echo "##############################################"
	echo "#        STACK PROXY DOCKER TRAEFIK          #"
	echo "##############################################"
	echo "   DOCKER-COMPOSE	: $DOCKER_COMPOSE_LAST_VERSION"
	echo ""
	echo "   DOCKAND 		: $DOCKER_DOCKHAND"
	echo "   DOZZLE 		: $DOCKER_DOZZLE"
	echo "   HAWSER    	        : v$DOCKER_HAWSER"
	echo "   LIBRESPEED           : $DOCKER_LIBRESPEED"
	echo "   MYSPEED    		: v$DOCKER_MYSPEED"
	echo "   SOCKET-PROXY    	: $DOCKER_SOCKET_PROXY"
	echo "   TRAEFIK    	        : $DOCKER_TRAEFIK3"
	echo "   TRAEFIK-MANAGER    	: v$DOCKER_TRAEFIK_MANAGER"
	echo "   WHOAMI 		: $DOCKER_WHOAMI"
	echo "###############################################"

fi

echo ""
echo ""
echo ""
echo "######################################"
# shellcheck disable=SC2153
echo "# DIU VERSION 		: $DIU_VERSION #"
# VERSION provient de la configuration historique, distincte des versions locales des modules.
# shellcheck disable=SC2153
echo "# Update SCRIPT - RI 	: $VERSION #"
echo "######################################"
echo ""
echo ""
echo ""

if [[ "${SYSTEM_DEBIAN_ENVIRONNEMENT}" == "PROXMOX" ]]; then
  dmesg | grep -e DMAR -e IOMMU -e AMD-Vi || true
fi

system_info_network

exit 0
