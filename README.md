# repo-app — Imagen Listmonk (no-root) + GHCR + CI (Trivy + Cosign)

Construye imagen basada en `listmonk/listmonk:v6.0.0` con usuario **no-root** y `entrypoint.sh` que genera `/tmp/config.toml`.
Publica en **GHCR** y ejecuta CI con **Trivy (SARIF + reporte non‑blocking)** y **Cosign (keyless/OIDC)**. Además, actualiza el tag en `repo-gitops`.

## Variables en runtime
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `LISTMONK_ADMIN_USER`, `LISTMONK_ADMIN_PASSWORD`
- `LISTMONK_APP_ADDRESS` (def: `0.0.0.0:9000`)
- `LISTMONK_APP_ROOT_URL` (ej: `http://listmonk.local/`)

## Build local
```bash
docker build -t ghcr.io/<ORG>/listmonk2:dev .
```

## CI (GitHub Actions)
- Lint (shellcheck + hadolint)
- Trivy: **SARIF** a Code Scanning + **reporte non‑blocking** en Job Summary / artefacto
- Cosign: firma **keyless/OIDC** por digest (OCI 1.1 referrers)
- `update_gitops`: edita `kustomization.yaml` con `kustomize edit set image` y hace push a `repo-gitops`
  - Requiere **secret** `GITOPS_TOKEN` (Contents: Read/Write en repo gitops)

### Verificar firma (cosign)
```bash
# si usas cosign v2 local:
export COSIGN_REGISTRY_REFERRERS_MODE=oci-1-1
cosign verify   --certificate-oidc-issuer https://token.actions.githubusercontent.com   --certificate-identity-regexp 'https://github.com/<ORG>/listmonk2-app/.github/workflows/ci\.yml@.*'   ghcr.io/<ORG>/listmonk2@sha256:<DIGEST>
```

---

