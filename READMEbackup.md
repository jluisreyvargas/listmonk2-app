# repo-app — Imagen Listmonk (no-root) + GHCR + CI (Trivy + Cosign)

Este repo construye una imagen basada en `listmonk/listmonk:v6.0.0` con:

- usuario **no-root**
- `entrypoint.sh` que genera `/tmp/config.toml` a partir de variables
- publicación a **GitHub Container Registry (GHCR)**

Además, el CI incluye:
- Lint (shellcheck + hadolint)
- Trivy (SARIF a GitHub Security + reporte no-bloqueante)
- Firmado de imagen con **Cosign (keyless/OIDC)**

---

## Variables en runtime

- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `LISTMONK_ADMIN_USER`, `LISTMONK_ADMIN_PASSWORD` (importante solo en el primer `--install`)
- `LISTMONK_APP_ADDRESS` (def: `0.0.0.0:9000`)
- `LISTMONK_APP_ROOT_URL` (ej: `http://listmonk.local/`)

---

## Build local

```bash
docker build -t ghcr.io/TU_ORG/listmonk2:dev .
```

---

## CI (GitHub Actions)

### Tags publicados
- `sha-<commit>`
- si haces un tag Git `vX.Y.Z`, también publica ese tag

### Trivy
- **SARIF** se sube a GitHub Security (Code Scanning)
- El “gating” HIGH/CRITICAL está en modo **non-blocking**:
  - genera `trivy-report.txt`
  - lo publica en el **Job Summary**
  - y lo sube como artefacto

### update_gitops
El workflow puede actualizar el repo GitOps (cambiar `newTag`) usando un PAT:

- Secret requerido en **este repo**: `GITOPS_TOKEN`
- Debe tener permisos de escritura sobre `jluisreyvargas/listmonk2-gitops`
- El workflow usa `kustomize` instalado (no contenedor GHCR)

> Si el repo gitops tiene branch protection (no push directo a main), tendrás que cambiar el enfoque a “crear PR” en vez de push.

---

## Cosign (keyless) — firmado y verificación

El workflow firma la imagen en GHCR usando OIDC de GitHub Actions.

### 1) Obtener el digest firmado
En los logs del step `Cosign sign (keyless OIDC)` verás:

- `Digest: sha256:...`
- `Signing tags: ghcr.io/...:sha-...`

Ese `Digest` es el que debes usar para verificar.

### 2) Verificar (modo OCI 1.1 referrers)
Si estás usando cosign v2 en tu máquina (ej: v2.4.1) y el CI usa cosign v3, es normal que la firma esté en referrers OCI 1.1.

Verifica así:

```bash
export COSIGN_REGISTRY_REFERRERS_MODE=oci-1-1

cosign verify   --certificate-oidc-issuer https://token.actions.githubusercontent.com   --certificate-identity-regexp 'https://github.com/jluisreyvargas/listmonk2-app/.github/workflows/ci\.yml@.*'   ghcr.io/jluisreyvargas/listmonk2@sha256:<DIGEST_DEL_RUN>
```

> Nota: `cosign triangulate ...` puede devolver un `.sig` “teórico”, pero con cosign v3 la firma puede no existir como tag `.sig` (se publica por referrers OCI 1.1).

---

## Troubleshooting

### “no signatures found”
- Asegúrate de verificar el **digest del run que fue firmado** (el que imprime el step).
- Si tu cosign es v2 y el CI usa v3, usa:
  ```bash
  export COSIGN_REGISTRY_REFERRERS_MODE=oci-1-1
  ```
- Alternativa: instala cosign v3 localmente y verifica con esa versión.

### Trivy falla el pipeline
El gating está en `continue-on-error: true`. Si lo quieres estricto, quita esa línea.

### update_gitops push 403
- El secreto `GITOPS_TOKEN` debe existir en **listmonk2-app**
- El PAT debe tener permisos `Contents: write` sobre el repo gitops
- Si hay branch protection, necesitarás PR flow.
