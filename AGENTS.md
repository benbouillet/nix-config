# AGENTS.md

AI agent reference for this Nix Flake-based homelab configuration.

---

## Project Overview

Homelab managing **4 NixOS hosts** — 1 desktop + 3 servers — via a single flake. Servers use impermanence (ephemeral root, persistent bind-mounts). Services include databases, OCI containers (ARR suite, Paperless, Immich), reverse proxy with SSO, and a full observability stack.

| Host | Role | State version | Key traits |
|---|---|---|---|
| `obiwan` | Desktop (Framework 13 7040 AMD) | 24.11 | Home Manager, Hyprland, nixvim, stylix theming, jump-host for SOPS secrets |
| `chewie` | Primary server | 24.05 | ZFS (ssd+hdd), OCI containers, PostgreSQL/MySQL/Redis, most services |
| `yoda` | Secondary server | 25.05 | ZFS backup node, minimal services |
| `leia` | Observability server | 25.05 | Prometheus, Grafana, Loki, Alloy, Caddy reverse proxy |

---

## File Layout

```
flake.nix                          # Entry point: mkHost helper, devShells, packages
flake.lock                         # Pinned inputs — let Renovate manage this
.sops.yaml                         # SOPS routing rules (path → Age keys)
renovate.json                      # Automated updates (nix deps + Docker images via custom regex manager)

hosts/<name>/
  configuration.nix                # Imports all modules for this host
  hardware-configuration.nix       # Auto-generated — do not edit manually
  globals.nix                      # Per-host ZFS dataset paths, podman CIDR, etc. (extends globals-shared.nix)
  impermanence.nix                 # /persist bind-mount declarations (servers only)
  zfs.nix                          # ZFS mount + sanoid config
  disko/                           # Declarative disk layout (zpools.nix, zfs-disks.nix, datasets.md)

modules/
  nixos/
    common.nix                     # ALL hosts: SOPS defaults, cachix substituters, gc, systemd-boot, user creation
    desktop.nix                    # Desktop-only: pipewire, XDG dirs
    server.nix                     # Server-only: nftables firewall, hardening, sshd lockdown, fail2ban, auditd, tailscale
    hyprland.nix                   # Hyprland compositor (obiwan)
    gaming.nix                     # Steam / Proton (obiwan)
    ssd.nix                        # SSD TRIM schedule
    zfs.nix                        # ZFS utilities + sanoid/sanemail configs
    overlays.nix                   # Package overrides (e.g. bambu-studio pinned to AppImage)
    stylix.nix                     # Base16 theming — called with { inputs, pkgs, theme, username, wallpaper_file }
    vpn.nix                        # WireGuard / Tailscale config (obiwan)
    sre.nix                        # CLI tools (curl, htop, jq…)
    globals-shared.nix             # Shared constants: domain name, host IPv4 addresses, port map, users/groups UIDs/GIDs
    services/                      # NixOS-level services
      ai.nix                       # Llama swap / local AI inference
      authentication.nix           # Authelia + OIDC
      mysql.nix / postgresql.nix / redis.nix  # Database servers (chewie)
      reverse-proxy.nix            # Caddy modules + shared config
      containers/
        common.nix                 # Podman base module (network, UID/GID mapping)
        arr.nix                    # Bazarr, Prowlarr, Radarr, Sonarr, Jellyfin, qBittorrent, NZBGet
        paperless.nix              # Paperless-ngx document management
        seafile.nix                # Seafile file sync
        mealie.nix                 # Recipe management
        search.nix                 # SearXNG meta-search
        foundryvtt.nix             # Foundry VTT game platform
        linkding.nix               # Bookmark manager
    observability/
      alloy.nix                    # Alloy agent — deployed on every host, ships journald logs to leia's Loki
      prometheus.nix               # Prometheus server (leia)
      grafana.nix                  # Grafana + dashboards (leia)
      loki.nix                     # Loki log aggregation (leia)
      ntfy.nix                     # Alert notification routing (leia)

  home/                            # Home Manager modules (obiwan only, wired through flake.nix HM config)
    neovim/                        # Full nixvim config (~15 plugin files + lsp.nix, treesitter.nix…)
    hyprland.nix                   # Hyprland window manager settings
    hyprland-keybindings.nix       # Keybind definitions
    hyprlock.nix / hyprpaper.nix   # Lockscreen & wallpaper daemon
    waybar.nix                     # Status bar (with Tailscale, ping widgets)
    zsh.nix / tmux.nix / git.nix   # Shell, multiplexer, VCS config
    agentic/                       # AI agent tooling config
    sunday.nix                     # Sunday integration
    sre.nix                        # Dev/SRE CLI tools for desktop

scripts/                           # Nix-packaged bash scripts (waybar widgets, emoji picker, etc.)
packages/                          # Custom derivations (auggie)
```

---

