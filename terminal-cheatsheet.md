# Terminal — Cheat Sheet

## LAZYGIT  (`lg`)

| Touche | Action |
|--------|--------|
| `lg` | Ouvrir lazygit |
| `space` | Stager / unstager un fichier |
| `a` | Stager / unstager tous les fichiers |
| `c` | Commit |
| `C` | Commit avec éditeur |
| `A` | Amend le dernier commit |
| `p` | Pull |
| `P` | Push |
| `b` | Aller dans l'onglet branches |
| `n` | Nouvelle branche |
| `r` | Renommer la branche / rebase |
| `M` | Merge dans la branche courante |
| `d` | Supprimer / discard |
| `s` | Stash |
| `t` | Revert commit |
| `g` | Reset (options) |
| `e` | Ouvrir fichier dans l'éditeur |
| `o` | Ouvrir dans le navigateur (PR) |
| `?` | Aide / toutes les touches |
| `q` | Quitter |
| `tab` | Changer de panneau |
| `[` / `]` | Changer d'onglet |
| `h` / `l` | Naviguer entre les blocs |
| `j` / `k` | Naviguer dans une liste |
| `H` / `L` | Scroller le diff |
| `K` / `J` | Scroller le diff (alt) |
| `ctrl+r` | Repos récents |

---

## GIT — Aliases

| Commande | Équivalent |
|----------|------------|
| `gs` | `git status -sb` |
| `ga <fichier>` | `git add <fichier>` |
| `gaa` | `git add .` |
| `gc` | `git commit` |
| `gcm "msg"` | `git commit -m "msg"` |
| `gco <branche>` | `git checkout <branche>` |
| `gcb <branche>` | `git checkout -b <branche>` |
| `gp` | `git push` |
| `gpl` | `git pull` |
| `glog` | Log graphique coloré |
| `gundo` | Annuler le dernier commit (garde les fichiers) |
| `git unstage <f>` | Désindexer un fichier |
| `git aliases` | Lister tous les alias git |

---

## FZF — Fuzzy Finder

| Raccourci | Action |
|-----------|--------|
| `Ctrl+T` | Recherche fichier et insère le chemin |
| `Ctrl+R` | Recherche dans l'historique de commandes |
| `Alt+C` | Recherche dossier et navigue dedans |
| `Ctrl+/` | Afficher / masquer la prévisualisation |
| `Ctrl+A` | Tout sélectionner |
| `Ctrl+Y` | Copier la sélection dans le presse-papiers |
| `fshow` | Navigation interactive dans l'historique git |

---

## EZA — Meilleur `ls`

| Commande | Description |
|----------|-------------|
| `ls` | Listing simple avec icônes |
| `la` | Listing avec fichiers cachés |
| `ll` | Listing détaillé + infos git |
| `lt` | Arbre niveau 2 |
| `llt` | Arbre niveau 3 détaillé + git |

---

## BAT — Meilleur `cat`

| Commande | Description |
|----------|-------------|
| `cat <fichier>` | Affiche avec coloration syntaxique |
| `less <fichier>` | Lecture paginée avec coloration |
| `bat -n <fichier>` | Avec numéros de ligne |
| `bat -A <fichier>` | Affiche les caractères invisibles |

---

## ZOXIDE — Meilleur `cd`

| Commande | Description |
|----------|-------------|
| `cd <dossier>` | Navigation normale (apprend le chemin) |
| `cd <partiel>` | Saute vers le dossier le plus visité qui matche |
| `cdi` | Sélection interactive avec fzf |
| `cd -` | Retourne au dossier précédent |

---

## ATUIN — Meilleur historique

| Raccourci | Action |
|-----------|--------|
| `Ctrl+R` | Recherche interactive dans l'historique |
| `Entrée` | Exécuter la commande sélectionnée |
| `Tab` | Éditer la commande avant exécution |
| `Échap` | Annuler |

---

## FONCTIONS CUSTOM

| Commande | Description |
|----------|-------------|
| `mkcd <nom>` | Crée un dossier et y entre directement |
| `gclone <url>` | Clone un repo et y entre directement |
| `port-kill <port>` | Tue le process qui occupe un port |
| `fshow` | Historique git interactif avec prévisualisation |

---

## UTILITAIRES

| Commande | Description |
|----------|-------------|
| `reload` | Recharge le `.zshrc` |
| `zshrc` | Ouvre le `.zshrc` dans vim |
| `ports` | Liste tous les ports en écoute |
| `path` | Affiche le PATH ligne par ligne |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `df` | Espace disque lisible |
| `du` | Taille du dossier courant |

---

## DELTA — Meilleur `git diff`

Activé automatiquement dans tous les `git diff`, `git show`, `git log -p`.

| Touche (dans le pager) | Action |
|------------------------|--------|
| `n` / `N` | Fichier diff suivant / précédent |
| `q` | Quitter |
| `/` | Recherche dans le diff |

---

*Fichier généré le 2026-05-14 — rechargez avec `source ~/.zshrc` après installation*
