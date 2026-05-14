# Configuration ZSH — Machine de Sébastien

## Fichiers de config

| Fichier | Rôle |
|---------|------|
| `~/.zshrc` | Config principale du shell |
| `~/.zprofile` | Variables d'environnement (PATH, Homebrew…) |
| `~/.zshenv` | Variables chargées en premier (Flutter, Cargo) |
| `~/.gitconfig` | Config git globale avec delta |
| `~/.config/lazygit/config.yml` | Config lazygit (thème Catppuccin, delta) |
| `~/.config/starship.toml` | Prompt starship |

---

## Outils installés

| Outil | Install | Rôle |
|-------|---------|------|
| oh-my-zsh | `~/.oh-my-zsh` | Framework zsh |
| lazygit | `brew install lazygit` | TUI git |
| git-delta | `brew install git-delta` | Diff coloré |
| ripgrep | `brew install ripgrep` | `grep` ultra-rapide (`rg`) |
| fd | cargo | `find` rapide |
| fzf | `brew install fzf` | Fuzzy finder |
| bat | `brew install bat` | `cat` avec coloration |
| eza | `brew install eza` | `ls` avec icônes et git |
| zoxide | `brew install zoxide` | `cd` intelligent |
| starship | `brew install starship` | Prompt rapide |
| atuin | `brew install atuin` | Historique shell avancé |

### Installer tous les outils d'un coup

```bash
brew install lazygit git-delta ripgrep fzf bat eza zoxide starship atuin
```

---

## `.zshrc` complet

```zsh
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(git node npm)

source $ZSH/oh-my-zsh.sh

# Load custom plugins (ensure no duplicates with oh-my-zsh)
if [[ -f ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# User configuration
export EDITOR="vim"

# pnpm
export PNPM_HOME="/Users/seb/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
if [[ -s "$HOME/.bun/_bun" ]]; then
  source "$HOME/.bun/_bun"
fi
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# rbenv
if command -v rbenv &> /dev/null; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - zsh)"
fi

# deno
if [[ -s "$HOME/.deno/env" ]]; then
  . "$HOME/.deno/env"
fi

# dotnet
export DOTNET_ROOT=/usr/local/share/dotnet

# nvm
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  \. "$NVM_DIR/nvm.sh"
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  \. "$NVM_DIR/bash_completion"
fi

# kiro editor integration
if command -v kiro &> /dev/null; then
  [[ "$TERM_PROGRAM" == "kiro" ]] && \. "$(kiro --locate-shell-integration-path zsh)"
fi

# pyenv
if command -v pyenv &> /dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
fi

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$PATH:$HOME/.yarn/bin"

# Angular CLI completion (only if installed)
if command -v ng &> /dev/null; then
  source <(ng completion script) 2>/dev/null
fi

# ── Starship prompt ──────────────────────────────────────────────────────────
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# ── fzf ──────────────────────────────────────────────────────────────────────
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS="
    --height 50%
    --layout=reverse
    --border=rounded
    --info=inline
    --prompt='❯ '
    --pointer='▶'
    --marker='✓'
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --preview 'bat --style=numbers --color=always --line-range :300 {}'
    --preview-window=right:60%:hidden
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-a:select-all'
    --bind='ctrl-y:execute-silent(echo {+} | pbcopy)'"
fi

# ── zoxide (remplace cd) ─────────────────────────────────────────────────────
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# ── atuin (historique shell amélioré) ────────────────────────────────────────
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# ── bat (remplace cat) ───────────────────────────────────────────────────────
if command -v bat &> /dev/null; then
  export BAT_THEME="Catppuccin-mocha"
  alias cat='bat --paging=never'
  alias less='bat --paging=always'
fi

# ── eza (remplace ls) ────────────────────────────────────────────────────────
if command -v eza &> /dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --icons --group-directories-first -la --git'
  alias la='eza --icons --group-directories-first -a'
  alias lt='eza --icons --tree --level=2'
  alias llt='eza --icons --tree --level=3 -la --git'
fi

# ── lazygit ───────────────────────────────────────────────────────────────────
alias lg='lazygit'

# ── git aliases utiles ────────────────────────────────────────────────────────
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gpl='git pull'
alias glog='git lg'
alias gundo='git undo'

# ── navigation rapide ─────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# ── utilitaires ───────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -sh'
alias ports='lsof -i -P -n | grep LISTEN'
alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.zshrc && echo "zshrc rechargé"'
alias zshrc='$EDITOR ~/.zshrc'

# fshow — recherche interactive dans l'historique git (fzf + lazygit)
fshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index \
    --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
      (grep -o '[a-f0-9]\{7\}' | head -1 |
      xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
      {}
FZF-EOF"
}

# mkcd — crée un dossier et s'y déplace
mkcd() { mkdir -p "$1" && cd "$1"; }

# gclone — clone et entre dans le repo
gclone() { git clone "$1" && cd "$(basename "$1" .git)"; }

# port-kill — tue le process sur un port donné
port-kill() { lsof -ti :"$1" | xargs kill -9 2>/dev/null && echo "Port $1 libéré"; }
```

---

## `.zprofile`

```zsh
# Added by Toolbox App
export PATH="$PATH:/Users/seb/Library/Application Support/JetBrains/Toolbox/scripts"

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# pipx
export PATH="$PATH:/Users/seb/.local/bin"
```

---

## `.zshenv`

```zsh
# Flutter
export PATH="$HOME/Documents/developement/flutter/bin:$PATH"

# Rust/Cargo
. "$HOME/.cargo/env"
```

---

## `.gitconfig`

```ini
[user]
    name = Sébastien33am
    email = sebastien@ambona.fr

[core]
    autocrlf = input
    excludesfile = ~/.gitignore_global
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    dark = true
    side-by-side = true
    line-numbers = true
    syntax-theme = Monokai Extended

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default

[alias]
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    st = status -sb
    co = checkout
    br = branch
    undo = reset HEAD~1 --mixed
    unstage = restore --staged
    aliases = config --get-regexp alias
```

---

## Restauration depuis zéro

```bash
# 1. Installer Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Installer oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. Installer les plugins oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 4. Installer les outils
brew install lazygit git-delta ripgrep fzf bat eza zoxide starship atuin

# 5. Copier les fichiers de config
# ~/.zshrc, ~/.zprofile, ~/.zshenv, ~/.gitconfig
# ~/.config/lazygit/config.yml
# ~/.config/starship.toml
```
