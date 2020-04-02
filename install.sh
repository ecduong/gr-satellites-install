#!/bin/bash

# ------------------------------------------------------
# TODO: Copyright
# ------------------------------------------------------

set -e

# install dependencies
echo "Installing dependencies..."
sudo apt install git cmake python3 python3-pip swig -y
sudo apt autoremove -y
sudo pip3 install --upgrade git+https://github.com/gnuradio/pybombs.git
pip3 install construct requests

cd ~
git clone https://github.com/quiet/libfec
cd libfec
./configure
make
sudo make install

# install gnuradio
pybombs auto-config
pybombs recipes add-defaults

sudo pybombs prefix init /usr/local -R "gnuradio-default"
# update environment variables
pythonpath="export PYTHONPATH=/usr/local/lib/python3/dist-packages:\$PYTHONPATH"
ldlibpath="export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH"

echo $pythonpath >> ~/.bashrc
echo $pythonpath >> ~/.profile
echo $ldlibpath >> ~/.bashrc
echo $ldlibpath >> ~/.profile

source ~/.bashrc
source ~/.profile

# install gr-satellites
cd ~
git clone https://github.com/daniestevez/gr-satellites
cd gr-satellites
git checkout maint-3.8
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig
cd ..
./compile_hierarchical.sh
