# Debian Bookworm with MultiFlexi APT repo configured
FROM debian:bookworm-slim

ARG REPO_URL=https://repo.multiflexi.eu
ARG KEY_URL=https://repo.multiflexi.eu/pubkey.gpg

COPY scripts/add-multiflexi-apt.sh /usr/local/bin/add-multiflexi-apt.sh
RUN chmod +x /usr/local/bin/add-multiflexi-apt.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && add-multiflexi-apt.sh bookworm "$REPO_URL" "$KEY_URL" \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]

