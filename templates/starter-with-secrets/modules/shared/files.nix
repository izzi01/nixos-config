{ pkgs, config, ... }:

# let
#  githubPublicKey = "ssh-ed25519 AAAA...";
# in
{

  # ".ssh/id_github.pub" = {
  #   text = githubPublicKey;
  # };

  # Neovim LazyVim configuration
  ".config/nvim" = {
    source = ./config/nvim;
    recursive = true;
  };
}
