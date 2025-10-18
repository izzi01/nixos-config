# Fixes Applied to NixOS Config

## Errors Fixed

### 1. **programs.programs doesn't exist**
**Location**: `modules/darwin/home-manager.nix:130`

**Problem**: The shared home-manager.nix already returns a programs attribute set, but we were wrapping it with `programs = {} //`

**Fix**: Changed from:
```nix
programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };
```

To:
```nix
programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
```

### 2. **hostname is null error**
**Location**: `modules/shared/default.nix:24`

**Problem**: `config.networking.hostName` doesn't exist during overlay evaluation on Darwin

**Fix**: Changed to safely handle null hostname:
```nix
hostname = config.networking.hostName or null;
excludedFiles = if hostname != null && builtins.hasAttr hostname excludeForHost
                then excludeForHost.${hostname} else [];
```

### 3. **Shell escaping syntax error**
**Location**: `modules/shared/home-manager.nix:150`

**Problem**: `${}` in shell string wasn't properly escaped for Nix

**Fix**: Changed from:
```bash
fzf --preview "eval 'echo \${}'"
```

To:
```bash
fzf --preview "eval 'echo \''${}'"
```

### 4. **Wrong username**
**Location**: Multiple files

**Problem**: Template default user was "dustin" instead of actual user "bscx"

**Fix**: Updated user in:
- `flake.nix:54` - Changed `user = "dustin"` to `user = "bscx"`
- `modules/darwin/home-manager.nix:4` - Changed `user = "dustin"` to `user = "bscx"`
- `modules/shared/home-manager.nix:3-5` - Updated name/user/email to bscx

## Additional Improvements

### Passwordless Homebrew
Added sudo configuration to avoid password prompts for Homebrew:
```nix
security.sudo.extraConfig = ''
  Defaults timestamp_timeout=30
  ${user} ALL=(root) NOPASSWD: /opt/homebrew/bin/brew
'';
```

### Migrated Packages from Homebrew to Nixpkgs
Removed these from Homebrew and added to nixpkgs:
- eza, lazygit, kubectl, k9s, kubernetes-helm, kustomize
- neovim, rclone, stow, thefuck, tree-sitter, watch
- yazi, zellij, zoxide, termscp

### Added Cross-Platform GUI Apps
Added to `modules/shared/packages.nix` (works on macOS + Linux):
- discord, insomnia, slack, steam, syncthing
- telegram-desktop, vlc, vscode, wireshark

### NixOS Management Aliases
Added helpful aliases in `modules/shared/home-manager.nix`:
- `nix-switch` - Quick rebuild
- `nix-update` - Update all flake inputs and rebuild
- `nix-update-nixpkgs` - Update only nixpkgs
- `nix-clean` - Clean old generations
- `nix-check` - Validate flake
- `nix-search` - Search nixpkgs

### Upstream Sync Setup
Added `upstream` remote pointing to `dustinlyons/nixos-config`:
```bash
git remote add upstream https://github.com/dustinlyons/nixos-config.git
```

⚠️ **Note**: Upstream template uses Emacs, your config uses LazyVim - don't blindly merge!

## How to Build

```bash
# Use the build-switch script
./apps/aarch64-darwin/build-switch

# Or after first build, use the alias
nix-switch

# Or use nix run
nix run '.#build'
```

## Next Steps

1. **Update your personal info** in `modules/shared/home-manager.nix`:
   - Change `name` from "bscx" to your actual name
   - Change `email` from "bscx@example.com" to your actual email

2. **Test the build**:
   ```bash
   ./apps/aarch64-darwin/build-switch
   ```

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Fix configuration errors and update user settings"
   ```

## Reference Documents

- `QUICK_REFERENCE.md` - Daily workflows and command reference
- `README.md` - Original template documentation
