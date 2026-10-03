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
    "ssh/chewie-alt" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/chewie-alt.conf";
    };
    "ssh/yoda-alt" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/yoda-alt.conf";
    };
    "ssh/tarkin" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/tarkin.conf";
    };
  };
}
