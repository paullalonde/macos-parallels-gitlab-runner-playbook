# MacOS Parallels Gitlab Runner Playbook

An Ansible playbook that provisions a Gitlab CI runner on macOS.
The runner executes jobs via a Parallels Desktop VM.
It runs as a LaunchDaemon, so it doesn't require a user to be logged in.

## Requirements

#### Controller

- Ansible

#### Nodes

- A somewhat up-to-date version of macOS.
- Minimally, the Command Line Developer Tools need to be installed.
- An Administrator account (i.e. capable of `sudo`) with a known password.
- Parallels Desktop 17 (Pro or Business edition)
- Parallels Virtualization SDK 17.1.4

## Related Repositories

- [Bootable ISO images for macOS](https://github.com/paullalonde/macos-bootable-iso-images).
- [Base VMs for macOS](https://github.com/paullalonde/macos-parallels-base-vms).
- [Build VMs for macOS](https://github.com/paullalonde/macos-parallels-build-vms).
- [Gitlab CI executor VMs for macOS](https://github.com/paullalonde/macos-parallels-gitlab-golang-executor-vms).
