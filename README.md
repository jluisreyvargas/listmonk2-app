# repo-app — Imagen Listmonk (no-root) + GHCR

Este repo construye una imagen basada en `listmonk/listmonk:v6.0.0` con:

- usuario **no-root**
- `entrypoint.sh` que genera `/tmp/config.toml` a partir de variables
- publicación a **GitHub Container Registry (GHCR)**

## Variables en runtime

- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `LISTMONK_ADMIN_USER`, `LISTMONK_ADMIN_PASSWORD` (solo importante en el primer `--install`)
- `LISTMONK_APP_ADDRESS` (def: `0.0.0.0:9000`)
- `LISTMONK_APP_ROOT_URL` (ej: `http://listmonk.local/`)

## Build local

```bash
docker build -t ghcr.io/TU_ORG/listmonk2:dev .
```

## CI (GitHub Actions)

- lint (shellcheck + hadolint)
- build
- push a GHCR con tags:
  - `sha-<commit>`
  - si haces un tag Git `vX.Y.Z`, también publica ese tag
