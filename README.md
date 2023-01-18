# Motivation

## About: 
ABST is a tool to batch transcode videos. Its main focus is to allow bulk/batch conversion of softsubbed mkv videos to hardsubbed mp4 that are more compatible with web players. It can also do bulk processing for videos that do not have subtitles attached inside the video container but have them as an external file in the same folder with the same name. You do not have to manually extract fonts if they are attached to the mkv.



## The name
The software is called ABST: AnimeFN's Batch (hard)Subtitling Tool. The name is an intended pun on the arabic word "أبسط" which means "simpler" as the software makes life much simpler when it comes to encoding hardsubs.


## Tedious methods we want to eradicate
- Writing your own script manually
    - https://www.msoms-anime.net/showthread.php?t=191296
    - Or using MeGUI...
- manual selection for video, sub, and on top of that no bulk processing or fonts managements x264gui tmod or staxrip.
    - https://www.msoms-anime.net/showthread.php?t=191297
    - https://www.youtube.com/watch?v=RZ1ufcY74gg&lc=UgwuA3QCaXxq2aXKEC54AaABAg.904X11QsXAN9HDjZIOcC0E&ab_channel=Jawad
- https://www.youtube.com/watch?v=fS-EoGYzP6k&ab_channel=ZakAlqadi
- https://github.com/Abu3safeer/mpv-bulk-encode-ass
---> mpv so libass + requires node installation, might get a bit tedious and no GUI
- staxrip, handbrake, writing manual scripts, other solutions using of mpv/ffmpeg w/out the correct fonts or with libass making the subtitles appear wrongly

# Simple Usage guide (GUI)
For most users you want to read this section only and skip the next section about CLI.



# syntax and Usage (CLI) - for advanced users
- Example

` .\abst_cli.exe -crf 24 -subpriority "internal_first" -f "C:\path\input_video1.mkv" -output_destination "out2"` will output to out2 folder

` .\abst_cli.exe -crf 24 -subpriority "internal_first" -f "C:\path\input_video1.mkv::C:\path\input_video2.mkv::C:\path\input_video3"` each output will be in its corresponding input's directory
full example:
` .\abst_cli.exe -crf 24 -preset "medium" -subpriority "internal_first" -audio "all_to_aac" -f $input_video1` each output will be in its corresponding input's directory
- Currently no way to set profile nor level, they are left blank in encoder command.
- `crf` values (official ones): .. from  0 to 51 (no default), prefer values around 19-25 for a secondary hardsubs encode for distribution. Lower means higher quality at the expense of a bigger filesize.
more on this https://slhck.info/video/2017/02/24/crf-guide.html
- `preset` values (official ones): default ultrafast
- `tune` (official x264 ones) animation by default
- `subpriority` : 
    - "internal_first" :(i.e prefer internal, if no internal, it will look for external local)
    - "external_first" :(i.e prefer local external, if no external, it will look for internal)
    - "ignore" : will completely remove subtitles if internal and ignore them if external in same folder. useful for people who want re-encoded raws out of MKVs at one go
- `audio`:
    - "copy": audio will be left untouched as source
    - "all_to_aac": audio will always be transcoded 
    - "ac3_to_aac": any audio will be copied except ac3 audio will re-encoded
    - "non_aac_only": if input has non-aac audio, it will be reenocded (default )
    - "disable": output will not have any audio (for people doing FX/TS w/out a need for audio)
- `qaac_quality`:
    - [int], a value between 0 and 127. Prefer values around 90-100. Higher means better quality at the expense of bigger filesize.
    This value, corresponds to the --tvbr value in qaac encoder.
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
  - "int" one of the following choices 360,480,720,1080. This option will only downscale, it will not upscale.
    That means, if your input is 720p and you picked the 1080 parameter, it will be ignored.
    If you gave as input a list of files, only eligible files will be downscaled.
   - There is no option to input  width(int) and height(int) at the time being.





##  Other useful (batch) tools to use with this
- InviskaMKVExtract/JMKVPropedit (use https://github.com/BrunoReX/jmkvpropedit  doom9 discussion https://forum.doom9.org/showthread.php?t=163753)
- https://github.com/yaser01/mkv-muxing-batch-gui (a great and highly recommended tool)
- batch file renamer
- crc32
- in some cases that ABST does not cover, you may want to use https://sourceforge.net/projects/ffmpeg-batch/

# Limitations:
- If your input has multiple audio tracks /multiple sub tracks, without any of them having the default flag, you will get no audio/sub.  (see faq for a workaround)



# FAQ

## Genral User FAQ

### My videos have English (default) and Japanese (not default) audio, how do I get the output to have that non-default sweet Japanese audio?
ABST can't and is not meant to do this. You need to do 2 steps.
1- Use mkv-muxing-batch-gui [url] to keep 1 signle audio with specific language or track id and discard any other audio tracks (and preferably set that as default for consistency).
2- Now use ASBT as usual, since the file has 1 audio only, this 1 single audio track will be used.

### Do I need to install the software? Are admin priveleges needed?
No, the app is fully portable, you do not need to install any thing. Just download it and extract the archive.

### Do I need to manually install fonts?
No, ABST handles everything for you and will install the fonts temporarily (without admin priveleges) for the session during encode and remove them once done.

### what encoders are available?
The only options is x264 for the time being, other options might be cosnidered in the near future depeding on requests and feedbacks.

### Can I request a new feature? / Any plans to add X,Y features?
Before making requests, please note that ABST is not meant as the swiss knife of video encoders, a GUI to ffmpeg, nor as some primary tool for everything.
We have the vision that 1 problem = 1 solution, in order to keep tools simple and less confusing. Our sole aim is to provide a fool-proof tool where you drag-and-drop your MKVs and get them hardsubbed (correctly) without even understanding what happens, just by using the default values that we chose for you.  
Adding many tabs in ABST, more fields and options etc, may make the UI much more complicated for newbies.

With that in mind, We will happily consider requests depending on demands and necessary developement time, no promises though.
Please do note that feedback is necessary, we don't add features for the sake of completeness unless there is demand. So if you need a feature don't expect it to be added out of the blue, please do reach out to us, and let us hear your ideas so we can gather information on requested features. Fixing bugs will surely have higher priority than "extra" features. Feauture requested that are sponsored/backed up by a financial donation may get higher priority.


### Can I offer a new language for the user interface?
Translations of our software are welcome! Please open an issue and we will give you the source file (in English) and you can translate it to your language.
Translation is very easy, and requires very simple computer skills no specialized/complicated knowledge needed!

### I am having trouble using your tool? The tool did not work as expected...
Please open an issue on github, contact us on discord or via Email on dev-support<{AT}>animefn.com  (replace <{AT}> with @).

## More advanced FAQ
### What OS are supported?
Currently windows only. Our releases are 32 bit, so they run fine for people on 32 bit OS or 64 bit. We will release 64 bit version (better efficiency for 64 bit OS users) in the near future.

### Any plans to support other OS? MAC? Linux?
Maybe Linux, Our UI is cross-os compatible, and so is avisynth (in theory), but the main problem is vsfilter and libass is very limited, specially for non-latin languages. VSfilter Could be used with avs2yuv, wine etc, but it is a long shot...
We have no plans to support MAC os for the time being,it might be considered after we add suport for linux (if ever). 
