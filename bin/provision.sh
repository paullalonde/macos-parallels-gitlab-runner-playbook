#!/bin/bash

set -eu

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

case "${HOST}" in
  botte)
  ANSIBLE_HOST=botte
  HOST_SERVICE=botte.local-ansible-vault-password
  ;;

  *)
  echo "Unsupported host '${HOST}'" 1>&2
  exit 10
esac

SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="${SELF_DIR}/.."

TEMP_DIR="${BASE_DIR}/.temp"
mkdir -p "${TEMP_DIR}"

pushd "${BASE_DIR}" >/dev/null

# PIP_VERSION=22.0.4
#
# echo "Setting up virtualenv, if necessary ..."
#
# if [[ -z "`which virtualenv`" ]]; then
#   echo "virtualenv is not installed. Please install it and try again." 1>&2
#   exit 1
# fi
#
# NEED_PIP_INSTALL=''
#
# if [[ ! -d venv ]]; then
#   echo "Initializing virtualenv environment ..."
#   virtualenv venv
#   NEED_PIP_INSTALL=1
# fi
#
# OLD_VIRTUAL_ENV="${VIRTUAL_ENV:-}"
#
# if [ -n "${OLD_VIRTUAL_ENV}" -a "${OLD_VIRTUAL_ENV}" != "${PWD}/venv" ]; then
#   echo "The active virtualenv environment (${OLD_VIRTUAL_ENV}) does not match the current project; please run \"source venv/bin/activate\"." 1>&2
#   exit 11
# fi
#
# if [ -z "${OLD_VIRTUAL_ENV}" -o "${OLD_VIRTUAL_ENV}" != "${PWD}/venv" ]; then
#   . venv/bin/activate
# fi
#
# if [[ -n "${NEED_PIP_INSTALL}" ]]; then
#   pip3 install --upgrade -r "${BASE_DIR}/requirements.txt"
# fi



ANSIBLE_DIR="${BASE_DIR}/ansible"

# ANSIBLE_BOOTSTRAP_HOST_DIR="${ANSIBLE_DIR}/files/hosts/${HOST}"
# ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_CIPHERTEXT="${ANSIBLE_BOOTSTRAP_HOST_DIR}/ansible-ssh-key"
# ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT="${ANSIBLE_BOOTSTRAP_HOST_DIR}/.ansible-ssh-key"
#
# ANSIBLE_RUNNER_HOST_DIR="${ANSIBLE_DIR}/files/runner-playbook/files/hosts/${HOST}"
# ANSIBLE_RUNNER_SSH_PRIVATE_KEY_CIPHERTEXT="${ANSIBLE_BOOTSTRAP_HOST_DIR}/runner-ssh-key"
# ANSIBLE_RUNNER_SSH_PRIVATE_KEY_PLAINTEXT="${ANSIBLE_RUNNER_HOST_DIR}/.runner-ssh-key"

VAULT_PASSWORD_PATH="${TEMP_DIR}/.ansible-vault-pw"

# trap "{ rm -f ${VAULT_PASSWORD_PATH} ${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT} ${ANSIBLE_RUNNER_SSH_PRIVATE_KEY_PLAINTEXT}; }" EXIT

echo "Decrypting secrets ..."

rm -f "${VAULT_PASSWORD_PATH}"
touch "${VAULT_PASSWORD_PATH}"
chmod 600 "${VAULT_PASSWORD_PATH}"
security find-generic-password -s "${HOST_SERVICE}" -g 2>&1 >/dev/null \
  | sed 's/^password: "\([^"]*\)"/\1/' \
    >>"${VAULT_PASSWORD_PATH}"

# rm -f "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}"
# touch "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}"
# chmod 600 "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}"
# ansible-vault decrypt "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_CIPHERTEXT}" \
#   --vault-password-file="${VAULT_PASSWORD_PATH}" \
#   --output "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}"
#
# rm -f "${ANSIBLE_RUNNER_SSH_PRIVATE_KEY_PLAINTEXT}"
# touch "${ANSIBLE_RUNNER_SSH_PRIVATE_KEY_PLAINTEXT}"
# chmod 600 "${ANSIBLE_RUNNER_SSH_PRIVATE_KEY_PLAINTEXT}"
# ansible-vault decrypt "${ANSIBLE_RUNNER_SSH_PRIVATE_KEY_CIPHERTEXT}" \
#   --vault-password-file="${VAULT_PASSWORD_PATH}" \
#   --output "${ANSIBLE_RUNNER_SSH_PRIVATE_KEY_PLAINTEXT}"
#
# echo "Installing developer tools ..."
#
# set -x
#
# ANSIBLE_USER=$(yq read "${ANSIBLE_DIR}/group_vars/all.yaml" ansible_user)
# TOOLS_URL=$(yq read "${ANSIBLE_DIR}/group_vars/botte.yaml" command_line_tools_url)
#
# scp -i "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}" "${BASE_DIR}/scripts/install-tools.sh" "${ANSIBLE_USER}@${HOST}:/tmp"
# ssh -i "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}" "${ANSIBLE_USER}@${HOST}" "TOOLS_URL=${TOOLS_URL} /tmp/install-tools.sh"
# ssh -i "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}" "${ANSIBLE_USER}@${HOST}" "rm /tmp/install-tools.sh"
#
# echo "Installing developer tools ..."
#
# XCODE_VERSION=$(yq read "${ANSIBLE_DIR}/group_vars/botte.yaml" xcode_version)
# XCODE_URL=$(yq read "${ANSIBLE_DIR}/group_vars/botte.yaml" xcode_url)
#
# scp -i "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}" "${BASE_DIR}/scripts/install-xcode.sh" "${ANSIBLE_USER}@${HOST}:/tmp"
# ssh -i "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}" "${ANSIBLE_USER}@${HOST}" "XCODE_VERSION=${XCODE_VERSION} XCODE_URL=${XCODE_URL} /tmp/install-xcode.sh"
# ssh -i "${ANSIBLE_BOOTSTRAP_SSH_PRIVATE_KEY_PLAINTEXT}" "${ANSIBLE_USER}@${HOST}" "rm /tmp/install-xcode.sh"
#
# exit 44
#
pushd "${ANSIBLE_DIR}" >/dev/null

ansible-playbook \
  --vault-password-file="${VAULT_PASSWORD_PATH}" \
  --inventory=inventory.yaml \
  --limit "${HOST}" \
  playbook.yaml
  # --extra-vars=@"${ANSIBLE_BOOTSTRAP_ARGS}" \

popd >/dev/null

popd >/dev/null # ${BASE_DIR}
