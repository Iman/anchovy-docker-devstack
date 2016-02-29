FROM mysql:5.5

ENV VAULT_ADDR "vault:8200"

RUN apt-get update -q \
&& apt-get install -y jq curl

RUN mkdir -p /opt/anchovy/bin/
COPY scripts/entrypoint.sh /opt/anchovy/bin/
RUN chmod u+x /opt/anchovy/bin/entrypoint.sh

ENTRYPOINT /opt/anchovy/bin/entrypoint.sh
CMD ["mysqld"]
