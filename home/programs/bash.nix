{ vars, ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/flake/";
      pinrs = "nixos-rebuild switch --flake ~/flake#pi --target-host ${vars.username}@${vars.piAddress} --build-host ${vars.username}@${vars.piAddress} --sudo --ask-sudo-password";
      pissh = "ssh ${vars.username}@${vars.piAddress}";
    };
  };
}
