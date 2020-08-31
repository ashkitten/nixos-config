bindkey -v

KEYTIMEOUT=1

function history-incremental-search-backward-buf {
    zle history-incremental-search-backward $BUFFER
}
zle -N history-incremental-search-backward-buf
bindkey -M vicmd '/' history-incremental-search-backward-buf

bindkey -M viins "^[[H" beginning-of-line
bindkey -M viins "^[[F" end-of-line

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

WORDCHARS='_'

function vi-backward-delete-char vi-backward-kill-word {
    zle ${funcstack[1]:s/vi-//}
}
zle -N vi-backward-delete-char
zle -N vi-backward-kill-word
