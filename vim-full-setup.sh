#!/bin/bash

if ! which git; then
    echo "Please install git"
    exit 1
fi

if ! which curl; then
    echo "Please install curl"
    exit 1
fi

if [ ! -f vim-full-setup.sh ] && [ ! -f vim-install.sh ]; then
    echo "run this in the .vim directory"
    exit 1
fi

ROOT_DIR="$PWD"
LLVM_VER=clang+llvm-7.0.0-x86_64-linux-gnu-ubuntu-16.04
LLVM_URL=http://releases.llvm.org/7.0.0/$LLVM_VER.tar.xz

function usage {
cat <<EOF
Usage: $0 -c <config>
-c <config>
Configs:
ycm - use YCM instead of asyncomplete
nocompile - install only vimscript plugins
windows - only stuff that works in windows, (currently an alias for nocompile)
asyncomplete - use asyncomplete as a replacement for YCM

EOF
}

CONFIG=none

while getopts "c:h" opt; do 
    case $opt in
        c)
            case "$OPTARG" in
                ycm) CONFIG="$OPTARG" ;;
                nocompile) CONFIG="$OPTARG" ;;
                windows) CONFIG="nocompile" ;;
                asyncomplete) CONFIG="$OPTARG" ;;
                *) echo "Invalid config: $OPTARG"; exit 1 ;;
            esac
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

function download_llvm {
    pushd "$ROOT_DIR"
    if [ ! -f $LLVM_VER.tar.xz ]; then
        if ! wget $LLVM_URL; then
            echo "failed to download LLVM"
            exit 1
        fi
    fi
    
    if [ ! -d $LLVM_VER ]; then
        echo "Untarring LLVM..."
        if ! tar -xf $LLVM_VER.tar.xz; then
            echo "failed to untar LLVM"
            exit 1
        fi
    fi

    llvm_dir="$ROOT_DIR"/$LLVM_VER
    popd
}

function compile_install {
    echo "Compiling vim from Github repository"
    sleep 2

    read -p "Use LLVM to compile vim [y/n]?" yn
    if [ "$yn" = y ]; then
        download_llvm
        export USE_CLANG=true LLVM_DIR="$llvm_dir"
    fi

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
    if ! sudo apt install vim vim-gnome; then
        echo "Failed to install vim via apt"
        exit 1
    fi
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

if [ ! -f autoload/plug.vim ]; then
    curl -fLo autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [ $? -ne 0 ]; then
        echo "Failed to download vim-plug"
        exit 1
    fi
fi

cd "$ROOT_DIR"

echo "Checking vim can run..."
if ! vim --help; then
    echo "vim does not run"
    exit 1
fi
echo "Ok, vim runs"

# Run vundle to configure all plugins, ignore the errors from this
vim +PlugUpdate +qall

if [ "$CONFIG" = nocompile ]; then
    echo Everything is done for nocompile
    exit 0
fi

if ! which cmake; then
    echo "Please install cmake"
    exit 1
fi

if which ccache; then
    ccache_args=(
        -DCMAKE_C_COMPILER_LAUNCHER=ccache
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    )
else
    ccache_args=()
fi

read -p "Install libncurses zlib via apt (Required) [y/n]?" yn
if [ "$yn" = y ]; then
    sudo apt install libncurses[0-9]-dev zlib1g-dev zlib1g
fi

# Need llvm for pretty much all the compiled plugins
download_llvm

cd "$ROOT_DIR"

# CQuery
# CQuery doesn't like the the Apt based Clang/LLVM. But it downloads LLVM 6.01 which
# we can use to compile Color Coded and YoucompleteMe
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

rm -rf build
mkdir build
cd build

cmake .. -DCMAKE_PREFIX_PATH="$llvm_dir" -DCMAKE_INSTALL_RPATH="$llvm_dir/lib" -DSYSTEM_CLANG=1 \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=release "${ccache_args[@]}" &&
    make -j$(nproc) && make install

if [ $? -ne 0 ]; then
    echo "Failed to build cquery"
    exit 1
fi


cd "$ROOT_DIR"

# Color Coded
if [ -d ./bundle/color_coded ]; then
    cd ./bundle/color_coded
    # Add support for llvm-6.0
    git reset --hard
    git apply "$ROOT_DIR"/color_coded_llvm_6.diff
    rm -rf build
    mkdir build
    cd build

    cmake -DDOWNLOAD_CLANG=0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_RPATH="$llvm_dir/lib" \
        -DLLVM_ROOT_DIR="$llvm_dir" "${ccache_args[@]}" .. &&
        make -j$(nproc) && make install

    if [ $? -ne 0 ]; then
        echo "Failed to build color coded"
        exit 1
    fi
    rm ./* -r
fi

cd "$ROOT_DIR"

# Skip YCM for asyncomplete
if [ "$CONFIG" = asyncomplete ]; then
    echo "Everything done for config: asyncomplete"
    exit 0
fi

# Rust
rustok=true
if ! which rustup; then
    echo "rustup is required for rust, skipping rust config"
    rustok=false
fi

if $rustok; then
    rustup component add rls-preview rust-analysis rust-src
fi

# YouCompleteMe
if [ -d ./bundle/YouCompleteMe ]; then
    cd ./bundle/YouCompleteMe

    if $rustok; then
        ./install.py --rust-completer --skip-build --no-regex
    fi

    rm -rf build
    mkdir build
    cd build

    cmake -DCMAKE_BUILD_TYPE=Release -DPATH_TO_LLVM_ROOT="$llvm_dir" \
        -DCMAKE_INSTALL_RPATH="$llvm_dir/lib" -DCMAKE_BUILD_RPATH="$llvm_dir/lib" . \
        -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,$llvm_dir/lib" \
        "$ROOT_DIR"/bundle/YouCompleteMe/third_party/ycmd/cpp "${ccache_args[@]}" -DUSE_PYTHON2=OFF &&
        make -j$(nproc) ycm_core
    if [ $? -ne 0 ]; then
        echo "Failed to build ycmd"
        exit 1

    fi

    cd ..
    rm -rf build_regex
    mkdir build_regex
    cd build_regex

    cmake . "$ROOT_DIR"/bundle/YouCompleteMe/third_party/ycmd/third_party/cregex \
        -DCMAKE_BUILD_TYPE=Release "${ccache_args[@]}" &&
        make -j$(nproc) _regex
    if [ $? -ne 0 ]; then
        echo "Failed to build cregex for ycm"
        exit 1
    fi

    # Delete ycm's copy of libclang and force it to use the one we compiled cquery with
    cd "$ROOT_DIR"
    rm bundle/YouCompleteMe/third_party/ycmd/libclang.so.7
fi

echo "Everything was completed successfully!"
exit 0
