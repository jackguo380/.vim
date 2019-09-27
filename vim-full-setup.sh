#!/bin/bash

set -e

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

function usage {
cat <<EOF
Usage: $0 -c <config> -l <language server>
-c <config>
Configs:
ycm - use YCM
nocompile - install only vimscript plugins
windows - only stuff that works in windows, (currently an alias for nocompile)

EOF
}

CONFIG=none

while getopts "l:c:h" opt; do 
    case $opt in
        c)
            case "$OPTARG" in
                ycm) CONFIG="$OPTARG" ;;
                nocompile) CONFIG="$OPTARG" ;;
                windows) CONFIG="nocompile" ;;
                *) echo "Invalid config: $OPTARG" ; exit 1 ;;
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

# Downloaded LLVM
LLVM_VER=clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04
LLVM_URL=http://releases.llvm.org/9.0.0/$LLVM_VER.tar.xz

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

source /etc/lsb-release

if [ "$DISTRIB_ID" = LinuxMint ]; then
    PACKAGE_MANAGER=apt-get
elif [ "$DISTRIB_ID" = Ubuntu ]; then
    PACKAGE_MANAGER=apt-get
elif [ "$DISTRIB_ID" = ManjaroLinux ]; then
    PACKAGE_MANAGER=pamac
else
    echo "Unsupported distro $DISTRIB_ID"
    exit 1
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

read -p "Install libncurses zlib via $PACKAGE_MANAGER [y/n]?" yn
if [ "$yn" = y ]; then
    if [ $PACKAGE_MANAGER = "apt-get" ]; then
        sudo apt-get install libncurses[0-9]-dev zlib1g-dev zlib1g
    elif [ $PACKAGE_MANAGER = "pamac" ]; then
        sudo pamac install zlib ncurses
    fi
fi

# Need llvm for pretty much all the compiled plugins
if [ $PACKAGE_MANAGER = "pamac" ]; then
    sudo pamac install llvm clang
else
    download_llvm
fi

cd "$ROOT_DIR"

if [ ! -d ccls ]; then
    if ! git clone https://github.com/MaskRay/ccls.git --recursive ccls; then
        echo "failed to clone ccls"
        exit 1
    fi
fi

cd ccls

if ! git pull && git submodule update --init; then
    echo "failed to update ccls"
    exit 1
fi

rm -rf build
mkdir build
cd build

cmake .. -DCMAKE_PREFIX_PATH="$llvm_dir" -DCMAKE_INSTALL_RPATH="$llvm_dir/lib" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=release "${ccache_args[@]}" &&
    make -j$(nproc) && make install

if [ $? -ne 0 ]; then
    echo "Failed to build ccls"
    exit 1
fi

cd "$ROOT_DIR"

# Rust

# Detect per user cargo installations
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

rustok=false
if command -v rustup && command -v cargo; then
    echo "rustup and cargo is required for rust, skipping rust config"
    rustok=true
fi

cd "$ROOT_DIR"
if $rustok; then
    rustup install nightly
    rustup component add --toolchain stable rls rust-analysis rust-src
    rustup component add --toolchain nightly rls rust-analysis rust-src

    # Install fd
    if ! command -v fd; then
        cargo install fd-find
    fi
fi

# YouCompleteMe
cd "$ROOT_DIR"
if [ -d ./bundle/YouCompleteMe ]; then
    cd ./bundle/YouCompleteMe

    install_py_flags=(
    --clangd-completer
    --skip-build # Don't build ycm_core, do this manually via CMake
    --no-regex   # Same with regex
    )

    if $rustok; then
        install_py_flags+=( --rust-completer )
    fi

    if ! ./install.py "${install_py_flags[@]}"; then
        echo "Failed to run install.py"
        exit 1
    fi

    rm -rf build
    mkdir build
    cd build

    if [ $PACKAGE_MANAGER = pamac ]; then
        cmake -DCMAKE_BUILD_TYPE=Release \
            -DPATH_TO_LLVM_ROOT=/usr \
            "$ROOT_DIR"/bundle/YouCompleteMe/third_party/ycmd/cpp "${ccache_args[@]}" -DUSE_PYTHON2=OFF &&
            make -j$(nproc) ycm_core
    else
        cmake -DCMAKE_BUILD_TYPE=Release -DPATH_TO_LLVM_ROOT="$llvm_dir" \
            -DCMAKE_INSTALL_RPATH="$llvm_dir/lib" -DCMAKE_BUILD_RPATH="$llvm_dir/lib" . \
            -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,$llvm_dir/lib" \
            "$ROOT_DIR"/bundle/YouCompleteMe/third_party/ycmd/cpp "${ccache_args[@]}" -DUSE_PYTHON2=OFF &&
            make -j$(nproc) ycm_core
    fi

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
    rm -f bundle/YouCompleteMe/third_party/ycmd/libclang.so*
fi

echo "Everything was completed successfully!"
exit 0
