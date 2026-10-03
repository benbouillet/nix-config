{ config, ... }:
{
  sops.secrets = {
    "tarkin/aws_account_id" = { };
    "tarkin/tfstate_bucket" = { };
    "tarkin/tfstate_region" = { };
    "tarkin/ssh_public_key" = { };
  };

  sops.templates = {
    tarkin-backend = {
      content = ''
        bucket       = "${config.sops.placeholder."tarkin/tfstate_bucket"}"
        key          = "infrastructure/terraform.tfstate"
        region       = "${config.sops.placeholder."tarkin/tfstate_region"}"
        profile      = "homelab-deployment"
        use_lockfile = true
      '';
      owner = "ben";
      mode = "0400";
    };
    tarkin-tfvars = {
      content = ''
        {
          "aws_account_id": "${config.sops.placeholder."tarkin/aws_account_id"}",
          "ssh_public_key": "${config.sops.placeholder."tarkin/ssh_public_key"}",
          "create_instance": true
        }
      '';
      owner = "ben";
      mode = "0400";
    };
  };
}
