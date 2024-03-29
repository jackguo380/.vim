#!/bin/bash

set -e
set -o pipefail

if ! command -v git; then
    echo "Please install git"
    exit 1
fi

if ! command -v curl; then
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
LLVM_MAJOR_VER=14
LLVM_VER=clang+llvm-$LLVM_MAJOR_VER.0.0-x86_64-linux-gnu-ubuntu-18.04
LLVM_URL=http://releases.llvm.org/$LLVM_MAJOR_VER.0.0/$LLVM_VER.tar.xz

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
elif [ "$DISTRIB_ID" = Arch ]; then
    PACKAGE_MANAGER=pacman
else
    echo "Unsupported distro $DISTRIB_ID"
    exit 1
fi

cd "$ROOT_DIR"

# Run vundle to configure all plugins, ignore the errors from this
vim +PlugUpdate +qall

if ! command -v cmake; then
    echo "Please install cmake"
    exit 1
fi

if command -v ccache; then
    ccache_args=(
        -DCMAKE_C_COMPILER_LAUNCHER=ccache
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    )
else
    ccache_args=()
fi

read -r -p "Install libncurses zlib via $PACKAGE_MANAGER [y/n]?" yn
if [ "$yn" = y ]; then
    if [ $PACKAGE_MANAGER = "apt-get" ]; then
        sudo apt-get install libncurses[0-9]-dev zlib1g-dev zlib1g
    elif [ $PACKAGE_MANAGER = "pamac" ]; then
        sudo pamac install zlib ncurses
    elif [ $PACKAGE_MANAGER = "pacman" ]; then
        sudo pacman -S zlib ncurses
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
elif [ $PACKAGE_MANAGER = "pacman" ]; then
    if ! pacman -Q llvm; then
        sudo pacman -S llvm
    fi

    if ! pacman -Q clang; then
        sudo pacman -S clang
    fi
else
    llvm_packages=(
        "llvm-$LLVM_MAJOR_VER"
        "llvm-$LLVM_MAJOR_VER-dev"
        "clang-$LLVM_MAJOR_VER"
        "libclang-$LLVM_MAJOR_VER-dev"
    )
    if ! dpkg -l "${llvm_packages[@]}" > /dev/null; then
        sudo apt install "${llvm_packages[@]}"
    fi
    #download_llvm
    if ! llvm_dir=$(llvm-config-$LLVM_MAJOR_VER --prefix); then
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

if [ -f "$HOME/.vim/llvm_install/bin/llvm-config" ]; then
    echo "Using custom built llvm in ~/.vim/llvm_install"
    echo "Version: $("$HOME/.vim/llvm_install/bin/llvm-config" --version)"
    llvm_dir="$HOME/.vim/llvm_install"
fi

cmake .. -DCMAKE_PREFIX_PATH="$llvm_dir" -DCMAKE_INSTALL_RPATH="$llvm_dir/lib" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=release "${ccache_args[@]}" &&
    cmake --build . -- -j"$(nproc)" && cmake --install .

cmake --build . --target clean || true

cd "$ROOT_DIR"

# Rust
read -r -p "Build Rust Deps [y/n]?" yn
if [ "$yn" != y ]; then
    exit 0
fi

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

    cd "$ROOT_DIR"

    # FD
    if [ ! -d fd ]; then
        git clone https://github.com/sharkdp/fd
    fi

    # Ripgrep
    if [ ! -d ripgrep ]; then
        git clone https://github.com/BurntSushi/ripgrep
    fi

    # Install the rust analyzer lsp server
    if [ ! -d rust-analyzer ]; then
        git clone https://github.com/rust-analyzer/rust-analyzer
    fi

    function do_rust_install {
        project=$1
        shift

        cd "$project"

        git pull

        rustup override set nightly

        if [ $# -eq 0 ]; then
            cargo build --release

            cargo install --force --path .
        else
            cargo "$@"
        fi

        cargo clean

        cd "$ROOT_DIR"
    }

    do_rust_install fd &
    fd_pid=$!

    do_rust_install ripgrep &
    ripgrep_pid=$!

    do_rust_install rust-analyzer xtask install --server &
    ra_pid=$!

    wait $fd_pid $ripgrep_pid $ra_pid
fi

echo "Everything was completed successfully!"
exit 0
