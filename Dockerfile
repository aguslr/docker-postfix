ARG BASE_IMAGE=alpine:latest

FROM docker.io/${BASE_IMAGE}

RUN \
  apk add --update --no-cache postfix cyrus-sasl-login \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

EXPOSE 25/tcp

HEALTHCHECK --interval=10m --timeout=3s \
  CMD timeout 2 nc -z 127.0.0.1 25

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start-fg"]
