{
  description = "NixOS Flakes config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      # On force HM à suivre la même version de nixpkgs que ton système
      inputs.nixpkgs.follows = "nixpkgs";
    }; 

  };

  outputs = { self, nixpkgs, lanzaboote, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        lanzaboote.nixosModules.lanzaboote
	home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.hello = import ./home.nix;
        }
      ];
    };
  };
}
