{ vars, ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/flake/";
      pinrs = "nixos-rebuild switch --flake ~/flake#pi --target-host ${vars.username}@192.168.10.112 --build-host ${vars.username}@192.168.10.112 --sudo --ask-sudo-password";
      pissh = "ssh ${vars.username}@192.168.10.112";
    };
  };
}
