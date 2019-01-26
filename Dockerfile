FROM quay.io/spivegin/golang:v1.11.4 AS build-env-go110
WORKDIR /opt/src/src/github.com/mholt
ADD files/caddy_mods/caddyhttp.go.txt /tmp/caddyhttp.go
ADD files/caddy_mods/run.go.txt /tmp/run.go
#ADD files/caddy_mods/commands.go.txt /tmp/commands.go
RUN apt-get update && apt-get install -y gcc &&\
    go get github.com/caddyserver/builds &&\
    go get github.com/mholt/caddy
# RUN cp /tmp/caddyhttp.go ${GOPATH}/src/github.com/mholt/caddy/caddyhttp/ &&\
ENV GO111MODULE=on
# cd caddy &&\
# git fetch --all --tags --prune &&\
# git checkout tags/v0.11.1 -b v0.11.1
# RUN cd caddy && rm -rf vendor && glide init --non-interactive && glide install --force
#RUN cd caddy && git checkout v0.11.1  &&\
#    cp /tmp/commands.go ${GOPATH}/src/github.com/mholt/caddy/ &&\
RUN cd caddy &&\
    cp /tmp/run.go ${GOPATH}/src/github.com/mholt/caddy/caddy/caddymain/ &&\
    cp /tmp/caddyhttp.go ${GOPATH}/src/github.com/mholt/caddy/caddyhttp/ &&\
    go mod init && go mod tidy
RUN cd caddy/caddy && go run build.go

FROM quay.io/spivegin/tlmbasedebian
WORKDIR /opt/tricllproxy
RUN mkdir /opt/bin
COPY --from=build-env-go110 /opt/src/src/github.com/mholt/caddy/caddy/caddy /opt/bin/caddy
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