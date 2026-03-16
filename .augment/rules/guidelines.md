---
type: always_apply
---
# No SSH / No NixOS commands

NEVER run any of the following, under any circumstances, without explicit permission from the user for that specific action:

- `ssh` or any remote shell command targeting a host
- `nixos-rebuild`, `nixdeploy`, or any NixOS switch/boot/test command
- `nix copy`, `nix build` targeting a remote host

Propose the command to the user and ask them to run it themselves instead.

# No unrequested changes

NEVER make any changes to the codebase without explicit permission from the user for that specific change.
