{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";

    shellAliases = {
      ls = "eza -gF --hyperlink";
      icat = "kitty +icat";
    };

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 100000;
      share = false;
    };

    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }
    ];

    initExtraBeforeCompInit = ''
      # Allows commands like sudo to gain privileges for completion
      zstyle ":completion:*" gain-privileges true
      # Keep the prefix when completing (~/f expands to ~/foo instead of /home/user/foo)
      zstyle ":completion:*" keep-prefix true
      # Completion colors
      zstyle ":completion:*" list-colors "=^(-- *)=32=37"
      # Use a menu style selector if it's very long
      zstyle ":completion:*" menu select=long
      # Don't change the prefix if it's in this format
      zstyle ":completion:*" preserve-prefix "//[^/]##/"
      # Multiple slashes mean the same as one
      zstyle ":completion:*" squeeze-slashes true
      # Match first nothing, then lowercase = uppercase, then they match each other
      zstyle ":completion:*" matcher-list "" "m:{[:lower:]}={[:upper:]}" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}"
      # Completion name format
      zstyle ":completion:*" format "%B%F{cyan}Completing %d%f%b"
      # Add space after an in-word completion
      zstyle ":completion:*" add-space true
      # Completions
      zstyle ":completion:*" completer _complete _match
      zstyle ":completion:*:match:*" original only
      # Don't match stuff like _foo if only foo is typed
      zstyle ":completion:*:functions" prefix-needed true
    '';

    initExtra = ''
      setopt append_history
      setopt inc_append_history
      setopt bang_hist
      setopt hist_find_no_dups
      setopt hist_verify

      setopt no_match
      setopt notify
      setopt no_beep
      setopt no_menu_complete
      setopt correct
      setopt dvorak

      ${builtins.readFile ./vimmode.zsh}

      ${builtins.readFile ./prompt.zsh}

      ${builtins.readFile ./functions.zsh}
    '';
  };

  # programs.mcfly = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   keyScheme = "vim";
  # };
}
