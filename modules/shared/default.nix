{ config, pkgs, ... }:

{

  nixpkgs = {
    config = {
      allowUnfree = true;
      #cudaSupport = true;
      #cudaCapabilities = ["8.0"];
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };

    overlays =
      # Apply each overlay found in the /overlays directory
      let
        path = ../../overlays;
        # Note: config.networking might not be available during overlay evaluation on Darwin
        # So we use empty list for excluded files on non-NixOS systems
        excludeForHost = {
          "garfield" = [ "cider-appimage.nix" ];
        };
        hostname = config.networking.hostName or null;
        excludedFiles = if hostname != null && builtins.hasAttr hostname excludeForHost then excludeForHost.${hostname} else [];
      in with builtins;
      map (n: import (path + ("/" + n)))
          (filter (n:
            (match ".*\\.nix" n != null ||
             pathExists (path + ("/" + n + "/default.nix")))
            && !(elem n excludedFiles))
                  (attrNames (readDir path)));
  };
}
