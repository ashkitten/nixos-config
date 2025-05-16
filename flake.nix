{
  inputs = {
    nixpkgs.url = "github:ashkitten/nixpkgs";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, colmena, impermanence, sops-nix, home-manager,  ... }: {
    nixosConfigurations = {
      boson = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          nixpkgs.nixosModules.notDetected
          home-manager.nixosModules.home-manager
          ./common.nix
          ./devices/boson
        ];
      };
    };

    colmena = {
      meta.nixpkgs = import nixpkgs { system = "x86_64-linux"; };
    } // builtins.mapAttrs (name: value: {
      nixpkgs.system = value.config.nixpkgs.system;
      imports = value._module.args.modules;
    }) (self.nixosConfigurations);

    devShells."x86_64-linux".default = import ./shell.nix {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    };
  };
}
