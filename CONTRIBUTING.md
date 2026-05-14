# Convention — Ajout d'un fichier de config

## Règle obligatoire

> **À chaque fois qu'un nouveau fichier de configuration est ajouté dans ce repo, le `README.md` doit être mis à jour.**

---

## Quoi mettre à jour dans le README

### 1. Tableau "Contenu du repo"

Ajouter une ligne avec le nom du fichier et sa description :

```markdown
| [`nom-du-fichier.md`](./nom-du-fichier.md) | Description courte de ce que contient le fichier |
```

### 2. Tableau "Outils configurés" (si applicable)

Si le fichier introduit un nouvel outil, ajouter une ligne :

```markdown
| [nom-outil](https://lien-officiel) | Rôle en une phrase |
```

---

## Checklist avant de commit

- [ ] Le fichier de config est créé
- [ ] Le `README.md` est mis à jour (tableau "Contenu du repo")
- [ ] Si nouvel outil → le tableau "Outils configurés" est mis à jour
- [ ] Le commit mentionne les deux fichiers modifiés

---

## Exemple de commit correct

```
feat: add starship config

- Ajout de starship.toml
- README mis à jour (contenu + outils)
```

## Exemple de commit incorrect

```
add starship.toml       ← README non mis à jour, pas mentionné
```
