# Debian Trixie with MultiFlexi APT repo configured
FROM debian:trixie-slim

ARG REPO_URL=https://repo.multiflexi.eu
ARG KEY_URL=https://repo.multiflexi.eu/KEY.gpg

ENV DEBIAN_FRONTEND=noninteractive

COPY scripts/add-multiflexi-apt.sh /usr/local/bin/add-multiflexi-apt.sh
RUN chmod +x /usr/local/bin/add-multiflexi-apt.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg debconf-utils \
    && echo 'pbuilder pbuilder/mirrorsite string http://deb.debian.org/debian' | debconf-set-selections \
    && add-multiflexi-apt.sh trixie "$REPO_URL" "$KEY_URL" \
    && apt-get update \
&& apt-get install -y --no-install-recommends build-essential devscripts pbuilder sudo aptitude fakeroot git php unzip \
    && (getent group 222 >/dev/null || groupadd -g 222 jenkins) \
    && (id -u 222 >/dev/null 2>/dev/null || useradd -m -u 222 -g 222 -s /bin/bash -G sudo jenkins) \
    && echo 'jenkins ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jenkins \
    && chmod 0440 /etc/sudoers.d/jenkins \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]

