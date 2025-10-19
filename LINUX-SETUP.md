# Linux Setup Guide (Non-NixOS)

This guide is for setting up your Nix configuration on **regular Linux distributions** (Ubuntu, Debian, Arch, etc.) with Nix installed via the Determinate Nix Installer.

> **Note:** If you're running full NixOS, use the standard NixOS installation process instead.

## Quick Start (Automated)

```bash
# 1. Clone this repository
git clone <your-repo-url> ~/nixos-config
cd ~/nixos-config

# 2. Run the setup script
./setup-linux.sh
```

The script will:
- ✅ Install Nix (if not already installed)
- ✅ Install Home Manager
- ✅ Install direnv for automatic environment loading
- ✅ Apply your complete configuration
- ✅ Install all packages (zsh, git, neovim, tmux, etc.)
- ✅ Set up all dotfiles and configurations

## Manual Setup

If you prefer to set up manually:

### 1. Install Nix (Determinate Installer)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Install Home Manager

```bash
nix run home-manager/master -- init --switch
```

### 3. Clone Your Config

```bash
git clone <your-repo-url> ~/nixos-config
cd ~/nixos-config
```

### 4. Apply Your Configuration

For **aarch64** (ARM64):
```bash
home-manager switch --flake .#bscx@aarch64-linux
```

For **x86_64**:
```bash
home-manager switch --flake .#bscx@x86_64-linux
```

### 5. Restart Your Shell

```bash
exec $SHELL
```

## Daily Usage

After setup, use these commands to manage your configuration:

```bash
cd ~/nixos-config

# Apply configuration changes
nix-apply

# Build without applying (test)
nix-build

# Update dependencies
nix flake update

# Show what's available
nix flake show
```

## What Gets Installed

When you apply the configuration, Home Manager will install and configure:

### Packages
- **Shell:** zsh with powerlevel10k theme, completions, syntax highlighting
- **Editor:** neovim with LSP servers and plugins
- **Terminal:** wezterm, tmux, zellij
- **Git:** git with LFS, GPG signing, custom config
- **Tools:** bat, eza, fzf, ripgrep, fd, zoxide, lazygit, htop, btop
- **Languages:** go, nodejs, python, rust
- **Cloud:** kubectl, k9s, terraform, docker, awscli
- And many more! (see `modules/shared/packages.nix`)

### Configurations
- ✅ Zsh configuration with aliases, functions, and integrations
- ✅ Git configuration with your email/name
- ✅ Neovim setup with LSP support
- ✅ Tmux with plugins and custom keybindings
- ✅ SSH configuration
- ✅ All your dotfiles

## Updating Your Configuration

1. Edit files in `~/nixos-config`
2. Run `nix-apply` to apply changes
3. Commit and push to git

## Switching to a Different Machine

Just clone your config and run `./setup-linux.sh` - all your settings will be applied automatically!

## Troubleshooting

### "home-manager: command not found"

Install Home Manager:
```bash
nix run home-manager/master -- init --switch
```

### Packages not found in PATH

Restart your shell:
```bash
exec $SHELL
```

### Changes not taking effect

Make sure to run:
```bash
nix-apply
```

## Differences from NixOS

| Feature | NixOS | Nix on Linux |
|---------|-------|--------------|
| System config | ✅ Full system | ❌ User-level only |
| Command | `nixos-rebuild` | `home-manager` |
| Manages | Everything | User packages & dotfiles |
| Requires | Full NixOS install | Just Nix package manager |
| Root access | Required | Not required |

Your configuration automatically detects which environment you're in and uses the appropriate commands!
