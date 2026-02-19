# Aliases and abbreviations
# This file defines shell aliases and abbreviations

# Core aliases
alias cat "bat"
alias ls "eza --color=always"
alias zz "zellij"
alias lg "lazygit"

# Wezterm SSH alias
if command -v wezterm &>/dev/null
    alias wssh "wezterm ssh"
end

# Laravel Artisan
alias art "php artisan"

# Use difftastic, syntax-aware diffing
alias diff "difft"

# Podman as Docker alias (if Docker is not installed)
if command -v podman &>/dev/null; and not command -v docker &>/dev/null
    alias docker "podman"
end

# Linux-specific aliases
if test (uname -s) = "Linux"
    alias open "xdg-open"
    alias windows "sudo systemctl reboot --boot-loader-entry=auto-windows"
end

# Abbreviations (expand on space)
# Git abbreviations
abbr -a g git
abbr -a ga "git add"
abbr -a gaa "git add --all"
abbr -a gc "git commit"
abbr -a gcm "git commit -m"
abbr -a gco "git checkout"
abbr -a gd "git diff"
abbr -a gp "git push"
abbr -a gpl "git pull"
abbr -a gs "git status"
abbr -a gst "git status"

# Common commands
abbr -a c "clear"
abbr -a h "history"
abbr -a v "nvim"
abbr -a n "nvim"
abbr -a ll "eza -la --color=always"
abbr -a lt "eza --tree --level=2 --color=always"
abbr -a l "eza --color=always"

# Tmux
abbr -a t "tmux"
abbr -a tn "tmux new -s"
abbr -a ta "tmux attach -t"
abbr -a tl "tmux ls"
abbr -a tk "tmux kill-session -t"

# Zellij
abbr -a zj "zellij"
abbr -a zja "zellij attach"
abbr -a zjl "zellij list-sessions"

# Devenv sessions
abbr -a conductly "tmux -S /run/user/1000/tmux-conductly attach -t conductly"
abbr -a river "tmux -S /run/user/1000/tmux-river attach -t river"
