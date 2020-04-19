#!/bin/sh

container="$(buildah from docker.io/crystallang/crystal:0.33.0)"

buildah run "$container" -- bash -e <<- EOF
    # Install buildah
    apt-get update -qq
    apt-get install -yqq libzmq3-dev
EOF

buildah commit --rm "$container" "zeromq-server"
