{
  description = "General Purpose Configuration for macOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-specific.url = "github:nixos/nixpkgs/2c36ece932b8c0040893990da00034e46c33e3e7";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    agenix.url = "github:ryantm/agenix";
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs = { 
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
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
    homebrew-kpt = {
      url = "github:kptdev/kpt";
      flake = false;
    };
    homebrew-doppler = {
      url = "github:dopplerhq/homebrew-cli";
      flake = false;
    };
    homebrew-flux = {
      url = "github:fluxcd/homebrew-tap";
      flake = false;
    };
    homebrew-fuse = {
      url = "github:gromgit/homebrew-fuse";
      flake = false;
    };
    homebrew-youtube-music = {
      url = "github:th-ch/homebrew-youtube-music";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/dustinlyons/nix-secrets.git";
      flake = false;
    };
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, darwin, claude-desktop, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-kpt, homebrew-doppler, homebrew-flux, homebrew-fuse, homebrew-youtube-music, home-manager, plasma-manager, nixpkgs, nixpkgs-specific, flake-utils, disko, agenix, secrets, chaotic } @inputs:
    let
      user = "bscx";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git age age-plugin-yubikey ];
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
          exec ${self}/apps/${system}/${scriptName} "$@"
        '')}/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "build-switch-emacs" = mkApp "build-switch-emacs" system;
        "clean" = mkApp "clean" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
        "install-with-secrets" = mkApp "install-with-secrets" system;
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
      templates = {
        starter = {
          path = ./templates/starter;
          description = "Starter configuration without secrets";
        };
        starter-with-secrets = {
          path = ./templates/starter-with-secrets;
          description = "Starter configuration with secrets";
        };
      };
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;
      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs // { inherit user; };
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
                  "kptdev/homebrew-kpt" = homebrew-kpt;
                  "dopplerhq/homebrew-cli" = homebrew-doppler;
                  "fluxcd/homebrew-tap" = homebrew-flux;
                  "gromgit/homebrew-fuse" = homebrew-fuse;
                  "th-ch/homebrew-youtube-music" = homebrew-youtube-music;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
      );
      nixosConfigurations = 
        # Platform-based configurations (current behavior)
        nixpkgs.lib.genAttrs linuxSystems (system:
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = inputs // { inherit user; };
            modules = [
              disko.nixosModules.disko
              chaotic.nixosModules.default
              home-manager.nixosModules.home-manager {
                home-manager = {
                  sharedModules = [ plasma-manager.homeModules.plasma-manager ];
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  users.${user} = { config, pkgs, lib, ... }:
                    import ./modules/nixos/home-manager.nix { inherit config pkgs lib inputs; };
                };
              }
              ./hosts/nixos
            ];
          }
        )
        
        // # Named host configurations
        
        {
          garfield = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = inputs // { inherit user; };
            modules = [
              disko.nixosModules.disko
              chaotic.nixosModules.default
              home-manager.nixosModules.home-manager {
                home-manager = {
                  sharedModules = [ plasma-manager.homeModules.plasma-manager ];
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  users.${user} = { config, pkgs, lib, ... }:
                    import ./modules/nixos/home-manager.nix { inherit config pkgs lib inputs; };
                };
              }
              ./hosts/nixos/garfield
            ];
          };
        };

      # Home Manager standalone configurations (for non-NixOS Linux with Nix installed)
      homeConfigurations =
        let
          mkHomeConfig = system:
            let
              pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
            in {
              inherit pkgs;
              modules = [
                {
                  nixpkgs.config.allowUnfree = true;
                  home = {
                    username = user;
                    homeDirectory = "/home/${user}";
                    stateVersion = "23.11";
                    packages = pkgs.callPackage ./modules/shared/packages.nix {};
                  };
                  programs = import ./modules/shared/home-manager.nix {
                    config = {};
                    inherit pkgs;
                    lib = pkgs.lib;
                  };

                  # LazyVim configuration
                  xdg.configFile = {
                    "nvim/init.lua".text = ''
                      -- Bootstrap lazy.nvim, LazyVim and your plugins
                      require("config.lazy")
                    '';

                    "nvim/lua/config/lazy.lua".text = ''
                      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
                      if not (vim.uv or vim.loop).fs_stat(lazypath) then
                        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
                        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
                        if vim.v.shell_error ~= 0 then
                          vim.api.nvim_echo({
                            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                            { out, "WarningMsg" },
                            { "\nPress any key to exit..." },
                          }, true, {})
                          vim.fn.getchar()
                          os.exit(1)
                        end
                      end
                      vim.opt.rtp:prepend(lazypath)

                      require("lazy").setup({
                        spec = {
                          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
                          { import = "plugins" },
                        },
                        defaults = {
                          lazy = false,
                          version = false,
                        },
                        install = { colorscheme = { "tokyonight", "habamax" } },
                        checker = { enabled = true, notify = false },
                        performance = {
                          rtp = {
                            disabled_plugins = {
                              "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
                            },
                          },
                        },
                      })
                    '';

                    "nvim/lua/config/options.lua".text = ''
                      -- Options are automatically loaded before lazy.nvim startup
                    '';

                    "nvim/lua/config/keymaps.lua".text = ''
                      -- Keymaps are automatically loaded on the VeryLazy event
                      vim.keymap.set({ "n", "v" }, "x", '"_x')
                      vim.keymap.set({ "n", "v" }, "X", '"_X')
                    '';

                    "nvim/lua/config/autocmds.lua".text = ''
                      -- Autocmds are automatically loaded on the VeryLazy event
                    '';

                    "nvim/lua/plugins/colorscheme.lua".text = ''
                      return {
                        "catppuccin/nvim",
                        lazy = true,
                        name = "catppuccin",
                        opts = {
                          flavor = "frappe",
                          integrations = {
                            cmp = true,
                            gitsigns = true,
                            nvimtree = true,
                            treesitter = true,
                            notify = true,
                            mini = true,
                          },
                        },
                      }
                    '';
                  };
                }
              ];
            };
        in {
        "${user}@aarch64-linux" = home-manager.lib.homeManagerConfiguration (mkHomeConfig "aarch64-linux");

        "${user}@x86_64-linux" = home-manager.lib.homeManagerConfiguration (mkHomeConfig "x86_64-linux");
      };
    };
}
