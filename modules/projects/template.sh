#!/usr/bin/env bash

projects_template_openspec() {
    local project_id="${1:-}"
    local projects_root="${DEVOPS_PROJECTS_ROOT:-/home/${ENV_DEVOPS_USER:-}/datas}"
    local project_path="${projects_root}/${project_id}"
    local openspec_command="" command=""

    if [[ "$#" -ne 1 || ! "${ENV_DEVOPS_USER:-}" =~ ^[a-z_][a-z0-9_-]*\$?$ ||
        -z "${project_id}" || "${project_id}" == */* || "${project_id}" == . ||
        "${project_id}" == .. || "${project_id}" =~ [[:cntrl:]] ]]; then
        print_error 'Usage : rid projects template openspec <ID PROJECT> (identifiant sans chemin et utilisateur DevOps valide).'
        return 1
    fi
    if [[ -L "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Le dossier du projet est absent ou symbolique : ${project_path}"
        return 1
    fi
    if [[ -L "${project_path}/openspec" ||
        ( -e "${project_path}/openspec" && ! -d "${project_path}/openspec" ) ]]; then
        print_error 'La cible openspec doit être un répertoire ordinaire.'
        return 1
    fi
    if ! id -u "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error "Utilisateur DevOps introuvable : ${ENV_DEVOPS_USER}."
        return 1
    fi

    if [[ -d "${project_path}/openspec" ]]; then
        openspec_command='openspec update'
    else
        case "${OPENCODE:-}" in
            1) openspec_command='openspec init --tools opencode --profile custom' ;;
            0) openspec_command='openspec init --profile custom' ;;
            *) print_error 'OPENCODE doit valoir 0 ou 1 pour initialiser OpenSpec.'; return 1 ;;
        esac
    fi

    # Un chemin absolu et des apostrophes échappées préservent le chemin dans le shell de connexion.
    if ! project_path="$(cd -- "${project_path}" && pwd -P)"; then
        print_error 'Impossible de résoudre le répertoire du projet.'
        return 1
    fi
    command="cd '${project_path//\'/\'\\\'\'}' && ${openspec_command}"
    if ! su - "${ENV_DEVOPS_USER}" -c "${command}"; then
        print_error "Initialisation ou mise à jour OpenSpec échouée : ${project_path}"
        return 1
    fi
    print_success "OpenSpec préparé : ${project_path}"
}

# Les outils hôte ne doivent pas être résolus dans le PATH DevOps.
projects_template_devops_host_binary() {
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin type -P -- "$1"
}

projects_template_devops_user_run() {
    local devops_home="$1"
    shift
    local user_path="${devops_home}/node/current/bin:${devops_home}/python/current/bin:${devops_home}/go/current/bin:/usr/local/bin:/usr/bin:/bin"

    if [[ "$(id -un)" == "${ENV_DEVOPS_USER}" ]]; then
        (
            cd -- "${devops_home}" || return 1
            PATH="${user_path}" GOTOOLCHAIN=local /usr/bin/timeout 15s "$@"
        )
    else
        # Expansion des arguments dans le shell enfant, après changement d'utilisateur.
        # shellcheck disable=SC2016
        runuser -u "${ENV_DEVOPS_USER}" -- env PATH="${user_path}" GOTOOLCHAIN=local \
            bash -c 'cd -- "$1" || exit 1; shift; exec /usr/bin/timeout 15s "$@"' \
            bash "${devops_home}" "$@"
    fi
}

projects_template_devops_version() {
    local context="$1" devops_home="$2" binary="$3"
    local output=""
    shift 3

    if [[ -z "${binary}" || ! -x "${binary}" ]]; then
        printf '%s\n' 'indisponible (binaire absent)'
        return 0
    fi

    if [[ "${context}" == node && ! -x "${devops_home}/node/current/bin/node" ]]; then
        printf '%s\n' 'indisponible (Node DevOps absent)'
        return 0
    fi
    if [[ "${context}" == python && ! -x "${devops_home}/python/current/bin/python3" ]]; then
        printf '%s\n' 'indisponible (Python DevOps absent)'
        return 0
    fi

    if [[ "${context}" == host ]]; then
        if ! output="$(/usr/bin/timeout 15s "${binary}" "$@" 2>/dev/null)"; then
            printf '%s\n' 'indisponible (sonde échouée)'
            return 0
        fi
    else
        case "${context}" in
            node)
                if ! output="$(projects_template_devops_user_run "${devops_home}" \
                    "${devops_home}/node/current/bin/node" "${binary}" "$@" 2>/dev/null)"; then
                    printf '%s\n' 'indisponible (sonde échouée)'
                    return 0
                fi
                ;;
            python)
                if ! output="$(projects_template_devops_user_run "${devops_home}" \
                    "${devops_home}/python/current/bin/python3" -I -B "${binary}" "$@" 2>/dev/null)"; then
                    printf '%s\n' 'indisponible (sonde échouée)'
                    return 0
                fi
                ;;
            *)
                if ! output="$(projects_template_devops_user_run "${devops_home}" "${binary}" "$@" 2>/dev/null)"; then
                    printf '%s\n' 'indisponible (sonde échouée)'
                    return 0
                fi
                ;;
        esac
    fi

    if [[ "${output}" =~ [0-9]+(\.[0-9]+){1,3}[[:alnum:].+-]* ]]; then
        printf '%s\n' "${BASH_REMATCH[0]}"
    else
        printf '%s\n' 'indisponible (version non reconnue)'
    fi
}

projects_template_devops_section() {
    local title="$1" version="$2" binary="$3"
    printf '# %s\n\n  * %s\n  * %s\n\n\n' \
        "${title}" "${version}" "${binary:-binaire introuvable}"
}

projects_template_devops_postgresql() {
    local project_env="$1" psql_binary="$2"
    if [[ ! -x /usr/bin/python3 ]]; then
        printf '  * indisponible (Python système absent pour la lecture de configuration)\n  * adresse non vérifiée\n'
        return 0
    fi

    # Le parseur ne restitue jamais les identifiants, les valeurs du fichier ou
    # les erreurs brutes de psql, et ne peut pas exécuter une expression shell.
    /usr/bin/python3 -I -B - "${project_env}" "${psql_binary}" <<'PY'
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys

config_path, psql = sys.argv[1:]
keys = {'PG_HOST', 'PG_SERVER', 'PG_PORT', 'PG_DATABASE', 'PG_USERNAME',
        'PG_USER', 'PG_PASSWORD', 'PG_SSLMODE'}
values = {}
version = 'indisponible (configuration absente ou invalide)'
address = 'adresse non configurée'
diagnostic = 'fichier project.env absent ou illisible'
try:
    lines = Path(config_path).read_text(encoding='utf-8').splitlines()
    for line in lines:
        match = re.match(r'^\s*(?:export\s+)?([A-Z_]+)\s*=\s*(.*)$', line)
        if not match or match[1] not in keys:
            continue
        literal = match[2].strip()
        diagnostic = f'affectation non littérale pour {match[1]}'
        # shlex retire les guillemets sans développer variables ou commandes.
        # Les caractères spéciaux d'un mot de passe restent donc littéraux.
        parsed = shlex.split(literal, comments=True)
        if len(parsed) > 1:
            raise ValueError('affectation non littérale')
        values[match[1]] = parsed[0] if parsed else ''
    host = values.get('PG_HOST') or values.get('PG_SERVER', '')
    port = values.get('PG_PORT', '')
    if not values.get('PG_HOST') and host.count(':') == 1:
        host, server_port = host.split(':')
        port = port or server_port
    port = port or '5432'
    diagnostic = 'PG_HOST ou PG_SERVER absent' if not host else 'adresse invalide'
    if not re.fullmatch(r'[A-Za-z0-9_./:-]+', host):
        raise ValueError('adresse invalide')
    diagnostic = 'PG_PORT invalide'
    if not port.isascii() or not port.isdigit() or not 0 < int(port) < 65536:
        raise ValueError('port invalide')
    address = f'[{host}]:{port}' if ':' in host else f'{host}:{port}'
    version = 'indisponible (client PostgreSQL absent)'
    if psql and os.access(psql, os.X_OK):
        # Éviter tout paramètre PostgreSQL hérité du shell appelant.
        environment = {key: value for key, value in os.environ.items() if not key.startswith('PG')}
        environment.update(PGHOST=host, PGPORT=port,
                           PGDATABASE=values.get('PG_DATABASE', 'postgres'),
                           PGUSER=values.get('PG_USERNAME') or values.get('PG_USER', ''),
                           PGPASSWORD=values.get('PG_PASSWORD', ''),
                           PGCONNECT_TIMEOUT='5', PGOPTIONS='-c statement_timeout=5000')
        sslmode = values.get('PG_SSLMODE', 'prefer')
        if sslmode not in {'disable', 'allow', 'prefer', 'require', 'verify-ca', 'verify-full'}:
            raise ValueError('sslmode invalide')
        environment['PGSSLMODE'] = sslmode
        result = subprocess.run([psql, '-X', '-w', '-A', '-t', '-q', '-c', 'SHOW server_version;'],
                                env=environment, capture_output=True, text=True, timeout=10, check=False)
        observed = re.match(r'^\s*([0-9]+(?:\.[0-9]+){0,2})(?:\s|$)', result.stdout)
        version = observed[1] if result.returncode == 0 and observed else 'indisponible (serveur inaccessible ou version non vérifiable)'
except (OSError, ValueError, UnicodeError, subprocess.TimeoutExpired):
    if address != 'adresse non configurée':
        version = 'indisponible (connexion ou configuration non vérifiable)'
    else:
        version = f'indisponible (configuration absente ou invalide : {diagnostic})'
print(f'  * {version}\n  * {address}')
PY
}

projects_template_devops_python_manifest() {
    local devops_home="$1" project_path="$2" project_id="$3"
    if [[ -e "${project_path}/pyproject.toml" || -L "${project_path}/pyproject.toml" ]]; then
        return 0
    fi
    if [[ ! -x /usr/bin/python3 ]]; then
        print_error 'Impossible de vérifier PROJECT_TYPE : Python système absent.'
        return 1
    fi

    projects_template_devops_user_run "${devops_home}" /usr/bin/python3 -I -B - \
        "${project_path}" "${project_id}" <<'PY'
from pathlib import Path
import re
import shlex
import sys

project_path = Path(sys.argv[1])
try:
    lines = (project_path / 'project.env').read_text(encoding='utf-8').splitlines()
except FileNotFoundError:
    sys.exit(0)
except (OSError, UnicodeError):
    print('Impossible de lire PROJECT_TYPE dans project.env.', file=sys.stderr)
    sys.exit(1)
project_type = ''
try:
    for line in lines:
        match = re.match(r'^\s*(?:export\s+)?PROJECT_TYPE\s*=\s*(.*)$', line)
        if match:
            values = shlex.split(match[1], comments=True)
            if len(values) > 1:
                raise ValueError('affectation non littérale')
            project_type = values[0] if values else ''
except ValueError:
    print('PROJECT_TYPE doit être une affectation littérale.', file=sys.stderr)
    sys.exit(1)
if project_type == 'PYTHON':
    name = re.sub(r'[^A-Za-z0-9._-]', '-', sys.argv[2]).strip('._-') or 'project'
    try:
        # Création exclusive : un manifeste apparu entre-temps reste conservé.
        with (project_path / 'pyproject.toml').open('x', encoding='utf-8', newline='\n') as stream:
            stream.write(f'[project]\nname = "{name}"\nversion = "0.0.0"\ndependencies = []\n')
    except FileExistsError:
        pass
    except OSError:
        print('Impossible de créer pyproject.toml pour le projet Python.', file=sys.stderr)
        sys.exit(1)
PY
}

projects_template_devops_dependencies() {
    local devops_home="$1" template_path="$2" python_binary="$3"
    if [[ ! -f "${template_path}/pyproject.toml" ]]; then
        printf '  * pyproject.toml absent : dépendances non déclarées dans le projet\n'
        return 0
    fi
    if [[ ! -x "${python_binary}" ]]; then
        printf '  * Versions non vérifiables : Python DevOps absent\n'
        return 0
    fi

    projects_template_devops_user_run "${devops_home}" "${python_binary}" -I -B - \
        "${template_path}/pyproject.toml" "${python_binary}" <<'PY'
from importlib import metadata
from pathlib import Path
import re
import sys

try:
    import tomllib
except ImportError:
    print('  * Lecture non disponible : module tomllib absent du Python DevOps')
    sys.exit(0)
try:
    project = tomllib.loads(Path(sys.argv[1]).read_text(encoding='utf-8')).get('project', {})
    dependencies = project.get('dependencies', [])
    if not isinstance(dependencies, list) or not all(isinstance(item, str) for item in dependencies):
        raise ValueError('dépendances invalides')
    if 'dependencies' in project.get('dynamic', []):
        print('  * Dépendances dynamiques : versions non vérifiables depuis pyproject.toml')
    elif not dependencies:
        print('  * Aucune dépendance déclarée dans [project].dependencies')
    for dependency in dependencies:
        match = re.match(r'^([A-Za-z0-9][A-Za-z0-9._-]*)', dependency)
        if not match or '\n' in dependency or '\r' in dependency:
            raise ValueError('dépendance invalide')
        # Les références directes peuvent contenir des identifiants : ne pas
        # les publier, seules les contraintes de version ordinaires sont rendues.
        constraint = dependency[match.end():].strip()
        if '@' in constraint:
            constraint = '(référence directe déclarée dans pyproject.toml)'
        try:
            version = metadata.version(match[1])
        except metadata.PackageNotFoundError:
            version = 'non installé'
        print(f'  * {match[1]} {constraint} : {version} --> {sys.argv[2]}'.replace('  :', ' :'))
except (OSError, ValueError, UnicodeError, tomllib.TOMLDecodeError):
    print('  * pyproject.toml illisible ou invalide : dépendances non vérifiables')
PY
}

projects_template_devops_render() {
    local devops_home="$1" template_path="$2"
    local project_title="${3:-${template_path##*/}}"
    local name="" binary="" version="" context="" operating_system=""
    local psql_binary="" compose_binary="" python_binary="${devops_home}/python/current/bin/python3"
    local venv_status='indisponible'
    local -a version_arguments=()

    if [[ -r /etc/os-release ]]; then
        operating_system="$(
            # shellcheck source=/dev/null
            . /etc/os-release
            printf '%s' "${PRETTY_NAME:-système non identifié}"
        )" || return 1
    else
        operating_system='indisponible (/etc/os-release absent)'
    fi
    if [[ "${project_title}" == template ]]; then
        project_title=Template
    fi
    printf '# DEVOPS.md — %s\n\nVersion : 0.2\n\n\n# Système d\047exploitation\n\n  * %s\n\n\n' "${project_title}" "${operating_system}" || return 1

    for name in Docker Docker-Compose Git Go Node NPM OpenCode OpenSpec OpenSSL 'PostgreSQL Client'; do
        context=host
        version_arguments=(--version)
        case "${name}" in
            Docker) binary="$(projects_template_devops_host_binary docker)" || binary='' ;;
            Docker-Compose)
                binary="$(projects_template_devops_host_binary docker-compose)" || binary=''
                if [[ -z "${binary}" ]]; then
                    for compose_binary in \
                        /usr/local/lib/docker/cli-plugins/docker-compose \
                        /usr/local/libexec/docker/cli-plugins/docker-compose \
                        /usr/lib/docker/cli-plugins/docker-compose \
                        /usr/libexec/docker/cli-plugins/docker-compose; do
                        if [[ -x "${compose_binary}" ]]; then
                            binary="${compose_binary}"
                            break
                        fi
                    done
                fi
                ;;
            Git) binary="$(projects_template_devops_host_binary git)" || binary='' ;;
            Go) context=user; binary="${devops_home}/go/current/bin/go"; version_arguments=(version) ;;
            Node) context=user; binary="${devops_home}/node/current/bin/node" ;;
            NPM) context=node; binary="${devops_home}/node/current/bin/npm" ;;
            OpenCode) context=user; binary="${devops_home}/.opencode/bin/opencode" ;;
            OpenSpec) context=node; binary="${devops_home}/.local/npm/bin/openspec" ;;
            OpenSSL) binary="$(projects_template_devops_host_binary openssl)" || binary=''; version_arguments=(version) ;;
            'PostgreSQL Client') binary="$(projects_template_devops_host_binary psql)" || binary=''; psql_binary="${binary}" ;;
        esac
        version="$(projects_template_devops_version "${context}" "${devops_home}" "${binary}" "${version_arguments[@]}")" || return 1
        projects_template_devops_section "${name}" "${version}" "${binary}" || return 1
    done

    printf '# PostgreSQL Serveur\n\n' || return 1
    projects_template_devops_postgresql "${template_path}/project.env" "${psql_binary}" || return 1
    printf '  * Les variables PostgreSQL sont chargées depuis project.env\n  * PG_HOST PG_PORT PG_DATABASE PG_USERNAME PG_PASSWORD\n\n\n' || return 1

    version="$(projects_template_devops_version user "${devops_home}" "${python_binary}" --version)" || return 1
    if [[ -x "${python_binary}" ]] && projects_template_devops_user_run \
        "${devops_home}" "${python_binary}" -I -B -c 'import venv, ensurepip; ensurepip.version()' >/dev/null 2>&1; then
        venv_status=disponible
    fi
    printf '# Python\n\n  * %s\n  * %s\n  * venv: %s\n\n\n' "${version}" "${python_binary}" "${venv_status}" || return 1
    # Les accents graves font partie du titre Markdown, sans expansion shell.
    # shellcheck disable=SC2016
    printf '# Python - Dépendances du projet - Source de vérité `pyproject.toml`\n\n' || return 1
    if ! projects_template_devops_dependencies "${devops_home}" "${template_path}" "${python_binary}" 2>/dev/null; then
        printf '  * Versions des dépendances non vérifiables : sonde Python échouée\n' || return 1
    fi
    printf '\n\n' || return 1
    binary="${devops_home}/python/current/bin/pip3"
    version="$(projects_template_devops_version python "${devops_home}" "${binary}" --version)" || return 1
    projects_template_devops_section 'Python - Gestionnaire de paquets' "${version}" "${binary}"
}

