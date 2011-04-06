#!/bin/sh

REV_ID=`git --git-dir="$SRCROOT/.git" rev-parse --short HEAD`
TARBALL_NAME="$PRODUCT_NAME-$REV_ID"
TARBALL_FULLNAME="$TARBALL_NAME.tar.bz2"
TARBALL_SRC_DIR="$SRCROOT/TarballSources"
TARBALL_TMP_DIR="$DERIVED_FILE_DIR/$TARBALL_NAME"
TARBALL_DST_DIR="$CONFIGURATION_BUILD_DIR"

PRODUCT="$CONFIGURATION_BUILD_DIR/$EXECUTABLE_NAME"

RELEASE_TARBALL_NAME="$PRODUCT_NAME-$PRODUCT_VER"
RELEASE_TARBALL_FULLNAME="$RELEASE_TARBALL_NAME.tar.bz2"

echo "This is `basename $0`"

echo "$TARBALL_DST_DIR/$TARBALL_FULLNAME"
if [ -e "$TARBALL_DST_DIR/$TARBALL_FULLNAME" ]; then
	echo "Tarball exists"
	exit
fi

echo "Preparing tarball source"

rm -rf "$TARBALL_TMP_DIR"
mkdir -p "$TARBALL_TMP_DIR"
if [ -d "$TARBALL_SRC_DIR" ]; then
	cp -a "$TARBALL_SRC_DIR/" "$TARBALL_TMP_DIR"
fi
cp -a "$PRODUCT" "$TARBALL_TMP_DIR"

echo "Creating tarball"

( cd `dirname $TARBALL_TMP_DIR`; tar cjf "$TARBALL_DST_DIR/$TARBALL_FULLNAME" `basename $TARBALL_TMP_DIR` )

echo "Checking if tagged as a release version"

TAG=`git --git-dir="$SRCROOT/.git" describe --tags --exact-match 2> /dev/null`
if [ $? -ne 0 ]; then
	echo "Not tagged"
	exit
fi

IS_RELEASE_TAG=`perl -e 'print $ARGV[0] =~ /^v\d+(\.\d+)+$/ ? 1 : 0' $TAG`
if [ $IS_RELEASE_TAG -eq 0 ]; then
	echo "Not a release version"
	exit
fi

echo "Creating release tarball"

( cd `dirname $TARBALL_TMP_DIR`; tar cjf "$TARBALL_DST_DIR/$RELEASE_TARBALL_FULLNAME" `basename $TARBALL_TMP_DIR` )
