{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      colorizer
      editorconfig-vim
      goyo-vim
      lightline-vim
      neomake
      nerdtree
      onedark-vim
      vim-better-whitespace
      vim-polyglot
      vim-tmux-navigator
      nvim-lspconfig
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      nvim-cmp
      cmp-vsnip
      vim-vsnip

      (pkgs.vimUtils.buildVimPluginFrom2Nix rec {
        pname = "firenvim";
        version = "0.2.5";
        src = pkgs.fetchFromGitHub {
          owner = "glacambre";
          repo = "firenvim";
          rev = "v${version}";
          sha256 = "001mv3q7azc5llb6iadiy9s1xpw9a23cipnqcqf0jd94pmy8f6fk";
        };
      })
    ];

    extraConfig = builtins.readFile ./init.vim;
  };
}
