# Environment variables and PATH configuration
# This file sets up environment variables and PATH modifications

# Editor
set -gx EDITOR nvim
set -gx TALOSCONFIG "_out/talosconfig"

# Nix daemon setup
if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
end

# OS-specific configurations
switch (uname -s)
    case Darwin
        set -gx LC_CTYPE en_US.UTF-8
        set -gx LC_ALL en_US.UTF-8
    case Linux
        # WSL SSH agent
        if set -q WSL_DISTRO_NAME; or test -e /proc/version; and grep -q Microsoft /proc/version
            eval ($HOME/wsl2-ssh-agent)
        end
end

# PATH modifications
# pnpm packages
fish_add_path --prepend $HOME/.pnpm-packages/bin
fish_add_path --prepend $HOME/.pnpm-packages

# npm packages and local bin
fish_add_path --prepend $HOME/.npm-packages/bin
fish_add_path --prepend $HOME/bin

# Local bin directories
if test -d $HOME/.local/bin
    fish_add_path --prepend $HOME/.local/bin
end
fish_add_path --prepend $HOME/.local/share/bin

# Go PATH
if command -v go &>/dev/null
    fish_add_path --append (go env GOPATH)/bin
end

# Bun PATH
if command -v bun &>/dev/null
    fish_add_path --prepend $HOME/.bun
end

# Podman as Docker alias (if Docker is not installed)
if command -v podman &>/dev/null; and not command -v docker &>/dev/null
    set -gx DOCKER_HOST unix:///run/user/1000/podman/podman.sock
end
