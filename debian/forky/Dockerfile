# Debian Forky with MultiFlexi APT repo configured
FROM debian:forky-slim

ARG REPO_URL=https://repo.multiflexi.eu
ARG KEY_URL=https://repo.multiflexi.eu/KEY.gpg

ENV DEBIAN_FRONTEND=noninteractive

COPY scripts/add-multiflexi-apt.sh /usr/local/bin/add-multiflexi-apt.sh
RUN chmod +x /usr/local/bin/add-multiflexi-apt.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg debconf-utils \
    && echo 'pbuilder pbuilder/mirrorsite string http://deb.debian.org/debian' | debconf-set-selections \
    && add-multiflexi-apt.sh forky "$REPO_URL" "$KEY_URL" \
    && apt-get update \
    && apt-get install -y --no-install-recommends build-essential devscripts pbuilder \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]

