{ pkgs, ... }:

let
  isAarch64Darwin = pkgs.stdenv.system == "aarch64-darwin";
in

[
  # Development Tools
  "claude"
  "insomnia"
  "tableplus"
  "ngrok"
  "postico"
  "visual-studio-code"
  "wireshark-app"

  # Communication Tools
  "discord"
  "loom"
  "slack"
  "telegram"
  "zoom"

  # Utility Tools
  "appcleaner"
  "syncthing-app"

  # Entertainment Tools
  "steam"
  "vlc"

  # Productivity Tools
  "raycast"
  "asana"

  # Browsers
  "google-chrome"
] ++ pkgs.lib.optionals isAarch64Darwin [
  # Battery monitoring for Apple Silicon Macs
  "battery"
]
