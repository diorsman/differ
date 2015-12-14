#!/bin/sh

baselog=BASE.TMP.DIR.ignore
targetlog=TARGET.TMP.DIR.ignore
find $1 -type b >> $baselog
find $1 -type c >> $baselog
find $1 -type p >> $baselog
find $1 -type l >> $baselog
find $1 -type s >> $baselog
find $1 -type b -exec rm -f {} \;
find $1 -type c -exec rm -f {} \;
find $1 -type p -exec rm -f {} \;
find $1 -type l -exec rm -f {} \;
find $1 -type s -exec rm -f {} \;

find $2 -type b >> $targetlog
find $2 -type c >> $targetlog
find $2 -type p >> $targetlog
find $2 -type l >> $targetlog
find $2 -type s >> $targetlog
find $2 -type b -exec rm -f {} \;
find $2 -type c -exec rm -f {} \;
find $2 -type p -exec rm -f {} \;
find $2 -type l -exec rm -f {} \;
find $2 -type s -exec rm -f {} \;

diff -r $1 $2 | grep -E " differ$" 2>/dev/null

exit 0
