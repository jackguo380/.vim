#! /bin/bash
# -- Compiled by Name --
MYNAME="Jack Guo"

# -- Git --
REPO=https://github.com/vim/vim.git
# Version to checkout
# vim's master branch isn't too stable so its good use a known working version
VER=v8.0.1453

# -- Compilation --
VIM_RUNTIME_DIR=/usr/local/share/vim/vim80
CONFIG_OPTS=(
    --enable-pythoninterp=yes 
    --enable-python3interp=yes 
    --enable-perlinterp=yes  
    --enable-luainterp=yes 
#    --with-lua-prefix=/usr/local
    --enable-cscope 
    --enable-autoservername 
    --enable-terminal
    --enable-gui=gtk3
    --enable-gtk3-check
    --with-features=huge 
    --with-x 
    --enable-fontset 
    --enable-multibyte
    --enable-largefile 
    --with-compiledby="$MYNAME"
    --enable-fail-if-missing 
    --prefix=/usr/local
)

UBUNTU1604_APT_PKGS=(
lua5.1
liblua5.1-0-dev
libperl-dev
libpython-dev
libpython3-dev
)

do_git_clone() {
    git clone "$REPO" vim
    
    if [ $? -ne 0 ]; then
        echo "Failed to git clone Vim"
        exit 1
    fi
}

do_git_checkout() {
    # Ensure all recent versions are here
    git pull
    git checkout "$VER"

    if [ $? -ne 0 ]; then
        echo "Failed to checkout $VER"
        exit 1
    fi
}

do_apt_packages() {
    sudo apt install "${UBUNTU1604_APT_PKGS[@]}"

    if [ $? -ne 0 ]; then
        echo "Failed to do apt install"
        exit 1
    fi
}

do_configure() {
    make clean distclean
    CFLAGS="-O3" CPPFLAGS="-O3" ./configure "${CONFIG_OPTS[@]}"

    if [ $? -ne 0 ]; then
        echo "Failed to configure Vim"
        return 1
    fi

}

do_compile() {
    make clean

    make -j$(nproc) VIMRUNTIMEDIR="$VIM_RUNTIME_DIR"

    if [ $? -ne 0 ]; then
        echo "Failed to make Vim"
        exit 1
    fi
}

do_install() {
    echo "Installing..."
    sudo make install

    if [ $? -ne 0 ]; then
        echo "Failed to install Vim"
        exit 1
    fi
}

do_alternatives() {
    echo "Setting alternatives..."
    sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
    sudo update-alternatives --set editor /usr/local/bin/vim
    sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
    sudo update-alternatives --set vi /usr/local/bin/vim
    sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/vim 1
    sudo update-alternatives --set vim /usr/local/bin/vim
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

echo -e "The following apt packages are recommended for Ubuntu 16.04: ${UBUNTU1604_APT_PKGS[*]}\n"

if yn_prompt "install them [y/n]?"; then
    do_apt_packages
fi

while ! do_configure; do
    if yn_prompt "Enter shell to install dependencies [y/n]?"; then
        bash
    else
        exit 1
    fi
done

do_compile

if yn_prompt "Install [y/n]?"; then
    do_install
fi

if yn_prompt "Do update-alternatives [y/n]?"; then
    do_alternatives
fi
