{ pkgs, nixpkgs-specific ? null, nixpkgs-unstable ? null, ... }:
let
  myFonts = import ./fonts.nix { inherit pkgs; };

  # Packages from specific nixpkgs version
  specificPkgs = if nixpkgs-specific != null then
    import nixpkgs-specific {
      system = pkgs.system;
      config.allowUnfree = true;
    }
  else pkgs;

  # Packages from nixpkgs-unstable
  unstablePkgs = if nixpkgs-unstable != null then
    import nixpkgs-unstable {
      system = pkgs.system;
      config.allowUnfree = true;
    }
  else pkgs;
in
with pkgs; [
  # A
  act # Run Github actions locally
  age # File encryption tool
  age-plugin-yubikey # YubiKey plugin for age encryption
  ansible # Automations tools
  aspell # Spell checker
  aspellDicts.en # English dictionary for aspell

  # B
  bash-completion # Bash completion scripts
  bat # Cat clone with syntax highlighting
  btop # System monitor and process viewer
  bun # JavaScript runtime and toolkit

  # C
  coreutils # Basic file/text/shell utilities
  colima # Docker tools

  # D
  direnv # Environment variable management per directory
  difftastic # Structural diff tool
  # Docker - use specific version to avoid conflicts
  docker-client # Docker CLI client from specific version
  docker-buildx # Docker CLI plugin for extended build capabilities
  docker-compose # Docker Compose from specific version
  du-dust # Disk usage analyzer

  # E
  eza # Modern ls replacement

  # F
  fd # Fast find alternative
  ffmpeg # Multimedia framework
  specificPkgs.fluxcd # GitOps toolkit for Kubernetes
  flyctl # Fly.io tools
  fzf # Fuzzy finder

  # G
  go # Go
  gcc # GNU Compiler Collection
  gh # GitHub CLI
  glow # Markdown renderer for terminal
  gnupg # GNU Privacy Guard
  gopls # Go language server

  # H
  htop # Interactive process viewer
  hunspell # Spell checker

  # I
  iftop # Network bandwidth monitor
  imagemagick # Image manipulation toolkit

  # J
  jpegoptim # JPEG optimizer
  jq # JSON processor

  # K
  killall # Kill processes by name
  kitty # GPU-accelerated terminal emulator
  kpt # Automate Kubernetes Configuration Editing
  kubectl # Kubernetes CLI
  kubectx # Kube context switcher
  k9s # Kubernetes TUI
  kubernetes-helm # Kubernetes package manager
  kustomize # Kubernetes configuration customization

  # L
  lazydocker # Simple terminal UI for docker
  lazygit # Simple terminal UI for git
  lnav # Log file navigator
  lima # Linux runtimes

  # N
  ncurses # Terminal control library with terminfo database
  neofetch # System information tool
  ngrok # Secure tunneling service
  nodejs_20 # Node.js JavaScript runtime (includes npm)

  # O
  openssh # SSH client and server
  opentofu # Open-source Terraform alternative
  oh-my-posh

  # S - Additional tools moved from Homebrew
  superfile # Pretty fancy and modern terminal file manager

  # P
  pandoc # Document converter
  p7zip # New 7zip fork with additional codecs and improvements
  pngquant # PNG compression tool
  posting # HTTP Post client
  protobuf # Protocol Buffers with protoc compiler (includes protoc-gen-go, protoc-gen-go-grpc)

  # Q
  qt5.qtbase # Qt5 base library with platform plugins

  # R
  ripgrep # Fast text search tool
  repomix # AI tooling
  rclone # Cloud storage sync tool

  # S
  sqlite # SQL database engine
  # steam # Gaming platform - not available on macOS ARM64
  stow # Symlink farm manager
  syncthing # Continuous file synchronization

  # T
  talosctl # CLI for out-of-band management of Kubernetes nodes created by Talos
  termscp # Terminal file transfer client
  pay-respects # Command correction tool (replacement for thefuck)
  tmux # Terminal multiplexer
  tree # Directory tree viewer
  tree-sitter # Parsing system for programming tools

  # U
  unbound # Validating, recursive, and caching DNS resolver
  unrar # RAR archive extractor
  unzip # ZIP archive extractor

  # V
  vscode # Visual Studio Code editor

  # W
  wget # File downloader
  watch # Execute program periodically
  wezterm # GPU-accelerated terminal emulator
  wireshark # Network protocol analyzer

  # Y
  yazi # Terminal file manager
  yarn # Yarn tools

  # Z
  zellij # Terminal multiplexer
  zip # ZIP archive creator
  zoxide # Smarter cd command
  zsh # Z shell
  zsh-powerlevel10k # Zsh theme

  # Other tools
  androidenv.androidPkgs.platform-tools
] ++ myFonts
  ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [
    pkgs.vlc # Media player - Linux only (depends on libudev)
  ])
  ++ (pkgs.lib.optionals (pkgs.stdenv.system == "x86_64-linux") [
    pkgs.steam # Gaming platform - x86_64-linux only (requires i686 support)
  ])
  ++ (pkgs.lib.optionals (pkgs.stdenv.system != "aarch64-linux") [
    unstablePkgs.google-chrome # Web browser from unstable - not available on aarch64-linux
    pkgs.insomnia # HTTP client - not available on aarch64-linux
  ])
  ++ (pkgs.lib.optionals (pkgs.stdenv.system != "x86_64-darwin") [
    pkgs.ncdu # Disk space utility - not for x64-darwin
  ])
