{ pkgs, config, ... }:

{
  # Neovim LazyVim configuration
  ".config/nvim" = {
    source = ./config/nvim;
    recursive = true;
  };
}
