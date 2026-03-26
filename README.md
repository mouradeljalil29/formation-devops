# Formation Docker — Support Slidev

Support de formation Docker construit avec [Slidev](https://sli.dev/).

## Pré-requis

- Node.js LTS (recommandé : version 18+)
- `pnpm` installé globalement
- Docker Desktop (optionnel, nécessaire pour exécuter les TPs Docker)
- Git installé

## Usage

### 1) Installer les dépendances

```bash
pnpm install
```

### 2) Lancer la présentation en local

```bash
pnpm dev
```

Puis ouvrir le navigateur sur l’URL affichée (par défaut : http://localhost:3030).

### 3) Construire la présentation

```bash
pnpm build
```

### 4) Exporter la présentation

```bash
pnpm export
```

## Structure utile

- `slides.md` : point d’entrée principal
- `modules/` : contenu pédagogique par module
- `src/` : sources des TPs
