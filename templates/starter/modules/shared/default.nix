{ config, pkgs, ... }:

let
  emacsOverlaySha256 = "11p1c1l04zrn8dd5w8zyzlv172z05dwi9avbckav4d5fk043m754";
in
{

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
      # Handle incompatible packages by ignoring platform checks
      # Useful for aarch64 systems where some packages may not be marked as compatible
      permittedInsecurePackages = [];
    };

    overlays =
      # Apply each overlay found in the /overlays directory
      let path = ../../overlays; in with builtins;
      map (n: import (path + ("/" + n)))
          (filter (n: match ".*\\.nix" n != null ||
                      pathExists (path + ("/" + n + "/default.nix")))
                  (attrNames (readDir path)))

      ++ [(import (builtins.fetchTarball {
               url = "https://github.com/dustinlyons/emacs-overlay/archive/refs/heads/master.tar.gz";
               sha256 = emacsOverlaySha256;
           }))];
  };
}
