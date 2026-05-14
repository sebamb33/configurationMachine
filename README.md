# Configuration Machine — Sébastien

Configuration complète du terminal — compatible **macOS** et **Debian/Ubuntu** : zsh, outils CLI, git et éditeurs.

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

### macOS

```bash
brew install lazygit git-delta ripgrep fd fzf bat eza zoxide starship atuin
```

### Debian / Ubuntu

```bash
sudo apt install -y zsh git curl ripgrep fzf zoxide fd-find bat xclip
# Voir zsh-config.md pour lazygit, eza, delta, starship et atuin (non disponibles dans apt)
```

### Commun (oh-my-zsh + plugins)

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

Voir [`zsh-config.md`](./zsh-config.md) pour les instructions complètes et les différences par OS.

---

## Contribuer

Voir [`CONTRIBUTING.md`](./CONTRIBUTING.md) avant d'ajouter un fichier de config.
