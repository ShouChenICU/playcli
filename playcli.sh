#!/bin/bash
echo 'Author: ShouChen'
echo ''
if [ $# -eq 0 ];
then
	echo 'Invalid file name'
	exit -1
fi

echo 'Playing...'
COLORTERM=truecolor
FILE=$1
DURATION=`ffprobe -i $FILE 2>&1 | grep Duration|awk '{print $2}'`
LST=(`echo $DURATION|tr ":" "\n"`)
H=${LST[0]}
M=${LST[1]}
S=`echo ${LST[2]}|tr "." " "|awk '{print $1}'`
echo "Duration: "$H"H" $M"M" $S"S"
DURATION=$[$H * 3600 + $M * 60 + $S]
TIME_START=`date +%s.%N`
TIME_NOW=$TIME_START
WIDTH=`stty size|awk '{print $2}'`
HEIGHT=`stty size|awk '{print $1}'`

while [ `echo "$TIME_NOW - $TIME_START < $DURATION"|bc` -eq 1 ]
do
	TIME_NOW=`date +%s.%N`
	TIME_OFFSET=`echo "$TIME_NOW - $TIME_START"|bc`
	ffmpeg -v quiet -ss `printf "%.3f" $TIME_OFFSET` -i "$FILE" -f apng -an -c:v apng -frames 1 - |jp2a --color --fill --chars="  " --size=$WIDTH"x"$HEIGHT -
done
