#!/bin/bash

if [ -z "$FFMPEG" ]; then FFMPEG=ffmpeg; fi

# extract 20 seconds from original video
if [ ! -f "gta-orig.720p.mp4" ]; then
  $FFMPEG -loglevel warning -stats -i cVGRDjlmMFk.mp4 -ss 8.2 -t 20 gta-orig.720p.mp4
fi

# unpack original into separate frames
rm -rf gta-frames
mkdir -p gta-frames
$FFMPEG -loglevel warning -stats -i gta-orig.720p.mp4 -vf scale=900:506 gta-frames/gta-%03d.png -y

for PPF in 1 2 5 10 20 50 100 150 200 300 600 900 1200 1600 2000 2400; do
	echo gta-${PPF}-900x506.webp
	$FFMPEG -loglevel warning -stats -r 30 -i gta-frames/gta-%03d.png -c:v splash -ppf $PPF -ppk 2 splash-gta-${PPF}-900x506.mkv -y
	$FFMPEG -loglevel warning -stats -r 30 -i splash-gta-${PPF}-900x506.mkv -q:v 85 gta-${PPF}-900x506.webp -y
done

# Upscale 90x50
echo Upscale 90x50
$FFMPEG -loglevel warning -stats -r 30 -i splash-gta-1-900x506.mkv  -vf scale=90:50   -crf 18 gta-90x50.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i gta-90x50.mkv     -vf scale=420:236 -crf 18 gta-90x50-420x236.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i gta-90x50.mkv     -vf scale=420:236 -q:v 85 gta-90x50-420x236.webp -y
$FFMPEG -loglevel warning -stats -r 30 -i gta-90x50.mkv     -vf scale=900:506 -crf 18 gta-90x50-900x506.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i gta-90x50.mkv     -vf scale=900:506 -q:v 85 gta-90x50-900x506.webp -y

# Upscale 285x160 to 420x236
echo Upscale 285x160
$FFMPEG -loglevel warning -stats -r 30 -i splash-gta-1-900x506.mkv  -vf scale=285:160 -crf 18 gta-285x160.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i gta-285x160.mkv   -vf scale=420:236 -crf 18 gta-285x160-420x236.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i gta-285x160.mkv   -vf scale=420:236 -q:v 85 gta-285x160-420x236.webp -y
$FFMPEG -loglevel warning -stats -r 30 -i gta-285x160.mkv   -vf scale=900:506 -crf 18 gta-285x160-900x506.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i gta-285x160.mkv   -vf scale=900:506 -q:v 85 gta-285x160-900x506.webp -y

# scale PPF=100 to 420x236
echo PPF=100
$FFMPEG -loglevel warning -stats -r 30 -i splash-gta-100-900x506.mkv  -vf scale=420:236 -crf 18 gta-100-420x236.mkv -y
$FFMPEG -loglevel warning -stats -r 30 -i splash-gta-100-900x506.mkv  -vf scale=900:506 -crf 18 gta-100-900x506.mkv -y

# Create gta side-by-size
echo SBS
$FFMPEG -loglevel warning -stats -i gta-100-420x236.mkv -i gta-90x50-420x236.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -q:v 85 gta-sbs-820x236.webp -y
$FFMPEG -loglevel warning -stats -i gta-100-900x506.mkv -i gta-90x50-900x506.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -q:v 85 gta-sbs-1800x506.webp -y
$FFMPEG -loglevel warning -stats -i gta-100-900x506.mkv -i gta-90x50-900x506.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -crf 18 -profile:v baseline -level 3.0 -movflags +faststart -pix_fmt yuv420p gta-sbs-1800x506.mp4 -y

# preview
$FFMPEG -loglevel warning -stats -i gta-frames/gta-001.png -q 0 gta-900x506.jpg -y
$FFMPEG -loglevel warning -stats -i gta-100-420x236.mkv -i gta-90x50-420x236.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -ss 2 -frames:v 1 -q 0 gta-sbs-820x236.jpg -y
$FFMPEG -loglevel warning -stats -i gta-100-900x506.mkv -i gta-90x50-900x506.mkv -filter_complex "[0:v][1:v]hstack=inputs=2[v]" -map "[v]" -ss 2 -frames:v 1 -q 0 gta-sbs-1800x506.jpg -y
