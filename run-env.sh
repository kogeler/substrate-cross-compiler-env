#!/bin/bash

docker run -u 1000 -ti --rm -v "$(pwd)/cargo_target_debian_${1}_${2}:/opt/cargo_target" -v $(pwd)/cargo_home_registry:/opt/cargo_home/registry -v $(pwd)/cargo_home_git:/opt/cargo_home/git -v $(pwd)/git:/git "rust-env-debian-${1}-${2}"
