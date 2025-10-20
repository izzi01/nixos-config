{ agenix, config, pkgs, inputs, ... }:
let
  user = "bscx";
in
{
  imports = [
    ../../modules/darwin/secrets.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    agenix.darwinModules.default
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Setup user, packages, programs
  nix = {
    enable = false;
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };
    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    agenix.packages."${pkgs.system}".default
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; nixpkgs-specific = inputs.nixpkgs-specific; });

  #launchd.user.agents = {
  #  emacs = {
  #    path = [ config.environment.systemPath ];
  #    serviceConfig = {
  #      KeepAlive = true;
  #      ProgramArguments = [
  #        "/bin/sh"
  #        "-c"
  #        "{ osascript -e 'display notification \"Attempting to start Emacs...\" with title \"Emacs Launch\"'; /bin/wait4path ${pkgs.emacs}/bin/emacs && { ${pkgs.emacs}/bin/emacs --fg-daemon; if [ $? -eq 0 ]; then osascript -e 'display notification \"Emacs has started.\" with title \"Emacs Launch\"'; else osascript -e 'display notification \"Failed to start Emacs.\" with title \"Emacs Launch\"' >&2; fi; } } &> /tmp/emacs_launch.log"
  #      ];
  #      StandardErrorPath = "/tmp/emacs.err.log";
  #      StandardOutPath = "/tmp/emacs.out.log";
  #    };
  #  };
  #};

  system = {
    # Turn off NIX_PATH warnings now that we're using flakes
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 4;
    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };
      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        tilesize = 48;
      };
      finder = {
        _FXShowPosixPathInTitle = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
