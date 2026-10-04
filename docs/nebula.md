# Nebula lighthouse architecture and deployment

Tarkin is an AWS eu-west-3a ARM64 NixOS EC2 instance whose only role is to be
the Nebula Lighthouse. There is one lighthouse. The Nebula overlay is
`172.29.217.0/24`, with Tarkin at `172.29.217.1`; clients reach it through the
Elastic IP on public UDP/4242. Public TCP/22 is not exposed. Management is
exclusively OpenSSH tunneled through AWS SSM, never public SSH or SSH over
Nebula.

As the sole Lighthouse, Tarkin must not list itself in its `lighthouse.hosts`
settings list. Future clients must add Tarkin to their `static_host_map`
instead.

The instance is operationally stateless and disposable: its encrypted gp3
root volume is deleted with the instance and there is no persistent service
data. This does not mean it is disk-forensically empty; a generic AMI may
leave residual artifacts on the disposable volume.

## Architecture / moving parts

- **Terraform / AWS:** `infra/tarkin` creates a dedicated `10.202.0.0/16` VPC,
  the `10.202.0.0/24` public subnet in `eu-west-3a`, Internet routing, an EIP,
  and the `tarkin-lighthouse` security group. The EC2 instance is a `t4g.small`
  ARM64 NixOS host with an encrypted, delete-on-termination 8 GiB gp3 root
  volume, IMDSv2 required, and the `tarkin-ec2-host` instance role/profile.
- **Network exposure:** the security group and NixOS firewall allow Nebula's
 public UDP/4242 transport only. Client firewalls allow overlay traffic by
  Nebula `cidr` for inbound source overlay addresses, while the outbound policy
  uses `host = "any"`. Tarkin is transport/discovery-only and has no overlay
  application firewall allowance; it is not a transit router or overlay
  application endpoint. The instance uses HTTPS for SSM and AWS
  Secrets Manager and VPC DNS for its runtime dependencies.
- **SSM SSH transport:** the `ssh/tarkin` value in Obiwan's encrypted SOPS
  file is deployed by `hosts/obiwan/ssh.nix` to
  `/home/ben/.ssh/tarkin.conf`. It is an SSH configuration snippet for the
  EC2 instance ID and `AWS-StartSSHSession` `ProxyCommand`; it contains no SSH
  private key. This is the only management path.
- **Secrets:** Tarkin retrieves one value, its Age private identity, from AWS
  Secrets Manager using its EC2 role. The identity is used to decrypt the
  encrypted `secrets/tarkin.yaml` artifacts: the Nebula CA public certificate,
  Tarkin's host certificate, and Tarkin's host key. Terraform creates the
  Secrets Manager container but never manages its value. The Age identity is
  inserted manually through the AWS console.
- **Nebula PKI:** the CA private key remains offline and is never deployed to
  Git, SOPS, AWS, or Tarkin. Tarkin is the sole lighthouse for the overlay.
- **AWS access:** use the IAM Identity Center `TarkinSSMOperator` and
  `TarkinTerraformProvisioner` roles as appropriate. Because the operator has
  chosen console insertion of the Secrets Manager value, a
  `TarkinSecretBootstrapper` role is not needed.
- **Root SSH key:** the NixOS root authorized key is declared in
  `modules/nixos/nebula-lighthouse.nix`. Terraform creates the `tarkin-root`
  EC2 key pair from the `ssh_public_key` variable in
  `infra/tarkin/variables.tf`; its value is supplied outside the repository.
  This documentation does not assume a relationship between that key and any
  generic AMI key. Private keys are never stored in Terraform, Nix, SOPS, AWS,
  or this repository.

Tarkin has no Tailscale, Alloy, Podman, application workload, or other service.

## Security model and limitations

- This design makes no claim of being impervious. Its public attack surface is
  intentionally limited to UDP/4242, but Nebula and the host still require
  timely patching and certificate maintenance.
- AWS IAM, SSM, the AWS control plane, and the console operator are trusted.
  SSM session content logging is not configured; accept that observability gap.
