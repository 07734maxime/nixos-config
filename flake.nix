{
  description = "My NixOS Config!! With flake now";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		noctalia.url = "github:noctalia-dev/noctalia";

    nixvim = {
			url = "github:nix-community/nixvim";
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

  outputs = { self, nixpkgs, lanzaboote, home-manager, nur, nixvim,  ... }@inputs: {
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
          home-manager.users.hello = import ./home/default.nix;
	  home-manager.sharedModules = [
						nixvim.homeModules.nixvim
						inputs.noctalia.homeModules.default
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
