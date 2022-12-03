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
