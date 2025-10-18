# NixOS Config - Quick Reference Guide

## Daily Workflows

### 1. Apply Configuration Changes
After editing any `.nix` files in your configuration:

```bash
# Use the build-switch script (recommended)
./apps/aarch64-darwin/build-switch

# Or use the alias (after rebuilding once with new aliases)
nix-switch

# Manual command
darwin-rebuild switch --flake .
```

### 2. Update Flake Dependencies
Update nixpkgs, home-manager, and other inputs to latest versions:

```bash
# Update everything and rebuild
nix-update

# Or step-by-step
nix flake update          # Update all inputs
darwin-rebuild switch --flake .  # Apply updates

# Update only nixpkgs
nix-update-nixpkgs

# Update specific input
nix flake lock --update-input home-manager
darwin-rebuild switch --flake .
```

### 3. Search for Packages

```bash
# Search nixpkgs
nix-search packagename

# Or manual
nix search nixpkgs packagename

# Search with JSON output
nix search nixpkgs packagename --json
```

### 4. Clean Up Old Generations

```bash
# Remove old generations and rebuild
nix-clean

# Or manual
nix-collect-garbage -d
darwin-rebuild switch --flake .

# List generations
nix-env --list-generations
darwin-rebuild --list-generations

# Delete specific generation
sudo nix-env --delete-generations 14 15 16
```

## Helpful Aliases

All these aliases are configured in `modules/shared/home-manager.nix`:

- `nix-switch` - Apply current configuration changes
- `nix-update` - Update all flake inputs and rebuild
- `nix-update-nixpkgs` - Update only nixpkgs and rebuild
- `nix-clean` - Clean old generations and rebuild
- `nix-check` - Validate flake configuration
- `nix-search` - Search nixpkgs for packages

## Common Tasks

### Add a New Package

1. Edit `modules/shared/packages.nix` (for CLI tools) or `modules/darwin/packages.nix` (for macOS-specific)
2. Add package name alphabetically under the appropriate comment section
3. Rebuild: `nix-switch`

### Add a Homebrew Cask (macOS GUI apps)

1. Edit `modules/darwin/casks.nix`
2. Add cask name to the list
3. Rebuild: `nix-switch`

### Update Neovim Configuration

1. Edit files in `modules/shared/config/nvim/`
2. Rebuild: `nix-switch`
3. Open nvim and run `:Lazy sync` if needed

### Update WezTerm Configuration

1. Edit `modules/shared/home-manager.nix` - look for `programs.wezterm`
2. Rebuild: `nix-switch`

### Update ZSH Configuration

1. Edit `modules/shared/home-manager.nix` - look for `programs.zsh`
2. Rebuild: `nix-switch`

## Troubleshooting

### Build Fails

```bash
# Check flake syntax
nix flake check

# Build without switching
nix build .#darwinConfigurations.aarch64-darwin.system

# Verbose output
darwin-rebuild switch --flake . --show-trace
```

### Homebrew Permission Issues

The config includes passwordless sudo for Homebrew. If still having issues:

```bash
# Check /etc/sudoers.d/
cat /etc/sudoers.d/nix-darwin
```

### Rollback to Previous Generation

```bash
# List generations
darwin-rebuild --list-generations

# Rollback to previous
sudo darwin-rebuild --rollback

# Switch to specific generation
sudo darwin-rebuild switch --switch-generation 123
```

## File Structure

```
nixos-config/
├── flake.nix              # Main flake configuration
├── modules/
│   ├── darwin/            # macOS-specific configuration
│   │   ├── home-manager.nix
│   │   ├── casks.nix      # Homebrew GUI apps
│   │   └── packages.nix   # macOS-specific packages
│   └── shared/            # Cross-platform configuration
│       ├── home-manager.nix  # Shell, editor, git config
│       ├── packages.nix      # CLI tools and packages
│       ├── files.nix         # Dotfile symlinks
│       └── config/
│           ├── nvim/         # Neovim/LazyVim config
│           ├── wezterm/      # WezTerm config (in home-manager.nix)
│           ├── zellij/       # Zellij config
│           └── yazi/         # Yazi config
└── apps/
    ├── aarch64-darwin/build-switch
    └── x86_64-darwin/build-switch
```

## Syncing with Upstream Template

Your config was initialized from `dustinlyons/nixos-config#starter` but has been heavily customized.

### One-Time Setup

```bash
# Add upstream remote (already done)
git remote add upstream https://github.com/dustinlyons/nixos-config.git
```

### Check for Updates

```bash
# Fetch latest upstream changes
git fetch upstream

# See what changed (file list)
git diff main upstream/main --stat

# See specific file differences
git diff main upstream/main -- path/to/file.nix

# View upstream file content
git show upstream/main:modules/shared/packages.nix
```

### ⚠️ Important Notes

- **Don't blindly merge**: Upstream uses Emacs, you use LazyVim/Neovim
- **Cherry-pick carefully**: Only take specific bug fixes or features you need
- **Keep your customizations**: Your config is already customized for your workflow

### Recommended Approach

1. Periodically fetch: `git fetch upstream`
2. Review changes: `git diff main upstream/main --stat`
3. Manually apply relevant changes to your files
4. Commit your updates

## Learning Resources

- [Nix Official Docs](https://nixos.org/manual/nix/stable/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Package Search](https://search.nixos.org/)
- [Upstream Template Repo](https://github.com/dustinlyons/nixos-config)

## Tips

1. **Always rebuild from the config directory**: `cd ~/nixos-config && nix-switch`
2. **Test before committing**: Changes are reversible via rollback
3. **Commit often**: `git commit` after successful changes
4. **Check what changed**: `nix store diff-closures /run/current-system ./result`
5. **Keep inputs updated**: Run `nix-update` weekly/monthly
