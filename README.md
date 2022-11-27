# troll official motivation

sometimes you might have a lot of content you extracted from BD/DVd with makemkv or some shit and just want to binge watch them on the go on every device so this tools make it easier, it is portable, and can be used even without admin priveleges.

# Motivation
We dot not encourage hardsubs, may hardsubbers burn in hell, it is a crime, but that did not stop people from doing it anyway. 
So at least if you are gonna do it, do it with the least harmful way.
Lots of nobiish mistakes, people not including fonts, picking wrong profiles in handbrake, getting lost in this trash piece called
staxrix.

we do not have option to speicify fixed size,
why because it degrades the quality a lot. USE CRF dammit. we told we are encouraging less shit.
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

P.s for temp files let us keep them in some hidden folder, c temp 

# shit we want to eradicate
- https://www.msoms-anime.net/showthread.php?t=191297
- https://www.msoms-anime.net/showthread.php?t=191296
- staxrip, handbrake, writing manual scripts, usage of mpv/ffmpeg w/out the correct fonts or with libass making the subtitles appear wrongly

# to do

- get avs dll from https://github.com/AviSynth/AviSynthPlus/releases
- get ffmpeg 
- get xy-vs subfilter
- extract fonts
- make sure they're embedded correctly
---·> or does directshowsource handle it if font are embedded?
if so maybe we mux to mkv if external, then run the usual routine


 options are: ommit subs, no subtitles
22:44 <mohamedh> - internal, external, none
22:44 <mohamedh> - external, internal, none

# x264 use external avs
x264 --crf 22 --synth-lib D:\AviSynth.dll --output aaa.h264 aaa.avs
https://forum.doom9.org/showthread.php?p=1937622#post1937622


# ffmpeg Check if a video file has internal subtitles
ffmpeg -i video -c copy -map 0:s:0 -frames:s 1 -f null - -v 0 -hide_banner; echo $?
https://stackoverflow.com/questions/43005432/check-if-a-video-file-has-subtitles

# AVs dependencies
- xysub filder
- directshow source, 
---" should be added manually to script path

# see how we handle audio
# script

```
# call vsfilter and ffms2 dll files

ffms2(videfile.ext,atrack=-1, fpsnum=24000, fpsden=1001)  # convert to CFR
convertbit(8, dither=0)
ConvertToYV12()
textsub(subfile)

# resize is to be decided, in script? in ffmpeg?
```
# syntax and Usage
- Example
`abst.exe -crf 22  -preset -subpriority`

- crf values (official ones): .. from  0 to 51
- preset values (official ones): ..
- subpriority : 
    - none 
    - internal (then external, then none)
    - external (then internal, then none)
- output 
    - "" empty => same as source
    - /path/to/folder a directory to save output
- prefix 
    - "string" add some prefix before name
- suffix
  - "string" add some suffix after name but before extension

- audio:
    - copy
    - all_to_aac
    - ac3_only
- dimensions
    - null => same i.e copy
    - width(int) height(int)
- list of filesnames:file name

# v1 investigate
- packaging entire program + dependendcies etc as 1single .exe
> distro 2 files: cli_only, gui
# v2 suggestions
- auto-update 
    - check API if new version of some compenents, get if from url in json response
- adding custom commands
- fixed filesize
- logo?
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
depending on demands and necessary developement time, maybe yes, maybe no, no primises.

### Why do I need this?
- batch processing, faster, even for single files and correct, fonts are preserved. 
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