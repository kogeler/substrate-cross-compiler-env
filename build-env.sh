#!/bin/bash

cd dockerfiles
docker build --pull --no-cache --file Dockerfile-env-${2} --build-arg "DEBIAN_VERSION=${1}" -t "rust-env-debian-${1}-${2}" .
