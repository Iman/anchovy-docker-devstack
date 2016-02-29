FROM alpine:latest
MAINTAINER Iman Samizadeh

ENV VERSION 0.4.1

ADD http://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_linux_amd64.zip vault.zip

RUN apk update \
	&& apk add unzip \
	&& apk add curl \
	&& apk add jq \
	&& unzip vault.zip \
	&& mv vault /bin/ \
	&& chmod u+x /bin/vault \
	&& rm vault.zip \
	&& apk add ca-certificates

COPY config/vault.hcl /etc/vault.hcl
VOLUME /var/vault/

EXPOSE 8200

ENTRYPOINT ["vault", "server"]
CMD ["--config", "/etc/vault.hcl"]
