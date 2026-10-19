{ ... }:

{
  services.openssh.enable = true;
  programs.ssh.extraConfig = "UpdateHostKeys no";
}
