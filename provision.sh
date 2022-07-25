#!/bin/bash

set -eu

SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function usage() {
  echo "usage: provision <options>"                         1>&2
  echo "options:"                                           1>&2
  echo "  --force        Force a VM update."                1>&2
  echo "  --host <host>  Required. The host to provision."  1>&2
  echo "  --uninstall    Uninstall the runner."             1>&2
  exit 20
}

HOST=''
FORCE_VM=false
UNINSTALL=false

while [[ $# -gt 0 ]]
do
  case "$1" in
    --host)
    HOST="$2"
    shift
    shift
    ;;

    --force)
    FORCE_VM=true
    shift
    ;;

    --uninstall)
    UNINSTALL=true
    shift
    ;;

    *)
    usage
  esac
done

if [[ -z "${HOST}" ]]; then
  usage
fi

if [[ -f "${SELF_DIR}/.env" ]]; then
  source "${SELF_DIR}/.env"
fi

cd "${SELF_DIR}/ansible"

TEMP_DIR=../.temp
mkdir -p "${TEMP_DIR}"

VAULT_PASSWORD_BOTTE_FILE="${TEMP_DIR}/.ansible-vault-pw-botte"
VAULT_PASSWORD_GITLAB_FILE="${TEMP_DIR}/.ansible-vault-pw-gitlab"
VAULT_PASSWORD_MASKIROVKA_FILE="${TEMP_DIR}/.ansible-vault-pw-maskirovka"
trap "{ rm -f ${VAULT_PASSWORD_BOTTE_FILE} ${VAULT_PASSWORD_GITLAB_FILE} ${VAULT_PASSWORD_MASKIROVKA_FILE}; }" EXIT

# Note that Ansible locates the password files via a directive in ansible.cfg
echo "${VAULT_PASSWORD_BOTTE}" >"${VAULT_PASSWORD_BOTTE_FILE}"
echo "${VAULT_PASSWORD_GITLAB}" >"${VAULT_PASSWORD_GITLAB_FILE}"
echo "${VAULT_PASSWORD_MASKIROVKA}" >"${VAULT_PASSWORD_MASKIROVKA_FILE}"

EXTRA_VARS_JSON="${TEMP_DIR}/extra-vars.json"
jq --null-input \
  --argjson force "${FORCE_VM}" \
  --argjson uninstall "${UNINSTALL}" \
  '{force_vm_update: $force, uninstall_runner: $uninstall}' \
  >"${EXTRA_VARS_JSON}"

ansible-playbook \
  --extra-vars "@${EXTRA_VARS_JSON}" \
  --inventory=inventory.yaml \
  --limit "${HOST}" \
  playbook.yaml
