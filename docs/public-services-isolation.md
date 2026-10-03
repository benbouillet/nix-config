# Segregating Public Services (e.g. Matrix/Synapse) from Tailscale Homelab

Hosting public-facing services (like Matrix, Nextcloud, or a public website) on a homelab inherently introduces risk. Unlike internal services protected by a zero-trust Tailscale perimeter and an identity provider like Authelia, public services are exposed to the open internet and must be treated as hostile or "eventually compromised."

This guide outlines a strict Defense-in-Depth architecture for NixOS and Podman to isolate public workloads from your private data.

## 1. The Entrypoint: Reverse Proxy Segregation (The DMZ Pattern)

If your reverse proxy (`leia`) handles both Tailscale and public traffic, you must explicitly bind your domains to the correct network interfaces to avoid accidentally exposing private services.

**NixOS Caddy Configuration Example:**

```caddyfile
# Public internet services - Bind ONLY to the public IP
matrix.${globals.domain} {
    bind <leia-public-ip> # e.g. eth0 IP
    reverse_proxy chewie-dmz:8008
}

# Internal Tailscale services - Bind ONLY to the Tailscale IP
vault.${globals.domain} {
    bind ${globals.hosts.leia.ipv4} # e.g. 100.x.x.x
    reverse_proxy chewie:9070
}
```

*Best Practice:* Run a completely separate Caddy instance or use a dedicated, expendable node purely for public internet traffic to prevent any configuration mix-ups.

## 2. The Backend: Container Network Isolation

By default, Podman attaches containers to `podman0`. If your NixOS firewall allows `podman0` to access host ports (like `5432` for PostgreSQL), a compromised public container can easily pivot to your private databases.

**Solution: Create a Dedicated DMZ Network**

Create a custom Podman network that has absolutely no access to the host.

```nix
systemd.services.podman-network-dmz = {
  description = "Create public DMZ podman network";
  script = ''
    ${pkgs.podman}/bin/podman network exists dmz || \
    ${pkgs.podman}/bin/podman network create dmz --disable-dns
  '';
  wantedBy = [ "multi-user.target" ];
};

virtualisation.oci-containers.containers."synapse" = {
  image = "matrixdotorg/synapse:latest";
  extraOptions = [ "--network=dmz" ]; # Attach exclusively to the DMZ network
  ports = [ "127.0.0.1:8008:8008" ];  # Bind to localhost (see Section 4)
};
```
Because NixOS firewalls are **default deny**, the new `dmz` interface will drop all packets trying to reach the host OS.

## 3. The Data Layer: Database Segregation

Never place the database for a public service in the same bare-metal PostgreSQL instance as your private homelab data (Vaultwarden, Paperless). 

**Solution: Containerized DMZ Database**

Deploy a dedicated database container on the `dmz` network. It should not expose any ports to the host.

```nix
virtualisation.oci-containers.containers."synapse-db" = {
  image = "postgres:15";
  extraOptions = [ "--network=dmz" ];
  # No ports exposed! Synapse communicates via Podman internal DNS (synapse-db:5432)
};
```

## 4. The Bridge: Preventing the NAT Trap

If you map a container port to an external IP (`ports = [ "''${globals.hosts.chewie.ipv4}:8008:8008" ]`), Podman creates a `PREROUTING` DNAT rule in iptables/nftables. **This completely bypasses the NixOS firewall.**

To retain firewall control, bind the container to `127.0.0.1` and use a host-level proxy to bridge the Tailscale interface to the container.

**NixOS Proxy Configuration Example:**

```nix
# 1. Bind the container securely
virtualisation.oci-containers.containers."synapse".ports = [ "127.0.0.1:8008:8008" ];

# 2. Proxy Tailscale traffic to localhost
systemd.services.synapse-proxy = {
  description = "Proxy Tailscale to DMZ Synapse";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = "''${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ''${globals.hosts.chewie.ipv4}:8008 127.0.0.1:8008";
    DynamicUser = true;
  };
};

# 3. Explicitly allow the traffic in the NixOS firewall
networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8008 ];
```

## 5. Compute Isolation: Preventing Container Escapes

NixOS `oci-containers` with the Podman backend run as `root`. If an attacker achieves a container escape, they gain `root` access to your entire host, bypassing all network isolation.

**Solution A: User Namespace Remapping (Recommended)**

Map the container's `root` user to an unprivileged high UID on the host.

```nix
virtualisation.oci-containers.containers."synapse".extraOptions = [ 
  "--userns=auto" # Automatically allocate a unique UID/GID map
];
```

**Solution B: True VM / Physical Isolation (Maximum Security)**

Containers share the host's Linux kernel. For high-risk applications, deploy them in a lightweight virtual machine using `microvm.nix` or run them on a physically separate node (like a cheap cloud VPS) that connects back to your homelab via Tailscale.
