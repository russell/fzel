FZEL_PATH=${0:a:h}

__fzelcmd() {
    [ -n "$TMUX_PANE" ] && { [ "${FZEL_TMUX:-0}" != 0 ] || [ -n "$FZEL_TMUX_OPTS" ]; } &&
        echo "$FZEL_PATH/bin/tmux-panel ${FZEL_TMUX_OPTS:--d${FZEL_TMUX_HEIGHT:-40%}} -- " || echo ""
}

fzel-history-widget() {
    local selected num history_file chosen_item_file
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

    history_file=$(mktemp /tmp/history.XXXXXX)
    chosen_item_file=$(mktemp /tmp/chosen.XXXXXX)

    (fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\s+(.*)/, $1)}++' > $history_file)

    $(__fzelcmd) emacs --load $FZEL_PATH/history.el -nw -q --eval "(progn (fzel-file-candidates \"$history_file\") (helm-fzel-completion \"$chosen_item_file\") (kill-emacs))" </dev/tty
    local ret=$?

    selected=$(cat $chosen_item_file)
    rm $chosen_item_file $history_file
    if [ -n "$selected" ]; then
        zle vi-fetch-history -n $selected
    fi
    zle reset-prompt
    return $ret
}

zle     -N   fzel-history-widget
bindkey '^R' fzel-history-widget
