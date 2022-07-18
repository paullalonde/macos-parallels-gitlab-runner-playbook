# MacOS Parallels Gitlab Runner Playbook

An Ansible playbook that provisions a Gitlab CI runner on macOS.
The runner executes jobs via a Parallels Desktop VM.
It's run as a LaunchDaemon, so it doesn't require a user to be logged in.
