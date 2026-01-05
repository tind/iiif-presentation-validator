# Set up base
FROM debian:13-slim AS base

WORKDIR /app

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get --yes install --no-install-recommends \
    python3 \
    python3-venv \
    python3-legacy-cgi

apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
groupadd -g 150 appuser
useradd -u 150 -g 150 -s /sbin/nologin appuser
EOF

# Build stage
FROM base AS builder

COPY requirements.txt .

RUN <<EOF
python3 -m venv /opt/venv
/opt/venv/bin/pip install --no-cache-dir -r requirements.txt
chown -R appuser:appuser /opt/venv
EOF

# Runtime stage
FROM base

LABEL org.opencontainers.image.source=https://github.com/tind/iiif-presentation-validator

COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv
COPY --chown=appuser:appuser . .

EXPOSE 8000

USER appuser

ENTRYPOINT ["/app/docker-files/entrypoint"]

CMD ["--hostname", "0.0.0.0", "--port", "8000"]
