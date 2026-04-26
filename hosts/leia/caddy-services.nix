{ globals, lib, ... }:
{
  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    # From modules/nixos/observability/prometheus.nix

    @prometheus host prometheus.${globals.domain}
    handle @prometheus {
      reverse_proxy localhost:${toString globals.ports.prometheus}
    }

    @alertmanager host alerts.${globals.domain}
    handle @alertmanager {
      reverse_proxy localhost:${toString globals.ports.prometheus-alertmanager}
    }

    # From modules/nixos/services/ai.nix

    @llama-cpp host llama-cpp.${globals.domain}
    handle @llama-cpp {
      reverse_proxy chewie:${toString globals.ports.llama-cpp}
    }

    # From modules/nixos/observability/grafana.nix

    @grafana host grafana.${globals.domain}
    handle @grafana {
      reverse_proxy localhost:${toString globals.ports.grafana}
    }

    # From modules/nixos/services/vaultwarden.nix

    @vault host vault.${globals.domain}
    handle @vault {
      reverse_proxy chewie:${toString globals.ports.vaultwarden}
    }

    # From modules/nixos/services/radicale.nix

    @contacts host contacts.${globals.domain}
    handle @contacts {
      reverse_proxy chewie:${toString globals.ports.radicale}
    }

    # From modules/nixos/services/immich.nix

    @images host images.${globals.domain}

    # API + machine endpoints: NO forward_auth (mobile needs these)
    @immich_api {
      host images.${globals.domain}
      path /api/* /.well-known/immich
    }

    handle @immich_api {
      reverse_proxy chewie:${toString globals.ports.immich}
    }

    # Everything else (web UI): protect with Authelia
    handle @images {
      forward_auth http://chewie:${toString globals.ports.authelia} {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy chewie:${toString globals.ports.immich}
    }

    # From modules/nixos/services/ntfy.nix

    @ntfy host ntfy.${globals.domain}
    handle @ntfy {
      reverse_proxy localhost:${toString globals.ports.ntfy}
    }

    # From modules/nixos/services/containers/paperless.nix

    @docs host paperless.${globals.domain}
    handle @docs {
      reverse_proxy chewie:${toString globals.ports.paperless}
    }

    # From modules/nixos/services/containers/seafile.nix

    @seafile host seafile.${globals.domain}
    handle @seafile {
      @notif path /notification*
      handle @notif {
        reverse_proxy chewie:${toString globals.ports.seafile-notification-server}
      }

      @api path /api2/* /api/v2.1/* /seafhttp* /seafdav*
      handle @api {
        reverse_proxy chewie:${toString globals.ports.seafile}
      }

      handle {
        forward_auth http://chewie:${toString globals.ports.authelia} {
          uri /api/authz/forward-auth
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
        }

        reverse_proxy chewie:${toString globals.ports.seafile}
      }
    }

    # From modules/nixos/services/containers/mealie.nix

    @mealie host mealie.${globals.domain}
    handle @mealie {
      reverse_proxy chewie:${toString globals.ports.mealie}
    }

    # From modules/nixos/services/containers/search.nix

    @searxng host search.${globals.domain}
    handle @searxng {
      reverse_proxy chewie:${toString globals.ports.searxng}
    }

    # From modules/nixos/services/containers/linkding.nix

    @linkding host links.${globals.domain}
    handle @linkding {
      reverse_proxy chewie:${toString globals.ports.linkding}
    }

    # From modules/nixos/services/containers/foundryvtt.nix

    @foundryvtt host dnd.${globals.domain}
    handle @foundryvtt {
      reverse_proxy chewie:${toString globals.ports.foundryvtt}
    }

    # From modules/nixos/services/containers/arr.nix

    # Health routes
    @sonarr_ping {
      host sonarr.${globals.domain}
      path /ping
    }
    handle @sonarr_ping {
      reverse_proxy chewie:${toString globals.ports.sonarr}
    }

    @radarr_ping {
      host radarr.${globals.domain}
      path /ping
    }
    handle @radarr_ping {
      reverse_proxy chewie:${toString globals.ports.radarr}
    }

    @qbittorrent_ping {
      host qbittorrent.${globals.domain}
      path /api/v2/app/version
    }
    handle @qbittorrent_ping {
      reverse_proxy chewie:${toString globals.ports.qbittorrent}
    }

    # App behind OIDC
    @qbittorrent host qbittorrent.${globals.domain}
    handle @qbittorrent {
      forward_auth http://chewie:${toString globals.ports.authelia} {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy chewie:${toString globals.ports.qbittorrent}
    }

    @nzbget host nzbget.${globals.domain}
    handle @nzbget {
      forward_auth http://chewie:${toString globals.ports.authelia} {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy chewie:${toString globals.ports.nzbget}
    }

    @bazarr host bazarr.${globals.domain}
    handle @bazarr {
      forward_auth http://chewie:${toString globals.ports.authelia} {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy chewie:${toString globals.ports.bazarr}
    }

    @prowlarr host prowlarr.${globals.domain}
    handle @prowlarr {
      forward_auth http://chewie:${toString globals.ports.authelia} {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy chewie:${toString globals.ports.prowlarr}
    }

    @radarr host radarr.${globals.domain}
    handle @radarr {
      forward_auth http://chewie:${toString globals.ports.authelia} {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy chewie:${toString globals.ports.radarr}
    }

    @sonarr host sonarr.${globals.domain}
    handle @sonarr {
      forward_auth http://chewie:${toString globals.ports.authelia} {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy chewie:${toString globals.ports.sonarr}
    }

    # Available on tailnet
    @seerr host seerr.${globals.domain}
    handle @seerr {
      reverse_proxy chewie:${toString globals.ports.seerr}
    }

    @jellyfin host jellyfin.${globals.domain}
    handle @jellyfin {
      reverse_proxy chewie:${toString globals.ports.jellyfin}
    }

    # From modules/nixos/services/containers/lubelogger.nix

    @lubelogger host lubelogger.${globals.domain}
    handle @lubelogger {
      reverse_proxy chewie:${toString globals.ports.lubelogger}
    }
      # From modules/nixos/services/authentication.nix
    @auth host auth.${globals.domain}
    handle @auth {
      reverse_proxy chewie:${toString globals.ports.authelia}
    }
  '';
}