## How `mkHost` Works

Defined in `flake.nix`, the `mkHost` helper builds every host:

```nix
mkHost {
  host = "<name>";                                    // matches hosts/<name>/configuration.nix
  extraModules ? [ ];                                 // additional NixOS modules (disko, sops-nix, impermanence)
  extraSpecialArgs ? { };                             // extra module system arguments
}
```

- **Common special args** injected into every host: `inputs`, `host`, `username` ("ben")
- **obiwan only** gets `auggie` + Home Manager wired in flake outputs
- Servers get disko + sops-nix + impermanence as extraModules

Host-specific modules are imported inside each `hosts/<name>/configuration.nix`. The pattern is:

```nix
{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./zfs.nix
    ./impermanence.nix
    ../../modules/nixos/common.nix       # ← shared baseline always imported first
    ../../modules/nixos/server.nix       # ← or desktop.nix for obiwan
    # … host-specific services
  ];

  system.stateVersion = "24.05";         # DO NOT MODIFY
}
```

---

## `globals` Module Argument System

Shared constants live in `modules/nixos/globals-shared.nix`, injected via `_module.args.globals`. Each server extends it with host-specific overrides in its `globals.nix`.

Key globals:
- `globals.domain` — `r4clette.com`
- `globals.hosts.<name>.ipv4` — Tailscale IPv4 per host
- `globals.ports.<service>` — every service port (9000–9999 range)
- `globals.zfs.<category>.<dataset>` — ZFS dataset name + mountPoint paths
- `globals.users.<service> / globals.groups.<service>` — dedicated UIDs/GIDs

Access in any module via the `globals` argument:

```nix
{ globals, ... }: {
  networking.firewall.allowedTCPPorts = [ globals.ports.prometheus ];
}
```

---

## SOPS Secrets Architecture

### Routing (`.sops.yaml`)

Each host's secrets file is encrypted with **two keys**: its own Age key + `obiwan`'s key (admin jump-host):

```
secrets/chewie.yaml → encrypt: chewie, obiwan
secrets/yoda.yaml   → encrypt: yoda, obiwan
secrets/leia.yaml   → encrypt: leia, obiwan
```

### Age key storage

- Servers store their private key at `/var/lib/sops-nix/key.txt` (declared in `server.nix`)
- Obiwan stores keys in `~/.config/sops/age/keys.txt`
- Keys are **not tracked in git** — never commit `.age` or `keys.txt` files

### Adding a new secret

1. Define the key path in the relevant Nix module:
   ```nix
   sops.secrets."my-service/api-key" = { };  # inherits defaultSopsFile from common.nix
   ```
2. Add the value to `secrets/<host>.yaml` (edit with `sops secrets/<host>.yaml`)
3. If the secret is only for one host, the path_regex routing handles encryption automatically

### Default SOPS config (`common.nix`)

Every host inherits:
```nix
sops.defaultSopsFile = ../../secrets/${host}.yaml;
sops.defaultSopsFormat = "yaml";
```

---

## Impermanence Pattern (servers only)

Servers boot with a tmpfs root. Persistent directories are bind-mounted from `/persist` via `hosts/<name>/impermanence.nix`:

- `/var/lib/sops-nix` — Age key file (required for SOPS decryption at boot)
- `/etc/nixos` — flake clone (for `nixos-rebuild`)
- `/var/log`, `/var/lib/prometheus-node-exporter` — persistent logs/metrics
- Service-specific data dirs

**Rule**: any new service needing disk persistence MUST be added to the impermanence module, or all writes vanish on reboot.

---

## Observability Stack

| Component | Where deployed | What it does |
|---|---|---|
| **Alloy** (agent) | Every host | Collects journald logs, forwards to leia's Loki (`modules/nixos/observability/alloy.nix`) |
| **node-exporter** | Every host (via `server.nix`) | CPU, memory, disk metrics → Prometheus |
| **Prometheus** | leia only | Scrapes all hosts on port 9090 |
| **Grafana** | leia only | Dashboards + alerting on port 9095 |
| **Loki** | leia only | Log aggregation on port 9096 (http) / 9097 (grpc) |
| **ntfy** | leia only | Alert notification routing on port 9094 |

The Alloy agent config is embedded directly in `alloy.nix`. It hardcodes `globals.hosts.leia.ipv4` as the Loki endpoint — changing leia's IP requires updating `globals-shared.nix`.

---

## ZFS Disk Layout

Disk layouts are declared via **disko** in `hosts/<name>/disko/`:
- `zfs-disks.nix` — disk mapping (SSD vs HDD)
- `zpools.nix` → pool definitions with encryption
- `datasets.md` — authoritative reference for all datasets (maintain after imperative changes)

