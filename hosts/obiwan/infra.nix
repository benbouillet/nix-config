{ config, ... }:
{
  sops.secrets = {
    "infra/aws_account_id" = { };
    "infra/tfstate_bucket" = { };
    "infra/tfstate_region" = { };
    "infra/ssh_public_key" = { };
  };

  sops.templates = {
    tarkin-backend = {
      content = ''
        bucket       = "${config.sops.placeholder."infra/tfstate_bucket"}"
        key          = "infrastructure/terraform.tfstate"
        region       = "${config.sops.placeholder."infra/tfstate_region"}"
        profile      = "homelab-deployment"
        use_lockfile = true
      '';
      owner = "ben";
      mode = "0400";
    };
    tarkin-tfvars = {
      content = ''
        {
          "aws_account_id": "${config.sops.placeholder."infra/aws_account_id"}",
          "ssh_public_key": "${config.sops.placeholder."infra/ssh_public_key"}",
          "create_instance": true
        }
      '';
      owner = "ben";
      mode = "0400";
    };
  };
}
