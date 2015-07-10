#!/bin/bash -ex
# Copyright 2015 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

export MUMBLE_RELENG_ROOT=$(git rev-parse --show-toplevel)
export PATH=${MUMBLE_RELENG_ROOT}/mumble-build:${PATH}

./zlib.build
./bzip2.build
./openssl.build
./expat.build
./python.build
./libffi.build
./glib.build
./dbus.build
./libdaemon.build
./avahi.build
#./ncurses.build  # ncurses currently won't build on the gcc 5.1.0
./mysql.build
./protobuf.build
./boost.build
./qt4.build
./libmcpp.build
./berkeleydb.build
./zeroc-ice.build
./libcap.build
