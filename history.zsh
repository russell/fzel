FZEL_PATH=${0:a:h}
FZEL_GUI="${FZEL_GUI:--nw}"

__fzelcmd() {
    [ -n "$TMUX_PANE" ] && { [ "${FZEL_TMUX:-0}" != 0 ] || [ -n "$FZEL_TMUX_OPTS" ]; } &&
        echo "$FZEL_PATH/bin/tmux-panel ${FZEL_TMUX_OPTS:--d${FZEL_TMUX_HEIGHT:-40%}} -- " || echo ""
}

__fzelload() {
    [ -e "$FZEL_PATH" ] &&
        echo "--dump-file $FZEL_PATH/fzel.emacs" || echo "--load $FZEL_PATH/fzel-init.el"
}

fzel-history-widget() {
    local selected num history_file chosen_item_file
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

    history_file=$(mktemp /tmp/history.XXXXXX)
    chosen_item_file=$(mktemp /tmp/chosen.XXXXXX)

    (fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\s+(.*)/, $1)}++' > $history_file)

    $(__fzelcmd) emacs $(__fzelload) $FZEL_GUI -q --eval "(progn (load-file \"$FZEL_PATH/fzel-history.el\") (fzel-history \"$history_file\" \"$chosen_item_file\"))" </dev/tty
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
