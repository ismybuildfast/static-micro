# Build stage - runs build.sh to generate bench.txt with timestamps
FROM alpine:latest AS builder
WORKDIR /app
RUN apk add --no-cache bash coreutils
COPY . .
RUN chmod +x build.sh && ./build.sh

# Production stage - lightweight nginx
FROM nginx:alpine
COPY --from=builder /app/public/ /usr/share/nginx/html/

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Create a startup script that generates nginx config with PORT
RUN printf '#!/bin/sh\n\
echo "server { listen ${PORT:-80}; server_name _; root /usr/share/nginx/html; index index.html; location / { try_files \\$uri \\$uri/ =404; } }" > /etc/nginx/conf.d/default.conf\n\
exec nginx -g "daemon off;"\n' > /start.sh && chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
