# Motivation

## About: 
ABST is a tool to batch transcode videos. Its main focus is to allow bulk/batch conversion of softsubbed mkv videos to hardsubbed mp4 that are more compatible with web players. It can also do bulk processing for videos that do not have subtitles attached inside the video container but have them as an external file in the same folder with the same name. You do not have to manually extract fonts if they are attached to the mkv.

To download the latest portable version visit (then select the first 7z archive): https://github.com/animefn/ABST/releases/latest

<div dir="rtl">
لتفاصيل وشرح باللغة العربية يرجى زيارة الصفحة التالية
https://wiki.animefn.com/asbt-guide

لتحميل أخر نسخة محمولة من البرنامج
https://github.com/animefn/ABST/releases/latest
</div>

## Features:
- Portable (no admin privileges required, does not pollute your environment)
- Audio encoding via QAAC (best AAC encoder for the time being)
- Uses VSFilter instead of libass (libass may have issues displaying many fonts)
- A cool user interface with different themes :)

## The name
The software is called ABST: AnimeFN's Batch (hard)Subtitling Tool. The name is an intended pun on the Arabic word "أبسط" which means "simpler" as the software makes life much simpler when it comes to encoding hardsubs.


## Tedious methods we want to eradicate
- Writing your own script manually
    - https://www.msoms-anime.net/showthread.php?t=191296
    - Or using MeGUI...
- Manual selection of video and subs, and on top of that no bulk processing or font management, in x264gui tmod or StaxRip.
    - https://www.msoms-anime.net/showthread.php?t=191297
    - https://www.youtube.com/watch?v=RZ1ufcY74gg&lc=UgwuA3QCaXxq2aXKEC54AaABAg.904X11QsXAN9HDjZIOcC0E&ab_channel=Jawad
- https://www.youtube.com/watch?v=fS-EoGYzP6k&ab_channel=ZakAlqadi
- https://github.com/Abu3safeer/mpv-bulk-encode-ass
---> mpv so libass + requires node installation, might get a bit tedious and no GUI
- StaxRip, HandBrake, writing manual scripts, other solutions using mpv/ffmpeg without the correct fonts or with libass making the subtitles appear wrongly

# Simple usage guide (GUI)
For most users you want to read this section only and skip the next section about CLI.



# Syntax and usage (CLI) - for advanced users
- Example

` .\abst_cli.exe -crf 24 -subpriority "internal_first" -f "C:\path\input_video1.mkv" -output_destination "out2"` will output to out2 folder

` .\abst_cli.exe -crf 24 -subpriority "internal_first" -f "C:\path\input_video1.mkv::C:\path\input_video2.mkv::C:\path\input_video3"` each output will be in its corresponding input's directory
full example:
` .\abst_cli.exe -crf 24 -preset "medium" -subpriority "internal_first" -audio "all_to_aac" -f $input_video1` each output will be in its corresponding input's directory
- Currently no way to set profile nor level, they are left blank in encoder command.
- `crf` values (official ones): from 0 to 51 (no default), prefer values around 19-25 for a secondary hardsubs encode for distribution. Lower means higher quality at the expense of a bigger filesize.
more on this https://slhck.info/video/2017/02/24/crf-guide.html
- `preset` values (official ones): default ultrafast
- `tune` (official x264 ones) animation by default
    - one of "film", "animation", "grain", "stillimage", "psnr", "ssim", "fastdecode", "zerolatency", "touhou"
    - "none" (or an empty value) encodes without any tune
    - "psnr" and "ssim" optimise for those metrics and generally look worse to the eye. They are meant for benchmarking, not for distribution.
- `subpriority` : 
    - "internal_first" :(i.e prefer internal, if no internal, it will look for external local)
    - "external_first" :(i.e prefer local external, if no external, it will look for internal)
    - "ignore" : will completely remove subtitles if internal and ignore them if external in same folder. Useful for people who want re-encoded raws out of MKVs at one go
- `audio`:
    - "copy": audio will be left untouched as source
    - "all_to_aac": audio will always be transcoded 
    - "ac3_to_aac": any audio will be copied except ac3 audio which will be re-encoded
    - "non_aac_only": if input has non-aac audio, it will be re-encoded (default)
    - "disable": output will not have any audio (for people doing FX/TS without a need for audio)
