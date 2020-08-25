{ nodes ? [] }:

let
  # dummy config file for evaluation
  nixosConfig = builtins.toFile "configuration.nix" ''
    { nixpkgs.config.allowUnfree = true; }
  '';
in
  import ./external/nixus {} {
    defaults = { name, lib, ... }: {
      enabled = if nodes == [] then true else lib.elem name nodes;

      nixpkgs = ./external/nixpkgs;

      successTimeout = 120;
      switchTimeout = 240;
      ignoreFailingSystemdUnits = true;

      configuration = {
        imports = [
          ./common.nix
          ./external/home-manager/nixos
        ];

        nix.nixPath = [
          "nixos-config=${nixosConfig}"
          "nixpkgs=${./external/nixpkgs}"
        ];

        secrets.files = import ./external/secrets;
      };
    };

    nodes = {
      steve = {
        host = "root@10.100.0.1";
        configuration = ./devices/steve;
      };

      boson = {
        host = "root@10.100.0.2";
        configuration = ./devices/boson;
      };

      fucko = {
        host = "root@10.100.0.3";
        configuration = ./devices/fucko;
      };

      # 10.100.0.4 reserved for mclargehuge

      bugreport = {
        host = "root@10.100.0.5";
        configuration = ./devices/bugreport;
      };
    };
  }
