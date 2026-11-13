# Homelab Configurations

This repository is my configuration for a Nix flake-based homelab.

## Nodes

| Node | Role |
| --- | --- |
| `obiwan` | Workstation with Home Manager |
| `chewie` | Primary applications and data node |
| `yoda` | Backup node |
| `leia` | Reverse proxy and observability node |
| `tarkin` | ARM cloud Nebula lighthouse |
| `kylo` | Raspberry Pi camera node |

## Repository map

- `flake.nix` defines the six NixOS configurations, packages, development shell, and formatter.
- `hosts/` contains host-specific configuration and storage declarations.
- `modules/nixos/` contains shared NixOS modules.
- `modules/home/` contains Home Manager modules used by the workstation.
- `packages/` and `scripts/` provide custom packages and helper scripts.
- `infra/` contains infrastructure definitions.
- `docs/` contains operational notes and temporary-workaround status.

## Documentation

- [Kylo Raspberry Pi](docs/kylo.md): installer and camera-node operational notes.
- [Storage](docs/storage.md): ZFS dataset change workflow.
- [Temporary workarounds](docs/workarounds.md): current source-backed workaround status.

## Roadmap

- [Open roadmap](https://github.com/benbouillet/nix-config/issues?q=is%3Aissue%20is%3Aopen)
- [Completed history](https://github.com/benbouillet/nix-config/issues?q=is%3Aissue%20is%3Aclosed)
