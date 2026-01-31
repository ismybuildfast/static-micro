# Build stage - runs build.sh to generate bench.txt with timestamps
FROM alpine:latest AS builder
WORKDIR /app
RUN apk add --no-cache bash coreutils
COPY . .
RUN chmod +x build.sh && ./build.sh

# Production stage - lightweight nginx
FROM nginx:alpine
COPY --from=builder /app/public/ /usr/share/nginx/html/

# Railway uses PORT env var, nginx needs to listen on it
# Create a template that uses the PORT variable
RUN printf 'server {\n\
    listen ${PORT:-80};\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ =404;\n\
    }\n\
}\n' > /etc/nginx/templates/default.conf.template

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
