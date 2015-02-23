#!/bin/sh
set -e

rm -rf dist
mkdir -p dist

cleanup() {
    vagrant destroy -f
}

trap cleanup EXIT

vagrant init debian-jessie64
vagrant up

vagrant ssh -c '/usr/local/bin/build-packer.sh'

vagrant halt