- One lighthouse is an availability dependency: its outage partitions or
  disrupts overlay connectivity.
- `172.29.217.0/24` is selected to reduce IPv4 collisions, not to prove that
  collisions cannot occur.
- The disposable root disk can retain generic AMI artifacts.
  Volatile journald storage and runtime secret files are not a forensic
  erasure guarantee.
- Routine work must use IAM Identity Center with the `homelab-deployment`
  profile, never the AWS root account/profile. The relevant deployed AWS names
  are `tarkin-lighthouse`, `tarkin-ec2-host`, and `tarkin-age-identity`; the
  Terraform provider uses the `homelab-deployment` profile in `eu-west-3`.

## Deploy or redeploy

Prerequisites:

- Nebula credentials are prepared in encrypted `secrets/tarkin.yaml`: the CA
  public certificate, Tarkin host certificate, and Tarkin host key. The CA
  private key is offline and is not part of this workflow.
- The Tarkin Age identity has already been inserted manually into the
  `tarkin-age-identity` secret in AWS Secrets Manager. Do not put the value in
  Terraform, Terraform state, shell history, or this repository.
- Use the `homelab-deployment` IAM Identity Center SSO profile, not root.

Run the following in order:

1. From `infra/tarkin`, inspect the plan and apply the AWS resources:

   ```sh
   cd infra/tarkin
   terraform plan
   AWS_PROFILE=homelab-deployment terraform apply
   ```

    The default for `create_instance` is false. If a new EC2 instance must be
   created, set `create_instance = true` in the untracked Terraform variables
   before planning and applying (the current local variables file already
   enables it). Do not expect Terraform to create or populate the secret
   value.

2. Fetch the ID of the running instance without printing or embedding a stale
   ID. The current EC2 tags are `Name=tarkin`,
   `Project=nebula-lighthouse`, and `ManagedBy=terraform`:

   ```sh
   INSTANCE=$(
     AWS_PROFILE=homelab-deployment aws ec2 describe-instances \
       --region eu-west-3 \
       --filters \
          'Name=tag:Name,Values=tarkin' \
          'Name=tag:Project,Values=nebula-lighthouse' \
          'Name=tag:ManagedBy,Values=terraform' \
         'Name=instance-state-name,Values=running' \
       --query 'Reservations[].Instances[].InstanceId | [0]' \
       --output text
   )
   test -n "$INSTANCE" && test "$INSTANCE" != None
   ```

3. Edit the encrypted `ssh/tarkin` value with `sops secrets/obiwan.yaml`.
     Update its `HostName` to `$INSTANCE`, set `User root`, and retain the
     `AWS-StartSSHSession` proxy configuration. The value is SSH configuration,
     not a place for an SSH private key.

    The repository intentionally does not modify encrypted SSH configuration
    values. The operator must make this SOPS edit manually before deploying
    Obiwan. The required final snippet is equivalent to:

    ```sshconfig
    Host tarkin
      HostName i-NEW_INSTANCE_ID
      User root
      ProxyCommand sh -c 'aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p'
    ```

4. Deploy the updated SSH configuration to Obiwan:

   ```sh
   sudo nixos-rebuild switch --flake .#obiwan
   ```

5. From the repository root, verify the SSM SSH path:

   ```sh
   AWS_PROFILE=homelab-deployment ssh -o BatchMode=yes tarkin
   ```

6. From the repository root, deploy the final NixOS configuration:

   ```sh
   AWS_PROFILE=homelab-deployment nixdeploy tarkin
   ```

   The native ARM64 build runs on Tarkin. Keep the instance at its current
   `t4g.small` size or provide enough memory for the build; the former
   micro-instance size was insufficient and could OOM.

