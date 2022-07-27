# MacOS Parallels Gitlab Runner Playbook

An Ansible playbook that provisions a Gitlab CI runner on macOS.
The runner executes jobs via a Parallels Desktop VM.
It runs as a LaunchDaemon, so it doesn't require a user to be logged in.

## Requirements

#### Ansible Controller

- On macOS, either the Command Line Developer Tools or Xcode need to be installed.
- The provisioning script might work on other UNIX-like systems including Linux, but hasn't been tested.
- Ansible
- jq

#### Ansible Nodes

- A somewhat up-to-date version of macOS.
  Provisioning was tested on Catalina, Big Sur, and Monterey.
- Either the Command Line Developer Tools or Xcode need to be installed.
- An Administrator account (i.e. capable of `sudo`) with a known password.
- Parallels Desktop 17 (Pro or Business edition, ie $$)
- Parallels Virtualization SDK 17.1.4
- A Parallels Desktop VM containing a Gitlab executor.
  [This repository](https://github.com/paullalonde/macos-parallels-gitlab-golang-executor-vms) can generate a suitable executor VM.

## Setup

TBD

## Procedure

1. Run the script:
   ```bash
   ./provision.sh --host <host>
   ```
   where *host* is the name of the Ansible group containing the node to provision.

1. The script will perform the following steps:
   1. Prepare vault passwords for consumption by Ansible.
   1. Call `ansible-playbook`.

## Related Repositories

- [Bootable ISO images for macOS](https://github.com/paullalonde/macos-bootable-iso-images).
- [Base VMs for macOS](https://github.com/paullalonde/macos-parallels-base-vms).
- [Build VMs for macOS](https://github.com/paullalonde/macos-parallels-build-vms).
- [Gitlab CI executor VMs for macOS](https://github.com/paullalonde/macos-parallels-gitlab-golang-executor-vms).
