FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
MAINTAINER Joseph Lee <development@jc-lab.net>

RUN microdnf --setopt=tsflags=nodocs install -y bash which findutils curl unzip java-1.8.0-openjdk-devel git nodejs npm openssh-clients jq python3-pip jq

RUN pip3 install yq

RUN adduser -h /tmp -s /bin/bash -u 1000 -D git-user

COPY ["build.sh", "install_protoc.sh", "/"]
RUN chmod +x /*.sh && \
    /install_protoc.sh && \
    rm /install_protoc.sh

