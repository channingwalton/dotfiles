#!/bin/bash
filename=$1
outfile=${filename}.mp4
echo "Converting ${filename} to ${outfile}"
ffmpeg -hide_banner -loglevel panic -i "${filename}"  -c:v libx265 -preset slow -crf 0 -vtag hvc1 -c:a aac -map_metadata 0 "${outfile}" 
touch -r "${filename}" "${outfile}"
