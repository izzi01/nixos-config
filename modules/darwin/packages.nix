{ pkgs, nixpkgs-specific ? null, nixpkgs-unstable ? null }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs nixpkgs-specific nixpkgs-unstable; }; in
shared-packages ++ [
  dockutil
]