7. If the deployment changed Nebula SOPS artifacts, do not reboot until a
   read-only SSM SSH check confirms that `nebula@tarkin.service` is active and
   UDP/4242 is listening. If either check fails, stop and inspect the service
   journal rather than rebooting. Then reboot and verify all of the following:

   - SSM re-registers and `ssh tarkin` reconnects.
   - Root-only access over SSM SSH works after the reboot using the operator's
     configured local SSH identity.
   - The Age identity is retrieved from Secrets Manager, SOPS decrypts the
     three Nebula artifacts, and Nebula is active at `172.29.217.1`.
   - Public TCP/22 is absent and public UDP/4242 is the only intended inbound
     service; SSH over Nebula does not work.
   - Verify that password, keyboard-interactive authentication, forwarding,
     and public TCP/22 remain disabled.

The current EC2 can be trashed and replaced only after this configuration has
passed local validation. Replacement is expected to produce a new instance
ID: update the encrypted `ssh/tarkin` SOPS snippet to that ID, deploy Obiwan,
then use `ssh tarkin` and `nixdeploy tarkin` to configure and verify the new
instance. No AWS mutation is part of local validation.

## Add a Nebula client

First decide whether this is an existing NixOS host, a new NixOS host, or an
external client. In every case, deliberately allocate an address and decide
the client's firewall policy before issuing credentials. Do not make a normal
client change to Tarkin: it is the lighthouse and transport/discovery endpoint,
not an overlay application client.

Check `modules/nixos/globals-shared.nix` and the certificate inventory before
choosing an unused address in `172.29.217.0/24`. The current allocations are
Tarkin (`172.29.217.1`), Chewie (`172.29.217.10`), and Obiwan
(`172.29.217.11`). For a repository NixOS host, record the allocation as
`globals.hosts.<name>.nebula`; for an external client, record the address in
the certificate inventory instead. In both cases, keep the certificate
inventory and exact expiry date up to date, and prevent address collisions.

On the offline CA machine, issue an ordinary client certificate with the
present CA. The certificate commands below run `nebula-cert` from the Nixpkgs
Nebula package with `nix shell`; they do not require a permanent installation
on `PATH`.
First inspect the CA certificate expiry:

```sh
nix shell nixpkgs#nebula --command nebula-cert print -path ca.crt
```

Choose `<duration>` so the host certificate expires no later than the CA. Use
`8760h` as the normal one-year target only when the CA has at least one year of
validity remaining; otherwise choose a shorter duration or rotate the CA
before onboarding. Replace the remaining placeholders deliberately; do not
copy an address already in the inventory:

```sh
nix shell nixpkgs#nebula --command nebula-cert sign \
  -name <client-name> \
  -ip "<unused-ip>/24" \
  -duration <duration> \
  -ca-crt ca.crt \
  -ca-key ca.key \
  -out-crt <client-name>.crt \
  -out-key <client-name>.key
```

Keep `ca.key` offline. Adding an ordinary client does not generate a new CA.
Validate that the certificate was issued under the current CA, then inspect
its requested name, IP, and expiry locally. Do not copy sensitive command
output into tickets, chat, logs, or Git; record the expiry in the operator
password manager and calendar:

```sh
nix shell nixpkgs#nebula --command nebula-cert verify -ca ca.crt -crt <client-name>.crt
nix shell nixpkgs#nebula --command nebula-cert print -path <client-name>.crt
```

Store exactly the host key, host certificate, and current CA public certificate
under the existing SOPS keys `nebula/host-key`, `nebula/host-cert`, and
`nebula/ca-cert`. For a repository host, edit the appropriate encrypted file
with `sops secrets/<host>.yaml`. Never put `ca.key` in SOPS, Git, AWS, the
client, or shell history. Run `sops updatekeys` only when Age recipient routing
changes; issuing a client certificate does not require it.

For an existing repository NixOS host:

