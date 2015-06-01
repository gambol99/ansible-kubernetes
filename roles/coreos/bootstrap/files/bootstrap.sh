#/bin/bash
#
#   Author: Rohith
#   Date: 2015-05-03 12:38:06 +0100 (Sun, 03 May 2015)
#
#  vim:ts=2:sw=2:et
#

set -e

cd

if [[ -e $HOME/.bootstrapped ]]; then
  exit 0
fi

PYPY_VERSION=2.4.0

wget -O - https://bitbucket.org/pypy/pypy/downloads/pypy-$PYPY_VERSION-linux64.tar.bz2 |tar -xjf -
mv -n pypy-$PYPY_VERSION-linux64 pypy

## library fixup
mkdir -p pypy/lib
ln -snf /lib64/libncurses.so.5.9 $HOME/pypy/lib/libtinfo.so.5

mkdir -p $HOME/bin

cat > $HOME/bin/python <<EOF
#!/bin/bash
LD_LIBRARY_PATH=$HOME/pypy/lib:$LD_LIBRARY_PATH exec $HOME/pypy/bin/pypy "\$@"
EOF

chmod +x $HOME/bin/python
$HOME/bin/python --version

touch $HOME/.bootstrapped

