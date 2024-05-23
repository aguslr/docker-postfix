ARG BASE_IMAGE=library/debian:stable-slim

FROM docker.io/${BASE_IMAGE}

RUN <<-EOT bash
	set -eu

	apt-get update
	env DEBIAN_FRONTEND=noninteractive \
		apt-get install -y --no-install-recommends \
		postfix postfix-lmdb ca-certificates libsasl2-modules iproute2 \
		-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
	apt-get clean && rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/*

	sed -i 's/ y / n /' /etc/postfix/master.cf
EOT

COPY rootfs/ /

EXPOSE 25/tcp

HEALTHCHECK --interval=1m --timeout=3s \
  CMD ss -tl | grep -q smtp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start-fg"]
