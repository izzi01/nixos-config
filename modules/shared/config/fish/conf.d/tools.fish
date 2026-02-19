# Tool integrations
# This file configures integrations with various CLI tools

# FZF configuration
# Catppuccin Macchiato colors
set -l fg "#CAD3F5"
set -l bg "#24273A"
set -l bg_highlight "#1E2030"
set -l purple "#C6A0F6"
set -l blue "#8AADF4"
set -l cyan "#91D7E3"

set -gx FZF_DEFAULT_OPTS "--color=fg:$fg,bg:$bg,hl:$purple,fg+:$fg,bg+:$bg_highlight,hl+:$purple,info:$blue,prompt:$cyan,pointer:$cyan,marker:$cyan,spinner:$cyan,header:$cyan"
set -gx FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# FZF preview options
set -l show_file_or_dir_preview "if [ -d {} ]; eza --tree --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end"
set -gx FZF_CTRL_T_OPTS "--preview '$show_file_or_dir_preview'"
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

# Zoxide initialization (handled by home-manager, but we can add aliases)
# zoxide is initialized via programs.zoxide.enableFishIntegration

# Direnv (handled by home-manager)
# direnv is initialized via programs.direnv.enableFishIntegration

# FZF key bindings (source fzf for fish)
if command -v fzf &>/dev/null
    # Check if fzf has fish integration
    if test -f (dirname (dirname (which fzf)))/share/fish/vendor_functions.d/fzf_key_bindings.fish
        source (dirname (dirname (which fzf)))/share/fish/vendor_functions.d/fzf_key_bindings.fish
    end
end

# vfox activation
if command -v vfox &>/dev/null
    vfox activate fish | source
end

# pay-respects (thefuck replacement)
if command -v pay-respects &>/dev/null
    pay-respects fish --alias | source
end

# Doppler auto-inject (only with internet connection)
if command -v doppler &>/dev/null
    # Check for internet connection
    set -l internet_connected false
    
    # Method 1: Try to ping Google's DNS
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null
        set internet_connected true
    # Method 2: Try to connect to a reliable HTTP endpoint
    else if curl -s --max-time 2 --connect-timeout 2 https://api.doppler.com &>/dev/null
        set internet_connected true
    # Method 3: Check if we can reach Apple's connectivity test (macOS specific)
    else if test (uname -s) = "Darwin"; and ping -c 1 -W 2 17.253.144.10 &>/dev/null
        set internet_connected true
    end
    
    if test "$internet_connected" = true
        set -gx DOPPLER_PROJECT "api-key"
        set -gx DOPPLER_CONFIG "dev"
        eval (doppler secrets download --no-file --format env-no-quotes)
        set -e DOPPLER_PROJECT
        set -e DOPPLER_CONFIG
    else
        echo "⚠️  No internet connection detected - skipping Doppler secrets injection"
    end
end

# Keychain - SSH/GPG agent manager
# Manages SSH and GPG agents persistently across sessions
if command -v keychain &>/dev/null
    keychain --eval --quiet | source
end
