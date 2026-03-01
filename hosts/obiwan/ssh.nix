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
    "ssh/yoda" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/yoda.conf";
    };
    "ssh/chewie-local" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/chewie-local.conf";
    };
    "ssh/yoda-local" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/yoda-local.conf";
    };
    "ssh/jellybox" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/jellybox.conf";
    };
  };
}
