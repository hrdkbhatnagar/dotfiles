# ============================================================
#  zshrc: shared between Mac and cluster
# ============================================================

# ---------- Machine-specific: environment ----------
if [[ "$OSTYPE" == darwin* ]]; then
  # Google Cloud SDK
  [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"
  # Antigravity
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
  # Deno
  [ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
else
  # Cluster: defines the `module` command (not loaded automatically in non-login shells like tmux panes)
  [ -f /etc/profile.d/modules.sh ] && source /etc/profile.d/modules.sh
  # Neovim installed in home dir
  export PATH="$HOME/nvim-linux-x86_64/bin:$PATH"
fi

# ---------- PATH (shared) ----------
typeset -U path                                   # drop duplicate PATH entries automatically
path=("$HOME/.local/bin" "$HOME/bin" $path)
[ -d "$HOME/.grok/bin" ] && path=("$HOME/.grok/bin" $path)
export PATH

# ---------- zinit (plugin manager) ----------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# ---------- Completions ----------
zinit light zsh-users/zsh-completions             # extra completion definitions (must come before compinit)
[ -d "$HOME/.grok/completions/zsh" ] && fpath=("$HOME/.grok/completions/zsh" $fpath)
autoload -Uz compinit && compinit
zinit cdreplay -q

# ---------- Plugins (order matters) ----------
zinit light Aloxaf/fzf-tab                        # after compinit
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting     # keep last

# ---------- Prompt and tools ----------
command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
command -v fzf >/dev/null && eval "$(fzf --zsh)"

# ---------- Keybindings ----------
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# ---------- History ----------
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ---------- Completion styling ----------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ---------- Aliases ----------
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# ---------- nvm (Node) ----------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---------- Machine-specific: after completions ----------
if [[ "$OSTYPE" == darwin* ]]; then
  # gcloud shell completion (needs compinit first)
  [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"
fi

# ---------- Local overrides and secrets (not in git) ----------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
