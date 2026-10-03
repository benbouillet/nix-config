{ pkgs }:

pkgs.writeShellScriptBin "aws-creds-exporter" ''
  aws_sso_export() {
    profile_name=$1

    aws configure export-credentials --profile "''${profile_name}" --format env || (aws sso login --profile "''${profile_name}" && aws configure export-credentials --profile "''${profile_name}" --format env)
  }

  aws_sso_export "$@"
''
