{
  lib,
  config,
  globals,
  pkgs,
  ...
}:
let
  litellmConfig = pkgs.writeText "litellm-config.yaml" ''
    general_settings:
      disable_env_credential_login: true
      store_model_in_db: false
      store_prompts_in_spend_logs: true
      user_api_key_cache_ttl: 300
      alerting_args:
        outage_alert_ttl: 1800

    litellm_settings:
      request_timeout: 1800
      keepalive_seconds: 15
      callbacks: ["smtp_email"]
      drop_params: true
      json_logs: true
      enable_redis_auth_cache: true
      cache: true
      cache_params:
        type: redis
        host: os.environ/REDIS_HOST
        port: os.environ/REDIS_PORT
        password: os.environ/REDIS_PASSWORD
        namespace: "litellm.caching"

    model_list:
      - model_name: qwen3.8:27b
        litellm_params:
          model: llama-cpp/qwen3.8:27b
          api_base: https://ai.${globals.domain}/v1
          api_key: foo
        model_info:
          max_input_tokens: 128000

      - model_name: gemma4-26b-instruct
        litellm_params:
          model: llama-cpp/gemma4-26b-instruct
          api_base: https://ai.${globals.domain}/v1
          api_key: foo
        model_info:
          max_input_tokens: 128000
  '';
in
{
  sops.secrets."services/litellm/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  services = {
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = lib.mkAfter [
        "litellm"
      ];
      ensureUsers = lib.mkAfter [
        {
          name = "litellm";
          ensureDBOwnership = true;
          ensureClauses = {
            createrole = true;
            createdb = true;
            connection_limit = 20;
          };
        }
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    "litellm" = {
      image = "docker.litellm.ai/berriai/litellm:v1.103.3@sha256:e6e1c46cec92ab58b7ff95c790420aba9f05269b662a66c0dd11714171b9c64b";
      ports = [
        "${globals.hosts.chewie.tailscale}:${toString globals.ports.litellm}:4000"
      ];
      volumes = [
        "${litellmConfig}:/app/config.yaml:ro"
      ];
      environment = {
        PROXY_BASE_URL = "https://litellm.${globals.domain}";
        REDIS_HOST = "host.containers.internal";
        REDIS_PORT = toString globals.ports.redis;
        SMTP_HOST = "smtp.protonmail.ch";
        SMTP_TLS = "True";
        SMTP_PORT = "587";
        SMTP_SENDER_EMAIL = "admin@${globals.domain}";
        SMTP_USERNAME = "admin@${globals.domain}";
      };
      environmentFiles = [ config.sops.secrets."services/litellm/env".path ];
      extraOptions = [
        "--memory=2g"
      ];
      cmd = [
        "--config"
        "/app/config.yaml"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "litellm.${globals.domain}";
        resources = [ "^/ui(?:/.*)?(?:\\?.*)?$" ];
        policy = "one_factor";
        subject = "group:admins";
      }
    ];

    identity_providers.oidc.cors.allowed_origins = [
      "https://litellm.${globals.domain}"
    ];

  };

  systemd.services."podman-litellm" = {
    after = [
      "postgresql.service"
    ];
    requires = [
      "postgresql.service"
    ];
  };

}
