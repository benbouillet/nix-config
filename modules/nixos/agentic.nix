{ username, ... }:
{
  sops.secrets."applications/pi/authJson" = {
    owner = username;
    group = "users";
    mode = "0400";
    path = "/home/ben/.pi/agent/auth.json";
  };
}
