{ config, pkgs, lib, home-manager, inputs, ... }:

let
  user            = "bscx";
  sharedFiles     = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
    ./dock
  ];

  users.users.${user} = {
    name     = "${user}";
    home     = "/Users/${user}";
    isHidden = false;
    shell    = pkgs.zsh;
  };

  # Allow passwordless sudo for Homebrew cask installations
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30
    ${user} ALL=(root) NOPASSWD: /opt/homebrew/bin/brew
  '';

  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };
    taps   = [
      "dopplerhq/cli"
      "fluxcd/tap"
      "gromgit/fuse"
      "kptdev/kpt"
      "th-ch/youtube-music"
    ];
    brews  = [
      "abseil"
      "atuin"
      "bash"
      "ca-certificates"
      "caddy"
      "docker-buildx"
      "doppler"
      "flux@2.2"
      "gettext"
      "gmp"
      "gnu-getopt"
      "gnutls"
      "kpt"
      "kubectx"
      "lima"
      "libassuan"
      "libcbor"
      "libevent"
      "libgcrypt"
      "libgit2"
      "libgpg-error"
      "libidn2"
      "libksba"
      "libnghttp2"
      "libpng"
      "libssh2"
      "libtasn1"
      "libunistring"
      "libusb"
      "libuv"
      "lpeg"
      "luajit"
      "luv"
      "lz4"
      "mpdecimal"
      "mysql-client"
      "nettle"
      "npth"
      "oh-my-posh"
      "oniguruma"
      "openssl@3"
      "opentofu"
      "p11-kit"
      "p7zip"
      "pass"
      "pcre2"
      "pinentry"
      "protobuf"
      "protoc-gen-go"
      "protoc-gen-go-grpc"
      "python@3.13"
      "qrencode"
      "readline"
      "screenfetch"
      "skaffold"
      "superfile"
      "talosctl"
      "terragrunt"
      "unbound"
      "unibilium"
      "utf8proc"
      "vfox"
      "xz"
      "zlib"
      "zstd"
    ];
    casks  = pkgs.callPackage ./casks.nix {};
    #masApps = {
    #  "hidden-bar"   = 1452453066;
    #  "wireguard"    = 1451685025;
    #};
  };

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user} = { pkgs, config, lib, ... }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = map (pkg: lib.setPrio 10 pkg) (pkgs.callPackage ./packages.nix { nixpkgs-specific = inputs.nixpkgs-specific; });
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];
          stateVersion = "23.11";
        };
        programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
        manual.manpages.enable = false;
      };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock = {
    enable   = true;
    username = user;
    entries  = [
      { path = "/Applications/Slack.app/"; }
      { path = "/System/Applications/Messages.app/"; }
      { path = "${pkgs.wezterm}/Applications/WezTerm.app/"; }
      { path = "/System/Applications/Music.app/"; }
      { path = "/System/Applications/Photos.app/"; }
      { path = "/System/Applications/Photo Booth.app/"; }
      { path = "/System/Applications/TV.app/"; }
      { path = "${pkgs.jetbrains.phpstorm}/Applications/PhpStorm.app/"; }
      { path = "/Applications/TablePlus.app/"; }
      { path = "/Applications/Claude.app/"; }
      { path = "/Applications/Discord.app/"; }
      { path = "/Applications/TickTick.app/"; }
      { path = "/System/Applications/Home.app/"; }
      { path = "/System/Applications/Launchpad.app/"; }
      {
        path    = "${config.users.users.${user}.home}/.local/share/";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
      {
        path    = "${config.users.users.${user}.home}/.local/share/downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };
}
