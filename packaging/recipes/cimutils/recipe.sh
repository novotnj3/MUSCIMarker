#!/bin/bash

VERSION_cth=
URL_cth=
DEPS_cth=(python numpy)
MD5_cth=
BUILD_cth=$BUILD_PATH/cimutils/cimutils
RECIPE_cth=$RECIPES_PATH/cimutils

function prebuild_cth() {
	cd $BUILD_PATH/cimutils

	rm -rf cimutils
	if [ ! -d cimutils ]; then
		try cp -a $RECIPE_cth/src $BUILD_cth
	fi
}

function shouldbuild_cth() {
	if [ -d "$SITEPACKAGES_PATH/cimutils" ]; then
		DO_BUILD=0
	fi
}

function build_cth() {
	cd $BUILD_cth

	# if the last step have been done, avoid all
	if [ -f .done ]; then
		return
	fi
	
	push_arm

	export LDFLAGS="$LDFLAGS -L$LIBS_PATH"
	export LDSHARED="$LIBLINK"

	# cythonize
	try find . -iname '*.pyx' -exec $CYTHON {} \;
	try $HOSTPYTHON setup.py build_ext -v
	try $HOSTPYTHON setup.py install -O2

	unset LDSHARED

	touch .done
	pop_arm
}

function postbuild_cth() {
	true
}
