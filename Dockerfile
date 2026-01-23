# Imagen base oficial (pin explícito; evita :latest)
FROM listmonk/listmonk:v6.0.0

USER root

# Crear usuario no-root y asegurar permisos mínimos.
# Nota: la imagen oficial suele ser Alpine; si usas otra base, ajusta estas líneas.
RUN addgroup -S listmonk && adduser -S -G listmonk listmonk || true \
  && mkdir -p /tmp \
  && chown -R listmonk:listmonk /tmp || true \
  && chown -R listmonk:listmonk /listmonk || true

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

USER listmonk
WORKDIR /listmonk

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./listmonk","--config","/tmp/config.toml"]
