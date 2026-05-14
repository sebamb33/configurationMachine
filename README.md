# Configuration Machine — Sébastien

Configuration complète du terminal macOS : zsh, outils CLI, git et éditeurs.

---

## Contenu du repo

| Fichier | Description |
|---------|-------------|
| [`zsh-config.md`](./zsh-config.md) | `.zshrc`, `.zprofile`, `.zshenv` et guide de restauration |

---

## Outils configurés

| Outil | Rôle |
|-------|------|
| [oh-my-zsh](https://ohmyz.sh) | Framework zsh + plugins autosuggestions / syntax-highlighting |
| [starship](https://starship.rs) | Prompt rapide avec infos git et langages |
| [lazygit](https://github.com/jesseduffield/lazygit) | TUI git interactif |
| [git-delta](https://github.com/dandavison/delta) | Diff coloré side-by-side |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (`Ctrl+T`, `Ctrl+R`, `Alt+C`) |
| [bat](https://github.com/sharkdp/bat) | `cat` avec coloration syntaxique |
| [eza](https://github.com/eza-community/eza) | `ls` avec icônes et statut git |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` intelligent |
| [atuin](https://github.com/atuinsh/atuin) | Historique shell avancé |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` ultra-rapide (`rg`) |

---

## Installation rapide

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Plugins oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Outils CLI
brew install lazygit git-delta ripgrep fzf bat eza zoxide starship atuin
```

Ensuite copier les fichiers de config depuis ce repo vers leur emplacement respectif.

---

## Contribuer

Voir [`CONTRIBUTING.md`](./CONTRIBUTING.md) avant d'ajouter un fichier de config.
