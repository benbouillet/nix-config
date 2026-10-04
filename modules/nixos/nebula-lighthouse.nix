{
  lib,
  pkgs,
  ...
}:
{
  services.amazon-ssm-agent.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    trustedInterfaces = [ "lo" ];
    allowPing = false;
  };

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";
      PermitTunnel = false;
      GatewayPorts = "no";
      AllowStreamLocalForwarding = "no";
      ClientAliveInterval = 30;
      ClientAliveCountMax = 2;
    };
  };

  users.users.root.hashedPassword = "!";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgueapj7BN77sbhZ61B5VxL0sqrhr+H81OUDJibpeR2"
  ];

  systemd.tmpfiles.rules = [
    "d /run/tarkin 0700 root root -"
  ];
  systemd.services.tarkin-age-bootstrap = {
    description = "Fetch Tarkin Age identity from Secrets Manager";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "amazon-ssm-agent.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      TimeoutStartSec = "5min";
      ExecStart = pkgs.writeShellScript "tarkin-age-bootstrap" ''
        set -euo pipefail
        ${pkgs.coreutils}/bin/rm -f /run/tarkin/age-key.txt
        temporary_key=/run/tarkin/age-key.txt.tmp
        trap '${pkgs.coreutils}/bin/rm -f "$temporary_key"' EXIT
        for attempt in $(seq 1 30); do
            ${pkgs.awscli2}/bin/aws --region eu-west-3 --cli-connect-timeout 5 --cli-read-timeout 15 secretsmanager get-secret-value --secret-id tarkin-age-identity --query SecretString --output text > "$temporary_key" &&
            ${pkgs.coreutils}/bin/mv "$temporary_key" /run/tarkin/age-key.txt &&
            break
          ${pkgs.coreutils}/bin/sleep 10
        done
        ${pkgs.coreutils}/bin/chmod 0400 /run/tarkin/age-key.txt
        ${pkgs.coreutils}/bin/chown root:root /run/tarkin/age-key.txt
        ${pkgs.coreutils}/bin/test -s /run/tarkin/age-key.txt
      '';
    };
  };

  sops.useSystemdActivation = true;
  systemd.services.sops-install-secrets = {
    wantedBy = lib.mkForce [ "multi-user.target" ];
    requires = [ "tarkin-age-bootstrap.service" ];
    wants = [ "network-online.target" ];
    after = lib.mkForce [
      "network-online.target"
      "tarkin-age-bootstrap.service"
    ];
    unitConfig.DefaultDependencies = lib.mkForce "yes";
  };
  systemd.services."nebula@tarkin" = {
    requires = [ "sops-install-secrets.service" ];
    after = [ "sops-install-secrets.service" ];
  };

  services.journald.settings.Journal.Storage = "volatile";
}
