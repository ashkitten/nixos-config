{ nodes ? [] }:

import ./external/nixoses {
  imports = [
    ./external/secrets
  ];

  defaults = { name, lib, ... }: {
    enabled = if nodes == [] then true else lib.elem name nodes;

    nixpkgs = ./external/nixpkgs;

    configuration = {
      imports = [
        ./common.nix
        ./external/home-manager/nixos
      ];

      nix.nixPath = [
        "nixpkgs=${./external/nixpkgs}"
      ];
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
  };
}
