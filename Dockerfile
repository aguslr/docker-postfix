ARG BASE_IMAGE=library/alpine:latest

FROM docker.io/${BASE_IMAGE}

RUN \
  apk add --update --no-cache postfix cyrus-sasl-login \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

EXPOSE 25/tcp

HEALTHCHECK --interval=1m --timeout=3s \
  CMD netstat -tl | grep -q smtp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start-fg"]
