$input_video = "video.mkv"
$base_input_video = ([io.fileinfo]$input_video).basename
#$input_video = "vid.mp4"
#$tmp_dir = "tmp"+somerandom  hash-name to avoid collision
$tmp_dir = "my temp"

# dammit, can just dump attachement with 1 line
# ffmpeg -dump_attachment:t:0 n/* -i test.mkv
$info_array = .\mkvmerge.exe  --identification-format json --identify $input_video | ConvertFrom-Json         
$nb= $x.attachments.count
echo $nb
mkdir $tmp_dir
cd $tmp_dir

..\mkvextract.exe attachments ..\$input_video (1..$nb)
cd ..

#Check if input file has internal track
.\ffmpeg -i "$input_video" -c copy -map 0:s:0 -frames:s 1 -f null - -v 0 -hide_banner;  echo $?   | Tee-Object -Variable has_internalsub | Out-Null

echo ($has_internalsub)
#.ass hardcoded, what if file is srt/vtt? maybe we will be ok if textsub care not about .extention
ffmpeg -i $input_video -map 0:s:0 $base_input_video".ass"

echo "lol"

rmdir -Force $tmp_dir