#!/bin/bash

if ! which git; then
    echo "Please install git"
    exit 1
fi

if [ "$(realpath --relative-to "$HOME" .)" != .vim ]; then
    echo "Execute this script in the .vim directory"
    exit 1
fi

ROOT_DIR="$PWD"

function usage {
    cat <<EOF
Usage: $0 -c <config>
-c <config>
Configs:
all - install all plugins
nocompile - install only vimscript plugins

EOF
}

CONFIG=none

while getopts "c:h" opt; do 
    case $opt in
        c)
            case "$OPTARG" in
                all) ;;
                nocompile) ;;
                *) echo "Invalid config: $OPTARG"; exit 1 ;;
            esac
            CONFIG="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "Invalid option: $OPTARG"; exit 1 ;;
    esac
done

if [ "$CONFIG" = none ]; then
    usage
    echo "A configuration must be specified"
    exit 1
fi

echo "$CONFIG" > .config.txt

read -p "Install vim [y/n]?" yn

function compile_install {
    echo "Compiling vim from Github repository"
    sleep 2
    cd "$HOME" 
    if ! .vim/vim-install.sh; then
        echo "Failed to install vim"
        exit 1
    fi
    cd .vim
}

function apt_install {
    echo "Ubuntu 18.04 packages has a better vim than I can compile myself, installing via apt"
    sleep 2
    sudo apt install vim vim-gnome
}

# Do installation based on which platform we are on
if [ "$yn" = y ]; then
    source /etc/lsb-release

    if [ "$DISTRIB_ID" = LinuxMint ]; then
        if [ ${DISTRIB_RELEASE:0:2} = 19 ]; then
            apt_install
        else
            compile_install
        fi
    elif [ "$DISTRIB_ID" = Ubuntu ]; then
        if [ ${DISTRIB_RELEASE:0:2} = 18 ]; then
            apt_install
        else
            compile_install
        fi
    else
        compile_install
    fi
fi

# Get Vundle so we can install all the other plugins
if [ ! -d ./bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git bundle/Vundle.vim
    if [ $? -ne 0 ]; then
        echo "Failed to download vundle"
        exit 1
    fi
fi

cd "$ROOT_DIR"

# Run vundle to configure all plugins, ignore the errors from this
vim +PluginInstall +qall

if [ "$CONFIG" = nocompile ]; then
    exit 0
fi

if ! which cmake; then
    echo "Please install cmake"
    exit 1
fi

read -p "Install llvm6+clang6 (Works best for YCM+ColorCoded) via apt [y/n]?" yn
if [ "$yn" = y ]; then
    sudo apt install -y llvm-6.0 llvm-6.0-dev clang-6.0 libclang-6.0-dev
fi

read -p "Install libncurses zlib via apt (Required) [y/n]?" yn
if [ "$yn" = y ]; then
    sudo apt install libncurses[0-9]-dev zlib1g-dev zlib1g
fi

if [ -d ./bundle/color_coded ]; then
    cd ./bundle/color_coded
    # Add support for llvm-6.0
    git apply "$ROOT_DIR"/color_coded_llvm_6.diff
    rm -rf build
    mkdir build
    cd build

    cmake -DDOWNLOAD_CLANG=0 -DCMAKE_BUILD_TYPE=Release .. &&
        make -j$(nproc) && make install

    if [ $? -ne 0 ]; then
        echo "Failed to build color coded"
        exit 1
    fi
    rm ./* -r
else
    echo "color coded failed to download"
    exit 1
fi

cd "$ROOT_DIR"

if [ -d ./bundle/YouCompleteMe ]; then
    cd ./bundle/YouCompleteMe

    cd third_party/ycmd
    git apply "$ROOT_DIR"/ycmd_optimization.diff

    cd third_party/cregex
    git apply "$ROOT_DIR"/ycm_cregex_optimization.diff

    cd "$ROOT_DIR"/bundle/YouCompleteMe

    EXTRA_CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release" \
        ./install.py --clang-completer --system-libclang
    if [ $? -ne 0 ]; then
        echo "Failed to build YouCompleteMe"
        exit 1
    fi
else
    echo "YouCompleteMe failed to download"
    exit 1
fi

cd "$ROOT_DIR"

# CQuery
if [ ! -d cquery ]; then
    if ! git clone https://github.com/cquery-project/cquery.git --recursive cquery; then
        echo "failed to clone cquery"
        exit 1
    fi
fi

cd cquery

if ! git pull && git submodule update --init; then
    echo "failed to update cquery"
    exit 1
fi

if [ -d build ]; then
    rm -rf build
fi

mkdir build && cd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=release &&
    make -j$(nproc) && make install

if [ $? -ne 0 ]; then
    echo "Failed to build cquery"
    exit 1
fi

echo "Everything was completed successfully!"
exit 0
