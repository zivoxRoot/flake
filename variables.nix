{
  username = "theophile";
  hostname = "nixos";

  # Git
  gitUsername = "zivoxRoot";
  gitEmail = "theophiledefeche@ik.me";
  sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEO7hNh4LRf3uxe2CPUD6EW32frhQJ35YDUj/TInbJE4 theophiledefeche@ik.me";

  # Theme
  wallpaper = ./wallpaper.png;
  theme = "catppuccin";
  # Possible theme values:
  # catppuccin gruvbox gruvbox-material
  # rose-pine tokyo-night solarized
  # nord one ayu
  # flexoki selenized papercolor
  # primer edge oxocarbon
  bootAnimation = "lone";
  # Possible themes: https://github.com/adi1090x/plymouth-themes

  # PI
  piHostname = "pi";
  piAddress = "pi";

  # Do NOT touch
  stateVersion = "26.05";
}
