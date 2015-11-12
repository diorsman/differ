#!/bin/sh

echo "$0: $1 XXXXXX $2"
[ $1 == 'files' -o $1 == 'and' -o $1 == 'differ' -o $2 == 'files' -o $2 == 'and' -o $2 == 'differ' ] && exit 0

CWD=`pwd`

NEWCWD=$1.DIR
TMPDIR=$1.ISO
mkdir -p $NEWCWD
mkdir -p $TMPDIR
mount -o loop $1 $TMPDIR
cp -rf $TMPDIR/* $NEWCWD
umount $TMPDIR
rm -rf $TMPDIR
rm -rf $1

NEWCWD=$2.DIR
TMPDIR=$2.ISO
mkdir -p $NEWCWD
mkdir -p $TMPDIR
mount -o loop $2 $TMPDIR
cp -rf $TMPDIR/* $NEWCWD
umount $TMPDIR
rm -rf $TMPDIR
rm -rf $2

exit 0
