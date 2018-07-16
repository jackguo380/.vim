# -- Compiled by Name --
MYNAME="Jack Guo"

# -- Git --
REPO=https://github.com/vim/vim.git
# Version to checkout
VER=v8.0.1850

# -- Compilation --
VIM_RUNTIME_DIR=/usr/local/share/vim/vim80
CONFIG_OPTS=(
    --enable-pythoninterp=yes 
    --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu 
    --enable-python3interp=yes 
    --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu 
    --enable-perlinterp=yes 
    --enable-rubyinterp=yes 
    --enable-luainterp=yes 
    --enable-tclinterp=yes
    --enable-cscope 
    --enable-gui=gnome
    --with-features=huge 
    --with-x 
    --enable-fontset 
    --enable-multibyte
    --enable-largefile 
    --with-compiledby="$MYNAME"
    --enable-fail-if-missing 
    --prefix=/usr/local
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

do_apt() {
    sudo apt install libncurses5-dev libgnome2-dev libgnomeui-dev \
        libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
        libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
        python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev liblua5.1-dev tcl-dev

}

do_configure() {
    make distclean
    ./configure "${CONFIG_OPTS[@]}"

    if [ $? -ne 0 ]; then
        echo "Failed to configure Vim"
        exit 1
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

if yn_prompt "Install common apt dependencies [y/n]?"; then
    do_apt
fi

do_git_checkout

do_configure

do_compile

if yn_prompt "Install [y/n]?"; then
    do_install
    do_alternatives
else
    echo "Exiting..."
fi

