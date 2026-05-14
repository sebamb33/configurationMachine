# Configuration ZSH — macOS & Debian

## Fichiers de config

| Fichier | Emplacement | Rôle |
|---------|-------------|------|
| `.zshrc` | `~/.zshrc` | Config principale du shell |
| `.zprofile` | `~/.zprofile` | Variables d'environnement au login |
| `.zshenv` | `~/.zshenv` | Variables chargées en premier |
| `.gitconfig` | `~/.gitconfig` | Config git globale avec delta |
| `lazygit/config.yml` | `~/.config/lazygit/config.yml` | Config lazygit |
| `starship.toml` | `~/.config/starship.toml` | Prompt starship |

---

## Compatibilité OS

| Élément | macOS | Debian |
|---------|-------|--------|
| Détection | `IS_MAC=1` si `uname == Darwin` | non défini |
| Homebrew | `/opt/homebrew` | `/home/linuxbrew/.linuxbrew` |
| pnpm home | `~/Library/pnpm` | `~/.local/share/pnpm` |
| dotnet | `/usr/local/share/dotnet` | `/usr/share/dotnet` |
| clipboard | `pbcopy` | `xclip` ou `xsel` |
| JetBrains Toolbox | `~/Library/Application Support/…` | `~/.local/share/JetBrains/…` |
| git credential | `osxkeychain` | `libsecret` |

---

## Outils requis

| Outil | macOS | Debian |
|-------|-------|--------|
| zsh | `brew install zsh` | `apt install zsh` |
| oh-my-zsh | script curl | script curl |
| lazygit | `brew install lazygit` | voir ci-dessous |
| git-delta | `brew install git-delta` | `apt install git-delta` |
| ripgrep | `brew install ripgrep` | `apt install ripgrep` |
| fd | `brew install fd` | `apt install fd-find` + `ln -s $(which fdfind) ~/.local/bin/fd` |
| fzf | `brew install fzf` | `apt install fzf` |
| bat | `brew install bat` | `apt install bat` + `ln -s $(which batcat) ~/.local/bin/bat` |
| eza | `brew install eza` | voir ci-dessous |
| zoxide | `brew install zoxide` | `apt install zoxide` |
| starship | `brew install starship` | script curl |
| atuin | `brew install atuin` | script curl |
| xclip | — | `apt install xclip` |

### Installation macOS

```bash
# Accepter la licence Xcode si nécessaire
sudo xcodebuild -license accept

brew install lazygit git-delta ripgrep fd fzf bat eza zoxide starship atuin
```

### Installation Debian / Ubuntu

```bash
sudo apt update && sudo apt install -y zsh git curl ripgrep fzf zoxide fd-find bat xclip

# Aliases nécessaires (noms différents sur Debian)
mkdir -p ~/.local/bin
ln -sf $(which fdfind) ~/.local/bin/fd
ln -sf $(which batcat) ~/.local/bin/bat

# lazygit (pas dans apt)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -C ~/.local/bin -xf /tmp/lazygit.tar.gz lazygit

# eza (pas dans apt stable)
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza

# git-delta
DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep '"tag_name"' | sed 's/.*"\(.*\)".*/\1/')
curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
sudo dpkg -i /tmp/delta.deb

# starship
curl -sS https://starship.rs/install.sh | sh

# atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Plugins oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Définir zsh comme shell par défaut
chsh -s $(which zsh)
```

---

## `.zshrc` complet (cross-platform)

```zsh
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git node npm)

source $ZSH/oh-my-zsh.sh

if [[ -f ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# User configuration
export EDITOR="vim"

# OS detection
[[ "$(uname)" == "Darwin" ]] && export IS_MAC=1

# clipboard cross-platform
if [[ -n "$IS_MAC" ]]; then
  alias clip='pbcopy'
elif command -v xclip &> /dev/null; then
  alias clip='xclip -selection clipboard'
elif command -v xsel &> /dev/null; then
  alias clip='xsel --clipboard --input'
fi

# pnpm
if [[ -n "$IS_MAC" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
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
if [[ -n "$IS_MAC" ]]; then
  export DOTNET_ROOT=/usr/local/share/dotnet
elif [[ -d /usr/share/dotnet ]]; then
  export DOTNET_ROOT=/usr/share/dotnet
fi

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
    --bind='ctrl-y:execute-silent(echo {+} | clip)'"
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

## `.zprofile` — macOS

```zsh
# Added by Toolbox App
export PATH="$PATH:/Users/seb/Library/Application Support/JetBrains/Toolbox/scripts"

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# pipx
export PATH="$PATH:/Users/seb/.local/bin"
```

## `.zprofile` — Debian

```zsh
# JetBrains Toolbox
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"

# Homebrew sur Linux (optionnel)
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# pipx / binaires locaux
export PATH="$PATH:$HOME/.local/bin"
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

## `.gitconfig` — macOS

```ini
[credential]
    helper = osxkeychain
```

## `.gitconfig` — Debian

```ini
[credential]
    helper = libsecret
```

> Sur Debian, installer d'abord : `sudo apt install libsecret-1-0 libsecret-1-dev` puis compiler le helper :
> ```bash
> sudo make -C /usr/share/doc/git/contrib/credential/libsecret
> ```

---

## `.gitconfig` commun

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
