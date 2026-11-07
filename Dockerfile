# Multi-stage Dockerfile for GenieACS
FROM node:20-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install GenieACS globally
RUN npm install -g --unsafe-perm genieacs@1.2.13

# Create necessary directories
RUN mkdir -p /opt/genieacs /var/log/genieacs /var/lib/genieacs

WORKDIR /opt/genieacs

# Default command can be overridden by docker-compose
CMD ["genieacs-cwmp"]
