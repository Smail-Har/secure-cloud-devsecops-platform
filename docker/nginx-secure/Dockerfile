# syntax=docker/dockerfile:1

# Use official minimal NGINX image (alpine variant).
FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="secure-nginx" \
      org.opencontainers.image.description="Production-like hardened NGINX container" \
      org.opencontainers.image.source="secure-cloud-devsecops-platform"

# Pull latest security patches from Alpine repositories at image build time.
RUN apk --no-cache upgrade --available

# Remove default site and default nginx.conf to avoid accidental exposure
# of defaults that do not match our hardening profile.
RUN rm -f /etc/nginx/conf.d/default.conf /etc/nginx/nginx.conf

# Copy hardened NGINX configuration.
COPY nginx.conf /etc/nginx/nginx.conf

# Prepare runtime dirs for non-root execution.
# We keep ownership to uid/gid 101 (nginx user in official image).
RUN mkdir -p /var/cache/nginx /var/run /usr/share/nginx/html \
    && chown -R 101:101 /var/cache/nginx /var/run /usr/share/nginx/html /etc/nginx

# Create a minimal default page served by the secure config.
RUN printf '%s\n' \
    '<!doctype html>' \
    '<html lang="en">' \
    '<head><meta charset="utf-8"><title>Secure NGINX</title></head>' \
    '<body><h1>Secure NGINX is running</h1></body>' \
    '</html>' > /usr/share/nginx/html/index.html

# Run with least privilege.
USER 101:101

EXPOSE 80

# Keep foreground process behavior for container runtime.
STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]

