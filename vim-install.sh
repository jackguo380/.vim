#! /bin/bash
# -- Compiled by Name --
MYNAME="Jack Guo"

# -- Git --
REPO=https://github.com/vim/vim.git
# Version to checkout
# vim's master branch isn't too stable so its good use a known working version
VER=v8.1.1099

INSTALL_PREFIX=$HOME/.local
VIM_RUNTIME_DIR=$INSTALL_PREFIX/share/vim/vim81

# -- Compilation --
if [ "${USE_CLANG:-false}" = 1 ] || [ "${USE_CLANG:-false}" = true ]; then
    LLVM_DIR="${LLVM_DIR:-$HOME/.vim/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04}"
    if [ ! -d "$LLVM_DIR" ]; then
        echo "Cant use CLANG since its not downloaded"
        exit 1
    fi

    export CC="$LLVM_DIR/bin/clang"
    export CFLAGS="-Ofast -flto=thin -march=native"
    export LDFLAGS="-fuse-ld=lld -Ofast -flto=thin -march=native -Wl,--lto-O3,--threads,--thinlto-jobs=$(nproc)"
else
    export CFLAGS="-Ofast -march=native" 
fi

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
    --enable-gtk3-check
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
libx11-dev libxpm-dev libxt-dev
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
    sudo apt install "${UBUNTU_APT_PKGS[@]}"

    if [ $? -ne 0 ]; then
        echo "Failed to do apt install"
        exit 1
    fi
}

do_configure() {
    make clean distclean
    ./configure "${CONFIG_OPTS[@]}"

    if [ $? -ne 0 ]; then
        echo "Failed to configure Vim"
        return 1
    fi

}

do_compile() {
    make clean

    make -j$(nproc) #VIMRUNTIMEDIR="$VIM_RUNTIME_DIR"

    if [ $? -ne 0 ]; then
        echo "Failed to make Vim"
        exit 1
    fi
}

do_install() {
    echo "Installing..."
    make install

    if [ $? -ne 0 ]; then
        echo "Failed to install Vim"
        exit 1
    fi
}

do_alternatives() {
    echo "Setting alternatives..."
    sudo update-alternatives --install /usr/bin/editor editor "$INSTALL_PREFIX/bin/vim" 1
    sudo update-alternatives --set editor "$INSTALL_PREFIX/bin/vim"
    sudo update-alternatives --install /usr/bin/vi vi "$INSTALL_PREFIX/bin/vim" 1
    sudo update-alternatives --set vi "$INSTALL_PREFIX/bin/vim"
    sudo update-alternatives --install /usr/bin/vim vim "$INSTALL_PREFIX/bin/vim" 1
    sudo update-alternatives --set vim "$INSTALL_PREFIX/bin/vim"
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
