function ztv
    # 1. Get the list of sessions (short names)
    # 2. Pipe into television for fuzzy picking
    set -l session (zellij list-sessions -s | tv)

    # If a session was selected (and not cancelled with ESC)
    if test -n "$session"
        # If inside Zellij, kill the current client connection and swap
        if set -q ZELLIJ
            # This exits the current session and immediately attaches to the new one
            exec zellij attach "$session"
        else
            zellij attach "$session"
        end
    end
end
function fish_user_key_bindings
    # Bind Ctrl+S to forward-char
    bind \cs ztv
end
tv init fish | source
