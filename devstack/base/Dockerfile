FROM alpine:latest

# Set environment variables
ENV VAULT_ADDR "http://vault:8200"
ENV GIT_BRANCH "dev-master"
ENV WORDPRESS_HOST "mysql"
ENV MONGODB_HOST "mongo"

# Install needed packages
RUN apk add --update curl git jq openssh-client\
&& rm -rf /var/cache/apk/*

# Configure entrypoint script
RUN mkdir -p /opt/anchovy/bin
ADD scripts/entrypoint.sh /opt/anchovy/bin/
RUN chmod u+x /opt/anchovy/bin/entrypoint.sh

# Configure ssh directory
RUN mkdir -p /root/.ssh/ \
&& chmod 755 -R /root/.ssh

VOLUME /var/www
WORKDIR /var/www

ENTRYPOINT /opt/anchovy/bin/entrypoint.sh
