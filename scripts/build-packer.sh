#!/bin/sh
set -e

rm -rf dist
mkdir -p dist

cleanup() {
    vagrant destroy -f
}

trap cleanup EXIT

ARCH="${ARCH:-amd64}"
OS="${OS:-linux}"
PACKER_REPOSITORY="https://github.com/mitchellh/packer.git"

rm -f Vagrantfile
vagrant init debian-jessie64
vagrant up

TEMPFILE="$(mktemp provision.XXXXXX.sh)"
cat > ${TEMPFILE} << EOF
#!/bin/sh
set -ex

export DEBIAN_FRONTEND="noninteractive"

sudo apt-get update
sudo apt-get -y install golang-go git mercurial
EOF

echo "I: Provisioning vagrant..."
vagrant ssh -c "sudo sh /vagrant/${TEMPFILE}"
rm -f ${TEMPFILE}

echo "I: Setting up build script..."
TEMPFILE="$(mktemp build.XXXXXX)"
cat > ${TEMPFILE} << EOF
#!/bin/sh
set -e

export GOPATH="~/gopath"
export PATH="\${PATH}:\${GOPATH}"
export XC_ARCH="${ARCH}"
export XC_OS="${OS}"
export PACKER_PATH="\${GOPATH}/src/github.com/mitchellh/packer"

go get -u github.com/mitchellh/gox
git clone ${PACKER_REPOSITORY} \${PACKER_PATH}

cd \${PACKER_PATH}
make updatedeps
make test
make bin

mv bin/* /vagrant/dist/
EOF
vagrant ssh -c "sh /vagrant/${TEMPFILE}"
rm -f ${TEMPFILE}

vagrant halt
