#!/usr/bin/env bash

system_network_hosts() {

  local hosts_ip="" hosts_config="${BASH_SCRIPT_PATH}/config/hosts.json" hosts_entries=""

  if [[ ! -e "$hosts_config" && ! -L "$hosts_config" ]]; then
      mkdir -p -- "${BASH_SCRIPT_PATH}/config" || return 1
      ( set -o noclobber; printf '[]\n' > "$hosts_config" ) || return 1
  fi
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

system_network_update() {
    system_network_hosts
}
