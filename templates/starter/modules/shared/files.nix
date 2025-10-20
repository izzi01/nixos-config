{ pkgs, config, ... }:

{
  # Neovim LazyVim configuration is handled by home.activation in home-manager.nix
  # to make it writable (LazyVim needs to update lazy-lock.json)

  # WezTerm configuration
  ".config/wezterm" = {
    source = ./config/wezterm;
    recursive = true;
  };

  # Tmux configuration
  ".config/tmux" = {
    source = ./config/tmux;
    recursive = true;
  };

  # Yazi configuration
  ".config/yazi" = {
    source = ./config/yazi;
    recursive = true;
  };

  # Zellij configuration
  ".config/zellij" = {
    source = ./config/zellij;
    recursive = true;
  };

  # Kitty configuration
  ".config/kitty" = {
    source = ./config/kitty;
    recursive = true;
  };
}
