[aguslr/docker-postfix][1]
==========================

[![docker-pulls](https://img.shields.io/docker/pulls/aguslr/postfix)](https://hub.docker.com/r/aguslr/postfix) [![image-size](https://img.shields.io/docker/image-size/aguslr/postfix/latest)](https://hub.docker.com/r/aguslr/postfix)


This *Docker* image sets up *Postfix* inside a docker container.

> **[Postfix][2]** is a free and open-source mail transfer agent (MTA) that
> routes and delivers electronic mail.


Installation
------------

To use *docker-postfix*, follow these steps:

1. Clone and start the container:

       docker run -p 25:25 \
         -e POSTFIX_HOSTNAME=mail.example.com \
         -e POSTFIX_RELAYSERVER=smtp.mail.com \
         -e POSTFIX_RELAYUSER=me@mail.com \
         -e POSTFIX_RELAYPASS=123456 \
         docker.io/aguslr/postfix:latest

2. Configure your systems to send email to your *Postfix* server's IP address on
   port `25`.


### Variables

The image is configured using environment variables passed at runtime. All these
variables are prefixed by `POSTFIX_`.

| Variable      | Function                                       | Required |
| :------------ | :--------------------------------------------- | -------- |
| `HOSTNAME`    | Hostname for the container                     | Y        |
| `DOMAIN`      | Domain name for Postfix                        | N        |
| `RELAYSERVER` | Address of the SMTP server to use              | Y        |
| `RELAYPORT`   | Port to connect to the SMTP server             | N        |
| `RELAYUSER`   | Username of SMTP server                        | Y        |
| `RELAYPASS`   | Password of SMTP server                        | N        |
| `OVERWRITE`   | Use this *from* address for all relayed emails | N        |
| `FROM`        | Rewrite *from* address                         | N        |
| `TO`          | Rewrite *to* address                           | N        |
| `DESTINATION` | List of domains allowed to use relay server    | N        |
| `NETWORKS`    | List of networks allowed to use relay server   | N        |


#### Password file

As an alternative to passing the relay's server password at runtime, we can use
a password file (e.g. `passwd`) with the format:

    [RELAYSERVER]:RELAYPORT RELAYUSER:RELAYPASS

We can then mount this file at runtime with this command:

    docker run -p 25:25 \
      -e POSTFIX_HOSTNAME=mail.example.com \
      -e POSTFIX_RELAYSERVER=smtp.mail.com \
      -e POSTFIX_RELAYUSER=me@mail.com \
      -v "${PWD}"/passwd:/etc/postfix/sasl_passwd \
      docker.io/aguslr/postfix:latest


Build locally
-------------

Instead of pulling the image from a remote repository, you can build it locally:

1. Clone the repository:

       git clone https://github.com/aguslr/docker-postfix.git

2. Change into the newly created directory and use `docker-compose` to build and
   launch the container:

       cd docker-postfix && docker-compose up --build -d


[1]: https://github.com/aguslr/docker-postfix
[2]: https://www.postfix.org/
