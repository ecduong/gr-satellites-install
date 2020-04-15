#!/bin/bash

set -e

show_help() {
  echo "Usage: $0 [option...]"
  echo
  echo "  -p, --prefix        absolute path to install gpredict"
  echo
  exit 1
}

while (( "$#" )); do
  case "$1" in
    -p | --prefix)
      prefix=$2
      shift 2
      ;;
    -h | --help)
      show_help
      exit 0
      ;;
    -* | --*)
      echo "Error: Unsupported flag $1"
      show_help
      exit 1
      ;;
    --) # end argparse
      break
  esac
done

if [[ -z ${prefix} ]]; then
  echo "Missing required parameter: --prefix"
  show_help
  exit 1
fi

cd ~
git clone https://github.com/victorhyde/gpredict
sudo apt install libtool intltool autoconf automake libcurl4-openssl-dev -y
sudo apt install pkg-config libglib2.0-dev libgtk-3-dev libgoocanvas-2.0-dev -y
cd gpredict
./autogen.sh --prefix=$prefix
sudo make
sudo make install
