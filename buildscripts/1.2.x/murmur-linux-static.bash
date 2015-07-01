#!/bin/bash -ex
# Copyright 2015 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

if [ `uname -m` == 'x86_64' ]; then
    CPU_TYPE=x64
else
    CPU_TYPE=x86
fi

source /MumbleBuild/latest-1.2.x/env
ver=$(python /MumbleBuild/latest-1.2.x/mumble-releng/tools/mumble-version.py)
if [ "${MUMBLE_BUILD_TYPE}" == "Release" ]; then
    qmake -recursive main.pro CONFIG+="release no-client ermine" CONFIG-="static" DEFINES+="MUMBLE_VERSION=${ver}"
else
    qmake -recursive main.pro CONFIG+="release no-client ermine" CONFIG-="static" DEFINES+="MUMBLE_VERSION=${ver} SNAPSHOT_BUILD=1"
fi

# Fix LFLAGS and LIBS options in generated Makefile
mv src/murmur/Makefile.Release src/murmur/Makefile.Release.old
sed -e '/^LFLAGS\s*=/ s/\s-static\s/ /g' -e '/^LFLAGS\s*=/ s/\s-Wl,-rpath,[a-zA-Z0-9_\.\/\:\-]*/ /g' -e '/^LFLAGS\s*=/ s/$/ -static-libstdc++/' -e '/^LIBS\s*=/ s/\s-L[a-zA-Z0-9_\.\/\:\-]*/ /g' -e '/^LIBS\s*=/ s/\s-lavahi-common\s*-lavahi-client\s/ -lavahi-client -lavahi-common /' -e '/^LIBS\s*=/ s/\(-ldl\|-lm\|-lpthread\|-lrt\)\s/ /g' -e '/^LIBS\s*=/ s/\s-l\([a-zA-Z0-9_\.\-]*\)/ $(MUMBLE_PREFIX)\/lib\/lib\1.a/g' -e '/^LIBS\s*=/ s/$/ $(MUMBLE_PREFIX)\/lib\/libbz2.a -ldl/' src/murmur/Makefile.Release.old > src/murmur/Makefile.Release

make

cd scripts
bash mkini.sh
cd ..

cd release
mkdir -p symbols
mkdir -p tarball-root
objcopy --only-keep-debug murmurd symbols/murmurd.dbg
objcopy --strip-debug murmurd
cp murmurd tarball-root/murmur.${CPU_TYPE}
cd ..

cp installer/gpl.txt release/tarball-root/LICENSE
cp README.static.linux release/tarball-root/README

mkdir -p release/tarball-root/dbus/
cp scripts/murmur.pl release/tarball-root/dbus/murmur.pl
cp scripts/weblist.pl release/tarball-root/dbus/weblist.pl

mkdir -p release/tarball-root/ice/
cp scripts/icedemo.php release/tarball-root/ice/icedemo.php
cp scripts/weblist.php release/tarball-root/ice/weblist.php
cp src/murmur/Murmur.ice release/tarball-root/ice/Murmur.ice

cp scripts/murmur.ini release/tarball-root/murmur.ini

cd release/
mv tarball-root murmur-static_${CPU_TYPE}-${ver}
mkdir -p tarball
tar --owner=root -cjpf tarball/murmur-static_${CPU_TYPE}-${ver}.tar.bz2 murmur-static_${CPU_TYPE}-${ver}
rm -rf murmur-static_${CPU_TYPE}-${ver}
