# troll official motivation

sometimes you might have a lot of content you extracted from BD/DVd with makemkv or some shit and just want to binge watch them on the go on every device so this tools make it easier, it is portable, and can be used even without admin priveleges.

# Motivation
We dot not encourage hardsubs, may hardsubbers burn in hell, it is a crime, but that did not stop people from doing it anyway. 
So at least if you are gonna do it, do it with the least harmful way.
Lots of nobiish mistakes, people not including fonts, picking wrong profiles in handbrake, getting lost in this trash piece called
staxrix.

we do not have option to speicify fixed size,
why because it degrades the quality a lot. USE CRF dammit. we told you we are encouraging less shit.
<AmjadSONY> طيب على الاقل ضع خيار للتحويل
22:03 <mohamedh> لا يا عم، اللي ينتج هاردسب احمر من كدة
22:03 <mohamedh> مش عايزين نعطي خيارات كثير فيتوه
22:03 <mohamedh> دا برنامج fool proof
22:03 <mohamedh> مش برنامج يرتقي بالفانسب
<mohamedh> عن طريق اولًا
22:04 <mohamedh> محدش يعمل دروس ثاني هاردسب 
22:04 <mohamedh> لان خلاص الطريقة واحدة وسهلة وصريحة
22:04 <mohamedh> ثانيًا، محدش بينسى خطوط
22:04 <mohamedh> لاني بستخرج الخطوط بffmpeg
22:04 <AmjadSONY> شوف انا متفقمع بكل شيء

<AmjadSONY> عموما في avspmod تقدر تجبره يستخدم dll مستقل
22:15 <AmjadSONY> تضع الdll الخاص بالافس بلس في مجلد tools

---
<mohamedh> قبل امر الترجمة؟
22:38 <AmjadSONY> ,atrack=-1, fpsnum=24000, fpsden=1001
22:38 <AmjadSONY> في امر ffms2
22:38 <AmjadSONY> حتى يخرج لك صوت ايضا
22:42 <mohamedh> ماشي
22:42 <mohamedh> عمومًا لو في اكثر من تراك صوت
22:42 <mohamedh> يختار الأول؟
22:42 <AmjadSONY> يختار الافتراضي مع -1
---

V1 no option to customize AVS commands

Nor ffmpeg command

Why?
Because we want it fool proof, you can't do mistakes even if u wanted, ba7mik men shar. Nafsak
With. Custom AVS u can add logo. Something we want to encourage against, Hoping that shitters will sacrifice the logo in favor of convenience and using our tool.

Why no custom x264 commands? Bcz fuck people, hardusbbers are staxrip users these ashholes use interlaced=true with progressive sources. We don't want u to copy shit u no understand and put them then complain.

Think u know what you're doing? Then if u really do, u should not do harsubs. Or u should know how to batch it on ur own, u don't need us...


Call. Call it abhr
Afn batch hardusbbeing réencoder ? not cool

## name 
abst -> af batch sub tool
absl-> af batch sub for linux (cuz it takes courage to ditch windows)

# useful (batch) tools to use with this
- InviskaMKVExtract
- batch file renamer
- crc32

# mechanism
//assume internal then external chosen
Foreach $file:
If (file_has_internal):
    $sub_file = extract first internal subtitles file
    else 
    $sub_file = Look for name match .srt/.ass.vtt, etc (with some priority)
    extract internal attachement for fonts
    install fonts (in portable manner)

    write .avs script as:
        ```
        videosource($file)
        subsource($sub_file) #find way to handle font
        resize_command(...)
        ```
    do x264 command with picked crf, preset and .avs file 



# shit we want to eradicate
- https://www.msoms-anime.net/showthread.php?t=191297
- https://www.msoms-anime.net/showthread.php?t=191296
- https://www.youtube.com/watch?v=fS-EoGYzP6k&ab_channel=ZakAlqadi
- https://github.com/Abu3safeer/mpv-bulk-encode-ass
---> mpv libass + not batch and manual fonts extraction
- staxrip, handbrake, writing manual scripts, usage of mpv/ffmpeg w/out the correct fonts or with libass making the subtitles appear wrongly




# x264 use external avs
x264 --crf 22 --synth-lib D:\AviSynth.dll --output aaa.h264 aaa.avs
https://forum.doom9.org/showthread.php?p=1937622#post1937622


# ffmpeg Check if a video file has internal subtitles
ffmpeg -i video -c copy -map 0:s:0 -frames:s 1 -f null - -v 0 -hide_banner; echo $?
https://stackoverflow.com/questions/43005432/check-if-a-video-file-has-subtitles




