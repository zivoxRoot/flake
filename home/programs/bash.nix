{... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/flake/";
    };
  };
}
