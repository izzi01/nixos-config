{ pkgs, nixpkgs-specific ? null }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs nixpkgs-specific; }; in
shared-packages ++ [
  # D
  dockutil # Manage icons in the dock

  # F
  fswatch # File change monitor
]
