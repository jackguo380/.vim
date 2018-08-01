#!/bin/bash

if ! which git; then
    echo "install git"
    exit 1
fi

if ! which cmake; then
    echo "install cmake"
    exit 1
fi

if [ "$(realpath --relative-to "$HOME" .)" != .vim ]; then
    echo "Execute this script in the .vim directory"
    exit 1
fi

ROOT_DIR="$PWD"

function usage {
    cat <<EOF
Usage: $0 [-c <config> ]
-c <config>
Configs:
all - install all plugins
nocompile - install only vimscript plugins
EOF
}

CONFIG=all

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
            ;;
        *)
            echo "Invalid option: $OPTARG" ;;
    esac
done

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

read -p "Install llvm6+clang6 via apt [y/n]?" yn
if [ "$yn" = y ]; then
    sudo apt install -y llvm-6.0 llvm-6.0-dev clang-6.0 libclang-6.0-dev
fi

if [ -d ./bundle/color_coded ]; then
    cd ./bundle/color_coded
    # Add support for llvm-6.0
    git apply "$ROOT_DIR"/color_coded_llvm_6.diff
    mkdir build
    cd build
    # Let cmake find llvm-config
    cmake -DDOWNLOAD_CLANG=0 -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_VERBOSE_MAKEFILE=1 .. && \
    make -j$(nproc) && \
    make install
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

    EXTRA_CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=1" \
        ./install.py --clang-completer --system-libclang
    if [ $? -ne 0 ]; then
        echo "Failed to build YouCompleteMe"
        exit 1
    fi
else
    echo "YouCompleteMe failed to download"
    exit 1
fi
