{ username, ... }: {
  users.groups.plugdev = { };

  users.users.${username}.extraGroups = [
    "plugdev"
    "dialout"
  ];

  # DFU bootloader access for STM32 and AT32/BetaFPV flight controllers
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", MODE="0664", GROUP="plugdev"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="plugdev"
  '';
}
