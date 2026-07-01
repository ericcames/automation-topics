#!/usr/bin/env bash
# aap-versions.sh — report containerized AAP components and their versions.
#
# For containerized Ansible Automation Platform (e.g. AAP 2.7 on RHEL), the
# component images are typically tagged ":latest", so the tag tells you nothing.
# This script reads the true version-release from each image's OCI labels and
# also pulls the running-app version from inside each container.
#
# Run as the AAP install user (the rootless account that owns the containers).
# Root's Podman will not see them; use `sudo -iu <install_user>` if needed.

set -uo pipefail

printf '\n=== AAP Platform ===\n'
# Major version comes from the image namespace (…-platform-27 = 2.7)
ns=$(podman images --format '{{.Repository}}' \
       | grep -oE 'ansible-automation-platform-[0-9]+' | head -1)
echo "Namespace: ${ns:-unknown}  ->  ${ns:+AAP ${ns##*-}}" | sed 's/-2\([0-9]\)/ 2.\1/'

printf '\n=== Component images (build version-release from labels) ===\n'
printf '%-72s %s\n' "IMAGE" "VERSION-RELEASE"
podman images --format '{{.Repository}}:{{.Tag}}' \
  | grep -E 'ansible-automation-platform-[0-9]+|postgresql|redis' \
  | sort -u \
  | while read -r img; do
      ver=$(podman inspect "$img" \
              --format '{{index .Labels "version"}}-{{index .Labels "release"}}' 2>/dev/null)
      printf '%-72s %s\n' "$img" "${ver:--}"
    done

printf '\n=== Running services (app version from inside containers) ===\n'
# Map a discovered container name (by keyword) to its version command.
report() {  # $1=keyword  $2...=command
  local kw=$1; shift
  local c
  c=$(podman ps --format '{{.Names}}' | grep -m1 -i "$kw") || return 0
  printf '%-28s ' "$c"
  podman exec "$c" "$@" 2>/dev/null | head -1 || echo "(n/a)"
}
report controller     awx-manage version
report gateway        gateway-manage --version
report hub            pulpcore-manager --version
report eda            aap-eda-manage --version
report receptor       receptor --version

printf '\n=== Supporting services ===\n'
report postgres  postgres --version
report redis     redis-server --version

printf '\n'
