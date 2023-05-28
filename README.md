# playcli

![playcli](https://img.shields.io/badge/playcli-v0.13-5bc2e7?style=for-the-badge "playcli v0.13")
![FFmpeg](https://img.shields.io/badge/-FFmpeg-ff69b4?style=for-the-badge "FFmpeg")
![jp2a](https://img.shields.io/badge/-jp2a-success?style=for-the-badge "jp2a")

Play vedio on your console

## Description

It will automatically get the current window size and play with adaptive frame rate on your console, and you can also set the start offset and playback speed.

## Fetures

- Only need one console
- Window size updated in real time
- Adaptive frame rate
- Beautiful timeline
- Audio support

## Requirements

- [ffmpeg](https://github.com/FFmpeg/FFmpeg)
- [jp2a](https://github.com/Talinx/jp2a)

You can run this command to install it on your debian-like system

`sudo apt install ffmpeg jp2a`

## Usage

```SHELL
playcli.sh <your vedio> [offset_seconds [speed]]
```

Mute

```SHELL
AUDIO_ENABLE=0 playcli.sh <your vedio> [offset_seconds [speed]]
```

## Examples

```BASH
playcli.sh 1.mkv
playcli.sh 1.mkv 114
playcli.sh 1.mkv 514 10
```

![Pic1](res/playcli1.png "playcli1")

![Pic2](res/playcli2.png "playcli2")

![Gif](res/demo.gif "demo")
