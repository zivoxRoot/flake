{ ... }:

{
  services.printing.enable = true;

  # http://localhost:631

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
