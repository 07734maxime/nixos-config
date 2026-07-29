{
  description = "My NixOS Config!! With flake now";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = {
    self,
    nixpkgs,
    lanzaboote,
    home-manager,
    nur,
    nixvim,
    nix-vscode-extensions,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix

        {
          nix.settings = {
            substituters = ["https://niri-nix.cachix.org"];
            trusted-public-keys = [
              "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
            ];
          };
        }

        {
          nixpkgs.overlays = [
            nix-vscode-extensions.overlays.default
            ];
        }
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
          home-manager.users.hello = import ./home/default.nix;
          home-manager.sharedModules = [
            nixvim.homeModules.nixvim
          ];
        }
        {
          nixpkgs.config.packageOverrides = pkgs: {
            nur = import nur {
              inherit pkgs;
              nurpkgs = pkgs;
            };
          };
        }
      ];
    };
  };
}