Chewie dataset hierarchy:
```
ssd/services/infra   → /srv/services/infra
ssd/services/apps    → /srv/services/apps
ssd/db/postgres      → /srv/db/postgres
ssd/db/mysql         → /srv/db/mysql
hdd/data/media       → /srv/data/media
hdd/data/paperless   → /srv/data/paperless
hdd/data/seafile     → /srv/data/seafile
hdd/data/immich      → /srv/data/immich
```

**ZFS change workflow**: make changes imperatively first, then sync `datasets.md` → `zfs.nix` (sanoid config) → `disko/zpools.nix`.

---

## Networking & Firewall

- All hosts use **Tailscale** for private networking (`services.tailscale.enable = true` in `common.nix` / `server.nix`)
- Servers use **nftables** firewall: default deny, only `tailscale0` trusted + SSH port allowed
- Tailscale forces nftables mode via `TS_DEBUG_FIREWALL_MODE=nftables` env var (avoids iptables-compat)
- Wired interfaces use systemd-networkd DHCP (`en*`, `eth*`)
- Fail2ban protects SSH, ignores Tailscale CGNAT ranges
- Reverse proxy on leia: Caddy with Cloudflare DNS challenge for TLS

---

## Common Commands

```bash
# Enter dev shell (nixfmt, nil, deadnix, statix, nixdeploy, scram-sha-256, authelia-hash)
nix develop

# Deploy to local desktop
sudo nixos-rebuild switch --flake .#obiwan

# Deploy to remote server (uses SSH config from ~Ben/.ssh/config)
nixdeploy chewie    # wrapper: nixos-rebuild switch --flake .#$1 --target-host $1 ...

# Dry-build locally, then diff before switching
sudo nixos-rebuild build --flake .#obiwan
nvd diff /nix/var/nix/profiles/system-*-link /nix/store/...-nixos-system-obiwan-*

# Format all Nix files
nixfmt .

# Lint (unused bindings + static analysis)
deadnix .
statix check .

# Edit secrets (must run from a host that has the Age key — obiwan for all hosts)
sops secrets/chewie.yaml

# Generate PostgreSQL scram-sha-256 hash
scram-sha-256

# Generate Authelia argon2 hash
authelia-hash "$password"

# Build USB bootable NixOS ISO
nix build .#usbboot
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M conv=fsync status=progress

# Provision a bare metal machine (nixos-anywhere)
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./hosts/<name>/hardware-configuration.nix \
  --flake .#<name> --target-host <TARGET>

# Update SOPS keys after adding a new host key
sops updatekeys secrets/<host>.yaml
```

---

## Development Workflow Checklist

### Adding a new service

1. **Pick the right location**
   - NixOS-level → `modules/nixos/services/` (e.g. `postgresql.nix`)
   - OCI container → `modules/nixos/services/containers/` (follow pattern of existing containers)
   - Desktop tool → `modules/home/`

2. **Assign a port** in `globals-shared.nix` under `ports.`

3. **If it needs dedicated user/group**, add entries to `globals.users.` / `globals.groups.` with UID/GID

4. **If it needs secrets**, declare them via sops-nix and add values to the appropriate `secrets/<host>.yaml`

5. **If on an impermanent host**, ensure persistent dirs are in `hosts/<name>/impermanence.nix`

6. **Import the module** in the target host's `configuration.nix`

7. **If it exposes metrics**, add a node-exporter or custom scrape target to Prometheus config

### Modifying existing modules

- Prefer importing from shared modules rather than duplicating logic in `configuration.nix`
- Use `lib.mkDefault` / `lib.mkForce` appropriately (see `server.nix` for examples: gc options, user settings)
- When touching hardware config, update `hardware-configuration.nix` only via `nixos-generate-config` or nixos-anywhere

### Renovate

Managed via `renovate.json`. Handles:
- All Nix inputs (via flake.lock)
- Docker image tags (custom regex manager scanning `.nix` files for `image = "name:tag@digest"`)
- Lock file maintenance
- Vulnerability alerts (labelled `security`)
- Ignores `sunday-augment` input

---

## Temporary Workarounds

See [`README.md#temporary-workarounds`](./README.md#temporary-workarounds):
- **bambu-studio** pinned to Ubuntu 24.04 AppImage (nixpkgs source build broken) — overlay in `modules/nixos/overlays.nix`
- **hmts.nvim** disabled due to crash on `.nix` files — in `modules/home/neovim/plugins/treesitter.nix`

---

## Key Architectural Principles

1. **Composition over duplication**: shared logic lives in `modules/nixos/`, host configs are thin import lists
2. **Secrets follow the host**: each `secrets/<host>.yaml` is self-contained; obiwan can decrypt all for admin access
3. **Immutability by default**: servers reboot cleanly via impermanence; state is declared, not accidental
4. **Observability everywhere**: every host ships logs/metrics to leia; no black boxes
5. **Tailscale-first networking**: servers are firewalled behind Tailscale only; public exposure goes through Caddy on leia
