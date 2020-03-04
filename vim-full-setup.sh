#!/bin/bash

set -e
set -o pipefail

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
Usage: $0

EOF
}

while getopts "l:c:h" opt; do 
    case $opt in
        h)
            usage
            exit 0
            ;;
        *)
            echo "Invalid option: $OPTARG"
            usage
            exit 1 ;;
    esac
done

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

cd "$ROOT_DIR"

# Run vundle to configure all plugins, ignore the errors from this
vim +PlugUpdate +qall

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
    if ! ( pamac list | grep llvm ); then
        sudo pamac install llvm
    fi

    if ! ( pamac list | grep clang ); then
        sudo pamac install clang
    fi
else
    if ! dpkg -l llvm-9 llvm-9-dev clang-9 libclang-9-dev > /dev/null; then
        sudo apt install llvm-9 llvm-9-dev clang-9 libclang-9-dev
    fi
    #download_llvm
    if ! llvm_dir=$(llvm-config-9 --prefix); then
        echo "llvm-config not found!"
        exit 1
    fi
fi

cd "$ROOT_DIR"

if [ ! -d ccls ]; then
    if ! git clone https://github.com/MaskRay/ccls.git --recursive ccls; then
        echo "failed to clone ccls"
        exit 1
    fi
fi

cd ccls

if ! git pull origin master && git submodule update --init; then
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
    rustok=true
else
    echo "rustup and cargo is required for rust, skipping rust config"
fi

cd "$ROOT_DIR"
if $rustok; then
    if ! ( rustup show | grep "nightly" ); then
        rustup install nightly
    fi

    for comp in rls rust-analysis rust-src; do
        if rustup component list | grep "$comp"; then
            echo "$comp is installed"
        else
            rustup component add "$comp"
        fi

        if rustup component list --toolchain nightly | grep "$comp"; then
            echo "$comp is installed (nightly)"
        else
            echo
            #rustup component add --toolchain nightly "$comp"
        fi
    done

    export RUSTFLAGS="-C target-cpu=native"

    # Install fd
    if [ ! -d fd ]; then
        git clone https://github.com/sharkdp/fd
    fi

    cd fd

    git pull

    cargo build --release

    cargo install --force --path .

    # Ripgrep
    if [ ! -d ripgrep ]; then
        git clone https://github.com/BurntSushi/ripgrep
    fi

    cd ripgrep

    git pull

    rustup override set nightly

    cargo build --release --features simd-accel

    cargo install --force --path .

    # Install the rust analyzer lsp server
    if [ ! -d rust-analyzer ]; then
        git clone https://github.com/rust-analyzer/rust-analyzer
    fi

    cd rust-analyzer

    git pull

    cargo xtask install --server
fi

echo "Everything was completed successfully!"
exit 0
