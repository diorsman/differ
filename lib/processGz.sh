#!/bin/sh

echo "$0: $1 XXXXXX $2"
[ $1 == 'files' -o $1 == 'and' -o $1 == 'differ' -o $2 == 'files' -o $2 == 'and' -o $2 == 'differ' ] && exit 0

CWD=`pwd`

NEWCWD=$1.DIR
mkdir -p $NEWCWD
tar zxf $1 -C $NEWCWD 
rm -rf $1

NEWCWD=$2.DIR
mkdir -p $NEWCWD
tar zxf $2 -C $NEWCWD 
rm -rf $2

exit 0
