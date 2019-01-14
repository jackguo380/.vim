#! /bin/bash

set -e

if ! which terminology; then
    sudo add-apt-repository ppa:niko2040/e19
    sudo apt update
    sudo apt install terminology
    sudo update-alternatives --config x-terminal-emulator
fi

git clone https://github.com/sylveon/terminology-themes
cd terminology-themes
make
sudo make install
cd ..
rm -rf terminology-themes
