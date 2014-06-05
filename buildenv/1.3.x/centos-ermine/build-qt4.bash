#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash

if [ -d mumble-developers-qt ]; then
	cd mumble-developers-qt
	git reset --hard
	git clean -dfx
else
	git clone https://github.com/mumble-voip/mumble-developers-qt.git
	cd mumble-developers-qt
	git fetch origin 4.8-mumble
	git checkout 2147fa767980fe27a14f018b1528dbf880b96814
fi

export OPENSSL_LIBS="-L${MUMBLE_PREFIX}/lib -lssl -lcrypto"
./configure -v -fast -no-gui -nomake examples -nomake demos -nomake docs -release -rpath -glib -plugin-sql-sqlite -plugin-sql-mysql -dbus-linked -no-webkit -no-script -no-scripttools -no-phonon -no-phonon-backend -no-qt3support -no-multimedia -no-audio-backend -system-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg -openssl-linked -I${MUMBLE_PREFIX}/include -L${MUMBLE_PREFIX}/lib -R${MUMBLE_PREFIX}/lib -mysql_config ${MUMBLE_PREFIX}/bin/mysql_config -prefix ${MUMBLE_QT_PREFIX} -opensource -confirm-license
make -j4
make install