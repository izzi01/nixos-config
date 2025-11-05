{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-specific.url = "github:nixos/nixpkgs/cd5f33f23db0a57624a891ca74ea02e87ada2564";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    # fluxcd is now provided by Nixpkgs
    # doppler, kpt are now provided by Nixpkgs
    homebrew-fuse = {
      url = "github:gromgit/homebrew-fuse";
      flake = false;
    };
    homebrew-zadark = {
      url = "github:quaric/homebrew-zadark";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-search-cli = {
      url = "github:peterldowns/nix-search-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-fuse, homebrew-zadark, home-manager, nixpkgs, nixpkgs-specific, nixpkgs-unstable, disko, nix-search-cli } @inputs:
    let
      user = "%USER%";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git ];
          shellHook = with pkgs; ''
            export EDITOR=vim
          '';
        };
      };
      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName}
        '')}/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "clean" = mkApp "clean" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
      };
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "clean" = mkApp "clean" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "rollback" = mkApp "rollback" system;
      };
    in
    {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system: let
        user = "%USER%";
      in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs // { inherit inputs; };
          modules = [
            ({ config, ...}: {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            })
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  # fluxcd, doppler, kpt are now provided by Nixpkgs
                  "gromgit/homebrew-fuse" = homebrew-fuse;
                  "quaric/zadark" = homebrew-zadark;
                };
                mutableTaps = true;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
      );

      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/nixos/home-manager.nix;
            };
          }
          ./hosts/nixos
        ];
     });

      # Home Manager standalone configurations (for non-NixOS Linux with Nix installed)
      homeConfigurations = {
        "%USER%@aarch64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-linux";
            config = {
              allowUnfree = true;
              allowBroken = true;
              allowInsecure = false;
              allowUnsupportedSystem = true;
            };
          };
          modules = [
            ({ pkgs, config, lib, ... }: {
              home = {
                username = "%USER%";
                homeDirectory = "/home/%USER%";
                stateVersion = "23.11";
                packages = pkgs.callPackage ./modules/shared/packages.nix { nixpkgs-unstable = nixpkgs-unstable; };
                file = import ./modules/shared/files.nix { inherit pkgs config; };

                # Copy nvim config as writable directory (LazyVim needs to update lock files)
                activation.copyNvimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
                  nvim_config_source="${./modules/shared/config/nvim}"
                  nvim_config_target="$HOME/.config/nvim"

                  # Only copy if source is newer or target doesn't exist
                  if [ ! -d "$nvim_config_target" ] || [ "$nvim_config_source" -nt "$nvim_config_target" ]; then
                    $DRY_RUN_CMD mkdir -p "$HOME/.config"
                    $DRY_RUN_CMD rm -rf "$nvim_config_target"
                    $DRY_RUN_CMD cp -r "$nvim_config_source" "$nvim_config_target"
                    $DRY_RUN_CMD chmod -R u+w "$nvim_config_target"
                  fi
                '';
              };
              programs = import ./modules/shared/home-manager.nix { inherit config pkgs lib; };
            })
          ];
        };

        "%USER%@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config = {
              allowUnfree = true;
              allowBroken = true;
              allowInsecure = false;
              allowUnsupportedSystem = true;
            };
          };
          modules = [
            ({ pkgs, config, lib, ... }: {
              home = {
                username = "%USER%";
                homeDirectory = "/home/%USER%";
                stateVersion = "23.11";
                packages = pkgs.callPackage ./modules/shared/packages.nix { nixpkgs-unstable = nixpkgs-unstable; };
                file = import ./modules/shared/files.nix { inherit pkgs config; };

                # Copy nvim config as writable directory (LazyVim needs to update lock files)
                activation.copyNvimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
                  nvim_config_source="${./modules/shared/config/nvim}"
                  nvim_config_target="$HOME/.config/nvim"

                  # Only copy if source is newer or target doesn't exist
                  if [ ! -d "$nvim_config_target" ] || [ "$nvim_config_source" -nt "$nvim_config_target" ]; then
                    $DRY_RUN_CMD mkdir -p "$HOME/.config"
                    $DRY_RUN_CMD rm -rf "$nvim_config_target"
                    $DRY_RUN_CMD cp -r "$nvim_config_source" "$nvim_config_target"
                    $DRY_RUN_CMD chmod -R u+w "$nvim_config_target"
                  fi
                '';
              };
              programs = import ./modules/shared/home-manager.nix { inherit config pkgs lib; };
            })
          ];
        };
      };
  };
}
