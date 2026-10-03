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
  public UDP/4242 transport only. The instance uses HTTPS for SSM and AWS
  Secrets Manager and VPC DNS for its runtime dependencies.
- **SSM SSH transport:** the `ssh/tarkin` value in Obiwan's encrypted SOPS
  file is an SSH configuration snippet. It targets the EC2 instance ID, uses
  `User root`, `IdentityFile ~/.ssh/id_ed25519`, and
  `AWS-StartSSHSession` as `ProxyCommand`; it contains no SSH private key.
  This is the only management path.
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
- **Root SSH key:** the Terraform EC2 key pair is intentional and permanent.
  Its public key is the same key declared in `modules/nixos/tarkin.nix` and
  `infra/tarkin/terraform.tfvars`. The matching private key remains only at
  the operator's `~/.ssh/id_ed25519`; it is never stored in Terraform, Nix,
  SOPS, AWS, or this repository.

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
    Update its `HostName` to `$INSTANCE`, set `User root` and
    `IdentityFile ~/.ssh/id_ed25519`, and retain the `AWS-StartSSHSession`
    proxy configuration. The value is SSH configuration, not a place for an
     SSH private key. If the obsolete encrypted `ssh/tarkin-bootstrap` entry is
     still present, remove it in this same SOPS edit; do not copy its private
     key anywhere.

    The repository intentionally does not modify encrypted SSH configuration
    values. The operator must make this SOPS edit manually before deploying
    Obiwan. The required final snippet is equivalent to:

    ```sshconfig
    Host tarkin
      HostName i-NEW_INSTANCE_ID
      User root
      IdentityFile ~/.ssh/id_ed25519
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
   - Root-only access over SSM SSH works after the reboot, using the local
     `~/.ssh/id_ed25519` private key.
   - The Age identity is retrieved from Secrets Manager, SOPS decrypts the
     three Nebula artifacts, and Nebula is active at `172.29.217.1`.
   - Public TCP/22 is absent and public UDP/4242 is the only intended inbound
     service; SSH over Nebula does not work.
   - The generic AMI root key and the declared NixOS root key are the same
     public key, so no separate generic-key cleanup or key-finalization service
     is required. Verify that password, keyboard-interactive authentication,
     forwarding, and public TCP/22 remain disabled.

The current EC2 can be trashed and replaced only after this configuration has
passed local validation. Replacement is expected to produce a new instance
ID: update the encrypted `ssh/tarkin` SOPS snippet to that ID, deploy Obiwan,
then use `ssh tarkin` and `nixdeploy tarkin` to configure and verify the new
instance. No AWS mutation is part of local validation.

## Certificate maintenance

The Nebula v2 CA lifetime is 5 years and the lighthouse certificate lifetime
is 1 year. Record the exact expiry date of each issued certificate in the
operator password manager and calendar. Renew the lighthouse certificate at
least 30 days before expiry. Begin CA replacement and coordinated client
migration at least 90 days before CA expiry; CA replacement requires reissuing
the affected host certificates and distributing the replacement CA certificate.

## References

- [AWS VPC documentation](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [Amazon EC2 instance metadata and IMDSv2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)
- [AWS Systems Manager SSH connections](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
- [NixOS Nebula options](https://search.nixos.org/options?channel=unstable&show=services.nebula.networks)
- [Nebula configuration](https://nebula.defined.net/docs/config/)
- [Nebula certificates](https://nebula.defined.net/docs/certificates/)