# script

    ```
        # call vsfilter and ffms2 dll files

        ffms2(videfile.ext,atrack=-1, fpsnum=24000, fpsden=1001)  # convert to CFR
        convertbits(8, dither=0)
        ConvertToYV12()
        textsub(subfile)
        # resize is to be decided, in script? in ffmpeg?
    ```
# syntax and Usage
- Example
`abst.exe -crf 22  -preset -subpriority`
` .\abst.exe -crf 24 -subpriority "internal_first" -f input_video1.mkv input_video2.mkv -output_destination "out2"` will out output to out2 folder
` .\abst.exe -crf 24 -subpriority "internal_first" -f $input_video1` each output will be in its corresponding input's directory
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

- some dimensions parameter TO BE ADDED LATER
    - null => same i.e copy
    - width(int) height(int)


# v1 investigate
- P.s for temp files let us keep them in some hidden folder, c temp 
- qaac audio
- packaging entire program + dependendcies etc as 1single .exe
>>> goal: distribute 2 files only: cli_only, gui
# v2 suggestions
- auto-update 
    - check API if new version of some compenents, get them from url in json response
- adding custom commands for avs or ffmpeg
- fixed filesize
- logo?
- more audio options?
- add parameter Crc32
    - true : contactenate [crc32] value at the end
    - false

## Faq


### What happens if multiple audio or multiple subs?
Default one is picked. (first one is picked). you are going to have re-arrange your mkv attachements.

### Any plans to support other OS? Linux?
Maybe, UI is compatible, and so it avisynth, but the main problem is vsfilter. 
Coul be used with avs2yuv, etc, but damn...

### Why no customization?
copy from above- for fool proofing

### plans to add features?
depending on demands and necessary developement time, maybe yes, maybe no, no promises.
Please do note that feedback is necessary, we don't add features for the sake of completeness unless there is demand. So if you need a feature don't expect to be added just like that, please do ask, so we can gather information on requested features.

### Why do I need this?
- batch processing, faster (no time wasted on manual extraction, etc), even for single files and correct, fonts are preserved. 
- No need to extract anything
- Portable no need to install anything.
- No need to write avisynth scripts
- F*ck staxrip (and people who use it)
### Can I use it for any input?
- Alpha version was distrubited internally and tested with various (600+) mkv coming from ar fansub community and so far we have tried to improve the script to tackle all issue encountered, including 10 bits and yuv444p10, etc
### OS supported?
currently windows, x86. It could easily be turned to 64 bit version for better efficiency if you are on 64 bit OS.

### why not other tools, Konoyaki, fansub encoder
- does fansub encoder actually support yuv444p10?
fansub encoder, arabic only, not updated since a while, closed source, no batch processing, you need to manually extract subtitles, does not handle fonts.
- kon whatever, not portable, requires heavy installation cost, definetely more complete than our tool, I even daresay better in some use-cases BUT not fool proof and not as simple as our tool. We aim for simplicity and portability (even accross OSes hopefully in a future version), they aim for completeness.

### PR videos
- show time required to install kounyaki vs time required to install our tool

### Usage examples
- MKV to MP4 (hardsubs)
- Raws+Srt to mp4(muxed hardsubs)

### for better batching and efficiency combine it bulk rename utility, etc



# issues to take into account
: in filename and ,


# qualtiy parameters in x264, crf only?


# Fonts:
## linux fonts (local, not portable)
The ~/.fonts directory can be used for installing fonts locally. Create it if it does not exist.
>> but can erase once done
## windows fonts
https://stackoverflow.com/questions/12946384/windows-install-fonts-from-cmd-bat-file/67903796#67903796
> probably the most awesome solution
    https://superuser.com/questions/1185779/is-it-possible-to-install-fonts-in-windows-without-admin-rights
    https://stackoverflow.com/questions/12946384/windows-install-fonts-from-cmd-bat-file/67903796#67903796

https://gist.github.com/anthonyeden/0088b07de8951403a643a8485af2709b
---
install font temporarily in windows but through avisynth http://forum.doom9.org/showthread.php?t=175515
---
et another alternative is to install fonts "temporary", just for current user session. The idea is to run fontview.exe for each font, which makes it available for other Windows applications:see http://www.msfn.org/board/topic/28300-installing-fonts-temporarly/page__view__findpost__p__194037

source: https://superuser.com/questions/201896/how-do-i-install-a-font-from-the-windows-command-prompt

with FontLoaderEx: https://github.com/0xb160c0c5/FontLoaderEx/issues/1

> https://404.website/thread-3848-12-1.html

> https://www.no-nonsens.nl/temporary-font-manager/

