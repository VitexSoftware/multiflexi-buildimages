# Ubuntu Jammy with MultiFlexi APT repo configured
FROM ubuntu:jammy

ARG REPO_URL=https://repo.multiflexi.eu
ARG KEY_URL=https://repo.multiflexi.eu/KEY.gpg

COPY scripts/add-multiflexi-apt.sh /usr/local/bin/add-multiflexi-apt.sh
RUN chmod +x /usr/local/bin/add-multiflexi-apt.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && add-multiflexi-apt.sh jammy "$REPO_URL" "$KEY_URL" \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]

