# Prompt configuration
# This file configures the shell prompt using oh-my-posh

# Oh-my-posh with PowerLevel10k theme (using nixpkgs)
if command -v oh-my-posh &>/dev/null
    # Find oh-my-posh theme directory from nix store
    set -l oh_my_posh_path (dirname (dirname (which oh-my-posh)))
    if test -f "$oh_my_posh_path/share/oh-my-posh/themes/powerlevel10k_lean.omp.json"
        oh-my-posh init fish --config $oh_my_posh_path/share/oh-my-posh/themes/powerlevel10k_lean.omp.json | source
    else
        # Fallback to default theme if powerlevel10k_lean is not found
        oh-my-posh init fish | source
    end
end

# Vi mode for fish (optional - fish uses emacs mode by default)
# Uncomment to enable vi mode:
# fish_vi_key_bindings

# Hybrid key bindings (vi mode with emacs-style word movement)
fish_hybrid_key_bindings
