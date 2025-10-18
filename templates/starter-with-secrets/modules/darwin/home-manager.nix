{ config, pkgs, lib, home-manager, ... }:

let
  user = "%USER%";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    taps = [
      "dopplerhq/cli"
      "fluxcd/tap"
      "gromgit/fuse"
      "kptdev/kpt"
      "th-ch/youtube-music"
      "veeso/termscp"
    ];
    brews = [
      "abseil"
      "atuin"
      "bash"
      "ca-certificates"
      "caddy"
      "doppler"
      "eza"
      "flux@2.2"
      "gettext"
      "gmp"
      "gnu-getopt"
      "gnutls"
      "helm"
      "k9s"
      "kpt"
      "kubectx"
      "kubernetes-cli"
      "kustomize"
      "lazygit"
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
      "neovim"
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
      "rclone"
      "readline"
      "screenfetch"
      "skaffold"
      "stow"
      "superfile"
      "talosctl"
      "termscp"
      "terragrunt"
      "thefuck"
      "tree-sitter"
      "tree-sitter-cli"
      "unbound"
      "unibilium"
      "utf8proc"
      "vfox"
      "watch"
      "xz"
      "yazi"
      "zellij"
      "zlib"
      "zoxide"
      "zstd"
    ];
    casks = pkgs.callPackage ./casks.nix {};
    # onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)

    masApps = {
      # "wireguard" = 1451685025;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
          { "emacs-launcher.command".source = myEmacsLauncher; }
        ];

        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      username = user;
      entries = [
        { path = "/Applications/Safari.app/"; }
        { path = "/System/Applications/Messages.app/"; }
        { path = "/System/Applications/Notes.app/"; }
        { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
        { path = "/System/Applications/Music.app/"; }
        { path = "/System/Applications/Photos.app/"; }
        { path = "/System/Applications/Photo Booth.app/"; }
        { path = "/System/Applications/System Settings.app/"; }
        {
          path = toString myEmacsLauncher;
          section = "others";
        }
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
