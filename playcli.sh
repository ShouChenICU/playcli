#!/bin/bash
echo 'Author: ShouChen' >&2
echo 'Version: v0.13'
echo '' >&2
fun_print_help() {
        echo 'Usage:' >&2
        echo '    playcli.sh <your vedio> [offset_seconds [speed]]' >&2
        echo '' >&2
        echo 'Example:' >&2
        echo '    playcli.sh 1.mkv' >&2
        echo '    playcli.sh 1.mkv 114' >&2
        echo '    playcli.sh 1.mkv 514 10' >&2
        echo '' >&2
        echo 'Github: https://github.com/ShouChenICU/playcli' >&2
        echo '' >&2
}
if [[ $# == 0 ]];
then
    echo -e "Invalid args!\n" >&2
    fun_print_help
    exit -1
elif [[ ! -f $1 ]];
then
    echo -e "File not found!\n" >&2
    fun_print_help
    exit -1
fi
type 'ffmpeg' >/dev/null 2>&1
if [[ $? != 0 ]];
then
    echo "ffmpeg not found! Please install ffmpeg in your system" >&2
    exit -2
fi
type 'jp2a' >/dev/null 2>&1
if [[ $? != 0 ]];
then
    echo "jp2a not found! Please install jp2a in your system" >&2
    exit -2
fi

# Init variables
export COLORTERM=truecolor
FILE=$1
START_OFFSET=0
if [[ $# > 1 && `echo "scale=3; $2 > 0" | bc` == 1 ]];
then
    START_OFFSET=`printf '%.3f' $2`
fi
SPEED=1
if [[ $# > 2 && `echo "scale=3; $3 != 0" | bc` == 1 ]];
then
    SPEED=`printf '%.3f' $3`
fi
DURATION=`ffprobe -v quiet -show_format "$FILE" | awk -F '=' '/^duration/{print $2}'`
DURATION=`printf '%.3f' $DURATION`
TIME_START=`date +%s.%N`
TIME_OFFSET=0
WIN_SIZE=(`stty size | tr "[:space:]" "\n"`)

# Calculate time offset
fun_calc_time_offset() {
    TIME_NOW=`date +%s.%N`
    TIME_OFFSET=`echo "scale=3; ($TIME_NOW - $TIME_START) * $SPEED + $START_OFFSET" | bc`
    TIME_OFFSET=`printf '%.3f' $TIME_OFFSET`
}

# Render frame buffer
fun_render() {
    WIN_SIZE=(`stty size | tr "[:space:]" "\n"`)
    FRAME_BUFFER=`ffmpeg -v quiet -ss $TIME_OFFSET -i "$FILE" -f apng -an -c:v apng -frames 1 - | jp2a --color --fill --chars="  " --size=${WIN_SIZE[1]}"x"$[${WIN_SIZE[0]} - 1] -`
}

# Setting timeline style
if [[ "$TIMELINE_STYLE" == 'trans' ]];
then
    # Trans style
    fun_print_timeline() {
        TIMELINE=`echo "\033[36m$TIME_OFFSET\033[0ms / \033[33m$DURATION\033[0ms"`
        local len=$[${#TIMELINE} - 30]
        local str_len=`echo "scale=0;(${WIN_SIZE[1]} - $len - 4) * $TIME_OFFSET / $DURATION" | bc`
        local left=''
        local left_ts=''
        for((i=0; i < str_len; i++))
        do
            case `echo "$i % 6" | bc` in
                0)
                    local ch='\033[38;5;45m='
                    ;;
                1)
                    local ch='\033[38;5;218m='
                    ;;
                2)
                    local ch='\033[38;5;231m='
                    ;;
                3)
                    local ch='\033[38;5;218m='
                    ;;
                4)
                    local ch='\033[38;5;45m='
                    ;;
                5)
                    local ch='\033[38;5;231m='
                    ;;
            esac
            local left_ts="$left_ts$ch"
            local left="$left="
        done
        local str_len=$[${WIN_SIZE[1]} - $len - 5 - ${#left}]
        local right=''
        for((i=0; i < str_len; i++))
        do
            local right="$right-"
        done
        echo -en "$TIMELINE [$left_ts\033[32m@\033[0m$right]"
    }
else
    # Clasic style
    fun_print_timeline() {
        TIMELINE=`echo "\033[36m$TIME_OFFSET\033[0ms / \033[33m$DURATION\033[0ms"`
        local len=$[${#TIMELINE} - 30]
        local str_len=`echo "scale=0;(${WIN_SIZE[1]} - $len - 4) * $TIME_OFFSET / $DURATION" | bc`
        local left=''
        for((i=0; i < str_len; i++))
        do
            local left="$left="
        done
        local str_len=$[${WIN_SIZE[1]} - $len - 5 - ${#left}]
        local right=''
        for((i=0; i < str_len; i++))
        do
            local right="$right-"
        done
        echo -en "$TIMELINE [\033[32m$left\033[32m@\033[0m$right]"
    }
fi

echo 'Playing...'
fun_calc_time_offset
if [[ "$AUDIO_ENABLE" != '0' && $SPEED == 1 ]];
then
    ffplay -v quiet -nodisp -sn -vn -ss $START_OFFSET -autoexit "$FILE" &
    PID_AUDIO=$!
fi
while [ `echo "scale=3; $DURATION >= $TIME_OFFSET" | bc` -eq 1 ]
do
    fun_render
    echo -en "\033[0;0H"
    echo "$FRAME_BUFFER"
    fun_print_timeline
    fun_calc_time_offset
    if [[ `echo "scale=3; $TIME_OFFSET < 0" | bc` == 1 ]];
    then
        break
    fi
done
wait
echo ''
echo 'Play done.'
