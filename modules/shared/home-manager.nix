{ config, pkgs, lib, ... }:

let name = "bscx";  # Update with your name
    user = "bscx";
    email = "bscx@example.com"; in  # Update with your email
{

  direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

  zsh = {
    enable = true;
    autocd = false;
    cdpath = [ "~/.local/share/src" ];
    plugins = [
      {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./config;
          file = "p10k.zsh";
      }
    ];
    initContent = lib.mkBefore ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # Save and restore last directory
      LAST_DIR_FILE="$HOME/.zsh_last_dir"
      
      # Save directory on every cd
      function chpwd() {
        echo "$PWD" > "$LAST_DIR_FILE"
      }
      
      # Restore last directory on startup
      if [[ -f "$LAST_DIR_FILE" ]] && [[ -r "$LAST_DIR_FILE" ]]; then
        last_dir="$(cat "$LAST_DIR_FILE")"
        if [[ -d "$last_dir" ]]; then
          cd "$last_dir"
        fi
      fi

      export TERM=xterm-256color

      # Define PATH variables
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.composer/vendor/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH
      export PATH=$HOME/.local/share/src/conductly/bin:$PATH
      export PATH=$HOME/.local/share/src/conductly/utils:$PATH
      export PYTHONPATH="$HOME/.local-pip/packages:$PYTHONPATH"

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      # Ripgrep alias
      alias search='rg -p --glob "!node_modules/*" --glob "!vendor/*" "$@"'

      # Neovim is my editor
      export EDITOR="nvim"
      export VISUAL="nvim"

      # Initialize tools
      eval "$(zoxide init zsh)"
      eval "$(direnv hook zsh)"
      eval "$(thefuck --alias)"
      eval "$(thefuck --alias fk)"

      # Aliases from dotfiles
      alias cat="bat"
      alias ls="eza --color=always"
      alias zz="zellij"
      alias lg="lazygit"

      # NixOS/nix-darwin management aliases
      alias nix-switch="darwin-rebuild switch --flake ."
      alias nix-update="nix flake update && darwin-rebuild switch --flake ."
      alias nix-update-nixpkgs="nix flake lock --update-input nixpkgs && darwin-rebuild switch --flake ."
      alias nix-clean="nix-collect-garbage -d && darwin-rebuild switch --flake ."
      alias nix-check="nix flake check"
      alias nix-search="nix search nixpkgs"

      # Functions from dotfiles
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      function of() {
        open "$(fzf)" "$@"
      }

      function nf() {
        nvim "$(fzf)" "$@"
      }

      function tn() {
        tmux new -s "$1"
      }

      function ta() {
        tmux a -t "$1"
      }

      # FZF configuration
      fg="#CAD3F5"
      bg="#24273A"
      bg_highlight="#1E2030"
      purple="#C6A0F6"
      blue="#8AADF4"
      cyan="#91D7E3"

      export FZF_DEFAULT_OPTS="--color=fg:''${fg},bg:''${bg},hl:''${purple},fg+:''${fg},bg+:''${bg_highlight},hl+:''${purple},info:''${blue},prompt:''${cyan},pointer:''${cyan},marker:''${cyan},spinner:''${cyan},header:''${cyan}"
      export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

      # FZF completion functions
      _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
      }

      _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
      }

      show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
      export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
      export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

      _fzf_comprun() {
        local command=$1
        shift
        case "$command" in
          cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
          export|unset) fzf --preview "eval 'echo \''${}'"         "$@" ;;
          ssh)          fzf --preview 'dig {}'                   "$@" ;;
          *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
        esac
      }

      # Add Go bin to PATH if Go is installed
      if command -v go &> /dev/null; then
        export PATH="$PATH:$(go env GOPATH)/bin"
      fi

      # Podman as Docker alias if Docker is not installed
      if command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
        alias docker='podman'
        export DOCKER_HOST=unix:///run/user/1000/podman/podman.sock
      fi

      # Laravel Artisan
      alias art='php artisan'

      # Use difftastic, syntax-aware diffing
      alias diff=difft

      # Always color ls and group directories
      alias ls='ls --color=auto'
      
      # SSH wrapper functions with terminal color changes
      ssh-production() {
          # Change terminal background to dark red
          printf '\033]11;#3d1515\007'
          command ssh production "$@"
          # Reset terminal background
          printf '\033]11;#1f2528\007'
      }
      
      ssh-staging() {
          # Change terminal background to dark orange
          printf '\033]11;#3d2915\007'
          command ssh staging "$@"
          # Reset terminal background
          printf '\033]11;#1f2528\007'
      }
      
      ssh-droplet() {
          # Change terminal background to dark green
          printf '\033]11;#153d15\007'
          command ssh droplet "$@"
          # Reset terminal background
          printf '\033]11;#1f2528\007'
      }
      
      # Override ssh command to detect known hosts
      ssh() {
          case "$1" in
              production|209.97.152.81)
                  # Change terminal background to dark red
                  printf '\033]11;#3d1515\007'
                  command ssh "$@"
                  # Reset terminal background
                  printf '\033]11;#1f2528\007'
                  ;;
              staging|174.138.88.191)
                  # Change terminal background to dark orange
                  printf '\033]11;#3d2915\007'
                  command ssh "$@"
                  # Reset terminal background
                  printf '\033]11;#1f2528\007'
                  ;;
              droplet|165.227.66.119)
                  # Change terminal background to dark green
                  printf '\033]11;#153d15\007'
                  command ssh "$@"
                  # Reset terminal background
                  printf '\033]11;#1f2528\007'
                  ;;
              *)
                  command ssh "$@"
                  ;;
          esac
      }
      
      # Tmux alias for conductly devenv session
      alias conductly='tmux -S /run/user/1000/tmux-conductly attach -t conductly'
      
      # Tmux alias for river devenv session
      alias river='tmux -S /run/user/1000/tmux-river attach -t river'

      # macOS-style open command using Nautilus
      ${lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
        alias open="xdg-open"
        alias rxp="/home/dustin/.local/share/src/restxp/restxp"

        # Reboot to Windows partition (Linux only)
        alias windows='sudo systemctl reboot --boot-loader-entry=auto-windows'
      ''}
      
      # Screenshot function with path selection
      screenshot() {
          local project_path
          case "$1" in
              conductly|c)
                  project_path="/home/dustin/.local/share/src/conductly"
                  ;;
              bitcoin-noobs|b)
                  project_path="/home/dustin/.local/share/src/bitcoin-noobs"
                  ;;
              *)
                  echo "Usage: screenshot [conductly|c|bitcoin-noobs|b]"
                  echo "  conductly (c) - Save to conductly project"
                  echo "  bitcoin-noobs (b) - Save to bitcoin-noobs project"
                  return 1
                  ;;
          esac
          
          # Prompt user for filename
          echo -n "Enter screenshot filename (without .png extension): "
          read -r user_filename
          
          # Use user input or fallback to timestamp if empty
          if [[ -n "$user_filename" ]]; then
              local filename="$user_filename.png"
          else
              local filename="screenshot-$(date +'%Y%m%d-%H%M%S').png"
          fi
          
          spectacle -r -b -o "$project_path/$filename"
          echo "Screenshot saved to: $project_path/$filename"
      }
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
	    editor = "nvim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      # Language servers
      lua-language-server
      nil # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      pyright
      gopls

      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier
      black

      # Other tools
      ripgrep
      fd
      gcc
    ];
  };

  wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local config = {}

      config.font = wezterm.font("JetBrains Mono")
      config.font_size = 16.0

      -- Set default program based on operating system (Zellij on macOS if available)
      if wezterm.target_triple:find("apple") then
        local homebrew_paths_string = "/opt/homebrew/bin/zellij, /usr/local/bin/zellij"
        local zellij_in_homebrew = #wezterm.glob(homebrew_paths_string) > 0
        if zellij_in_homebrew then
          config.default_prog = { "/opt/homebrew/bin/zellij", "-l", "welcome" }
        else
          config.default_prog = nil
        end
      end

      -- Hiberee theme colors
      local hiberee = {
        foreground = "#c5c8c6",
        background = "#1d1f21",
        cursor_bg = "#c5c8c6",
        cursor_border = "#c5c8c6",
        cursor_fg = "#1d1f21",
        selection_bg = "#373b41",
        selection_fg = "#c5c8c6",

        ansi = {
          "#1d1f21", -- black
          "#cc6666", -- red
          "#b5bd68", -- green
          "#f0c674", -- yellow
          "#81a2be", -- blue
          "#b294bb", -- magenta
          "#8abeb7", -- cyan
          "#c5c8c6", -- white
        },

        brights = {
          "#373b41", -- bright black
          "#cc6666", -- bright red
          "#b5bd68", -- bright green
          "#f0c674", -- bright yellow
          "#81a2be", -- bright blue
          "#b294bb", -- bright magenta
          "#8abeb7", -- bright cyan
          "#ffffff", -- bright white
        },
      }

      config.colors = hiberee

      -- Key bindings
      config.keys = {
        { key = "F11", action = wezterm.action.ToggleFullScreen },
        { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
      }

      -- URL hyperlink rules (for Markdown files)
      config.hyperlink_rules = {
        -- Matches: a URL in parens: (URL)
        {
          regex = "\\((\\w+://\\S+)\\)",
          format = "$1",
          highlight = 1,
        },
        -- Matches: a URL in brackets: [URL]
        {
          regex = "\\[(\\w+://\\S+)\\]",
          format = "$1",
          highlight = 1,
        },
        -- Matches: a URL in curly braces: {URL}
        {
          regex = "\\{(\\w+://\\S+)\\}",
          format = "$1",
          highlight = 1,
        },
        -- Matches: a URL in angle brackets: <URL>
        {
          regex = "<(\\w+://\\S+)>",
          format = "$1",
          highlight = 1,
        },
        -- Handle URLs not wrapped in brackets
        {
          regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
          format = "$1",
          highlight = 1,
        },
        -- implicit mailto link
        {
          regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
          format = "mailto:$0",
        },
      }

      config.hide_mouse_cursor_when_typing = false

      return config
    '';
  };

  ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
    matchBlocks = {
      "*" = {
        # Set the default values we want to keep
        sendEnv = [ "LANG" "LC_*" ];
        hashKnownHosts = true;
      };
      #"github.com" = {
      #  identitiesOnly = true;
      #  identityFile = [
      #    (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
      #      "/home/${user}/.ssh/id_github"
      #    )
      #    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      #      "/Users/${user}/.ssh/id_github"
      #    )
      #  ];
      #};
    };
  };

  tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    sensibleOnTop = false;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible  # Re-enabled with workaround below
      yank
      prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
           set -g @tmux_power_theme 'gold'
        '';
      }
      {
        plugin = resurrect; # Used by tmux-continuum

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '/Users/dustin/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
    terminal = "screen-256color";
    prefix = "C-x";
    escapeTime = 10;
    historyLimit = 50000;
    extraConfig = ''
      # Remove Vim mode delays
      set -g focus-events on

      # Enable full mouse support
      set -g mouse on

      # -----------------------------------------------------------------------------
      # Key bindings
      # -----------------------------------------------------------------------------

      # Unbind default keys
      unbind C-b
      unbind '"'
      unbind %

      # Split panes, vertical or horizontal
      bind-key x split-window -v
      bind-key v split-window -h

      # Move around panes with vim-like bindings (h,j,k,l)
      bind-key -n M-k select-pane -U
      bind-key -n M-h select-pane -L
      bind-key -n M-j select-pane -D
      bind-key -n M-l select-pane -R

      # Smart pane switching with awareness of Vim splits.
      # This is copy paste from https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
      
      # Darwin-specific fix for tmux 3.5a with sensible plugin
      # This MUST be at the very end of the config
      set -g default-command "$SHELL"
      '';
    };
}
