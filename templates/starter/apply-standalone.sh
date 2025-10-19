#!/usr/bin/env bash
# Apply script for standalone Linux (Home Manager)
# This populates user values and applies Home Manager configuration

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Custom print function
_print() {
  echo -e "$1"
}

# Custom prompt function
_prompt() {
  local message="$1"
  local variable="$2"

  _print "$message"
  read -r $variable
}

_print "${BLUE}=== Home Manager Configuration Setup ===${NC}"
_print ""

# Detect architecture
export ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  ARCH="aarch64"
elif [[ "$ARCH" == "x86_64" ]]; then
  ARCH="x86_64"
fi

_print "${GREEN}Detected architecture: ${ARCH}-linux${NC}"
_print ""

# Fetch username from the system
export USERNAME=$(whoami)

# If the username is 'nixos' or 'root', ask the user for their username
if [[ "$USERNAME" == "nixos" ]] || [[ "$USERNAME" == "root" ]]; then
  _prompt "${YELLOW}You're running as $USERNAME. Please enter your desired username: ${NC}" USERNAME
fi

# Check if git is available
if command -v git >/dev/null 2>&1; then
  # Fetch email and name from git config
  export GIT_EMAIL=$(git config --get user.email)
  export GIT_NAME=$(git config --get user.name)
else
  _print "${YELLOW}Git is not available on this system. Will install it via Nix.${NC}"
fi

# If git email is not found or git is not available, ask the user
if [[ -z "$GIT_EMAIL" ]]; then
  _prompt "${YELLOW}Please enter your email: ${NC}" GIT_EMAIL
fi

# If git name is not found or git is not available, ask the user
if [[ -z "$GIT_NAME" ]]; then
  _prompt "${YELLOW}Please enter your full name: ${NC}" GIT_NAME
fi

# Confirmation step
confirm_details() {
  _print ""
  _print "${GREEN}Configuration Summary:${NC}"
  _print "${GREEN}  Username: $USERNAME${NC}"
  _print "${GREEN}  Email: $GIT_EMAIL${NC}"
  _print "${GREEN}  Name: $GIT_NAME${NC}"
  _print "${GREEN}  Architecture: ${ARCH}-linux${NC}"
  _print ""

  _prompt "${YELLOW}Is this correct? (yes/no): ${NC}" choice

  case "$choice" in
    [Yy]* ) _print "${GREEN}Continuing...${NC}";;
    [Nn]* ) _print "${RED}Exiting script. Please run again.${NC}" && exit 1;;
    * ) _print "${RED}Invalid option. Exiting script.${NC}" && exit 1;;
  esac
}

# Call the confirmation function
confirm_details

# Function to replace tokens in each file
replace_tokens() {
  local file="$1"

  # Skip the apply scripts themselves
  if [[ $(basename "$file") == "apply" ]] || [[ $(basename "$file") == "apply-standalone.sh" ]]; then
    return
  fi

  # Only process text files
  if file "$file" | grep -q text; then
    sed -i -e "s/%USER%/$USERNAME/g" "$file"
    sed -i -e "s/%EMAIL%/$GIT_EMAIL/g" "$file"
    sed -i -e "s/%NAME%/$GIT_NAME/g" "$file"
  fi
}

_print ""
_print "${YELLOW}Replacing tokens in configuration files...${NC}"

# Traverse directories and call replace_tokens on each file
export -f replace_tokens
export USERNAME GIT_EMAIL GIT_NAME
find . -type f -exec bash -c 'replace_tokens "$0"' {} \;

_print "${GREEN}✓ User information applied to configuration files.${NC}"

# Update flake.nix with correct username
_print "${YELLOW}Updating flake.nix with username...${NC}"
sed -i "s/user = \".*\";/user = \"$USERNAME\";/" flake.nix
_print "${GREEN}✓ flake.nix updated.${NC}"

# Check if Home Manager is installed
if ! command -v home-manager &> /dev/null; then
  _print "${YELLOW}Home Manager not found. Installing...${NC}"
  nix run home-manager/master -- init --switch
  _print "${GREEN}✓ Home Manager installed.${NC}"
fi

# Apply Home Manager configuration
_print ""
_print "${YELLOW}Applying Home Manager configuration...${NC}"
_print "${BLUE}Running: home-manager switch --flake .#${USERNAME}@${ARCH}-linux${NC}"
_print ""

if home-manager switch --flake ".#${USERNAME}@${ARCH}-linux"; then
  _print ""
  _print "${GREEN}╔════════════════════════════════════════════╗${NC}"
  _print "${GREEN}║  ✓ Configuration applied successfully!    ║${NC}"
  _print "${GREEN}╔════════════════════════════════════════════╗${NC}"
  _print ""
  _print "${GREEN}Next steps:${NC}"
  _print "  1. Restart your terminal: ${BLUE}exec \$SHELL${NC}"
  _print "  2. Your shell is now configured with all packages and settings"
  _print "  3. To update in the future, run: ${BLUE}home-manager switch --flake .#${USERNAME}@${ARCH}-linux${NC}"
  _print "     or use the alias: ${BLUE}nix-apply${NC}"
  _print ""

  # Save username for future reference
  echo "$USERNAME" > /tmp/username.txt
else
  _print ""
  _print "${RED}╔════════════════════════════════════════════╗${NC}"
  _print "${RED}║  ✗ Configuration failed to apply          ║${NC}"
  _print "${RED}╚════════════════════════════════════════════╝${NC}"
  _print ""
  _print "${YELLOW}Please check the error messages above.${NC}"
  exit 1
fi
