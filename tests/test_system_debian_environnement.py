#!/usr/bin/env python3
"""Tests isolés : aucun accès au matériel ni à la configuration locale."""
import os
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
DECLARATION = ROOT / 'modules/diu/variables/system/system_debian_environnement.sh'


class SystemDebianEnvironnementTests(unittest.TestCase):
    def check_detection(self, expected, container='none', container_status=1,
                        vm='none', vm_status=1, package='', package_status=1,
                        missing='', prelude='', check=''):
        env = dict(os.environ, DECLARATION=str(DECLARATION), CONTAINER=container,
                   CONTAINER_STATUS=str(container_status), VM=vm,
                   VM_STATUS=str(vm_status), PACKAGE=package,
                   PACKAGE_STATUS=str(package_status), MISSING=missing)
        env.pop('SYSTEM_DEBIAN_ENVIRONNEMENT', None)
        code = r'''
set -Eeuo pipefail
systemd-detect-virt() {
    case "$1" in
        --container) printf '%s\n' "$CONTAINER"; return "$CONTAINER_STATUS" ;;
        --vm) printf '%s\n' "$VM"; return "$VM_STATUS" ;;
        *) return 99 ;;
    esac
}
dpkg-query() {
    [[ "$*" == '-W -f=${Status} pve-manager' ]] || return 99
    printf '%s' "$PACKAGE"
    return "$PACKAGE_STATUS"
}
command() {
    if [[ "$1" == -v && "$2" == "$MISSING" ]]; then return 1; fi
    builtin command "$@"
}
''' + prelude + r'''
source "$DECLARATION"
[[ "$config" == DYNAMIC && "$state" == ENABLE && "$scope" == system && "$default_value" == UNSET ]]
bash -c 'printf "%s\n" "$SYSTEM_DEBIAN_ENVIRONNEMENT"'
''' + check
        result = subprocess.run(['bash', '-c', code], env=env, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, expected + '\n')
        if expected == 'UNSET':
            self.assertIn('SYSTEM_DEBIAN_ENVIRONNEMENT', result.stderr)
        else:
            self.assertEqual(result.stderr, '')

    def test_containers_override_host(self):
        for container, expected in [('docker', 'DOCKER'), ('lxc', 'LXC'), ('lxc-libvirt', 'LXC')]:
            with self.subTest(container=container):
                self.check_detection(expected, container=container, container_status=0,
                                     vm='kvm', vm_status=0, package='install ok installed',
                                     package_status=0, missing='dpkg-query')

    def test_vms_override_proxmox(self):
        for vm in ('kvm', 'qemu', 'microsoft', 'vmware', 'xen', 'oracle', 'amazon',
                   'bochs', 'uml', 'zvm', 'parallels', 'bhyve', 'qnx', 'acrn',
                   'powervm', 'apple', 'sre', 'google'):
            with self.subTest(vm=vm):
                self.check_detection('VM', vm=vm, vm_status=0,
                                     package='install ok installed', package_status=0)

    def test_physical_and_proxmox(self):
        self.check_detection('PHYSICAL')
        for state in ('install ok installed', 'hold ok installed'):
            self.check_detection('PROXMOX', package=state, package_status=0)
        for state in ('deinstall ok config-files', 'unknown ok not-installed',
                      'install ok unpacked', 'install ok half-configured'):
            self.check_detection('PHYSICAL', package=state, package_status=0)

    def test_unknown_and_errors(self):
        cases = [dict(container=c, container_status=0) for c in ('podman', 'openvz', 'wsl', 'container-other', 'none', '')]
        cases += [dict(vm=v, vm_status=0) for v in ('vm-other', 'future-hypervisor', 'none', '')]
        cases += [dict(container_status=2), dict(container='', container_status=1),
                  dict(container='docker', container_status=1), dict(vm_status=2),
                  dict(vm='kvm', vm_status=1), dict(package_status=2),
                  dict(package='invalid', package_status=0),
                  dict(package='invalid', package_status=1),
                  dict(missing='systemd-detect-virt'), dict(missing='dpkg-query')]
        for case in cases:
            with self.subTest(case=case):
                self.check_detection('UNSET', **case)

    def test_no_persistence_and_repeat(self):
        self.check_detection('PHYSICAL', prelude=r'''
echo() { printf '%s\n' 'unexpected persistence' >&2; return 99; }
''', check=r'''
[[ "$variable_config_file" == /root/diu/config/system.env ]]
systemd-detect-virt() { printf '%s\n' 'unexpected call' >&2; return 99; }
source "$DECLARATION"
[[ "$SYSTEM_DEBIAN_ENVIRONNEMENT" == PHYSICAL ]]
''')

    def test_existing_value_is_preserved(self):
        for value in ('', 'VM', 'custom'):
            with self.subTest(value=value):
                self.check_detection(value, prelude='export SYSTEM_DEBIAN_ENVIRONNEMENT=' + repr(value) + '\n',
                                     missing='systemd-detect-virt')

    def test_loader_discovery_and_consumer_migration(self):
        self.assertIn(DECLARATION, (ROOT / 'modules/diu/variables').glob('*/*.sh'))
        source = (ROOT / 'root-install-debian.sh').read_text()
        self.assertNotRegex(source, r'\bDEBIAN_TYPE\b')
        self.assertIn('SYSTEM_DEBIAN_ENVIRONNEMENT', source)


if __name__ == '__main__':
    unittest.main()