- Add or retain `../../modules/nixos/nebula-client.nix` in
  `hosts/<host>/configuration.nix`, and ensure that the host imports the
  module providing `globals` (the shared module or the host's `globals.nix`).
  The current client module uses `services.nebula.networks.tarkin`, the
  `nebula1` device, and Tarkin's static host mapping.
- Add the address to `modules/nixos/globals-shared.nix` (or the host override
  where appropriate), then add the three SOPS values to
  `secrets/<host>.yaml`. On an impermanent host, retain any Nebula-related
  paths required by its `hosts/<host>/impermanence.nix`.

For a new NixOS host, add `hosts/<name>/configuration.nix` and its host entry
to `flake.nix`, add its address under `globals.hosts.<name>.nebula` in
`modules/nixos/globals-shared.nix`, and create `secrets/<name>.yaml` with an
appropriate Age recipient and matching creation rule in `.sops.yaml`. In
`hosts/<name>/configuration.nix`, explicitly import
`../../modules/nixos/nebula-client.nix` as well as the established
`../../modules/nixos/common.nix`. Ensure the NixOS sops module is available
before `nebula-client.nix` declares `sops.secrets`, and configure the default
SOPS file and format. Normally provide
`inputs.sops-nix.nixosModules.sops` through the host's flake entry in
`flake.nix`; existing flake `extraModules` may already provide it, but a new
host must verify that it does. Add hardware, disko, and
`hosts/<name>/impermanence.nix` content as applicable, and add the host to the
repository's CI build matrix if one is introduced or maintained. This
repository currently has no `.github/` CI configuration.

An external client needs no Nix configuration: distribute only its host key,
host certificate, and current CA public certificate through a secure channel,
then configure its Nebula lighthouse mapping and local firewall separately.

The current Nebula inbound policy matches source overlay IP ranges with
`cidr`; choose explicitly between the broad `globals.nebulaCidr` rule (any
protocol and port) and narrower allowed source CIDRs, protocols, and ports.
`host` is also valid for certificate-name matching, and the current outbound
allow-all uses `host = "any"`. This Nebula policy is separate from the NixOS
host firewall and whether `nebula1` is trusted there; the current module trusts
it only on Chewie. Do not assume or prescribe enabling `trustedInterfaces` for
a new host.

Build and deploy using a path that is actually available to the host. From the
repository root, first build the target:

```sh
nixos-rebuild build --flake .#<host>
```

For a local host, deploy with `sudo nixos-rebuild switch --flake .#<host>`.
For a remote host, `nixdeploy <host>` uses the host's Tailscale name for both
SSH and the build, so it is usable only when that Tailscale path exists; it is
not a generic Nebula or SSM deployment method. Otherwise use the host's
established reachable SSH/console deployment path and the same flake target.

After deployment, verify a NixOS client with:

```sh
systemctl is-active nebula@tarkin.service
systemctl status nebula@tarkin.service
ip address show dev nebula1
ip route show dev nebula1
journalctl -u nebula@tarkin.service -b --no-pager
```

Use the journal command when the service is not active. An external client
must instead use its platform's Nebula process or service status and logs, then
verify its Nebula interface and route using that platform's tools; do not
assume NixOS or any particular command set. For either client type, verify a
client-to-client ping or an explicitly allowed service connection, according
to the firewall policy. Do not ping Tarkin at `172.29.217.1`; verify Tarkin
through SSM by checking `nebula@tarkin.service` and its UDP/4242 listener
instead.

## Certificate maintenance

The Nebula v2 CA lifetime is 5 years and the normal host certificate target is
1 year, provided the host certificate does not outlast the CA. Record the exact
expiry date of each issued certificate in the operator password manager and
calendar. Renew host certificates at least 30 days before expiry, selecting a
duration that does not outlast the CA.
Begin CA replacement and coordinated client migration at least 90 days before
CA expiry; CA replacement requires reissuing all host certificates and
distributing the replacement CA certificate.

### Host certificate renewal

1. Confirm the host certificate expires within the renewal window. The overlay
   hosts and addresses are defined in `modules/nixos/globals-shared.nix`:
   Tarkin (lighthouse), `172.29.217.1`; Chewie, `172.29.217.10`; and Obiwan,
   `172.29.217.11`.
2. On the offline CA machine, inspect the CA expiry and sign the replacement
   certificate and key with a duration that does not outlast it. Keep `ca.key`
   offline:

   ```sh
     nix shell nixpkgs#nebula --command nebula-cert print -path ca.crt
     nix shell nixpkgs#nebula --command nebula-cert sign -name <host> -ip "<nebula-ip>/24" -duration <duration> -ca-crt ca.crt -ca-key ca.key -out-crt <host>.crt -out-key <host>.key
   ```

3. From Obiwan, edit the relevant encrypted secrets file with
   `sops secrets/<host>.yaml`. Replace `nebula/host-key` and
   `nebula/host-cert` with the new key and certificate. Leave
   `nebula/ca-cert` unchanged. The files are `secrets/tarkin.yaml`,
   `secrets/chewie.yaml`, and `secrets/obiwan.yaml`; Obiwan holds all Age keys.
4. Deploy the host:

   ```sh
   AWS_PROFILE=homelab-deployment nixdeploy tarkin
   nixdeploy chewie
   sudo nixos-rebuild switch --flake .#obiwan
   ```

   Run only the command for the host whose certificate was renewed.
5. Verify the Nebula service after deployment. On every host, run
   `systemctl status nebula@tarkin.service`. Tarkin is transport- and
   discovery-only: it does not accept overlay ICMP or application traffic, so
   do not ping `172.29.217.1`. Instead, confirm Tarkin's service and UDP/4242
   listener through SSM, then verify a client-to-client path such as an
   Obiwan-to-Chewie ping or permitted application connection. Record the new
   expiry date in the password manager and calendar.

### CA rotation

1. Begin at least 90 days before the CA expiry. On the offline CA machine,
   generate a new five-year CA and keep its private key offline:

   ```sh
    nix shell nixpkgs#nebula --command nebula-cert ca -name <ca-name> -duration 43800h -out-crt ca.crt -out-key ca.key
   ```

2. Re-sign all three hosts with the new CA, using their addresses from
   `modules/nixos/globals-shared.nix`:

   ```sh
    nix shell nixpkgs#nebula --command nebula-cert sign -name tarkin -ip "172.29.217.1/24" -duration 8760h -ca-crt ca.crt -ca-key ca.key -out-crt tarkin.crt -out-key tarkin.key
    nix shell nixpkgs#nebula --command nebula-cert sign -name chewie -ip "172.29.217.10/24" -duration 8760h -ca-crt ca.crt -ca-key ca.key -out-crt chewie.crt -out-key chewie.key
    nix shell nixpkgs#nebula --command nebula-cert sign -name obiwan -ip "172.29.217.11/24" -duration 8760h -ca-crt ca.crt -ca-key ca.key -out-crt obiwan.crt -out-key obiwan.key
   ```

3. In one SOPS session from Obiwan, update `nebula/ca-cert`,
   `nebula/host-cert`, and `nebula/host-key` in all three files:
   `secrets/tarkin.yaml`, `secrets/chewie.yaml`, and `secrets/obiwan.yaml`.
   Do not put `ca.key` in Git, SOPS, AWS, or on a host.
4. Deploy Chewie and Obiwan first, then deploy Tarkin last:

   ```sh
   nixdeploy chewie
   sudo nixos-rebuild switch --flake .#obiwan
   AWS_PROFILE=homelab-deployment nixdeploy tarkin
   ```

   This is a coordinated cutover. A brief overlay disruption is expected
   because there is a single lighthouse.
5. Verify `systemctl status nebula@tarkin.service` on every host. Check
   Tarkin's UDP/4242 listener through SSM, not by sending overlay ICMP or
   application traffic to `172.29.217.1`; verify overlay connectivity between
   clients such as Obiwan and Chewie. Record the new CA and host certificate
   expiry dates in the password manager and calendar.

## References

- [AWS VPC documentation](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [Amazon EC2 instance metadata and IMDSv2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)
- [AWS Systems Manager SSH connections](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
- [NixOS Nebula options](https://search.nixos.org/options?channel=unstable&show=services.nebula.networks)
- [Nebula configuration](https://nebula.defined.net/docs/config/)
- [Nebula certificates](https://nebula.defined.net/docs/certificates/)
