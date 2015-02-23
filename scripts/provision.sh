#!/bin/sh
set -ex

export DEBIAN_FRONTEND="noninteractive"

apt-get update
apt-get -y install golang-go git mercurial

ARCH="${ARCH:-amd64}"
OS="${OS:-linux}"
PACKER_REPOSITORY="https://github.com/mitchellh/packer.git"

echo "I: Setting up build script..."
TEMPFILE="$(mktemp build.XXXXXX)"
cat > ${TEMPFILE} << EOF
#!/bin/sh
set -ex

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
Version: 0.7.5+$(date +%Y%m%d%H%M%S)
Maintainer: Ville Korhonen <ville@xd.fi>
Architecture: amd64
Description: Tool for creating identical machine images
 Packer is a tool for creating identical machine images for multiple
 platforms from a single source configuration.
Recommends: virtualbox, virtualbox-dkms, vagrant
Suggests: open-vm-tools
FOE

echo -n "Files:" >> packer.equivs
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

mv ${TEMPFILE} /usr/local/bin/build-packer.sh
chmod +x /usr/local/bin/build-packer.sh