- `qaac_quality`:
    - [int], a value between 0 and 127. Prefer values around 90-100. Higher means better quality at the expense of bigger filesize.
    This value corresponds to the --tvbr value in qaac encoder.
- `output_destination` 
    - "" empty => default: do not provide a value, and the same folder of the input will be used
    - /path/to/folder a directory to save output
- `fonts_dir`
    - "/path/to/folder" a folder of extra fonts to use for this encode, on top of the fonts already attached to the input.
    - The fonts are installed temporarily for the duration of the encode (no admin privileges needed) and removed again once it is done, exactly like the attached ones.
    - Useful when your subtitles are an external file and the fonts they need are not attached to the video. This works whether or not the input carries attached fonts of its own.
    - If the folder you give does not exist, ABST says so and carries on without it.
    - May be written `-fo` or `-fon`. `-f` on its own always means the input files, see `files_str` below.
- `files_str` (may be written `-f` or `-fi`)
    - ` "path/to/file1::path/to/file2..."` : paths to files separated by `::`, make sure to put the paths between `" "` to escape special characters
- `prefix`  
    - "string" add some prefix before the filename
- `suffix`
  - "string" add some suffix at the end of the name but before extension
- `auto_resize`
  - "int" one of the following choices 360,480,720,1080. This option will only downscale, it will not upscale.
    That means, if your input is 720p and you picked the 1080 parameter, it will be ignored.
    If you gave as input a list of files, only eligible files will be downscaled.
   - There is no option to input width(int) and height(int) for the time being.

## Informational and troubleshooting parameters (CLI)
These are used on their own, without the encoding parameters above.
- `version` (may be written `-v`)
    - prints the CLI version and exits, for example `1.03`.
- `check_update`
    - asks GitHub for the latest published release and tells you whether a newer version exists. Needs an internet connection; if it cannot reach GitHub it says so and gives up instead of hanging.

These two can be added to a normal encoding command line and are mostly useful when reporting a bug:
- `debug_verbose`
    - a switch that prints extra details while working, such as how many audio and subtitle tracks were found inside each file.
- `testdev`
    - a switch for development only. It prints the ffmpeg command instead of relying on it, and it skips installing/uninstalling fonts and skips deleting the temp folder. Encodes made with it are not representative, do not use it for real work.




