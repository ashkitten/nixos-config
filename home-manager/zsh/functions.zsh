# Copy the given file to clipboard, or standard input if none is given
function c {
    wl-copy < ${1:-/dev/stdin}
}

# Paste the clipboard to stdout or a file
function v {
    wl-paste > ${1:-/dev/stdout}
}

function ssh {
    [[ $TERM = "xterm-kitty" ]] && TERM=xterm-256color
    command ssh $@
}
