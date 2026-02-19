# Fish functions
# This file defines custom fish functions

# Tmux functions
function tn --description "Create new tmux session"
    tmux new -s $argv[1]
end

function ta --description "Attach to tmux session"
    tmux attach -t $argv[1]
end

# Yazi function - cd on exit
function y --description "Yazi file manager with cd on exit"
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# FZF functions
function of --description "Open file with fzf"
    open (fzf) $argv
end

function nf --description "Open file in nvim with fzf"
    nvim (fzf) $argv
end

# Claude CLI functions
function claude --description "Run Claude CLI"
    set -e ANTHROPIC_BASE_URL
    set -e ANTHROPIC_AUTH_TOKEN
    set -e ANTHROPIC_MODEL
    set -e ANTHROPIC_SMALL_FAST_MODEL
    command claude $argv
end

function cc --description "Run Claude CLI with skip permissions"
    set -e ANTHROPIC_BASE_URL
    set -e ANTHROPIC_AUTH_TOKEN
    set -e ANTHROPIC_MODEL
    set -e ANTHROPIC_SMALL_FAST_MODEL
    command claude --dangerously-skip-permissions $argv
end

function glm --description "Run Claude CLI with GLM API"
    set -gx ANTHROPIC_BASE_URL "https://open.bigmodel.cn/api/anthropic"
    set -gx ANTHROPIC_AUTH_TOKEN $GLM_API_KEY
    set -gx ANTHROPIC_MODEL "glm-4.6"
    set -gx ANTHROPIC_SMALL_FAST_MODEL "glm-4.6-air"
    command claude --dangerously-skip-permissions $argv
end

function glm-safe --description "Run Claude CLI with GLM API (safe mode)"
    set -gx ANTHROPIC_BASE_URL "https://open.bigmodel.cn/api/anthropic"
    set -gx ANTHROPIC_AUTH_TOKEN $GLM_API_KEY
    set -gx ANTHROPIC_MODEL "glm-4.6"
    set -gx ANTHROPIC_SMALL_FAST_MODEL "glm-4.6-air"
    command claude $argv
end

# YouTube download music
function dlm --description "Download music from YouTube"
    yt-dlp -x \
        --audio-format mp3 \
        --audio-quality 0 \
        --embed-metadata \
        --embed-thumbnail \
        -o "%(playlist_title)s/%(title)s.%(ext)s" \
        $argv[1]
end

# Zellij tab name function
function set_zellij_tab_name --on-event fish_preexec
    if set -q ZELLIJ
        set -l cmd $argv[1]
        set -l new_name (basename (string split ' ' $cmd)[1])
        zellij action rename-tab $new_name >/dev/null 2>&1
    end
end

# SSH wrapper functions with terminal color changes
function ssh-production --description "SSH to production with red background"
    printf '\033]11;#3d1515\007'
    command ssh production $argv
    printf '\033]11;#1f2528\007'
end

function ssh-staging --description "SSH to staging with orange background"
    printf '\033]11;#3d2915\007'
    command ssh staging $argv
    printf '\033]11;#1f2528\007'
end

function ssh-droplet --description "SSH to droplet with green background"
    printf '\033]11;#153d15\007'
    command ssh droplet $argv
    printf '\033]11;#1f2528\007'
end

# Override ssh command to detect known hosts
function ssh --description "SSH with automatic background color for known hosts"
    switch $argv[1]
        case production 209.97.152.81
            printf '\033]11;#3d1515\007'
            command ssh $argv
            printf '\033]11;#1f2528\007'
        case staging 174.138.88.191
            printf '\033]11;#3d2915\007'
            command ssh $argv
            printf '\033]11;#1f2528\007'
        case droplet 165.227.66.119
            printf '\033]11;#153d15\007'
            command ssh $argv
            printf '\033]11;#1f2528\007'
        case '*'
            command ssh $argv
    end
end

# Screenshot function with path selection (Linux only)
function screenshot --description "Take screenshot and save to project"
    if test (uname -s) != "Linux"
        echo "This function is only available on Linux"
        return 1
    end
    
    set -l project_path
    
    switch $argv[1]
        case conductly c
            set project_path "/home/dustin/.local/share/src/conductly"
        case bitcoin-noobs b
            set project_path "/home/dustin/.local/share/src/bitcoin-noobs"
        case '*'
            echo "Usage: screenshot [conductly|c|bitcoin-noobs|b]"
            echo "  conductly (c) - Save to conductly project"
            echo "  bitcoin-noobs (b) - Save to bitcoin-noobs project"
            return 1
    end
    
    # Prompt user for filename
    echo -n "Enter screenshot filename (without .png extension): "
    read -l user_filename
    
    # Use user input or fallback to timestamp if empty
    set -l filename
    if test -n "$user_filename"
        set filename "$user_filename.png"
    else
        set filename "screenshot-"(date +'%Y%m%d-%H%M%S')".png"
    end
    
    spectacle -r -b -o "$project_path/$filename"
    echo "Screenshot saved to: $project_path/$filename"
end
