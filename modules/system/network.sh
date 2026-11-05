#!/usr/bin/env bash

system_network_hosts() {

  local hosts_ip="" hosts_config="/root/diu/config/hosts.json" hosts_entries=""
  local development_config="${BASH_SCRIPT_PATH}/config/hosts.json" config_file=""

  for config_file in "$development_config" "$hosts_config"; do
      if [[ ! -e "$config_file" && ! -L "$config_file" ]]; then
          mkdir -p -- "$(dirname -- "$config_file")" || return 1
          ( set -o noclobber; printf '[]\n' > "$config_file" ) || return 1
      fi
  done
  if ! hosts_entries="$(python3 -B "${BASH_SCRIPT_PATH}/modules/system/hosts_json.py" "$hosts_config")"; then
      return 1
  fi

  if [[ "${INTERFACE_ETHERNET1_STATE}" == "UP" ]] \
      && [[ "${INTERFACE_ETHERNET1_IP}" != "NONE" ]] \
      && [[ "${INTERFACE_ETHERNET1_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

      hosts_ip="${INTERFACE_ETHERNET1_IP}"

  elif [[ "${INTERFACE_ETHERNET2_STATE}" == "UP" ]] \
      && [[ "${INTERFACE_ETHERNET2_IP}" != "NONE" ]] \
      && [[ "${INTERFACE_ETHERNET2_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

      hosts_ip="${INTERFACE_ETHERNET2_IP}"
  fi

  cat > /etc/hosts <<EOF || return 1
127.0.0.1       localhost
EOF

  if [[ -n "${hosts_ip}" ]]; then
      printf '%s\t%s\t%s\n' \
          "${hosts_ip}" \
          "${HOSTNAME_FQDN}" \
          "${HOSTNAME}" >> /etc/hosts || return 1
  fi

  cat >> /etc/hosts <<'EOF' || return 1

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

  if [[ -n "$hosts_entries" ]]; then
      printf '\n%s\n' "$hosts_entries" >> /etc/hosts || return 1
  fi

}


system_network_hosts_report() {
    local diagnostic="" status=0 cause=""
    if diagnostic="$(system_network_hosts 2>&1)"; then
        printf '✅ /etc/hosts mis à jour.\n'
        return 0
    else
        status=$?
    fi
    case "$diagnostic" in
        *'Configuration hosts invalide'*) cause='configuration JSON invalide ou illisible' ;;
        *'python3'*) cause='validateur JSON indisponible' ;;
        *'unbound variable'*) cause='variable requise absente' ;;
        *'/config'*) cause='création du fichier de configuration impossible' ;;
        *) cause='écriture impossible' ;;
    esac
    printf '❌ /etc/hosts : %s.\n' "$cause" >&2
    return "$status"
}

system_network_update() {
    system_network_hosts
}

system_network_manage_hosts() {
    python3 -B "${BASH_SCRIPT_PATH}/modules/system/hosts_json.py" manage /root/diu/config/hosts.json "$@"
}
