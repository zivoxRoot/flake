{
  pkgs,
  lib,
  vars,
  ...
}:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For ddcutil to manage brightness on external monitor
  boot.kernelModules = [ "i2c-dev" ];
  hardware.i2c.enable = true;
  users.users.${vars.username}.extraGroups = [ "i2c" ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Plymouth
  boot = {
    plymouth = {
      enable = true;
      theme = lib.mkForce vars.bootAnimation;
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ vars.bootAnimation ];
        })
      ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quit"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

    loader.timeout = 0;
  };
}
