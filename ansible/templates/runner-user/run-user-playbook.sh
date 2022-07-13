#!/bin/bash

set -eu

cd ~/.temp

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOME}/go/bin

ansible-playbook -i user-inventory.yaml user-playbook.yaml
