# Static site served by unprivileged nginx (runs as uid 101, listens on 8080).
FROM nginxinc/nginx-unprivileged:1.27-alpine

LABEL service="beveganmotherfucker"
LABEL org.opencontainers.image.source="https://github.com/leobrines/beveganmotherfucker"

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /usr/share/nginx/html/

EXPOSE 8080
