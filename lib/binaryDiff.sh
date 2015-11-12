#!/bin/sh

find $1 -type l -exec rm -f {} \;
find $2 -type l -exec rm -f {} \;

diff -r $1 $2 | grep -E " differ$" 2>/dev/null

exit 0
