#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_apache2() {
    local field="${1:-}"
    shift
    set -- apache2 "$@"
    local software=apache2 release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' apache2
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_APACHE2
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' remove
            ;;
        install_packages)
            case "${SYSTEM_DEBIAN_RELEASE:-}" in
                            bullseye) perl_package=perl-modules-5.32 ;;
                            bookworm) perl_package=perl-modules-5.36 ;;
                            trixie) perl_package=perl-modules-5.40 ;;
                            *) printf '%s\n' 'Version Debian non prise en charge pour Apache2.' >&2; return 1 ;;
                        esac
                        printf '%s\n' apache2 libapache2-mod-perl2 libapache2-mod-fcgid libapache-session-perl "$perl_package" \
                            libnet-ldap-perl libcache-cache-perl libdbi-perl libwww-perl libxml-simple-perl libsoap-lite-perl \
                            libhtml-template-perl libregexp-assemble-perl libregexp-common-perl libjs-jquery libxml-libxml-perl \
                            libcrypt-rijndael-perl libio-string-perl libxml-libxslt-perl libconfig-inifiles-perl libjson-perl \
                            libstring-random-perl libemail-date-format-perl libmime-lite-perl libcrypt-openssl-rsa-perl \
                            libdigest-hmac-perl libdigest-sha-perl libclone-perl libauthen-sasl-perl libnet-cidr-lite-perl \
                            libcrypt-openssl-x509-perl libauthcas-perl libtest-pod-perl libtest-mockobject-perl \
                            libauthen-captcha-perl libnet-openid-consumer-perl libnet-openid-server-perl libunicode-string-perl \
                            libconvert-pem-perl libmoose-perl libplack-perl libapache-session-browseable-perl libdbd-pg-perl libgssapi-perl
            ;;
        repository)
            printf '\n'
            ;;
        repository_variable)
            printf '\n'
            ;;
        repository_state_valid)
            return 1
            ;;
        repository_expected)
            printf '\n'
            ;;
        remove_repository)
            printf '0\n'
            ;;
        detector)
            printf '%s\n' software_apt_apache2_detect
            ;;
        artifact_url)
            printf '\n'
            ;;
        environment_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        sensitive_install)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '0\n'
            ;;
        pre_install_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        configuration_hook)
            printf '\n'
            ;;
        configuration_check)
            printf '\n'
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_convergence_package "${1:-}"
            ;;
        pre_remove_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" debian ;;
        *) return 2 ;;
    esac
}

software_apt_apache2_detect() { software_apt_package_state apache2; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "apache2" || return 1
fi
