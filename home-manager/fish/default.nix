{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      ls = "exa -gF";
      icat = "kitty +icat";
    };

    interactiveShellInit = ''
      fish_vi_key_bindings
    '';
    
    functions = {
      fish_prompt = ''
        echo    "$(set_color magenta)$USER@$hostname $(prompt_pwd) $(fish_vcs_prompt)"
        echo -n "$(fish_default_mode_prompt | string trim)$(set_color yellow) \$ "
      '';
      
      fish_mode_prompt = "";
    };
  };
}
