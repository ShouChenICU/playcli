#!/bin/bash
echo 'Author: ShouChen' >&2
echo '' >&2
if [ $# -eq 0 ];
then
	echo 'Invalid args!' >&2
	echo '' >&2
	echo 'Usage:' >&2
	echo 'playcli.sh <your vedio> [offset_seconds [speed]]' >&2
	echo ''
	echo 'Example: playcli.sh 1.mkv'
	echo 'Example: playcli.sh 1.mkv 114'
	echo 'Example: playcli.sh 1.mkv 514 10'
	echo '' >&2
	exit -1
fi

echo 'Playing...'
COLORTERM=truecolor
FILE=$1
START_OFFSET=$([ $# -gt 1 ]  && echo -n $2 || echo -n 0)
SPEED=$([ $# -gt 2 ]  && echo -n $3 || echo -n 1)
DURATION=`ffprobe -v quiet -show_format $FILE | grep duration | tr "=" " " | awk '{print $2}'`
# FRAME_RATE=`ffprobe -v quiet -select_streams v -show_entries stream=r_frame_rate $FILE | grep r_frame_rate | tr "=" " " | awk '{print $2}'`
# FRAME_RATE_NEW=`echo "scale=3; $SPEED * $FRAME_RATE" | bc`
TIME_START=`date +%s.%N`
TIME_START=`echo "scale=3; $TIME_START - $START_OFFSET / $SPEED" | bc`
TIME_NOW=$TIME_START
TIME_OFFSET=0
WIDTH=`stty size|awk '{print $2}'`
HEIGHT=`stty size|awk '{print $1}'`

while [ `echo "scale=3; $DURATION >= $TIME_OFFSET" | bc` -eq 1 ]
do
	TIME_NOW=`date +%s.%N`
	TIME_OFFSET=`echo "scale=3; ($TIME_NOW - $TIME_START) * $SPEED" | bc`
	ffmpeg -v quiet -ss `printf "%.3f" $TIME_OFFSET` -i "$FILE" -f apng -an -c:v apng -frames 1 - | jp2a --color --fill --chars="  " --size=$WIDTH"x"$HEIGHT -
done

echo 'Play done.'
