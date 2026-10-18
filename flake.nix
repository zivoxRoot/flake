{
  description = "My flake";

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

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:tomsch/claude-desktop-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

	sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      claude-desktop,
	  sops-nix,
      ...
    }@inputs:
    let
      vars = import ./variables.nix;
    in
    {
      nixosConfigurations.${vars.username} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit vars;
        };
        modules = [
          { environment.systemPackages = [ claude-desktop.packages.x86_64-linux.default ]; }
          stylix.nixosModules.stylix
		  sops-nix.nixosModules.sops
          ./hosts/thinkpad-t470/default.nix

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
    };
}
