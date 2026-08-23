# nix-config — Security Review (public repo exposure)

**Date:** 2026-08-20
**Scope:** Full static review of `/home/ben/dev/benbouillet/nix-config` (HEAD + full git history, 1270 commits) assuming the GitHub repo is public. No repo modifications made.
**Method:** Manual review of all 4 host configs, shared modules, SOPS setup, Caddy routing, container modules, observability stack; grep sweeps for plaintext secrets; full-history scans (`git log -S`, per-commit blob inspection of `secrets/**`, pickaxe for key patterns).

---

## TL;DR

No plaintext secrets are present or have ever been committed — the SOPS/age setup is clean, including history. The real risk profile is **lateral movement inside the homelab**, which the repo itself documents as a known, unimplemented gap (`docs/public-services-isolation.md`). Headline: a compromised podman container can reach the database tier unauthenticated-as-root (MySQL `root@'%'`) or via a passwordless Redis.

| Severity | Count | Top items |
|---|---|---|
| Critical | 1 | MySQL `root@'%'` with GRANT OPTION, reachable from container network |
| High | 4 | Redis no-auth on container CIDR; Caddy auth gaps (Prom/Grafana/ntfy/Loki); Loki no auth; stale SOPS recipients on `obiwan.yaml` |
| Medium | 9 | PG `md5` + wildcard podman CIDR; seafile `%` user; SOPS file owned by service user; vaultwarden signups; dead Authelia/Caddy rules; ntfy/llama-swap unauthenticated; `--network=host` container; blackbox SSRF; degoog public mode |
| Low | 8 | radikale plaintext htpasswd; work-repo disclosure; per-printer CA cert in tree; IP/port/UID map in tree; SSH 22 open on all interfaces; alloy→Loki plaintext HTTP; paperless admin username; `group:debug` membership |

---

## Critical

### C1. MySQL `root@'%'` — remote root DB account reachable from the container network
`modules/nixos/services/mysql.nix` creates `root@'%'` with `GRANT ALL PRIVILEGES ON *.* ... WITH GRANT OPTION`. Bind address includes `globals.podmanBridgeGateway` (10.88.0.1), and the `podman0` firewall allows TCP 3306 into the 10.88.0.0/16 bridge (`modules/nixos/services/containers/common.nix`).

- Any of ~15 podman containers (ARR suite, Paperless, Immich, Seafile, Mealie, degoog, …) — or any host on the tailnet — can connect as **MySQL root**.
- Combined with `ip_forward=1` on the bridge, this is the shortest path from a single container credential leak to full ownership of the database tier (all DBs: paperless, immich, seafile, vaultwarden, degoog).
- MySQL root shell → `LOAD DATA`/UDF-style primitives or simply dumping/modifying every dataset.

**Fix:** Keep root on `localhost`/socket only. Create one scoped user per database (host-restricted to the podman gateway IP, not `%`), `GRANT` minimal privileges, drop the existing `root@'%'`.

---

## High

### H1. Redis/Valkey: `protected-mode "no"` + no `requirepass`, reachable from the container network
`modules/nixos/services/redis.nix` — no auth, bound to 127.0.0.1 and the podman bridge gateway; `podman0` firewall allows TCP 6379.

- Any container can `FLUSHALL`, dump the entire keyspace, or overwrite keys (Immich de-dup/index data; any container talking to Redis).
- Unauthenticated Redis is a classic RCE primitive family (RDB/Cron write); here the impact is already "full control of cache backends of OIDC-protected apps".

**Fix:** `requirepass` via SOPS + `protected-mode "yes"`, and ideally restrict at firewall to only the containers that need it — or isolate per-container networks (see docs/public-services-isolation.md).

### H2. Caddy exposes observability and data services with no `forward_auth`
`hosts/leia/caddy-services.nix` — proxied **without** Authelia `forward_auth`: prometheus, alertmanager, ntfy, grafana, vaultwarden, ai (llama-swap), contacts, degoog, degoog-mcp.

- Any tailnet peer (laptop, phone, guest, any compromised device on the private network) can query Prometheus (metrics = internal map + SSRF via blackbox/probe targets), browse Grafana (all 4 hosts), read/write ntfy topics, or hit the LLM endpoint.
- Grafana has `disable_login_form = false` so its own login exists, but it has an Authelia access rule that is dead (see M5) — intent was SSO; actual state is "basic auth on tailnet".

**Fix:** Add `forward_auth` to every reverse-proxy route; for the observability tier, restrict to an `admins` Authelia group.

### H3. Loki: `auth_enabled = false`, bound 0.0.0.0:9096
`modules/nixos/observability/loki.nix` — all 4 hosts' journald logs (SSH auth attempts, service errors, container stderr) sit behind the nftables/tailnet trust only.

- Any tailnet peer can read 14 days of logs from the whole homelab without credentials.
- Alloy pushes over plaintext HTTP at the same time (see L6).

**Fix:** Enable Loki auth (per-client tokens or `auth_enabled` with a basic-auth user) or at minimum a dedicated Authelia group in front; consider TLS.

### H4. Stale SOPS recipients on `secrets/obiwan.yaml` (all files should be re-verified)
`.sops.yaml` declares `obiwan.yaml` → **obiwan only**, but the file's key metadata contains **4 age recipients**. Likewise verify the other 3 files.

- Anyone who historically held any of the extra keys (rotated laptop, lost device, old `~/.config/sops/age/keys.txt` backup) can still decrypt the file **today and in the future**, including `sunday_litellm_api_key`, `sunday_n8n_api_key`, `sunday_linear_api_key`, and `applications.pi.authJson` (work credentials in a personal public repo).

