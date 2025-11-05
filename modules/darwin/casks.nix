{ pkgs, ... }:

let
  isAarch64Darwin = pkgs.stdenv.system == "aarch64-darwin";

  # Get macOS version - returns major version number (14 for Sonoma, 15 for Sequoia, etc.)
  darwinVersion = pkgs.lib.strings.toInt (builtins.head (pkgs.lib.strings.splitString "." pkgs.stdenv.hostPlatform.darwinMinVersion));

  # Sonoma is version 14, so only include docker-desktop on version 15+ (Sequoia and later)
  isGreaterThanSonoma = darwinVersion > 14;
in

[
  # Development Tools
  # Note: Docker CLI tools are now managed via Nixpkgs in modules/shared/packages.nix
  # Docker Desktop can be added here if GUI is needed
  "visual-studio-code"
  "iterm2"
  # "cursor"

  # Productivity Tools
  "raycast"

  # Browsers
  # "google-chrome"

  # Communication Tools - Examples (uncomment as needed)
  # "discord"
  # "notion"
  # "slack"
  # "telegram"
  # "zoom"

  # Utility Tools - Examples (uncomment as needed)
  # "syncthing"
  # "1password"
  # "rectangle"

  # Entertainment Tools - Examples (uncomment as needed)
  # "spotify"
  # "vlc"

  "amethyst"
  "font-fira-mono-nerd-font"
  "kitty"
  "mysqlworkbench"
  "syncthing-app"
  "font-jetbrains-mono-nerd-font"
  "localsend"
  "rclone-ui"
  "visual-studio-code"
  "betterdisplay"
  "free-download-manager"
  "macfuse"
  "rio"
  "warp"
  "claude"
  "google-chrome"
  "mailspring"
  "rustdesk"
  "cursor"
  "iina"
  "mos"
  "spaceid"
  "keepassxc"
  "mounty"
  "stats"
  "macfuse"
] ++ pkgs.lib.optionals isAarch64Darwin [
  # Battery monitoring for Apple Silicon Macs
  "battery"
] ++ pkgs.lib.optionals isGreaterThanSonoma [
  # Docker Desktop requires macOS 15+ (Sequoia and later)
  "docker-desktop"
]
