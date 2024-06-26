#! /bin/bash
set -e
set -o pipefail

# -- Git --
REPO=https://github.com/neovim/neovim.git

# Install to a system directory rather than ~/.local so theres no broken
# vim installations left over when moving distros while keeping /home
INSTALL_PREFIX=/usr/local/guoj-nvim

# -- Compilation --

THIRDPARTY_CONFIG_OPTS=(
    -DUSE_BUNDLED=ON
    -DUSE_BUNDLED_LUV=ON
    -DUSE_BUNDLED_LIBUV=ON
    -DUSE_BUNDLED_LIBVTERM=ON
    -DUSE_BUNDLED_TS=ON
    -DUSE_BUNDLED_TS_PARSERS=ON
    -DCMAKE_BUILD_TYPE=Release
)

CONFIG_OPTS=(
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
    -DCMAKE_C_FLAGS="-Ofast -march=native"
    -DCMAKE_C_FLAGS_RELEASE="-DNDEBUG -Ofast -march=native"
    -DCMAKE_BUILD_TYPE=Release
)

UBUNTU_APT_PKGS=(
gperf
luajit
luarocks
autoconf
libtool
libtool-bin
libuv1-dev
libluajit-5.1-dev
libunibilium-dev
libmsgpack-dev
libtermkey-dev
libvterm-dev
libutf8proc-dev
lua-luv-dev
lua-lpeg-dev
lua-mpack
)

do_git_clone() {
    git clone --depth 1 "$REPO" neovim
    
    if [ $? -ne 0 ]; then
        echo "Failed to git clone Neovim"
        exit 1
    fi
}

do_git_checkout() {
    git checkout master
    git pull origin master
}

do_apt_packages() {
    sudo apt install "${UBUNTU_APT_PKGS[@]}"
}

do_compile() {
    rm -rf build
    mkdir build
    pushd build

    mkdir build-deps
    pushd build-deps

    # Build some third party libraries that are hard to install
    cmake "${THIRDPARTY_CONFIG_OPTS[@]}" ../../cmake.deps
    cmake --build . -- -j$(nproc)

    popd

    # Build Neovim
    DEPS_BUILD_DIR=$PWD/build-deps cmake "${CONFIG_OPTS[@]}" ..
    cmake --build . -- -j$(nproc)

    popd
}

do_install() {
    echo "Installing..."
    sudo cmake --build build --target install

    # Create some symlinks to .local
    rm -f "$HOME/.local/bin/nvim"
    ln -s "$INSTALL_PREFIX/bin/nvim" "$HOME/.local/bin/nvim"
}

do_clean() {
    echo "Cleaning..."
    cmake --build build --target clean || true
}

yn_prompt() {
    local MESSAGE yn
    MESSAGE="$1"

    read -p "$MESSAGE" yn
    if [ "$yn" = y ]; then
        return 0
    fi

    return 1
}

if [ -d neovim ]; then
    cd neovim
fi

if [ ! -d src/nvim ]; then
    if yn_prompt "Clone Repository into folder: $PWD/neovim [y/n]?"; then
        do_git_clone
        cd neovim
    else
        echo "No repo available... exiting"
        exit 1
    fi
fi

do_git_checkout

echo -e "The following apt packages are recommended for Ubuntu: ${UBUNTU_APT_PKGS[*]}\n"

if yn_prompt "install them [y/n]?"; then
    do_apt_packages
fi

do_compile

if yn_prompt "Install [y/n]?"; then
    do_install
fi

do_clean
