{ pkgs, ... }:

let
  isAarch64Darwin = pkgs.stdenv.system == "aarch64-darwin";
in

[
  # Development Tools
  # Note: Docker CLI tools are now managed via Nixpkgs in modules/shared/packages.nix
  # Docker Desktop can be added here if GUI is needed
  "visual-studio-code"
  "iterm2"
  "postman"
  "cursor"

  # Productivity Tools
  "raycast"

  # Browsers
  "google-chrome"

  # Communication Tools - Examples (uncomment as needed)
  "discord"
  "notion"
  "slack"
  "telegram"
  "zoom"

  # Utility Tools - Examples (uncomment as needed)
  "syncthing"
  "1password"
  "rectangle"

  # Entertainment Tools - Examples (uncomment as needed)
  "spotify"
  "vlc"

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
  "docker-desktop"
  "keepassxc"
  "mounty"
  "stats"
  "macfuse"
] ++ pkgs.lib.optionals isAarch64Darwin [
  # Battery monitoring for Apple Silicon Macs
  "battery"
]
