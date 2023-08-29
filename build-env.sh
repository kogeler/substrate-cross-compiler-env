#!/bin/bash

cd dockerfiles
docker build --load --pull --no-cache --file Dockerfile.${2} --build-arg "DEBIAN_VERSION=${1}" -t "rust-env-debian-${1}-${2}" .
