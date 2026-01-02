{
  username,
  ...
}:
{
  sops.secrets = {
    "ssh/chewie" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/chewie.conf";
    };
    "ssh/jellybox" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/jellybox.conf";
    };
  };
}
