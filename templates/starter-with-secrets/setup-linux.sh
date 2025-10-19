#!/usr/bin/env bash
# Setup script for NixOS configuration on regular Linux (non-NixOS)
# This uses Home Manager in standalone mode

set -e

echo "=== NixOS Config Setup for Linux (Home Manager Standalone) ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    ARCH="aarch64"
fi

echo -e "${GREEN}Detected architecture: ${ARCH}-linux${NC}"
echo ""

# Step 1: Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}Nix is not installed. Installing Nix using Determinate Nix Installer...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

    echo -e "${GREEN}Nix installed! Please restart your shell and run this script again.${NC}"
    exit 0
else
    echo -e "${GREEN}✓ Nix is already installed${NC}"
fi

# Step 2: Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Git is not installed. Installing via Nix...${NC}"
    nix profile install nixpkgs#git
fi

# Step 3: Clone or update the config repo
CONFIG_DIR="$HOME/nixos-config"
if [[ ! -d "$CONFIG_DIR" ]]; then
    echo -e "${YELLOW}Cloning nixos-config repository...${NC}"
    read -p "Enter your git repository URL (or press Enter to skip): " REPO_URL
    if [[ -n "$REPO_URL" ]]; then
        git clone "$REPO_URL" "$CONFIG_DIR"
    else
        echo -e "${RED}No repository URL provided. Please clone your config manually to $CONFIG_DIR${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Config directory already exists at $CONFIG_DIR${NC}"
fi

cd "$CONFIG_DIR"

# Step 4: Make app scripts executable
echo -e "${YELLOW}Making app scripts executable...${NC}"
find apps -type f \( -name apply -o -name build -o -name build-switch -o -name create-keys -o -name copy-keys -o -name check-keys -o -name rollback -o -name clean -o -name install -o -name install-with-secrets \) -exec chmod +x {} \; 2>/dev/null || true

# Step 5: Install Home Manager
if ! command -v home-manager &> /dev/null; then
    echo -e "${YELLOW}Installing Home Manager...${NC}"
    nix run home-manager/master -- init --switch
    echo -e "${GREEN}✓ Home Manager installed${NC}"
else
    echo -e "${GREEN}✓ Home Manager is already installed${NC}"
fi

# Step 6: Install direnv (for automatic environment loading)
if ! command -v direnv &> /dev/null; then
    echo -e "${YELLOW}Installing direnv...${NC}"
    nix profile install nixpkgs#direnv

    # Add direnv hook to shell
    SHELL_RC="$HOME/.bashrc"
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_RC="$HOME/.zshrc"
    fi

    if ! grep -q "direnv hook" "$SHELL_RC" 2>/dev/null; then
        echo 'eval "$(direnv hook bash)"' >> "$SHELL_RC"
        echo -e "${GREEN}Added direnv hook to $SHELL_RC${NC}"
    fi
else
    echo -e "${GREEN}✓ direnv is already installed${NC}"
fi

# Step 7: Allow direnv in config directory
echo -e "${YELLOW}Configuring direnv for this directory...${NC}"
direnv allow . || true

# Step 8: Apply Home Manager configuration
echo ""
echo -e "${GREEN}=== Ready to apply your configuration! ===${NC}"
echo ""
echo "Your configuration will:"
echo "  ✓ Install zsh and set it as default shell"
echo "  ✓ Install all packages (git, neovim, tmux, etc.)"
echo "  ✓ Configure all your dotfiles"
echo "  ✓ Set up development environment"
echo ""
read -p "Apply configuration now? [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Applying Home Manager configuration...${NC}"
    home-manager switch --flake ".#bscx@${ARCH}-linux"

    echo ""
    echo -e "${GREEN}=== Setup Complete! ===${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: exec \$SHELL"
    echo "  2. Your default shell is now zsh with all configurations applied"
    echo "  3. To update your config in the future, run: nix-apply"
    echo ""
    echo "Useful commands:"
    echo "  nix-apply  - Apply configuration changes"
    echo "  nix-build  - Build without applying"
    echo ""
else
    echo ""
    echo "Setup prepared but not applied. To apply manually, run:"
    echo "  cd $CONFIG_DIR"
    echo "  home-manager switch --flake .#bscx@${ARCH}-linux"
    echo ""
fi
