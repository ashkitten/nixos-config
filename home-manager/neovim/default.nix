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
          rev = "v0.2.5";
          sha256 = "001mv3q7azc5llb6iadiy9s1xpw9a23cipnqcqf0jd94pmy8f6fk";
        };
      })
    ];

    extraConfig = builtins.readFile ./init.vim;
  };
}
