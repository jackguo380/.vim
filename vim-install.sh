#! /bin/bash
set -e
set -o pipefail

# -- Compiled by Name --
MYNAME="Jack Guo"

# -- Git --
REPO=https://github.com/vim/vim.git
# Version to checkout
# vim's master branch isn't too stable so its good use a known working version
VER=master

# Install to a system directory rather than ~/.local so theres no broken
# vim installations left over when moving distros while keeping /home
INSTALL_PREFIX=/usr/local/guoj-vim

# -- Compilation --
# Do some optimization for fun and maybe get a bit of extra speed
export CFLAGS="-Ofast -march=native"

CONFIG_OPTS=(
    --enable-pythoninterp=no
    --enable-python3interp=yes 
    --enable-perlinterp=yes  
    #--enable-luainterp=yes 
    #--enable-rubyinterp=yes
    #--with-lua-prefix=/usr/local
    --enable-cscope 
    --enable-autoservername 
    --enable-terminal
    #--enable-gui=gtk3
    #--enable-gtk3-check
    --disable-gtktest
    --with-features=huge 
    --with-x 
    --enable-fontset 
    --enable-multibyte
    --enable-largefile 
    --with-compiledby="$MYNAME"
    --enable-fail-if-missing 
    --prefix="$INSTALL_PREFIX"
)

UBUNTU_APT_PKGS=(
#lua5.1
#liblua5.1-0-dev
libperl-dev
#libpython-dev
libpython3-dev
python3-dev
python3-distutils
libx11-dev libxpm-dev libxt-dev
libtinfo-dev
)

do_git_clone() {
    git clone "$REPO" vim
}

do_git_checkout() {
    # Ensure all recent versions are here
    git pull
    git checkout "$VER"
}

do_apt_packages() {
    sudo apt install "${UBUNTU_APT_PKGS[@]}"
}

do_configure() {
    make clean distclean
    ./configure "${CONFIG_OPTS[@]}"
}

do_compile() {
    make clean

    make -j$(nproc)
}

do_install() {
    echo "Installing..."
    sudo make install

    # Create some symlinks to .local
    rm -f "$HOME/.local/bin/vim"
    ln -s "$INSTALL_PREFIX/bin/vim" "$HOME/.local/bin/vim"
    rm -f "$HOME/.local/bin/vimdiff"
    ln -s "$INSTALL_PREFIX/bin/vimdiff" "$HOME/.local/bin/vimdiff"
}

do_clean() {
    echo "Cleaning..."
    make clean distclean || true
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

if [ -d vim ]; then
    cd vim
fi

if [ ! -f vim.h ] && [ ! -f src/vim.h ]; then
    if yn_prompt "Clone Repository into folder: $PWD/vim [y/n]?"; then
        do_git_clone
        cd vim
    else
        echo "No repo available... exiting"
        exit 1
    fi
fi

if [ ! -f vim.h ]; then
    cd src
fi


do_git_checkout

echo -e "The following apt packages are recommended for Ubuntu: ${UBUNTU_APT_PKGS[*]}\n"

if yn_prompt "install them [y/n]?"; then
    do_apt_packages
fi

do_configure

do_compile

if yn_prompt "Install [y/n]?"; then
    do_install
fi

do_clean
