# glibc: the plugins built here do not run on musl (Alpine).
FROM debian:bookworm-slim

ARG PLAKAR_VERSION
LABEL org.opencontainers.image.source=https://github.com/AforInnov/plakar-packages

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl sqlite3 \
 && rm -rf /var/lib/apt/lists/*

RUN cd /tmp \
 && release="https://github.com/PlakarKorp/plakar/releases/download/v${PLAKAR_VERSION}" \
 && deb="plakar_${PLAKAR_VERSION}_linux_amd64.deb" \
 && curl -fsSLO "$release/$deb" \
 && curl -fsSL "$release/plakar_${PLAKAR_VERSION}_checksums.txt" | grep " $deb$" | sha256sum -c - \
 && dpkg -i "$deb" \
 && rm "$deb"

COPY s3_*.ptar SHA256SUMS /tmp/
RUN cd /tmp \
 && grep ' s3_' SHA256SUMS | sha256sum -c - \
 && plakar pkg add -allow-unsigned s3_*.ptar \
 && rm s3_*.ptar SHA256SUMS

COPY backup.sh /usr/local/bin/backup.sh
ENTRYPOINT ["/usr/local/bin/backup.sh"]
