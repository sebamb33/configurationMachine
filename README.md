# Configuration Machine — Sébastien

Configuration complète de machine — compatible **macOS** et **Debian/Ubuntu** : terminal zsh, outils CLI, git, et setup VPS sécurisé.

---

## Contenu du repo

| Fichier | Description |
|---------|-------------|
| [`zsh-config.md`](./zsh-config.md) | `.zshrc`, `.zprofile`, `.zshenv`, `.gitconfig` et guide de restauration (macOS + Debian) |
| [`terminal-cheatsheet.md`](./terminal-cheatsheet.md) | Référence rapide de toutes les commandes et raccourcis |
| [`setup-vps.sh`](./setup-vps.sh) | Script d'installation et de sécurisation d'un VPS Ubuntu/Debian |
| [`vps-setup.md`](./vps-setup.md) | Documentation complète du setup VPS |

---

## Terminal & ZSH

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

### Installation rapide — Terminal

**macOS**
```bash
brew install lazygit git-delta ripgrep fd fzf bat eza zoxide starship atuin
```

**Debian / Ubuntu**
```bash
sudo apt install -y zsh git curl ripgrep fzf zoxide fd-find bat xclip
# Voir zsh-config.md pour lazygit, eza, delta, starship et atuin
```

**oh-my-zsh + plugins (commun)**
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

---

## VPS Sécurisé

Stack installée par [`setup-vps.sh`](./setup-vps.sh) :

| Outil | Rôle |
|-------|------|
| [UFW](https://wiki.ubuntu.com/UncomplicatedFirewall) | Firewall — ports 22/80/443/9090 uniquement |
| [Fail2ban](https://www.fail2ban.org) | Blocage automatique des IPs malveillantes |
| [Nginx](https://nginx.org) | Reverse proxy + security headers + rate limiting |
| [Cockpit](https://cockpit-project.org) | Interface web d'administration (port 9090) |
| [GoAccess](https://goaccess.io) | Stats de visites Nginx en temps réel |
| [Netdata](https://www.netdata.cloud) | Monitoring CPU/RAM/réseau (localhost:19999) |
| [Docker](https://www.docker.com) | Conteneurs |
| [Uptime Kuma](https://github.com/louislam/uptime-kuma) | Monitoring de disponibilité (localhost:3001) |

### Utilisation du script

```bash
# Interactif
wget https://raw.githubusercontent.com/sebamb33/configurationMachine/main/setup-vps.sh
chmod +x setup-vps.sh
sudo ./setup-vps.sh

# Silencieux (via variables d'environnement)
sudo SSH_PORT=2222 ADMIN_USER=seb TIMEZONE=Europe/Paris DOMAIN=monsite.fr ./setup-vps.sh
```

Le script vérifie chaque outil avant de l'installer — il est **idempotent** (safe à relancer).

Voir [`vps-setup.md`](./vps-setup.md) pour la documentation complète.

---

## Contribuer

Voir [`CONTRIBUTING.md`](./CONTRIBUTING.md) avant d'ajouter un fichier de config.
