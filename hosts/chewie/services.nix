{ lib, ... }:

let
  domain = "r4clette.com";
  services = {
    "2048" = { image = "alexwhen/docker-2048@sha256:4913452e5bd092db9c8b005523127b8f62821867021e23a9acb1ae0f7d2432e1"; hostPort = 9001; containerPort = 80; };
    "4096" = { image = "alexwhen/docker-2048@sha256:4913452e5bd092db9c8b005523127b8f62821867021e23a9acb1ae0f7d2432e1"; hostPort = 9002; containerPort = 80; };
  };

  mkContainers = name: s:
    lib.nameValuePair name ({
      image = s.image;
      autoStart = true;
      ports = [ "127.0.0.1:${toString s.hostPort}:${toString s.containerPort}" ];
    } // (s.extra or {}));

  renderedRoutes = lib.mapAttrsToList (k: v: ''
    @${k} host ${k}.${domain}
    handle @${k} {
      reverse_proxy 127.0.0.1:${toString v.hostPort}
    }
  '') services;

  routes = lib.concatStringsSep "\n" renderedRoutes;

in {
  virtualisation = {
    podman.enable = true;
    oci-containers = {
      backend = "podman";
      containers = lib.listToAttrs (lib.mapAttrsToList mkContainers services);
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig =
    lib.mkAfter routes;
}
