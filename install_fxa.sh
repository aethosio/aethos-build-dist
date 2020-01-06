#!/bin/bash

if [ ! -d /home/fxa ]; then
  useradd fxa -m 2>/dev/null
fi

cd /home/fxa

# Ubuntu dependencies
cat << EOF
  Installing Ubuntu dependencies
EOF

apt -y install build-essential git python-virtualenv python-dev pkg-config libssl-dev curl libgmp3-dev graphicsmagick 

# Need these?  I think they're only for testing
# openjdk-11-jre firefox

# Install nodejs 10 and npm 6

cat << EOF
  Installing node.js and npm
EOF

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs


# install Rust nightly

# (I think this is done via npm install anyway)

cat << EOF
  Installing Rust nightly (not now, later)

    Select "2) Customize installation"
    Leave "Default host triple" blank, hit "enter"
    Type "nightly" for "Default toolchain"
    Type "y" for "Modify PATH variable?"
    Select "1) Proceed with installation"
EOF

#curl https://sh.rustup.rs -sSf | su fxa sh

# Global grunt

cat << EOF
  Installing grunt
EOF

npm install -g grunt-cli

# Install fxa from git

cat << EOF
  Installing fxa from git
EOF

# TODO The following need to be done as the fxa user

#git clone https://github.com/mozilla/fxa.git

#cd fxa

#npm install
