FROM alpine:latest
MAINTAINER Joseph Lee <development@jc-lab.net>

RUN apk add bash bash protobuf git openjdk8 nodejs npm openssh-client jq python3 py3-pip jq && \
    pip3 install yq

COPY ["build.sh", "/build.sh"]
RUN chmod +x /build.sh

RUN adduser -h /tmp -s /bin/bash -u 1000 -D git-user


