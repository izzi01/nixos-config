{ pkgs, nixpkgs-specific ? null, ... }:
let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    slpp
    pip
    rich
    mysql-connector
    virtualenv
    black
    requests
    faker
    textual
    pyqt5
    pyyaml
    feedparser
    python-dateutil
  ]);

  myPHP = pkgs.php82.withExtensions ({ enabled, all }: enabled ++ (with all; [
    xdebug
  ]));

  myFonts = import ./fonts.nix { inherit pkgs; };

  # Packages from specific nixpkgs version
  specificPkgs = if nixpkgs-specific != null then
    import nixpkgs-specific {
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
  ansible # IT automation tool
  ghostty # GPU-accelerated terminal emulator
  aspell # Spell checker
  aspellDicts.en # English dictionary for aspell

  # B
  bash-completion # Bash completion scripts
  bat # Cat clone with syntax highlighting
  btop # System monitor and process viewer
  specificPkgs.bun # JavaScript runtime and toolkit

  # C
  coreutils # Basic file/text/shell utilities

  # D
  discord # Voice and text chat platform
  direnv # Environment variable management per directory
  difftastic # Structural diff tool
  du-dust # Disk usage analyzer
  # Docker - use specific version to avoid conflicts
  pkgs.docker_28 # Use specific Docker 27.3.2 version
  docker-client # Docker CLI client from specific version
  docker-buildx # Docker CLI plugin for extended build capabilities
  docker-compose # Docker Compose from specific version

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
  insomnia # HTTP client and API testing tool
  intelephense # PHP LSP server

  # J
  jetbrains.phpstorm # PHP IDE
  jpegoptim # JPEG optimizer
  jq # JSON processor

  # K
  killall # Kill processes by name
  kitty # GPU-accelerated terminal emulator
  kubectl # Kubernetes CLI
  k9s # Kubernetes TUI
  kubernetes-helm # Kubernetes package manager
  kustomize # Kubernetes configuration customization

  # L
  lazydocker # Simple terminal UI for docker
  lazygit # Simple terminal UI for git
  lnav # Log file navigator

  # M
  myPHP # Custom PHP with extensions
  myPython # Custom Python with packages

  # N
  ncurses # Terminal control library with terminfo database
  neofetch # System information tool
  ngrok # Secure tunneling service
  nodejs_20 # Node.js JavaScript runtime (includes npm)

  # O
  oh-my-posh # Prompt theme engine
  openssh # SSH client and server
  opentofu # Open-source Terraform alternative

  # P
  pandoc # Document converter
  php82Packages.composer # PHP dependency manager
  deployer # PHP deployment tool
  php82Packages.php-cs-fixer # PHP code style fixer
  php82Packages.phpstan # PHP static analysis tool
  phpactor # PHP language server with better refactoring support
  phpunit # PHP testing framework
  pngquant # PNG compression tool
  posting # HTTP posting client

  # Q
  qt5.qtbase # Qt5 base library with platform plugins

  # R
  ripgrep # Fast text search tool
  repomix # AI tooling
  rclone # Cloud storage sync tool

  # S
  slack # Team communication app
  sqlite # SQL database engine
  # steam # Gaming platform - not available on macOS ARM64
  stow # Symlink farm manager
  syncthing # Continuous file synchronization

  # T
  telegram-desktop # Telegram messaging client
  termscp # Terminal file transfer client
  pay-respects # Command correction tool (replacement for thefuck)
  tmux # Terminal multiplexer
  tree # Directory tree viewer
  tree-sitter # Parsing system for programming tools

  # U
  unrar # RAR archive extractor
  unzip # ZIP archive extractor
  uv # Python package installer

  # V
  vscode # Visual Studio Code editor

  # W
  wget # File downloader
  watch # Execute program periodically
  wezterm # GPU-accelerated terminal emulator
  wireshark # Network protocol analyzer

  # Y
  yazi # Terminal file manager

  # Z
  zed-editor
  zellij # Terminal multiplexer
  zip # ZIP archive creator
  zoxide # Smarter cd command
  zsh # Z shell
  zsh-powerlevel10k # Zsh theme
] ++ myFonts
  ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [
    pkgs.steam # Gaming platform - Linux only (requires i686 support)
    pkgs.vlc # Media player - Linux only (depends on libudev)
  ])
  ++ (pkgs.lib.optionals (pkgs.stdenv.system != "aarch64-linux") [
    pkgs.google-chrome # Web browser - not available on aarch64-linux
  ])
  ++ (pkgs.lib.optionals (pkgs.stdenv.system != "x86_64-darwin") [
    pkgs.ncdu # Disk space utility - not for x64-darwin
  ])