##  Other useful (batch) tools to use with this
- InviskaMKVExtract/JMKVPropedit (use https://github.com/BrunoReX/jmkvpropedit  doom9 discussion https://forum.doom9.org/showthread.php?t=163753)
- https://github.com/yaser01/mkv-muxing-batch-gui (a great and highly recommended tool)
- batch file renamer
- crc32
- in some cases that ABST does not cover, you may want to use https://sourceforge.net/projects/ffmpeg-batch/

# Limitations:
- If your input has multiple audio tracks /multiple sub tracks, without any of them having the default flag, you will get no audio/sub.  (see FAQ for a workaround)



# FAQ

## General User FAQ

### My videos have English (default) and Japanese (not default) audio, how do I get the output to have that non-default sweet Japanese audio?
ABST can't and is not meant to do this. You need to do 2 steps.
1- Use mkv-muxing-batch-gui (https://github.com/yaser01/mkv-muxing-batch-gui) to keep 1 single audio with specific language or track id and discard any other audio tracks (and preferably set that as default for consistency).
2- Now use ABST as usual, since the file has 1 audio only, this 1 single audio track will be used.

### Do I need to install the software? Are admin privileges needed?
No, the app is fully portable, you do not need to install anything. Just download it and extract the archive.

### Do I need to manually install fonts?
No, ABST handles everything for you and will install the fonts temporarily (without admin privileges) for the session during encode and remove them once done.

### What encoders are available?
The only option is x264 for the time being, other options might be considered in the near future depending on requests and feedback.

### Can I request a new feature? / Any plans to add X,Y features?
Before making requests, please note that ABST is not meant as the Swiss army knife of video encoders, a GUI to ffmpeg, nor as some primary tool for everything.
We have the vision that 1 problem = 1 solution, in order to keep tools simple and less confusing. Our sole aim is to provide a fool-proof tool where you drag-and-drop your MKVs and get them hardsubbed (correctly) without even understanding what happens, just by using the default values that we chose for you.  
Adding many tabs in ABST, more fields and options etc, may make the UI much more complicated for newbies.

With that in mind, we will happily consider requests depending on demand and necessary development time, no promises though.
Please do note that feedback is necessary, we don't add features for the sake of completeness unless there is demand. So if you need a feature don't expect it to be added out of the blue, please do reach out to us, and let us hear your ideas so we can gather information on requested features. Fixing bugs will surely have higher priority than "extra" features. Feature requests that are sponsored/backed up by a financial donation may get higher priority.


### Can I offer a new language for the user interface?
Translations of our software are welcome! Please open an issue and we will give you the source file (in English) and you can translate it to your language.
Translation is very easy, and requires very simple computer skills no specialized/complicated knowledge needed!

### I am having trouble using your tool? The tool did not work as expected...
Please open an issue on GitHub, contact us on Discord or via Email on dev-support<{AT}>animefn.com  (replace <{AT}> with @).

## More advanced FAQ
### Which OS are supported?
Currently Windows only. Our releases are 32 bit, so they run fine for people on 32 bit OS or 64 bit. We will release a 64 bit version (better efficiency for 64 bit OS users) in the near future.

### Any plans to support other OS? macOS? Linux?
Maybe Linux. Our UI is cross-OS compatible, and so is AviSynth (in theory), but the main problem is VSFilter, and libass is very limited, especially for non-Latin languages. VSFilter could be used with avs2yuv, wine etc, but it is a long shot...
We have no plans to support macOS for the time being, it might be considered after we add support for Linux (if ever). 


### Changelog

#### 1.04g7
- bug fix: `-fonts_dir` is now used even when the input has no fonts attached to it. It used to be applied only to videos that already carried their own fonts, so for a video with external subtitles and a folder of fonts (exactly what the option is for) the folder was silently ignored.
- if the fonts folder you give does not exist, ABST now tells you and carries on instead of ignoring it quietly.

#### 1.03g7
- bug fix: `-f` works again as the short form for the input files. Adding `-fonts_dir` had made a bare `-f` ambiguous between the two, so command lines that used to work started failing with "the parameter name 'f' is ambiguous". Use `-fo` or `-fonts_dir` for the fonts folder; `-f` always means the input files.
- added the "touhou" tune to the GUI.

#### 1.02g6
- bug fix: the `tune` setting had no effect at all. It was accepted and shown in the GUI, but never reached the encoder, so every encode ran untuned. Note that output now differs from earlier versions, because the documented "animation" default finally applies.
- the GUI now offers every x264 tune (stillimage, psnr, ssim, fastdecode, zerolatency) instead of only film/animation/grain, plus "none" to encode without a tune.
- update checks now read the latest release straight from GitHub, so there is no separate update server to go stale.

#### 1.01g5
- bug fix: the GUI would not start at all on Windows 11, with no error and no window. It asked the CLI for version information before creating its window, and any failure there killed the program before anything appeared. Several causes, all fixed:
    - the app now finds `abst_cli.exe`, `themes/` and `lang/` next to `ABST.exe` instead of relying on the folder you happened to launch it from, so shortcuts, a pinned taskbar entry, or running it from inside the archive all work.
    - the update check no longer goes through Internet Explorer, which is retired on Windows 11 and made the check fail there.
    - the update check now runs in the background with a time limit, so the window opens straight away instead of waiting on the network.
    - if something unexpected does go wrong, you now get a message box and an `abst_error.log` file next to `ABST.exe` instead of silence.
- bug fix: releases were being built with an empty `lang/` folder, so the Arabic and French translations were missing from the download.

#### V1 First Official release
- bug fix: No longer crash on startup if the program cannot reach update server (i.e now you can use the program without internet)
- Updated code syntax for python 3.12
- update mkvtoolnix
