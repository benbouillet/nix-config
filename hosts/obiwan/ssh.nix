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
    "ssh/chewieViaRouter" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/chewieViaRouter.conf";
    };
    "ssh/yodaViaRouter" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/yodaViaRouter.conf";
    };
    "ssh/jellybox" = {
      owner = username;
      group = "users";
      mode = "0400";
      path = "/home/ben/.ssh/jellybox.conf";
    };
  };
}
