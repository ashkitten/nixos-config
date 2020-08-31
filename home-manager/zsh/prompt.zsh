autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' get-unapplied true
zstyle ':vcs_info:git*' unstagedstr ' *'
zstyle ':vcs_info:git*' stagedstr ' ⇡'
zstyle ':vcs_info:git*' formats '%F{magenta}%b%i%u%c'
zstyle ':vcs_info:git*' actionformats '%F{yellow}%b (%a) %m%u%c'

function zle-line-init zle-keymap-select {
  case $KEYMAP in
    viins|main)
        printf '\e[6 q' # line cursor
        vim_mode='%F{cyan}[I]%f'
        ;;
    vicmd)
        printf '\e[2 q' # block cursor
        vim_mode='%F{green}[C]%f'
        ;;
  esac

  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# Do command substitutions and stuff on the prompt
setopt prompt_subst

precmd() {
    local EDIT_SYM='*'
    local PUSH_SYM='↑'
    local PULL_SYM='↓'

    vcs_info
}

PROMPT='%F{magenta}%n@%m %F{cyan}%~ ${vcs_info_msg_0_}%f
${vim_mode} %(?.%F{green}.%F{red})%(!.#.$)%f%k%b '
RPROMPT='%F{red}${ANY_NIX_SHELL_PKGS}%f'
