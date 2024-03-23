#!/bin/sh

# Configure Postfix
postconf -e 'maillog_file = /dev/stdout'
postconf -e 'inet_interfaces = all'
postconf -e 'smtpd_tls_security_level = none'
if env | grep -q ^POSTFIX_; then

	postconf -e "myhostname = ${POSTFIX_HOSTNAME}"
	if [ -z "${POSTFIX_DOMAIN}" ]; then
		POSTFIX_DOMAIN="${POSTFIX_HOSTNAME#*.}"
	fi
	postconf -e "mydomain = ${POSTFIX_DOMAIN}"
	postconf -e 'myorigin = $mydomain'

	if [ "${POSTFIX_DESTINATION}" ]; then
		postconf -e "mydestination = ${POSTFIX_DESTINATION}"
	else
		postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain'
	fi

	if [ "${POSTFIX_NETWORKS}" ]; then
		postconf -e "mynetworks = ${POSTFIX_NETWORKS}"
	else
		postconf -e 'mynetworks = 127.0.0.0/8, 192.168.0.0/16'
	fi

	postconf -e "relayhost = [${POSTFIX_RELAYSERVER}]:${POSTFIX_RELAYPORT:=587}"
	if [ "${POSTFIX_RELAYUSER}" ]; then
		postconf -e 'smtp_sasl_auth_enable = yes'
		postconf -e 'smtp_sasl_password_maps = lmdb:/etc/postfix/sasl_passwd'
		postconf -e 'smtp_sasl_security_options = noanonymous'
		postconf -e 'smtp_tls_wrappermode = yes'
		postconf -e 'smtp_tls_security_level = encrypt'
		postconf -e 'smtp_use_tls = yes'
		if [ ! -f /etc/postfix/sasl_passwd ]; then
			printf '[%s]:%d %s:%s\n' \
				"${POSTFIX_RELAYSERVER}" "${POSTFIX_RELAYPORT}" \
				"${POSTFIX_RELAYUSER}" "${POSTFIX_RELAYPASS}" \
				> /etc/postfix/sasl_passwd
		fi
		postmap lmdb:/etc/postfix/sasl_passwd
	fi

	if [ "${POSTFIX_OVERWRITE}" ]; then
		printf '/^From:.*$/ REPLACE From: %s\n' "${POSTFIX_OVERWRITE}" \
			> /etc/postfix/smtp_header_checks
		postmap /etc/postfix/smtp_header_checks
		postconf -e 'smtp_header_checks = regexp:/etc/postfix/smtp_header_checks'
	fi

	if [ "${POSTFIX_FROM}" ]; then
		printf '/^(.*)@.*\.%s$/ %s\n' "${POSTFIX_DOMAIN}" "${POSTFIX_FROM}" \
			> /etc/postfix/canonical_sender
		postconf -e 'sender_canonical_classes = envelope_sender, header_sender'
		postconf -e 'sender_canonical_maps = regexp:/etc/postfix/canonical_sender'
	fi

	if [ "${POSTFIX_TO}" ]; then
		printf '/^.*@.*\.%s$/ %s\n' "${POSTFIX_DOMAIN}" "${POSTFIX_TO}" \
			> /etc/postfix/canonical_recipient
		postconf -e 'recipient_canonical_classes = envelope_recipient, header_recipient'
		postconf -e 'recipient_canonical_maps = regexp:/etc/postfix/canonical_recipient'
	fi

fi

# Set up aliases
postalias /etc/postfix/aliases

# Start Postfix
/usr/sbin/postfix "$@"
