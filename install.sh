#!/usr/bin/env bash
# Symlink dotfiles from this repo into $HOME. The repo mirrors the home folder layout.
# Safe to re-run: existing real files are backed up, existing links are replaced.
set -euo pipefail

DOT="$(cd "$(dirname "$0")" && pwd)"

link() {  # usage: link <path in repo> [target path, defaults to the same path under $HOME]
  local src="$DOT/$1" dst="${2:-$HOME/$1}"
  [ -e "$src" ] || { echo "skipping $1 (not in repo)"; return; }
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.backup.$(date +%Y%m%d-%H%M%S)"
    echo "backed up existing $dst"
  fi
  ln -sfn "$src" "$dst"
  echo "linked $dst -> $src"
}

# Shared (Mac + cluster)
link .zshrc
link .tmux.conf
link .config/ohmyposh/zen.toml

# Mac only: Ghostty reads this path last on macOS, so it overrides ~/.config/ghostty/config
if [[ "$OSTYPE" == darwin* ]]; then
  link .config/ghostty/config "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
fi

# tmux theme (catppuccin) if missing
CAT="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$CAT" ]; then
  git clone https://github.com/catppuccin/tmux.git "$CAT"
fi

# Reminder about machine-specific secrets
[ -f "$HOME/.zshrc.local" ] || echo "note: no ~/.zshrc.local yet (put API keys and machine-only settings there)"

echo "done. open a new shell (and reload tmux) to pick up changes."