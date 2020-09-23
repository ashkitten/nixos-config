{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      colorizer
      deoplete-nvim
      editorconfig-vim
      goyo-vim
      lightline-vim
      neomake
      nerdtree
      onedark-vim
      supertab
      vim-better-whitespace
      vim-polyglot
      vim-tmux-navigator

      (pkgs.vimUtils.buildVimPluginFrom2Nix {
        name = "firenvim";
        src = pkgs.fetchFromGitHub {
          owner = "glacambre";
          repo = "firenvim";
          rev = "v0.1.31";
          sha256 = "10lww25ki7fd40bhsmvrpksg6gjhl68bsykkjs9w5wg2148nf5fn";
        };
      })
    ];

    extraConfig = builtins.readFile ./init.vim;
  };
}
