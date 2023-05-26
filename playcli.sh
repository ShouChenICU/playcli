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

export COLORTERM=truecolor
FILE=$1
START_OFFSET=`[ $# -gt 1 ]  && echo -n $2 || echo -n 0`
SPEED=`[ $# -gt 2 ]  && echo -n $3 || echo -n 1`
DURATION=`ffprobe -v quiet -show_format "$FILE" | awk -F '=' '/^duration/{print $2}'`
DURATION=`printf '%.3f' $DURATION`
# FRAME_RATE=`ffprobe -v quiet -select_streams v -show_entries stream=r_frame_rate "$FILE" | awk -F '=' '/r_frame_rate/{print $2}'`
# FRAME_RATE_NEW=`echo "scale=3; $SPEED * $FRAME_RATE" | bc`
TIME_START=`date +%s.%N`
TIME_START=`echo "scale=3; $TIME_START - $START_OFFSET / $SPEED" | bc`
TIME_OFFSET=0
WIDTH=`stty size | awk '{print $2}'`
HEIGHT=`stty size | awk '{print $1}'`
HEIGHT=$[$HEIGHT - 1]

fun_render() {
    FRAME_BUFFER=`ffmpeg -v quiet -ss $TIME_OFFSET -i "$FILE" -f apng -an -c:v apng -frames 1 - | jp2a --color --fill --chars="  " --size=$WIDTH"x"$HEIGHT -`
}

fun_print_timeline() {
    TIMELINE=`echo "\033[36m$TIME_OFFSET\033[0ms / \033[33m$DURATION\033[0ms"`
    local len=$[${#TIMELINE} - 30]
    local str_len=`echo "scale=0;($WIDTH - $len - 4) * $TIME_OFFSET / $DURATION" | bc`
    local left=''
    for((i=0; i < str_len; i++))
    do
        local left="$left="
    done
    local str_len=$[$WIDTH - $len - 5 - ${#left}]
    local right=''
    for((i=0; i < str_len; i++))
    do
        local right="$right-"
    done
    echo -en "$TIMELINE [\033[32m$left\033[35m%\033[0m$right]"
}

fun_calc_time_offset() {
    TIME_NOW=`date +%s.%N`
    TIME_OFFSET=`echo "scale=3; ($TIME_NOW - $TIME_START) * $SPEED" | bc`
    TIME_OFFSET=`printf '%.3f' $TIME_OFFSET`
}

echo 'Playing...'
while [ `echo "scale=3; $DURATION >= $TIME_OFFSET" | bc` -eq 1 ]
do
    fun_render
    clear
    echo "$FRAME_BUFFER"
    fun_print_timeline
    fun_calc_time_offset
done
echo ''
echo 'Play done.'
