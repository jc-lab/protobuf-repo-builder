#!/bin/bash

protoc_version=3.14.0

platform=`uname -m`
protoc_plat=""

if [ "$platform" == "x86_64" ]; then
	protoc_plat="x86_64"
elif [ "$platform" == "i386" ]; then # Not tested
	protoc_plat="x86_32"
elif [ "$platform" == "aarch64" ]; then
	protoc_plat="aarch_64"
elif [ "$platform" == "s390x" ]; then # Not tested
	protoc_plat="s390x"
fi

if [ -z "$protoc_plat" ]; then
	echo "Not supported platform: ${platform}"
	exit 1
fi

proto_download_url="https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-linux-${protoc_plat}.zip"
curl -L -o /tmp/protoc.zip ${proto_download_url}

( cd /usr && unzip /tmp/protoc.zip )

rm /tmp/protoc.zip

chmod +x /usr/bin/protoc
chmod +005 /usr/include
chmod +005 /usr/include/google

find /usr/include/google -type d | xargs chmod +555
find /usr/include/google -type f | xargs chmod +444

exit 0

