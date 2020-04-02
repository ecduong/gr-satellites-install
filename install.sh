#!/bin/bash

# ------------------------------------------------------
# TODO: Copyright
# ------------------------------------------------------

rm install.log
file=$(dirname $0)/install.log

# install dependencies
sudo apt install git cmake python3 python3-pip swig -y &>> $file
sudo apt autoremove -y &>> $file
sudo pip3 install --upgrade git+https://github.com/gnuradio/pybombs.git &>> $file
pip3 install construct requests &>> $file

cd ~
git clone https://github.com/quiet/libfec &>> $file
cd libfec
./configure &>> $file
make &>> $file
sudo make install &>> $file

# install gnuradio
pybombs auto-config &>> $file
pybombs recipes add-defaults &>> $file


echo "Installing GNU Radio 3.8... output logged to install.log"
sudo pybombs prefix init /usr/local -R "gnuradio-default" &>> $file
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
git clone https://github.com/daniestevez/gr-satellites &>> $file
cd gr-satellites
git checkout maint-3.8 &>> $file
mkdir build
cd build
cmake .. &>> $file
make &>> $file
sudo make install &>> $file
sudo ldconfig &>> $file
cd ..
./compile_hierarchical.sh &>> $file
