{ pkgs, ... }:

[
  # Packages that truly need Homebrew (not available or better in Homebrew)
  "gnu-getopt"  # macOS specific GNU getopt
  "gromgit/fuse/ntfs-3g-mac"  # macOS specific NTFS support
  "zadark"  # WhatsApp enhancement tool (Homebrew only)
  "screenfetch"  # System info tool (neofetch available in Nixpkgs as alternative)

  # Note: All development tools and libraries have been moved to Nixpkgs
  # Nix automatically handles all dependencies, so explicit libraries are not needed
  # - CLI tools: atuin, caddy, doppler, fluxcd, kpt, kubectx, mysql-client, p7zip, protobuf, talosctl, unbound
  # - Dev tools: oh-my-posh, opentofu, pass, python3, skaffold, superfile, terragrunt, vfox
  # - All build-time and runtime dependencies are managed by Nixpkgs
]
