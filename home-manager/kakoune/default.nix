{ pkgs, ... }:

{
  programs.kakoune = {
    enable = true;

    plugins = let
      smarttab-kak = pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
        pname = "smarttab-kak";
        version = "2021-02-24";
        src = pkgs.fetchFromGitHub {
          owner = "andreyorst";
          repo = "smarttab.kak";
          rev = "1dd3f33c4f65da5c13aee5d44b2e77399595830f";
          sha256 = "0g49k47ggppng95nwanv2rqmcfsjsgy3z1764wrl5b49h9wifhg2";
        };
        meta.homepage = "https://github.com/andreyorst/smarttab.kak/";
      };
    in with pkgs.kakounePlugins; [
      kak-lsp
      powerline-kak
      sleuth-kak
      smarttab-kak
    ];

    extraConfig = builtins.readFile ./kakrc;
  };
}
