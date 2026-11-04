{
  lib,
  config,
  globals,
  ...
}:
{
  sops.secrets."services/paperless/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/paperless 2770 1000 1000 - -"
  ];

  services = {
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = lib.mkAfter [
        "paperless"
      ];
      ensureUsers = lib.mkAfter [
        {
          name = "paperless";
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
    "paperless" = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:3.4.2@sha256:d704e84f88300eb6ab001ab15720a2330ff99169cf9f94d6b8fcc44b63a84c84";
      ports = [
        "${globals.hosts.chewie.tailscale}:${toString globals.ports.paperless}:8000"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/paperless:/usr/src/paperless/data:rw"
        "${globals.zfs.data.paperless.mountPoint}:/usr/src/paperless/media:rw"
        "paperless-consume:/usr/src/paperless/consume:rw"
      ];
      environment = {
        PAPERLESS_REDIS_PREFIX = "paperless";
        PAPERLESS_DBHOST = "database";
        PAPERLESS_DBPORT = toString globals.ports.postgres;
        PAPERLESS_DBENGINE = "postgresql";
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_URL = "https://paperless.${globals.domain}";
        PAPERLESS_ADMIN_USER = "ben";
        PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = "false";
        PAPERLESS_OCR_LANGUAGE = "fra+eng";
        PAPERLESS_AI_ENABLED = "true";
        PAPERLESS_AI_LLM_BACKEND = "openai-like";
        PAPERLESS_AI_LLM_MODEL = "qwen3.8:27b";
        PAPERLESS_AI_LLM_ENDPOINT = "https://ai.r4clette.com/v1";
        PAPERLESS_AI_LLM_API_KEY = "foo";
        PAPERLESS_AI_LLM_OUTPUT_LANGUAGE = "fra+eng";
        # PAPERLESS_AI_LLM_EMBEDDING_BACKEND = "openai-like";
        # PAPERLESS_AI_LLM_EMBEDDING_MODEL = "qwen3-embedding-4b";
        # PAPERLESS_AI_LLM_EMBEDDING_ENDPOINT = "https://ai.r4clette.com/v1";
      };
      environmentFiles = [ config.sops.secrets."services/paperless/env".path ];
      extraOptions = [
        "--memory=6144m"
        "--pids-limit=64"
        "--add-host=database:host-gateway"
      ];
    };
  };

  systemd.services."podman-paperless" = {
    after = [
      "postgresql.service"
      "redis-raclette.service"
    ];
    requires = [
      "postgresql.service"
      "redis-raclette.service"
    ];
  };

}
