#!/usr/bin/env bash
# Cœur générique d'authentification Git HTTPS par token
# Fournit git_with_token() — agnostique du fournisseur de forge

. "$BASH_SCRIPT_PATH/lib/logging.sh"

# Exécute une commande Git authentifiée via un token HTTPS temporaire.
#
# Signature :
#   git_with_token <project_path> <git_username> <token> <git_args...>
#
# Retourne le code de sortie de la commande Git.
# En cas de paramètres manquants ou token vide, retourne 1 sans exécuter Git.

git_with_token() {
    local project_path="${1:-}"
    local git_username="${2:-}"
    local token="${3:-}"
    shift 3 2>/dev/null || {
        print_error "git_with_token : paramètres manquants (project_path, git_username, token, git_args...)"
        return 1
    }
    local git_args=("${@}")

    # ----------------------------------------------------------
    # Validation des paramètres
    # ----------------------------------------------------------

    if [[ -z "${project_path}" ]]; then
        print_error "git_with_token : project_path est vide."
        return 1
    fi

    if [[ -z "${git_username}" ]]; then
        print_error "git_with_token : git_username est vide."
        return 1
    fi

    if [[ -z "${token}" ]]; then
        print_error "git_with_token : token est vide."
        return 1
    fi

    if [[ ${#git_args[@]} -eq 0 ]]; then
        print_error "git_with_token : aucun argument Git fourni."
        return 1
    fi

    # ----------------------------------------------------------
    # Exécution dans un subshell avec cleanup garanti
    # ----------------------------------------------------------

    (
        local tmp_dir=""

        tmp_dir="$(mktemp -d)" || {
            print_error "git_with_token : impossible de créer le répertoire temporaire."
            exit 1
        }

        chmod 700 "${tmp_dir}"

        trap 'rm -rf "${tmp_dir}"' EXIT

        # ----------------------------------------------------------
        # Création du fichier credentials (mode 600)
        # ----------------------------------------------------------

        local credentials_file="${tmp_dir}/credentials"

        printf '%s\n%s\n' "${git_username}" "${token}" > "${credentials_file}"
        chmod 600 "${credentials_file}"

        # Transférer la propriété à DEVOPS_USER si exécuté en root
        if [[ "$(id -u)" -eq 0 ]] && id "${DEVOPS_USER}" >/dev/null 2>&1; then
            chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${tmp_dir}" "${credentials_file}"
        fi

        # ----------------------------------------------------------
        # Création du script askpass.sh (mode 700, sans secret)
        # ----------------------------------------------------------

        local askpass_file="${tmp_dir}/askpass.sh"

        cat > "${askpass_file}" <<'ASKPASS_EOF'
#!/usr/bin/env bash
# Script ASKPASS temporaire — ne contient aucun secret.
# Lit le fichier credentials situé dans le même répertoire.

script_dir="$(cd "$(dirname "$0")" && pwd)"
credentials_file="${script_dir}/credentials"

prompt="${1:-}"

if [[ "${prompt}" == *"Username"* ]]; then
    IFS= read -r username < "${credentials_file}"
    printf '%s\n' "${username}"
elif [[ "${prompt}" == *"Password"* ]]; then
    {
        IFS= read -r _username
        IFS= read -r password
    } < "${credentials_file}"
    printf '%s\n' "${password}"
else
    exit 1
fi
ASKPASS_EOF

        chmod 700 "${askpass_file}"

        if [[ "$(id -u)" -eq 0 ]] && id "${DEVOPS_USER}" >/dev/null 2>&1; then
            chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${askpass_file}"
        fi

        # ----------------------------------------------------------
        # Exécution de la commande Git sous DEVOPS_USER
        # ----------------------------------------------------------

        local git_rc=0

        runuser -u "${DEVOPS_USER}" -- \
            env "LC_ALL=C" \
                "GIT_ASKPASS=${askpass_file}" \
                "GIT_TERMINAL_PROMPT=0" \
                "HOME=$(eval echo "~${DEVOPS_USER}")" \
            git -C "${project_path}" "${git_args[@]}" || git_rc=$?

        if [[ "${git_rc}" -ne 0 ]]; then
            print_error "git_with_token : commande Git échouée (code ${git_rc})."
        fi

        exit "${git_rc}"
    )

    return $?
}
