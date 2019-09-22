FROM quay.io/spivegin/tlmbasedebian
WORKDIR /opt/tricllproxy
RUN mkdir /opt/bin
COPY --from=quay.io/spivegin/caddy_only /opt/bin/caddy /opt/bin/caddy
ADD files/caddy/Caddyfile /opt/caddy/Caddyfile
ADD https://raw.githubusercontent.com/adbegon/pub/master/AdfreeZoneSSL.crt /usr/local/share/ca-certificates/
ADD files/bash/caddy_entry.sh /opt/bin/entry.sh
RUN update-ca-certificates --verbose &&\
    chmod +x /opt/bin/caddy &&\
    ln -s /opt/bin/caddy /bin/caddy &&\
    chmod +x /opt/bin/entry.sh &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

EXPOSE 80 
CMD ["/opt/bin/entry.sh"]