projects_template_devops() {
    local devops_home="/home/${ENV_DEVOPS_USER:-}"
    local project_id="${1:-}"
    local projects_root="${DEVOPS_PROJECTS_ROOT:-${devops_home}/datas}"
    local template_path="${projects_root}/${project_id}"
    local document="${template_path}/DEVOPS.md" temporary_document="" content=""
    local devops_group=""

    if [[ "$#" -ne 1 || ! "${ENV_DEVOPS_USER:-}" =~ ^[a-z_][a-z0-9_-]*\$?$ ||
        -z "${project_id}" || "${project_id}" == */* || "${project_id}" == . ||
        "${project_id}" == .. || "${project_id}" =~ [[:cntrl:]] ]]; then
        print_error 'Usage : rid projects template <ID PROJECT> devops (identifiant sans chemin et utilisateur DevOps valide).'
        return 1
    fi
    if [[ -L "${template_path}" ]]; then
        print_error 'Le dossier du projet doit être un chemin ordinaire.'
        return 1
    fi
    if [[ ! -d "${template_path}" ]]; then
        print_info "Dossier du projet absent : ${template_path}. Aucune action effectuée."
        return 0
    fi
    if [[ -L "${template_path}" || -L "${document}" || ( -e "${document}" && ! -f "${document}" ) ]]; then
        print_error 'Le projet et son fichier DEVOPS.md doivent être des chemins ordinaires.'
        return 1
    fi
    if ! id -u "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error "Utilisateur DevOps introuvable : ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ "${EUID}" -ne 0 && "$(id -un)" != "${ENV_DEVOPS_USER}" ]]; then
        print_error "Exécuter cette génération en root ou sous ${ENV_DEVOPS_USER}."
        return 1
    fi
    if ! projects_template_devops_python_manifest "${devops_home}" "${template_path}" "${project_id}"; then
        print_error 'Impossible de préparer le manifeste Python ; DEVOPS.md est conservé.'
        return 1
    fi
    if ! content="$(projects_template_devops_render "${devops_home}" "${template_path}" "${project_id}")"; then
        print_error 'Impossible de préparer DEVOPS.md ; le document existant est conservé.'
        return 1
    fi
    if ! temporary_document="$(mktemp "${template_path}/.DEVOPS.md.XXXXXX")"; then
        print_error 'Impossible de créer le fichier temporaire DEVOPS.md.'
        return 1
    fi
    if ! printf '%s\n' "${content}" > "${temporary_document}"; then
        if ! rm -f -- "${temporary_document}"; then
            print_error 'Impossible de supprimer le document temporaire.'
        fi
        print_error "Impossible d'écrire DEVOPS.md ; le document existant est conservé."
        return 1
    fi
    if [[ -f "${document}" ]]; then
        if ! chmod --reference="${document}" "${temporary_document}" ||
            ! chown --reference="${document}" "${temporary_document}"; then
            if ! rm -f -- "${temporary_document}"; then
                print_error 'Impossible de supprimer le document temporaire.'
            fi
            print_error 'Impossible de conserver les droits de DEVOPS.md.'
            return 1
        fi
    else
        if ! devops_group="$(id -gn "${ENV_DEVOPS_USER}")" ||
            ! chmod 644 "${temporary_document}" ||
            ! chown "${ENV_DEVOPS_USER}:${devops_group}" "${temporary_document}"; then
            if ! rm -f -- "${temporary_document}"; then
                print_error 'Impossible de supprimer le document temporaire.'
            fi
            print_error 'Impossible de définir les droits de DEVOPS.md.'
            return 1
        fi
    fi
    if ! mv -f -- "${temporary_document}" "${document}"; then
        if ! rm -f -- "${temporary_document}"; then
            print_error 'Impossible de supprimer le document temporaire.'
        fi
        print_error 'Impossible de remplacer DEVOPS.md ; le document existant est conservé.'
        return 1
    fi
    print_success "DEVOPS.md généré ou actualisé : ${document}. Les versions indisponibles sont indiquées dans le document."
}

projects_template_devops_project_is_configured() {
    local project_env="$1" project_id="$2"

    /usr/bin/timeout 15s /usr/bin/python3 -I -B - "${project_env}" "${project_id}" <<'PY'
from pathlib import Path
import re
import shlex
import sys

required = {'PROJECT_ID', 'PROJECT_NAME', 'PROJECT_TYPE',
            'PROJECT_DOCKERED', 'PROJECT_DEBIAN_PACKAGE'}
values = {}
try:
    for line in Path(sys.argv[1]).read_text(encoding='utf-8').splitlines():
        match = re.match(r'^\s*(?:export\s+)?([A-Z_]+)\s*=\s*(.*)$', line)
        if not match or match[1] not in required:
            continue
        parsed = shlex.split(match[2], comments=True)
        if len(parsed) > 1:
            raise ValueError('affectation non littérale')
        values[match[1]] = parsed[0] if parsed else ''
except (OSError, ValueError, UnicodeError):
    sys.exit(1)
valid = all(values.get(key, '').strip() for key in required)
sys.exit(0 if valid and values['PROJECT_ID'] == sys.argv[2] else 1)
PY
}

projects_template_devops_all() {
    local devops_home="/home/${ENV_DEVOPS_USER:-}"
    local projects_root="${DEVOPS_PROJECTS_ROOT:-${devops_home}/datas}"
    local project_path="" project_id=""
    local selected=0 succeeded=0 ignored=0 failed=0

    if [[ "$#" -ne 0 || ! "${ENV_DEVOPS_USER:-}" =~ ^[a-z_][a-z0-9_-]*\$?$ ]]; then
        print_error 'Usage : rid projects template all devops (utilisateur DevOps valide).'
        return 1
    fi
    if ! id -u "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error "Utilisateur DevOps introuvable : ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ "${EUID}" -ne 0 && "$(id -un)" != "${ENV_DEVOPS_USER}" ]]; then
        print_error "Exécuter cette génération en root ou sous ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ ! -d "${projects_root}" ]]; then
        print_error "Répertoire des projets introuvable : ${projects_root}"
        return 1
    fi
    if [[ ! -x /usr/bin/python3 ]]; then
        print_error 'Impossible de sélectionner les projets : Python système absent.'
        return 1
    fi

    # Les trois motifs disjoints incluent les dossiers cachés sans modifier
    # les options de glob du shell appelant ni suivre les liens symboliques.
    for project_path in "${projects_root}"/* "${projects_root}"/.[!.]* "${projects_root}"/..?*; do
        if [[ ! -d "${project_path}" && ! -L "${project_path}" ]]; then
            continue
        fi
        project_id="${project_path##*/}"
        if [[ "${project_id}" =~ [[:cntrl:]] ]]; then
            ignored=$((ignored + 1))
            print_info 'Projet ignoré : identifiant invalide.'
            continue
        fi
        if [[ -L "${project_path}" || -L "${project_path}/project.env" ||
            ! -f "${project_path}/project.env" ]] ||
            ! projects_template_devops_project_is_configured "${project_path}/project.env" "${project_id}"; then
            ignored=$((ignored + 1))
            print_info "Projet ignoré : ${project_id} (chemin symbolique ou configuration absente, incomplète, illisible ou invalide)."
            continue
        fi

        selected=$((selected + 1))
        if projects_template_devops "${project_id}"; then
            succeeded=$((succeeded + 1))
        else
            failed=$((failed + 1))
            print_error "Génération DevOps échouée pour le projet : ${project_id}."
        fi
    done

    if [[ "${selected}" -eq 0 ]]; then
        print_info "Aucun projet éligible à la génération DevOps dans ${projects_root}."
    fi
    print_info "Bilan DevOps : ${selected} sélectionné(s), ${succeeded} réussi(s), ${ignored} ignoré(s), ${failed} échoué(s)."
    if [[ "${failed}" -gt 0 ]]; then
        return 1
    fi
    return 0
}
