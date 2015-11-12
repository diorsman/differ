#!/bin/bash

sourceFilePath="$(dirname ${BASH_SOURCE[0]})"
sourceFileName="$(basename ${BASH_SOURCE[0]})"
log=$sourceFilePath/$sourceFileName.log

echo '-------Begin-----------' >> $log 2>&1
echo `date` > $log 2>&1

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

echo '-------Check cmd-----------' >> $log 2>&1
`which ruby` -v >> $log 2>&1 || exitCommandNotFound 'ruby'
`which perl` -v >> $log 2>&1 || exitCommandNotFound 'perl'
`which tar` --version >> $log 2>&1 || exitCommandNotFound 'tar'
`which zip` -h >> $log 2>&1 || exitCommandNotFound 'zip'
echo `which rpm2cpio` | grep "rpm2cpio" >> $log 2>&1 || exitCommandNotFound 'rpm2cpio'
`which cpio` --version >> $log 2>&1 || exitCommandNotFound 'cpio'

echo '-------Check arg-----------' >> $log 2>&1
# Check Arguments
[ $# -ne 2 ] && { usage; exitArgumentNumberIllegal; }

BASE=$1
TARGET=$2
[ -e $BASE -a -e $TARGET ] || { usage; exitArgumentTypeIllegal; }
[ -f $BASE -a -d $TARGET ] && { usage; exitArgumentTypeIllegal; } 
[ -d $BASE -a -f $TARGET ] && { usage; exitArgumentTypeIllegal; } 

echo '-------Check diskspace-----------' >> $log 2>&1
checkDiskSpace && { usage; exitDiskSpaceNotEnough; }

echo '-------Prepare base and target-----------' >> $log 2>&1
BASETMP="BASE.TMP.DIR"
TARGETTMP="TARGET.TMP.DIR"
rm -rf $BASETMP
rm -rf $TARGETTMP
mkdir -p $BASETMP
mkdir -p $TARGETTMP
cp -rf $BASE $BASETMP
cp -rf $TARGET $TARGETTMP

fixOnlyOneLine4pl()
{
    for file in `diff -r -u $1 $2 | grep -E "\-\-\- |\+\+\+ " | awk '{print $2}'`
    do
        if [ "1X" == "`wc -l $file | awk '{print $1}'`X" ];then
            echo "" >> $file
        fi
    done
}

echo '-------binary.rb-----------' >> $log 2>&1
ruby $sourceFilePath/lib/binary.rb $BASETMP/`basename $BASE` $TARGETTMP/`basename $TARGET` >> $log 2>&1 

echo '-------fixOnlyOneLine4pl-----------' >> $log 2>&1
fixOnlyOneLine4pl $BASETMP/`ls -1 $BASETMP` $TARGETTMP/`ls -1 $TARGETTMP/`

echo '-------differ.pl-----------' >> $log 2>&1
perl $sourceFilePath/lib/differ.pl -r -N -o report.html -t "$BASE    VS    $TARGET" $BASETMP/`ls -1 $BASETMP` $TARGETTMP/`ls -1 $TARGETTMP/` >> $log 2>&1

echo '-------Done-----------' >> $log 2>&1
echo 'Done. ^.^'
echo "The log file: $log"
echo "The base dir: $BASETMP"
echo "The target dir: $TARGETTMP"
echo "The report file: report.html"