> https://docs.microsoft.com/en-us/windows/win32/gdi/font-installation-and-deletion

> https://answers.microsoft.com/en-us/windows/forum/all/temporarily-load-fonts-in-windows-10/2aca7370-18f4-487c-b9c6-2a7e5a9e2edb

> https://www.youtube.com/watch?v=E3ryAF5O4SY

> https://sites.google.com/site/mocchau/install-fonts-temporarily

> http://www.ghacks.net/2011/10/09/font-load-unload-load-fonts-without-installing-them/

> https://www.ghacks.net/2007/08/16/clear-all-non-system-fonts-automatically/

# ###################
fmi
https://www.universalmediaserver.com/forum/viewtopic.php?t=3035

https://superuser.com/questions/304804/hardsubbing-mkv-files-that-use-ass-subtitles-and-embedded-fonts

http://forum.doom9.org/archive/index.php/t-140216.html

https://forum.videohelp.com/threads/348535-MKV-to-MP4-with-subtitles

https://forum.videohelp.com/threads/350111-Ripping-font-files-from-MKV-s-%28ASS%29

https://forum.videohelp.com/threads/328254-installing-fonts-in-MKV-on-demand

https://www.google.com/search?q=temporarily+install+fonts+powershell&client=ubuntu&hs=RfY&ei=MchvYr_sA-WTlwSMtJb4Dg&ved=0ahUKEwj_yLrD4sD3AhXlyYUKHQyaBe8Q4dUDCA4&uact=5&oq=temporarily+install+fonts+powershell&gs_lcp=Cgxnd3Mtd2l6LXNlcnAQAzIFCCEQoAEyBQghEKABMgUIIRCgATIICCEQFhAdEB46CwgAEIAEELEDEIMBOhEILhCABBCxAxCDARDHARCjAjoECAAQQzoICC4QsQMQgwE6DgguEIAEELEDEMcBEKMCOgoIABCxAxCDARBDOggIABCABBCxAzoFCAAQgAQ6CwguEIAEEMcBEK8BOg4ILhCABBCxAxCDARDUAjoFCC4QgAQ6BggAEBYQHjoECAAQEzoICAAQFhAeEBM6CggAEBYQChAeEBM6BwghEAoQoAE6BAghEBU6BAghEAo6CAgAEAgQDRAeSgQIQRgBSgQIRhgASgQIRxgDSgQIRxgDSgQIRxgDSgQIRxgDSgQIRxgDSgQIRxgDUOZVWNaoAWClqgFoAXAAeACAAVGIAY8QkgECMzaYAQCgAQHAAQE&sclient=gws-wiz-serp
----


Gui + exe
https://www.powershellgallery.com/packages/ps2exe/1.0.11




# absL # Linux

idea is to run avs2yuv through this portable wine, and output that to the encoder
Don't forget to handle failure and stop if a command fails

other links linux

https://www.google.com/search?q=x264+specify+avisynth+on+linux&client=ubuntu&hs=NwE&ei=TNZvYtOdMJaCur4PkNyx-A4&ved=0ahUKEwjT89T978D3AhUWgc4BHRBuDO8Q4dUDCA4&uact=5&oq=x264+specify+avisynth+on+linux&gs_lcp=Cgdnd3Mtd2l6EAMyBQghEKABOgQIIRAVOgcIIRAKEKABSgQIQRgBSgQIRhgAUJALWKwUYJQVaAFwAHgAgAFjiAH0BJIBATmYAQCgAQHAAQE&sclient=gws-wiz

http://forum.doom9.org/archive/index.php/t-165235.html


http://forum.doom9.org/archive/index.php/t-164386.html

http://avisynth.nl/index.php/Avs2YUV

http://avisynth.nl/index.php/Avs4x264mod

https://forum.doom9.org/showthread.php?t=150133

https://jellyflower.github.io/blog/2013/03/09/how-to-use-64-bit-x264-with-32-bit-avisynth/




Maybe hire someone for UI?
https://khamsat.com/programming/java-dot-net/1479325-%D8%A8%D8%B1%D9%85%D8%AC%D8%A9-%D8%AA%D8%B7%D8%A8%D9%8A%D9%82-%D9%84-windows-%D8%A8%D8%A7%D8%AD%D8%AA%D8%B1%D8%A7%D9%81%D9%8A%D8%A9-%D8%AA%D9%88%D8%AC%D8%AF-%D8%A8%D8%B9%D8%B6-%D8%A3%D8%B9%D9%85%D8%A7%D9%84%D9%8A-%D9%81%D9%8A-%D8%A7%D9%84%D9%88%D8%B5%D9%81