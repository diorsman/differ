#!/bin/bash

sourceFilePath="$(dirname ${BASH_SOURCE[0]})"
sourceFileName="$(basename ${BASH_SOURCE[0]})"
log=$sourceFilePath/$sourceFileName.log

echo "-------Begin@`date`-----------" > $log 2>&1

exitArgumentNumberIllegal(){ echo 'ERROR: The number of argument illegal'; exit 1; }
exitArgumentTypeIllegal(){ echo 'ERROR: The type of argument illegal'; exit 2; }
exitDiskSpaceNotEnough(){ echo 'ERROR: The disk space not enough'; exit 3; }
exitCommandNotFound(){ echo "ERROR: The command [$1] not found"; exit 4; }
exitCommandVersionWrong(){ echo "ERROR: The command [$1] version wrong"; exit 5; }

usage()
{
    echo USAGE: $sourceFileName BASE TARGET
}

checkDiskSpace()
{
    availSpace=`df $sourceFilePath | tail -n 1 | awk '{print $4}'`
    baseSpace=`du -c $BASE | grep -w "total" | awk '{print $1}'`
    targetSpace=`du -c $TARGET | grep -w "total" | awk '{print $1}'`
    [ $(( 3 * ( $baseSpace + $targetSpace ) )) -gt $availSpace ] && { return 1; }
}

echo "-------Check cmd@`date`-----------" >> $log 2>&1
`which ruby` -v >> $log 2>&1 || exitCommandNotFound 'ruby'
`which tar` --version >> $log 2>&1 || exitCommandNotFound 'tar'
`which zip` -h >> $log 2>&1 || exitCommandNotFound 'zip'
echo `which rpm2cpio` | grep "rpm2cpio" >> $log 2>&1 || exitCommandNotFound 'rpm2cpio'
`which cpio` --version >> $log 2>&1 || exitCommandNotFound 'cpio'

echo "-------Check arg@`date`-----------" >> $log 2>&1
# Check Arguments
[ $# -ne 2 ] && { usage; exitArgumentNumberIllegal; }

BASE=$1
TARGET=$2
[ -e $BASE -a -e $TARGET ] || { usage; exitArgumentTypeIllegal; }
[ -f $BASE -a -d $TARGET ] && { usage; exitArgumentTypeIllegal; } 
[ -d $BASE -a -f $TARGET ] && { usage; exitArgumentTypeIllegal; } 

echo "-------Check diskspace@`date`-----------" >> $log 2>&1
checkDiskSpace && { usage; exitDiskSpaceNotEnough; }

export LC_ALL="en_US.UTF-8"

echo "-------Prepare base and target@`date`-----------" >> $log 2>&1
BASETMP="BASE.TMP.DIR"
TARGETTMP="TARGET.TMP.DIR"
rm -rf $BASETMP
rm -rf $TARGETTMP
mkdir -p $BASETMP
mkdir -p $TARGETTMP
cp -rf $BASE $BASETMP
cp -rf $TARGET $TARGETTMP

echo "" > BASE.TMP.DIR.ignore
echo "" > TARGET.TMP.DIR.ignore

echo "-------binary.rb@`date`-----------" >> $log 2>&1
ruby $sourceFilePath/lib/binary.rb $BASETMP/`basename $BASE` $TARGETTMP/`basename $TARGET` >> $log 2>&1 

echo "-------diff@`date`-----------" >> $log 2>&1
diff -t --tabsize=4 -r -u $BASETMP/`ls -1 $BASETMP` $TARGETTMP/`ls -1 $TARGETTMP` > differ.diff 2>>$log

echo "-------diff2html.awk@`date`-----------" >> $log 2>&1
awk -f $sourceFilePath/lib/diff2html.awk differ.diff > report.html 2>>$log

echo "-------diff ignore@`date`-----------" >> $log 2>&1
echo "diff -t -r -u BASE.TMP.DIR.ignore TARGET.TMP.DIR.ignore" > ignore.diff
for dir in `ls -1 $BASETMP | grep "\.DIR$"`
do
    sed -i "s%BASE\.TMP\.DIR/$dir/%%g" BASE.TMP.DIR.ignore
done
for dir in `ls -1 $TARGETTMP| grep "\.DIR$"`
do
    sed -i "s%TARGET\.TMP\.DIR/$dir/%%g" TARGET.TMP.DIR.ignore
done
diff -t --tabsize=4 -u BASE.TMP.DIR.ignore TARGET.TMP.DIR.ignore >> ignore.diff 2>>$log
awk -f $sourceFilePath/lib/diff2html.awk ignore.diff > ignore.report.html 2>>$log

echo "-------Done@`date`-----------" >> $log 2>&1

echo 'Done. ^.^'
echo "The log file: $log"
echo "The base dir: $BASETMP"
echo "The target dir: $TARGETTMP"
echo "The report file: report.html"
echo "The ignore report file: ignore.report.html"