**Fix:** `sops updatekeys secrets/<host>.yaml --encrypt` (or re-encrypt after removing stale keys from `.sops.yaml` history). Then confirm `sops -d` only works from obiwan.

---

## Medium

| # | Finding | Where |
|---|---|---|
| M1 | PostgreSQL uses `md5` auth and binds the entire podman CIDR (10.88.0.0/16) | `modules/nixos/services/postgresql.nix` |
| M2 | `seafile` MySQL user created as `seafile@'%'` (wildcard host) | `hosts/chewie`, seafile module |
| M3 | SOPS secret file `services/seafile/env` is owned/readable by the `seafile` service user | seafile container module |
| M4 | vaultwarden `SIGNUPS_ALLOWED = "true"` on a tailnet-exposed app — self-service account creation on the password vault | `modules/nixos/services/vaultwarden.nix` |
| M5 | Caddy/Authelia mismatch: `dnd` (Foundry VTT), `links` (linkding), `lubelogger` have Authelia access rules but **no `forward_auth` in their Caddy routes** → SSO rules are dead | `hosts/leia/caddy-services.nix` vs `authentication.nix` |
| M6 | ntfy has no auth (any tailnet device can read/publish any topic); llama-swap has no API auth (GPU inference abuse) | `observability/ntfy.nix`, `services/ai.nix` |
| M7 | bambuddy container runs `--network=host` + `NET_BIND_SERVICE` — bypasses podman network isolation entirely | `containers/bambuddy.nix` |
| M8 | Prometheus blackbox exporter: SSRF via `__param_target` queryable by anyone with Prometheus access (see H2) | `observability/prometheus.nix` |
| M9 | degoog: `DEGOOG_PUBLIC_INSTANCE = "true"` and `DEGOOG_DISTRUST_PROXY = "0"` — meta-search usable by anyone reaching it | `containers/search.nix` |

---

## Low

| # | Finding | Where |
|---|---|---|
| L1 | `htpasswd_encryption = "plain"` — calendar creds stored in cleartext (in SOPS file, so mitigated) | `services/radicale.nix` |
| L2 | Work-repo disclosure: `sunday-augment` / `sunday-bastion` flake inputs (`github.com/sundayapp/*`) + `nix-private` submodule SSH URL in `.gitmodules` — org/infra disclosure in a personal public repo | `flake.nix`, `.gitmodules` |
| L3 | Per-printer "Virtual Printer CA" (r2d2) certificate embedded in the tree — public cert by design, but holder can impersonate the user's printer AI API to the slicer | `modules/nixos/overlays.nix` |
| L4 | `globals-shared.nix` exposes full tailnet IP map, all service ports, and UIDs — quality recon material (low because tailnet-only access) | `modules/nixos/globals-shared.nix` |
| L5 | SSH `openFirewall = true` → port 22 reachable on all interfaces (LAN + Tailscale); mitigated by key-only + fail2ban | `modules/nixos/server.nix` |
| L6 | Alloy → Loki push is plaintext HTTP (log traffic on tailnet); Loki tsdb on plain btrfs | `observability/alloy.nix`, `lokis.nix` |
| L7 | `PAPERLESS_ADMIN_USER = "ben"` plaintext (username disclosure; the password is SOPS) | `containers/paperless.nix` |
| L8 | Authelia hygiene: `seafile` user placed under `group:debug` | `services/authentication.nix` |

---

## What's done well

- **Secrets hygiene is genuinely solid.** All 4 SOPS files are AES256_GCM-encrypted; a full history scan (1270 commits, every blob ever at `secrets/**`) found **zero plaintext secret commits** — including the pre-split `secrets.yaml` era. No `ghp_*`, `sk-*`, private keys, or inline WI-FI PSKs ever in `.nix` files.
- Per-host SOPS key policy with obiwan as admin jump-host; Age private keys never in git.
- ZFS pools encrypted with per-pool passphrase (`keyformat = "passphrase"`); no key material anywhere in the repo or runtime modules.
- GitHub Actions CI uses `secrets.SUNDAY_AUGMENT_PAT` properly for the private-repo flake input.
- Desktop SSH configs and WiFi credentials are SOPS-encrypted, not committed.
- Servers: nftables default-deny, key-only SSH + fail2ban, Caddy 80/443 restricted to `tailscale0`, Cloudflare DNS-01 challenge, impermanence with persistent SSH host keys.
- Most containers use dedicated UIDs/GIDs in a private namespace; Immich/Paperless/Mealie use OIDC via Authelia.
- The podman0→database lateral-movement risk is explicitly documented as a known gap (`docs/public-services-isolation.md`) — good awareness, just not yet fixed.

---

## Suggested priority order

1. **Today:** Drop MySQL `root@'%'` → socket-only root + per-DB scoped users (C1). Highest blast radius for lowest effort.
2. **Today:** Redis `requirepass` (SOPS) + `protected-mode "yes"` (H1).
3. **This week:** `sops updatekeys` on all 4 secret files so the live key set matches `.sops.yaml` (H4).
4. **This week:** Add `forward_auth` to every Caddy route — especially prometheus/grafana/ntfy/loki/ai — and restrict the observ tier to an admins group (H2, H3, M5).
5. **This month:** Implement `docs/public-services-isolation.md` (per-container networks or at least a dedicated `db` network for the DB-tier talkers), disable vaultwarden signups after the initial admin account (M4), auth for ntfy / llama-swap (M6), replace bambuddy `--network=host` (M7), `scram-sha-256` + gateway-only binding for PostgreSQL (M1), scope `seafile@'%'` → gateway IP (M2).
