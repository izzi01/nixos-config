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
    autocd = true;  # From your .zshrc: setopt autocd
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History configuration from your .zshrc
    history = {
      size = 1000;
      save = 1000;
      path = "$HOME/.histfile";
      ignorePatterns = [ "pwd" "ls" "cd" ];
    };

    # Completion settings from your .zshrc (zstyle configurations)
    completionInit = ''
      autoload -Uz compinit
      compinit

      zstyle ':completion:*' auto-description 'specify: %d'
      zstyle ':completion:*' completer _expand _complete _correct _approximate
      zstyle ':completion:*' format 'Completing %d'
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*' menu select=2
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' list-colors '''
      zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
      zstyle ':completion:*' matcher-list ''' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
      zstyle ':completion:*' menu select=long
      zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
      zstyle ':completion:*' use-compctl false
      zstyle ':completion:*' verbose true
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
      zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
    '';

    # Vi mode from your .zshrc: bindkey -v
    defaultKeymap = "viins";

    initContent = ''
      # Nix daemon setup
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # OS-specific configurations from your .zshrc
      case "$(uname -s)" in
        Darwin)
          export LC_CTYPE=en_US.UTF-8
          export LC_ALL=en_US.UTF-8
          ;;
        Linux)
          eval "$(dircolors -b)"
          # WSL SSH agent
          if [ -n "$WSL_DISTRO_NAME" ] || [ -e /proc/version ] && grep -q Microsoft /proc/version; then
            eval "$($HOME/wsl2-ssh-agent)"
          fi
          ;;
      esac

      # PATH variables from your .zshrc
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH

      # Go PATH
      if command -v go &> /dev/null; then
        export PATH="$PATH:$(go env GOPATH)/bin"
      fi

      # Bun PATH
      if command -v bun &> /dev/null; then
        export PATH="$HOME/.bun/bin:$PATH"
      fi

      # Environment variables
      export EDITOR="nvim"
      export TALOSCONFIG="_out/talosconfig"

      # Podman as Docker alias (from your .zshrc)
      if command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
        alias docker='podman'
        export DOCKER_HOST=unix:///run/user/1000/podman/podman.sock
      fi

      # Tool initializations from your .zshrc
      # zoxide init is handled by programs.zoxide.enableZshIntegration
      source <(fzf --zsh)
      eval "$(direnv hook zsh)"

      # Oh-my-posh with PowerLevel10k theme (using nixpkgs)
      if command -v oh-my-posh &> /dev/null; then
        # Find oh-my-posh theme directory from nix store
        OH_MY_POSH_PATH=$(dirname $(dirname $(which oh-my-posh)))
        if [ -f "$OH_MY_POSH_PATH/share/oh-my-posh/themes/powerlevel10k_lean.omp.json" ]; then
          eval "$(oh-my-posh init zsh --config $OH_MY_POSH_PATH/share/oh-my-posh/themes/powerlevel10k_lean.omp.json)"
        else
          # Fallback to default theme if powerlevel10k_lean is not found
          eval "$(oh-my-posh init zsh)"
        fi
      fi

      # vfox activation
      if command -v vfox &> /dev/null; then
        eval "$(vfox activate zsh)"
      fi

      # pay-respects (thefuck replacement) - Note: thefuck is deprecated, using pay-respects
      if command -v pay-respects &> /dev/null; then
        eval "$(pay-respects zsh --alias)"
      fi

      # Aliases from your .zshrc
      alias cat="bat"
      alias ls="eza --color=always"
      alias zz="zellij"
      alias lg="lazygit"

      # tmux functions from your .zshrc
      function tn() {
        tmux new -s "$1"
      }

      function ta() {
        tmux a -t "$1"
      }

      # Yazi function from your .zshrc
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      # FZF functions from your .zshrc
      function of() {
        open "$(fzf)" "$@"
      }

      function nf() {
        nvim "$(fzf)" "$@"
      }

      # FZF theme from your .zshrc (Catppuccin Macchiato colors)
      fg="#CAD3F5"
      bg="#24273A"
      bg_highlight="#1E2030"
      purple="#C6A0F6"
      blue="#8AADF4"
      cyan="#91D7E3"

      export FZF_DEFAULT_OPTS="--color=fg:''${fg},bg:''${bg},hl:''${purple},fg+:''${fg},bg+:''${bg_highlight},hl+:''${purple},info:''${blue},prompt:''${cyan},pointer:''${cyan},marker:''${cyan},spinner:''${cyan},header:''${cyan}"

      # FZF with fd integration from your .zshrc
      export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

      # FZF completion functions from your .zshrc
      _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
      }

      _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
      }

      show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

      export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
      export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

      # FZF advanced customization from your .zshrc
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

      # Zellij tab name function from your .zshrc
      function set_zellij_tab_name() {
        if [[ -n "$ZELLIJ" ]]; then
          local cmd="$1"
          local new_name=$(basename "''${cmd%% *}")
          zellij action rename-tab "$new_name" >/dev/null 2>&1
        fi
      }
      preexec_functions+=(set_zellij_tab_name)

      # Doppler auto-inject from your .zshrc
      if command -v doppler &> /dev/null; then
        export DOPPLER_PROJECT="api-key"
        export DOPPLER_CONFIG="dev"
        eval "$(doppler secrets download --no-file --format env-no-quotes)"
        unset DOPPLER_PROJECT
        unset DOPPLER_CONFIG
      fi

      # Claude CLI alias and functions
      function claude() {
        unset ANTHROPIC_BASE_URL
        unset ANTHROPIC_AUTH_TOKEN
        unset ANTHROPIC_MODEL
        unset ANTHROPIC_SMALL_FAST_MODEL
        bun x @anthropic-ai/claude-code "$@"
      }

      function cc() {
        unset ANTHROPIC_BASE_URL
        unset ANTHROPIC_AUTH_TOKEN
        unset ANTHROPIC_MODEL
        unset ANTHROPIC_SMALL_FAST_MODEL
        bun x @anthropic-ai/claude-code --dangerously-skip-permissions "$@"
      }

      function glm() {
        export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
        export ANTHROPIC_AUTH_TOKEN=$GLM_API_KEY
        export ANTHROPIC_MODEL="glm-4.6"
        export ANTHROPIC_SMALL_FAST_MODEL="glm-4.6-air"
        bun x @anthropic-ai/claude-code --dangerously-skip-permissions "$@"
      }

      function glm-safe() {
        export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
        export ANTHROPIC_AUTH_TOKEN=$GLM_API_KEY
        export ANTHROPIC_MODEL="glm-4.6"
        export ANTHROPIC_SMALL_FAST_MODEL="glm-4.6-air"
        bun x @anthropic-ai/claude-code "$@"
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
      commit.gpgsign = false;
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

  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 15.0;
    };
    settings = {
      # Hiberee color scheme
      background = "#1d1f21";
      foreground = "#c5c8c6";
      cursor = "#c5c8c6";
      selection_background = "#373b41";
      selection_foreground = "#c5c8c6";

      # Black
      color0 = "#1d1f21";
      color8 = "#373b41";

      # Red
      color1 = "#cc6666";
      color9 = "#cc6666";

      # Green
      color2 = "#b5bd68";
      color10 = "#b5bd68";

      # Yellow
      color3 = "#f0c674";
      color11 = "#f0c674";

      # Blue
      color4 = "#81a2be";
      color12 = "#81a2be";

      # Magenta
      color5 = "#b294bb";
      color13 = "#b294bb";

      # Cyan
      color6 = "#8abeb7";
      color14 = "#8abeb7";

      # White
      color7 = "#c5c8c6";
      color15 = "#ffffff";
    };
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
