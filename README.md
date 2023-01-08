# Motivation

## The name
The software is is called ABST: AFN's Batch (hard)Subtitling Tool. The name is an intended pun on the arabic word "أبسط" which means "simpler" as the software makes life much simpler when it comes to encoding hardsubs.


## Things we want to eradicate
- Writing your own script manually
    - https://www.msoms-anime.net/showthread.php?t=191296
    - Or using MeGUI...
- manual selection for video, sub, and on top of that no bulk processing or fonts managements x264gui tmod or staxrip.
    - https://www.msoms-anime.net/showthread.php?t=191297
    - https://www.youtube.com/watch?v=RZ1ufcY74gg&lc=UgwuA3QCaXxq2aXKEC54AaABAg.904X11QsXAN9HDjZIOcC0E&ab_channel=Jawad
- https://www.youtube.com/watch?v=fS-EoGYzP6k&ab_channel=ZakAlqadi
- https://github.com/Abu3safeer/mpv-bulk-encode-ass
---> mpv: libass + no bulk/automated processing for fonts
- staxrip, handbrake, writing manual scripts, other solutions using of mpv/ffmpeg w/out the correct fonts or with libass making the subtitles appear wrongly



# syntax and Usage
- Example
`abst.exe -crf 22  -preset -subpriority`
` .\abst.exe -crf 24 -subpriority "internal_first" -f "C:\path\input_video1.mkv" -output_destination "out2"` will out output to out2 folder
` .\abst.exe -crf 24 -subpriority "internal_first" -f "C:\path\input_video1.mkv::C:\path\input_video2.mkv::C:\path\input_video3"` each output will be in its corresponding input's directory
full example:
` .\abst.exe -crf 24 -preset "medium" -subpriority "internal_first" -audio "all_to_aac" -f $input_video1` each output will be in its corresponding input's directory
- Currently no way to set profile nor level, they are left blank in encoder command.
- `crf` values (official ones): .. from  0 to 51 (no default)
- `preset` values (official ones): default ultrafast
- `tune` (official x264 ones) animation by default
- `subpriority` : 
    - "ignore" : will completely remove subtitles, useful for people who want re-encoded raws out of MKVs at one go
    - "internal_first" :(i.e prefer internal, if no internal will look for external local)
    - "external_first" :(i.e prefer local external, if no external will look for internal)
- `audio`:
    - "copy": audio will be left untouched as source
    - "all_to_aac": audio will always be transcoded 
    - "ac3_to_aac": any audio will be copied except ac3 audio will re-encoded
    - "non_aac_only": if input has non-aac audio, it will be reenocded (default )
    - "disable": output will not have any audio (for people doing FX/TS w/out a need for audio)
- `output_destination` 
    - "" empty => default: do not provide a value, and the same folder of the input will be used
    - /path/to/folder a directory to save output
- `files`
    - ` "path/to/file1" "path/to/file2..."` : paths to files separated with spaces, make sure to put each path between `" "` to escpae special characters
- `prefix`  
    - "string" add some prefix before name filename
- `suffix`
  - "string" add some suffix at the end of the name but before extension
- `auto_resize`
  - "int" one of the following choices 360,480,720,1080. This option will only downscale, if will not upscale.
    That means, if your input is 720p and you picked the 1080 parameter, it will be ignored.
    If you gave as input a list of files, only eligible files will be downscaled.

- some dimensions parameter TO BE ADDED LATER
    - null => same i.e copy
    - width(int) height(int)





##  Other useful (batch) tools to use with this
- InviskaMKVExtract
- batch file renamer
- crc32

# Limitations:
If your input has multiple audio tracks /multiple sub tracks, without any of them having the default flag, you will get no audio/sub. 


# FAQ

## Genral User FAQ

## More advanced FAQ