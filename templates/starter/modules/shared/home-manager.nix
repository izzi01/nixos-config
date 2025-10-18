{ config, pkgs, lib, ... }:

let name = "%NAME%";
    user = "%USER%";
    email = "%EMAIL%"; in
{
  direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History configuration
    history = {
      size = 1000;
      save = 1000;
      path = "$HOME/.histfile";
      ignorePatterns = [ "pwd" "ls" "cd" ];
    };

    # Completion settings (zstyle configurations)
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

    # Vi mode
    defaultKeymap = "viins";

    initExtra = ''
      # Nix daemon setup
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # OS-specific configurations
      case "$(uname -s)" in
        Darwin)
          export LC_CTYPE=en_US.UTF-8
          export LC_ALL=en_US.UTF-8
          ;;
        Linux)
          eval "$(dircolors -b)"
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
          # WSL SSH agent
          if [ -n "$WSL_DISTRO_NAME" ] || [ -e /proc/version ] && grep -q Microsoft /proc/version; then
            eval "$($HOME/wsl2-ssh-agent)"
          fi
          ;;
      esac

      # PATH variables
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH

      # Go PATH
      if command -v go &> /dev/null; then
        export PATH="$PATH:$(go env GOPATH)/bin"
      fi

      # Environment variables
      export EDITOR="nvim"
      export VISUAL="nvim"
      export TALOSCONFIG="_out/talosconfig"

      # Podman as Docker alias
      if command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
        alias docker='podman'
        export DOCKER_HOST=unix:///run/user/1000/podman/podman.sock
      fi

      # Tool initializations
      eval "$(zoxide init zsh)"
      source <(fzf --zsh)
      eval "$(direnv hook zsh)"

      # Oh-my-posh with PowerLevel10k theme
      if command -v oh-my-posh &> /dev/null; then
        eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/powerlevel10k_lean.omp.json)"
      fi

      # vfox activation
      if command -v vfox &> /dev/null; then
        eval "$(vfox activate zsh)"
      fi

      # pay-respects (thefuck replacement)
      if command -v pay-respects &> /dev/null; then
        eval $(pay-respects --alias)
        eval $(pay-respects --alias fk)
      fi

      # Aliases
      alias cat="bat"
      alias ls="eza --color=always"
      alias zz="zellij"
      alias lg="lazygit"
      alias diff=difft

      # tmux functions
      function tn() {
        tmux new -s "$1"
      }

      function ta() {
        tmux a -t "$1"
      }

      # Yazi function
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      # FZF functions
      function of() {
        open "$(fzf)" "$@"
      }

      function nf() {
        nvim "$(fzf)" "$@"
      }

      # FZF theme (Catppuccin Macchiato colors)
      fg="#CAD3F5"
      bg="#24273A"
      bg_highlight="#1E2030"
      purple="#C6A0F6"
      blue="#8AADF4"
      cyan="#91D7E3"

      export FZF_DEFAULT_OPTS="--color=fg:''${fg},bg:''${bg},hl:''${purple},fg+:''${fg},bg+:''${bg_highlight},hl+:''${purple},info:''${blue},prompt:''${cyan},pointer:''${cyan},marker:''${cyan},spinner:''${cyan},header:''${cyan}"

      # FZF with fd integration
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

      # FZF advanced customization
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

      # Zellij tab name function
      function set_zellij_tab_name() {
        if [[ -n "$ZELLIJ" ]]; then
          local cmd="$1"
          local new_name=$(basename "''${cmd%% *}")
          zellij action rename-tab "$new_name" >/dev/null 2>&1
        fi
      }
      preexec_functions+=(set_zellij_tab_name)

      # Doppler auto-inject
      if command -v doppler &> /dev/null; then
        export DOPPLER_PROJECT="api-key"
        export DOPPLER_CONFIG="dev"
        eval "$(doppler secrets download --no-file --format env-no-quotes)"
        unset DOPPLER_PROJECT
        unset DOPPLER_CONFIG
      fi

      # Claude CLI functions
      function cc() {
        unset ANTHROPIC_BASE_URL
        unset ANTHROPIC_AUTH_TOKEN
        unset ANTHROPIC_MODEL
        unset ANTHROPIC_SMALL_FAST_MODEL
        claude --dangerously-skip-permissions "$@"
      }

      function glm() {
        export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
        export ANTHROPIC_AUTH_TOKEN=$GLM_API_KEY
        export ANTHROPIC_MODEL="glm-4.6"
        export ANTHROPIC_SMALL_FAST_MODEL="glm-4.6-air"
        claude --dangerously-skip-permissions "$@"
      }

      function glm-safe() {
        export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
        export ANTHROPIC_AUTH_TOKEN=$GLM_API_KEY
        export ANTHROPIC_MODEL="glm-4.6"
        export ANTHROPIC_SMALL_FAST_MODEL="glm-4.6-air"
        claude "$@"
      }

      # nix shortcuts
      shell() {
        nix-shell '<nixpkgs>' -A "$1"
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
      local wezterm = require 'wezterm'
      local config = {}

      if wezterm.config_builder then
        config = wezterm.config_builder()
      end

      -- Font configuration
      config.font = wezterm.font('MesloLGS NF')
      config.font_size = '' + (if pkgs.stdenv.hostPlatform.isDarwin then "14.0" else "10.0") + ''

      -- Window configuration
      config.window_padding = {
        left = 24,
        right = 24,
        top = 24,
        bottom = 24,
      }

      -- Color scheme
      config.colors = {
        foreground = '#c0c5ce',
        background = '#1f2528',
        cursor_bg = '#c0c5ce',
        cursor_fg = '#1f2528',
        cursor_border = '#c0c5ce',
        selection_fg = '#1f2528',
        selection_bg = '#c0c5ce',
        scrollbar_thumb = '#65737e',
        split = '#65737e',

        ansi = {
          '#1f2528', -- black
          '#ec5f67', -- red
          '#99c794', -- green
          '#fac863', -- yellow
          '#6699cc', -- blue
          '#c594c5', -- magenta
          '#5fb3b3', -- cyan
          '#c0c5ce', -- white
        },
        brights = {
          '#65737e', -- bright black
          '#ec5f67', -- bright red
          '#99c794', -- bright green
          '#fac863', -- bright yellow
          '#6699cc', -- bright blue
          '#c594c5', -- bright magenta
          '#5fb3b3', -- bright cyan
          '#d8dee9', -- bright white
        },
      }

      -- Cursor configuration
      config.default_cursor_style = 'BlinkingBlock'

      -- Tab bar
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = false
      config.use_fancy_tab_bar = true

      -- Performance
      config.front_end = "WebGpu"
      config.max_fps = 120

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
      # Example SSH configuration for GitHub
      # "github.com" = {
      #   identitiesOnly = true;
      #   identityFile = [
      #     (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
      #       "/home/${user}/.ssh/id_github"
      #     )
      #     (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      #       "/Users/${user}/.ssh/id_github"
      #     )
      #   ];
      # };
    };
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
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
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
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
      '';
    };
}
