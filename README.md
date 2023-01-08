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

# Simple Usage guide (GUI)
For most users you want to read this section only and skip the next section about CLI.



# syntax and Usage (CLI) - for advanced users
- Example

` .\abst_cli.exe -crf 24 -subpriority "internal_first" -f "C:\path\input_video1.mkv" -output_destination "out2"` will out output to out2 folder

` .\abst_cli.exe -crf 24 -subpriority "internal_first" -f "C:\path\input_video1.mkv::C:\path\input_video2.mkv::C:\path\input_video3"` each output will be in its corresponding input's directory
full example:
` .\abst_cli.exe -crf 24 -preset "medium" -subpriority "internal_first" -audio "all_to_aac" -f $input_video1` each output will be in its corresponding input's directory
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
    - ` "path/to/file1::path/to/file2..."` : paths to files separated with spaces, make sure to put the pathes between `" "` to escape special characters
- `prefix`  
    - "string" add some prefix before name filename
- `suffix`
  - "string" add some suffix at the end of the name but before extension
- `auto_resize`
  - "int" one of the following choices 360,480,720,1080. This option will only downscale, if will not upscale.
    That means, if your input is 720p and you picked the 1080 parameter, it will be ignored.
    If you gave as input a list of files, only eligible files will be downscaled.
   - There is no option to input  width(int) and height(int) at the time being.





##  Other useful (batch) tools to use with this
- InviskaMKVExtract
- batch file renamer
- crc32

# Limitations:
If your input has multiple audio tracks /multiple sub tracks, without any of them having the default flag, you will get no audio/sub. 


# FAQ

## Genral User FAQ

### Do I need to install the software? Are admin priveleges needed?
No, the app is fully portable, you do not need to install any thing. Just download it and extract the archive.

### Do I need to manually install fonts?
No, ABST handles everything for you.

### Can I request a new feature? / Any plans to add X,Y features?
We may happily consider requests depending on demands and necessary developement time, maybe yes, maybe no, no promises.
Please do note that feedback is necessary, we don't add features for the sake of completeness unless there is demand. So if you need a feature don't expect it to be added out of the blue, please do reach out to us, and let us hear your ideas so we can gather information on requested features.

### I am having trouble using your tool? The tool did not work as expected...
Please open an issue on github or contact us by Email on dev-support<{AT}>animefn.com  (replace <{AT}> with @).

## More advanced FAQ

### Any plans to support other OS? MAC? Linux?
Maybe Linux, Our UI is cross-os compatible, and so is avisynth (in theory), but the main problem is vsfilter and libass is very limited, specially for non-latin languages. VSfilter Could be used with avs2yuv, wine etc, but it is a long shot...
We have no plans to support MAC os for the time being,it might be considered after we add suport for linux (if ever). 
