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
          rev = "v0.1.30";
          sha256 = "090g5vymc12iwc1b34pg0b0xg44x33m8lb6by8xg08y902d2pwd5";
        };
      })
    ];

    extraConfig = builtins.readFile ./init.vim;
  };
}
