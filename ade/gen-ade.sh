#!/bin/bash

if [ -z "$FFMPEG" ]; then FFMPEG=ffmpeg; fi

# extract 20 seconds from original video
if [ ! -f "ade-orig.720p.mp4" ]; then
  $FFMPEG -loglevel warning -stats -i ade-20191018_025041.mp4 -t 10 -vf scale=1280:720 ade-orig.720p.mp4
fi

# unpack original into separate frames
rm -rf ade-frames
mkdir -p ade-frames
$FFMPEG -loglevel warning -stats -i ade-orig.720p.mp4 -vf scale=900:506 ade-frames/ade-%03d.png -y

for PPF in 1 2 5 10 20 50 100 150 200 300 600 900 1200 1600 2000 2400; do
	echo ade-${PPF}-900x506.webp
	$FFMPEG -loglevel warning -stats -r 30 -i ade-frames/ade-%03d.png -c:v splash -ppf $PPF -ppk 2 splash-ade-${PPF}-900x506.mkv -y
	$FFMPEG -loglevel warning -stats -r 30 -i splash-ade-${PPF}-900x506.mkv -q:v 85 ade-${PPF}-900x506.webp -y
done

# Upscale 90x50
echo Upscale 90x50
$FFMPEG -loglevel warning -stats -r 30 -i splash-ade-1-900x506.mkv  -vf scale=90:50   -crf 18 ade-90x50.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i ade-90x50.mkv     -vf scale=420:236 -crf 18 ade-90x50-420x236.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i ade-90x50.mkv     -vf scale=420:236 -q:v 85 ade-90x50-420x236.webp -y
$FFMPEG -loglevel warning -stats -r 30 -i ade-90x50.mkv     -vf scale=900:506 -crf 18 ade-90x50-900x506.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i ade-90x50.mkv     -vf scale=900:506 -q:v 85 ade-90x50-900x506.webp -y

# Upscale 285x160 to 420x236
echo Upscale 285x160
$FFMPEG -loglevel warning -stats -r 30 -i splash-ade-1-900x506.mkv  -vf scale=285:160 -crf 18 ade-285x160.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i ade-285x160.mkv   -vf scale=420:236 -crf 18 ade-285x160-420x236.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i ade-285x160.mkv   -vf scale=420:236 -q:v 85 ade-285x160-420x236.webp -y
$FFMPEG -loglevel warning -stats -r 30 -i ade-285x160.mkv   -vf scale=900:506 -crf 18 ade-285x160-900x506.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i ade-285x160.mkv   -vf scale=900:506 -q:v 85 ade-285x160-900x506.webp -y

# scale PPF=100 to 420x236
echo PPF=100
$FFMPEG -loglevel warning -stats -r 30 -i splash-ade-100-900x506.mkv  -vf scale=420:236 -crf 18 ade-100-420x236.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i splash-ade-100-900x506.mkv  -vf scale=900:506 -crf 18 ade-100-900x506.mkv -y

# Create ade side-by-size
echo SBS
$FFMPEG -loglevel warning -stats -i ade-100-420x236.mkv -i ade-90x50-420x236.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -q:v 85 ade-sbs-820x236.webp -y
$FFMPEG -loglevel warning -stats -i ade-100-900x506.mkv -i ade-90x50-900x506.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -q:v 85 ade-sbs-1800x506.webp -y
$FFMPEG -loglevel warning -stats -i ade-100-900x506.mkv -i ade-90x50-900x506.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -crf 18 -profile:v baseline -level 3.0 -movflags +faststart -pix_fmt yuv420p ade-sbs-1800x506.mp4 -y

# preview
$FFMPEG -loglevel warning -stats -i ade-frames/ade-001.png -q 0 ade-900x506.jpg -y
$FFMPEG -loglevel warning -stats -i ade-100-420x236.mkv -i ade-90x50-420x236.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -ss 2 -frames:v 1 -q 0 ade-sbs-820x236.jpg -y
$FFMPEG -loglevel warning -stats -i ade-100-900x506.mkv -i ade-90x50-900x506.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -ss 2 -frames:v 1 -q 0 ade-sbs-1800x506.jpg -y

#
# $FFMPEG -loglevel warning -stats -r:v 240/1 -i ade-border-1920x1080.mp4 -vf scale=840:472 -r 12/1 ade-border-840x472.webp
