{ ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      ariang = (self.callPackage (self.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/a295a5c85a7218f68d4bb77c2a8defb7598235ea/pkgs/servers/web-apps/ariang/default.nix";
        sha256 = "0hcfxq7wa3rcpmda21k02hzb5718wpw8xm9v8562h6di9kb1csd2";
      }) {});
    })
  ];
}
