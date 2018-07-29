#!/bin/bash

if [ "$(realpath --relative-to "$HOME" .)" != .vim ]; then
    echo "Execute this script in the .vim directory"
    exit 1
fi

ROOT_DIR="$PWD"

read -p "Install vim [y/n]?" yn

if [ "$yn" = y ]; then
    cd "$HOME" 
    if ! .vim/vim-install.sh; then
        echo "Failed to install vim"
        exit 1
    fi
    cd .vim
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

if [ -d ./bundle/color_coded ]; then
    cd ./bundle/color_coded
    # Add support for llvm-6.0
    git apply "$ROOT_DIR"/color_coded_llvm_6.diff
    mkdir build
    cd build
    # Let cmake find llvm-config
    cmake -DDOWNLOAD_CLANG=0 .. && \
    make -j$(nproc) && \
    make install
    if [ $? -ne 0 ]; then
        echo "Failed to build color coded"
        exit 1
    fi
else
    echo "color coded failed to download"
    exit 1
fi

cd "$ROOT_DIR"

if [ -d ./bundle/YouCompleteMe ]; then
    cd ./bundle/YouCompleteMe

    # These optimizations are useful for large projects
    cd third_party/ycmd
    git apply "$ROOT_DIR"/ycmd_optimization.diff

    cd third_party/cregex
    git apply "$ROOT_DIR"/ycm_cregex_optimization.diff

    cd "$ROOT_DIR"/bundle/YouCompleteMe

    ./install.py --clang-completer --system-libclang
    if [ $? -ne 0 ]; then
        echo "Failed to build YouCompleteMe"
        exit 1
    fi
else
    echo "YouCompleteMe failed to download"
    exit 1
fi

