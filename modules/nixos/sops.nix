{
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  };
}
