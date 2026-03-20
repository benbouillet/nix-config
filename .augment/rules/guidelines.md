---
type: always_apply
---
# No SSH / No NixOS commands

Do not run any of the following, without explicit request from the user for that specific action:

- `ssh` or any remote shell command targeting a host
- `nixos-rebuild`, `nixdeploy`, or any NixOS switch/boot/test command
- `nix copy`, `nix build` targeting a remote host
- any command that would modify state

Propose the command to the user and ask them to run it themselves instead.
SSH exceptions must be explicitly granted per-host (e.g. "you can ssh to yoda") and do NOT extend to any other host.

# No unrequested changes

NEVER make any changes to the codebase without explicit permission from the user for that specific change.
