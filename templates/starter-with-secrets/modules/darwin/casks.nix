{ pkgs, ... }:

let
  isAarch64Darwin = pkgs.stdenv.system == "aarch64-darwin";
in

[
  # Development Tools
  "homebrew/cask/docker"
  "visual-studio-code"
  "iterm2"
  "postman"
  "cursor"

  # Productivity Tools
  "raycast"

  # Browsers
  "google-chrome"

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
] ++ pkgs.lib.optionals isAarch64Darwin [
  # Battery monitoring for Apple Silicon Macs
  "battery"
]