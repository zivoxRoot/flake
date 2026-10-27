{
  description = "My flake";

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    claude-desktop.url = "github:tomsch/claude-desktop-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      disko,
      impermanence,
      nixos-raspberrypi,
      claude-desktop,
      ...
    }@inputs:
    let
      vars = import ./variables.nix;
    in
    {
      nixosConfigurations.${vars.hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit vars;
        };
        modules = [
          { environment.systemPackages = [ claude-desktop.packages.x86_64-linux.default ]; }
          sops-nix.nixosModules.sops
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          ./hosts/laptop/default.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit inputs;
                inherit vars;
              };

              users.${vars.username} = import ./home/default.nix;

              backupFileExtension = "backup";
            };
          }
        ];
      };

      nixosConfigurations.${vars.piHostname} = nixos-raspberrypi.lib.nixosSystem {
        specialArgs = { inherit inputs nixos-raspberrypi vars; };
        modules = [
          sops-nix.nixosModules.sops
          inputs.disko.nixosModules.disko
          ({ nixos-raspberrypi, ... }: {
            imports = with nixos-raspberrypi.nixosModules; [
              raspberry-pi-5.base
            ];
          })
          ./hosts/pi
        ];
      };
    };
}
