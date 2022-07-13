#!/bin/bash

set -eu

SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="${SELF_DIR}/.."

function usage() {
  echo "usage: provision <options>"               1>&2
  echo "options:"                                 1>&2
  echo "  --host <host>  The host to provision."  1>&2
  exit 20
}

HOST=''

while [[ $# -gt 0 ]]
do
  case "$1" in
    --host)
    HOST="$2"
    shift
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

pushd "${BASE_DIR}" >/dev/null

TEMP_DIR=.temp
mkdir -p "${TEMP_DIR}"

VAULT_PASSWORD_GITLAB_PATH="${TEMP_DIR}/.ansible-vault-pw-gitlab"
VAULT_PASSWORD_BOTTE_FILE="${TEMP_DIR}/.ansible-vault-pw-botte"
VAULT_PASSWORD_MASKIROVKA_FILE="${TEMP_DIR}/.ansible-vault-pw-maski"
# trap "{ rm -f ${VAULT_PASSWORD_GITLAB_FILE} ${VAULT_PASSWORD_BOTTE_FILE} ${VAULT_PASSWORD_MASKIROVKA_FILE}; }" EXIT

case "${HOST}" in
  botte)
  VAULT_PASSWORD_PATH="${VAULT_PASSWORD_BOTTE_FILE}"
  VAULT_PASSWORD="${VAULT_PASSWORD_BOTTE}"
  ;;

  maskirovka)
  VAULT_PASSWORD_PATH="${VAULT_PASSWORD_MASKIROVKA_FILE}"
  VAULT_PASSWORD="${VAULT_PASSWORD_MASKIROVKA}"
  ;;

  *)
  echo "Unsupported host '${HOST}'" 1>&2
  exit 10
esac

echo "${VAULT_PASSWORD}" >"${VAULT_PASSWORD_PATH}"
echo "${VAULT_PASSWORD_GITLAB}" >"${VAULT_PASSWORD_GITLAB_PATH}"

ansible-playbook \
  --vault-id "gitlab@${VAULT_PASSWORD_GITLAB_PATH}" \
  --vault-id "${HOST}@${VAULT_PASSWORD_PATH}" \
  --inventory=ansible/inventory.yaml \
  --limit "${HOST}" \
  ansible/playbook.yaml

popd >/dev/null
