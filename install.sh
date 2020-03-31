#!/bin/bash

# ------------------------------------------------------
# TODO: Copyright
# ------------------------------------------------------

show_help() {
  echo "Usage: $0 [option...]" 
  echo
  echo "  -v, --version        gnu radio version (3.7 or 3.8)"
  echo
  exit 1
}

version=3.8  # default

while (( "$#" )); do
  case "$1" in
    -v | --version)
      if [ "$2" == "3.7" ] || [ "$2" == "3.8" ]; then
	version=$2
      else
        echo "GNU Radio version $2 is not supported by this script"
	exit 1
      fi
      shift 2
      ;;
    -h | --help)
      show_help
      exit 0
      ;;
    -* | --*)
      echo "Error: Unsupported flag $1"
      exit 1
      ;;
    --) # End argparse
      break
  esac
done

# install pybombs
sudo apt install git -y
sudo apt install cmake -y
sudo apt install python3 -y
sudo apt autoremove -y
sudo apt install python3-pip -y
sudo pip3 install --upgrade git+https://github.com/gnuradio/pybombs.git

# install gr-satellites dependencies
cd ~
git clone https://github.com/quiet/libfec
cd libfec
./configure
make
sudo make install
pip3 install construct
pip3 install requests
sudo apt install swig -y

# install gnuradio
pybombs auto-config
pybombs recipes add-defaults

if [ "$version" == "3.7" ]; then
  recipe="gnuradio-stable"
else
  recipe="gnuradio-default"
fi

sudo pybombs prefix init /usr/local -R $recipe

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
git checkout maint-$version
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig
cd ..
./compile_hierarchical.sh
