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

export GOPATH="\${HOME}/gopath"
export PATH="\${PATH}:\${GOPATH}/bin"
export XC_ARCH="${ARCH}"
export XC_OS="${OS}"
export PACKER_PATH="\${GOPATH}/src/github.com/mitchellh/packer"

echo "I: Install gox..."
go get -u github.com/mitchellh/gox

echo "I: Clone packer to GOPATH..."
git clone ${PACKER_REPOSITORY} \${PACKER_PATH}

echo "I: Install dependencies..."
cd \${PACKER_PATH}
make updatedeps

echo "I: Run tests..."
make test

echo "I: Build binaries..."
make bin

echo "I: Set-up equivs..."
cat >packer.equivs << FOE
Section: misc
Priority: optional
Homepage: https://packer.io/
Standards-Version: 3.9.2

Package: packer
Version: 0.7.5
Maintainer: Ville Korhonen <ville@xd.fi>
Architecture: amd64
Description: Tool for creating identical machine images
 Packer is a tool for creating identical machine images for multiple
 platforms from a single source configuration.
Recommends: virtualbox, virtualbox-dkms, vagrant
Suggests: open-vm-tools
Files:FOE

FILES="\$(ls bin/)"
for f in \${FILES}
do
    echo " bin/\$f /usr/" >>packer.equivs
done

echo "I: Build .deb with equivs..."
equivs-build packer.equivs

echo "I: Collect artifacts..."
mv *.deb /vagrant/dist/
EOF
vagrant ssh -c "sh /vagrant/${TEMPFILE}"
rm -f ${TEMPFILE}

vagrant halt
