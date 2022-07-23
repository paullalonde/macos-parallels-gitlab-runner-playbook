#!/bin/bash

set -eu

SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="${SELF_DIR}/.."

function usage() {
  echo "usage: provision <options>"               1>&2
  echo "options:"                                 1>&2
  echo "  --force        Force a VM update."      1>&2
  echo "  --host <host>  The host to provision."  1>&2
  exit 20
}

HOST=''
FORCE_VM=false

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

    *)
    usage
  esac
done

if [[ -z "${HOST}" ]]; then
  usage
fi

if [[ -f "${BASE_DIR}/.env" ]]; then
  source "${BASE_DIR}/.env"
fi

cd "${BASE_DIR}/ansible"

TEMP_DIR=../.temp
mkdir -p "${TEMP_DIR}"

VAULT_PASSWORD_EXECUTOR_FILE="${TEMP_DIR}/.ansible-vault-pw-executor"
VAULT_PASSWORD_GITLAB_FILE="${TEMP_DIR}/.ansible-vault-pw-gitlab"
VAULT_PASSWORD_BOTTE_FILE="${TEMP_DIR}/.ansible-vault-pw-botte"
VAULT_PASSWORD_MASKIROVKA_FILE="${TEMP_DIR}/.ansible-vault-pw-maski"
trap "{ rm -f ${VAULT_PASSWORD_EXECUTOR_FILE} ${VAULT_PASSWORD_GITLAB_FILE} ${VAULT_PASSWORD_BOTTE_FILE} ${VAULT_PASSWORD_MASKIROVKA_FILE}; }" EXIT

case "${HOST}" in
  botte)
  echo "${VAULT_PASSWORD_BOTTE}" >"${VAULT_PASSWORD_BOTTE_FILE}"
  VAULT_PASSWORD_FILE="${VAULT_PASSWORD_BOTTE_FILE}"
  ;;

  maskirovka)
  echo "${VAULT_PASSWORD_MASKIROVKA}" >"${VAULT_PASSWORD_MASKIROVKA_FILE}"
  VAULT_PASSWORD_FILE="${VAULT_PASSWORD_MASKIROVKA_FILE}"
  ;;

  *)
  echo "Unsupported host '${HOST}'" 1>&2
  exit 10
esac

echo "${VAULT_PASSWORD_EXECUTOR}" >"${VAULT_PASSWORD_EXECUTOR_FILE}"
echo "${VAULT_PASSWORD_GITLAB}" >"${VAULT_PASSWORD_GITLAB_FILE}"

EXTRA_VARS=$(jq --null-input -c --argjson force "${FORCE_VM}" '{force_vm_update: $force}|tojson')

ansible-playbook \
  --vault-id "executor@${VAULT_PASSWORD_EXECUTOR_FILE}" \
  --vault-id "gitlab@${VAULT_PASSWORD_GITLAB_FILE}" \
  --vault-id "${HOST}@${VAULT_PASSWORD_FILE}" \
  --extra-vars "${EXTRA_VARS}" \
  --inventory=inventory.yaml \
  --limit "${HOST}" \
  playbook.yaml
