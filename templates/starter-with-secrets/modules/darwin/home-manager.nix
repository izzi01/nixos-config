{ config, pkgs, lib, home-manager, inputs, ... }:

let
  user = "%USER%";
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
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };
    taps = [
      "dopplerhq/cli"
      "fluxcd/tap"
      "gromgit/fuse"
      "kptdev/kpt"
      "th-ch/youtube-music"
    ];
    brews = [
      "abseil"
      "atuin"
      "bash"
      "ca-certificates"
      "caddy"
      "doppler"
      "flux@2.2"
      "gettext"
      "gmp"
      "gnu-getopt"
      "gnutls"
      "kpt"
      "kubectx"
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
      "gromgit/fuse/ntfs-3g-mac"
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
    backupFileExtension = "backup";
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = map (pkg: lib.setPrio 10 pkg) (pkgs.callPackage ./packages.nix {})
          ++ [ inputs.nix-search-cli.packages.${pkgs.system}.default ];
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];
        stateVersion = "23.11";
        activation = {
          installClaudeCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
            if command -v npm >/dev/null 2>&1; then
              $DRY_RUN_CMD npm install -g @anthropic-ai/claude-code || true
            fi
          '';
        };
      };
      programs = import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock = {
    enable = true;
    username = user;
    entries = [
      { path = "/Applications/Safari.app/"; }
      { path = "/System/Applications/Messages.app/"; }
      { path = "/System/Applications/Notes.app/"; }
      { path = "${pkgs.wezterm}/Applications/WezTerm.app/"; }
      { path = "${pkgs.google-chrome}/Applications/Google Chrome.app/"; }
      { path = "/System/Applications/Music.app/"; }
      { path = "/System/Applications/Photos.app/"; }
      { path = "/System/Applications/Photo Booth.app/"; }
      { path = "/System/Applications/System Settings.app/"; }
      { path = "/System/Applications/Launchpad.app/"; }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };

}
