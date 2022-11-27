param (
        [Parameter(Mandatory)][ValidateRange(0,51)][Int]$crf, 
        [string]$preset='medium',
        # [string]$tune='animation',
        # # [string]$output_folder='',
        # [Parameter(Mandatory)][ValidateSet("copy","all_to_aac","ac3_to_aac","non_aac_only")][string]$audio,
        # [string]$aac_='animation',
        # [Parameter(Mandatory)][ValidateSet("ignore","internal_first","external_first")][string]$subpriority,
        [string[]]$files
        
    )

# echo $crf
# echo $preset 
# foreach ($input_video in $files){
#     echo "$input_video .dd"
#     }



$ErrorActionPreference = 'SilentlyContinue'
$script_path = split-path -parent $MyInvocation.MyCommand.Definition
Write-Output "Path of the script : $script_path"

[version]$my_version_counter = "1.0"

function check_for_update(){
    # get json from API in variable
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $animefn_json = Invoke-WebRequest 'https://animefn.com/abst.json' | ConvertFrom-Json
    [version]$latest_version = $animefn_json."latest_version" #get latest version number from some json web format
    $update_url = $animefn_json."release_url"

    
    if ($latest_version -gt $my_version_counter) {
    Write-Output "You need to get newer version from $update_url"
    # get json.update msg
    # get json.update url
    } elseif ($New_ver -eq $Old_ver) {
        Write-Output "You have latest version"
    } 
    
}

check_for_update 




# Function Get-FileName($initialDirectory) {
#     [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
#     $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
#     $OpenFileDialog.initialDirectory = $initialDirectory
#     $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
#     $OpenFileDialog.ShowDialog() | Out-Null
# }
# $fileName = Get-FileName c:\csvs


# cli parameters  https://stackoverflow.com/questions/2157554/how-to-handle-command-line-arguments-in-powershell
# use this https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.3

# write every action as a separate function


# https://powershell.org/2019/02/tips-for-writing-cross-platform-powershell-code/ 


# $input_video = "video.mkv"  #absolute path to video
$input_video ="G:\anime + fansubs\Anime[save]\[Yagame-sub] Shinsekai Yori - 13 [BD 720p Hi10].mkv"
$base_input_video = ([io.fileinfo]$input_video).basename
# $input_videos = @("G:\anime + fansubs\Anime[save]\[Yagame-sub] Shinsekai Yori - 13 [BD 720p Hi10].mkv")

# foreach ($input_video in $input_videos){
#     $base_input_video = ([io.fileinfo]$input_video).basename
#     #paste rest here
# }



#$input_video = "vid.mp4"
#$tmp_dir = "tmp"+somerandom  hash-name to avoid collision
# get temp dir depending on os https://github.com/PowerShell/PowerShell/issues/4216

#[IO.Path]::GetTempDirectory()
$tmp_dir = "my temp2"

$avs_script_path_name = "$tmp_dir/${base_input_video}_script.txt"
echo $avs_script_name

#create temp directory
mkdir $tmp_dir

## get file info (nb of fonts/attachements)
$info_array = & $script_path/mkvmerge.exe  --identification-format json --identify $input_video | ConvertFrom-Json         
$ff_info_array = & $script_path/ffprobe.exe  -v quiet  -print_format json -show_format -show_streams $input_video | ConvertFrom-Json
$nb_fonts= $info_array.attachments.count
echo "$base_input_video has: $nb_fonts fonts"


function mkvextract_codecs_to_ext($codec_id){
    # not an exhaustive list, just the audio and sub ones we may need
    # based on https://gist.github.com/pjobson/2603ea6c6697a761b3618f6ebcc8f063
    $assoc = @{}
    $assoc["A_AC3"]     = "ac3"
    $assoc["A_EAC3"]    ="eac3"
    $assoc["A_MPEG/L2"] = "mp2"
    $assoc["A_MPEG/L3"] = "mp3"
    $assoc["A_DTS"]     = "dts"
    $assoc["A_PCM/INT/LIT"] = "wav"
    $assoc["A_PCM/INT/BIG"] = "wav"
    $assoc["A_FLAC"]    = "flac"
    $assoc["A_ALAC"]    = "caf"
    $assoc["A_VORBIS"]  = "oga"
    $assoc["A_OPUS"]    = "opus"
    $assoc["A_AAC"]     = "aac"
    $assoc["A_REAL/"]   = "ra"
    $assoc["A_MLP"]     = "mlp"
    $assoc["A_TRUEHD"]  = "thd"
    $assoc["A_TTA1"]    = "tta"
    $assoc["A_WAVPACK4"]= "wv"
    

    $assoc["S_TEXT/UTF8"]   = "srt"
    $assoc["S_TEXT/ASCII"]  = "srt"
    $assoc["S_TEXT/SSA"]    = "ssa"
    $assoc["S_TEXT/ASS"]    = "ass"  
    $assoc["S_SSA"]         = "ssa"
    $assoc["S_ASS"]         = "ass"
    $assoc["S_VOBSUB"]      = "sub"
    $assoc["S_TEXT/USF"]    = "usf"
    $assoc["S_KATE"]        = "ogx"
    $assoc["S_HDMV/PGS"]    = "sup"
    $assoc["S_HDMV/TEXTST"] = "textst"
    $assoc["S_TEXT/WEBVTT"] = "vtt"
    return $assoc.$codec_id
    # return ($codec_id -eq "S_TEXT/ASS")

}
function extract_default_sub_n_audio2(){
    $internal_sub_found = $false
    $internal_audio_found = $false
    $audio_codec =""
    foreach ($entry in $info_array.tracks){
        echo $entry.type
        $codec_type= $entry.type
        $var1 =$entry.codec 
        $idx =$entry.id
        $is_default=$entry.properties.default_track  
        $codec = $entry.properties.codec_id
        $ext_from_codec= mkvextract_codecs_to_ext  $codec
        echo "   >>   $idx $var1   def: $is_default  extension:$ext_from_codec"
        if  (($codec_type -eq "audio")  -and $is_default){
            $internal_audio_found = $true
            echo "found default audio"
        }
        if  (($codec_type -eq "subtitles")  -and $is_default){
            $internal_sub_found = $true
            echo "found default sub"
        }
        # then rewrite the below function

    }
}


function extract_default_sub_n_audio(){
    #actually we can rewrite this function with info_array from mkvmerge, that way we don't need ffprobe it is too heavy
    # $retArray = @()
    
    # $sub_type=""
    $internal_sub_found = $false
    $internal_audio_found = $false
    $audio_codec =""
    foreach ($entry in $ff_info_array.streams){
            # echo $entry.codec_type
            # default audio
            if ($entry.codec_type -eq "audio") {
                $audio_codec=$entry.codec_name
                
                if($entry.disposition.default){
                    write-host  "found default audio"
                    $internal_audio_found = $true
                    $idx = $entry.index
                    write-host $idx
                    
                    ffmpeg -i "$input_video" -map 0:"$idx" -acodec copy "$base_input_video.$audio_codec"
                    # & $script_path/mkvextract.exe tracks  "$input_video"  "$idx":"$base_input_video.$audio_codec"
                    # $retArray +=$audio_codec
                    # write-host  $audio_codec

                }
            }

            # default sub + get sub extension while we are at it
            if ($entry.codec_type -eq "subtitle") {
                $sub_type=$entry.codec_name
                
                if($entry.disposition.default){
                    write-host  "found default sub "
                    $internal_sub_found = $true
                    $idx = $entry.index
                    $concat= $idx.""
                    & $script_path/mkvextract.exe -q tracks  "$input_video"  "$idx"":$base_input_video.$sub_type"
                    # $retArray +=$sub_type
                    # write-host  $sub_type
                }
                
            }
            # echo $ff_info_array.streams[4]
            if ($internal_sub_found -and $internal_audio_found){
                break
            }
        }
    


    # write-host "bye"
    return $internal_sub_found,$internal_audio_found, $audio_codec #,$sub_type

}

# $has_internalsub,$has_internalaudio, $audio_codec = extract_default_sub_n_audio 

# echo $audio_codec
# echo $has_internalaudio

#Now depending on audio parameter decide what to do based on audio codec
# Depending on sub priority what to do with has internal sub




## extract fonts (on windows call load after)  || move them in ~/.fonts/some_temp_folder on linux and don't call load on linux
function extract_fonts($destination, $nb ){
    $original_path = pwd
    cd $tmp_dir
    # add   -q  to hide output later
    & $script_path/mkvextract.exe  attachments $input_video (1..$nb)
    cd $original_path
}
function loadfonts_fromdir($dir){
    foreach($font in Get-ChildItem -Path $dir -Recurse -Include *.ttf, *.otf, *.TTF, *.OTF) {
    # [Session]::AddFontResource($font.FullName)
    # error reporting if one font fails, warn about it
    echo ($font.FullName)
    #& $script_path/load_fonts.exe $font.FullName
    }

}

function unloadfonts_fromdir($dir){
    #copy the one above without last line
    #& $script_path/unload_fonts.exe $font.FullName
}

# extract_fonts $tmp_dir $nb_fonts
# loadfonts_fromdir $tmp_dir

#cd ..

exit

# dammit, can just dump attachement with 1 line, extract fonts to temp directory
# ffmpeg -dump_attachment:t:0 $tmp_dir/* -i $input_video # actually this does not work

#Check if input file has internal track
#.\ffmpeg -i "$input_video" -c copy -map 0:s:0 -frames:s 1 -f null - -v 0 -hide_banner;  echo $?   | Tee-Object -Variable has_internalsub | Out-Null

echo ($has_internalsub)
#extract sub file some_file_name.ass hardcoded, what if file is srt/vtt? maybe we will be ok if textsub care not about .extention
#ffmpeg -i $input_video -map 0:s:0 $base_input_video".ass"


#Check if input file does NOT have internal track, look for external
echo "lol"




#write avs script
Set-Content -Path "$avs_script_path_name" -Value '# autogenerated avs script by ABST tool' 
Add-Content -Path "$avs_script_path_name" -Value "LoadPlugin(`"ffm2`")"   #replace with ffms2 variable
Add-Content -Path "$avs_script_path_name" -Value "LoadPlugin(`"vsfilter`")"  #replace with vsfilter variable
Add-Content -Path "$avs_script_path_name" -Value "ffms2(`"$input_video`",atrack=-1, fpsnum=24000, fpsden=1001)  # convert to CFR"
Add-Content -Path "$avs_script_path_name" -Value "convertbit(8, dither=0)"
Add-Content -Path "$avs_script_path_name" -Value "#ConvertToYV12()"
Add-Content -Path "$avs_script_path_name" -Value "# textsub(subfile)" #replace with subtitles variable

# @todo still need to handle audio...

# Last and not least, encode the episode!!!!!! Yayyy
# FFMPEG encode command goes here 


#unload fonts and clear temp directory
# unload fonts

unloadfonts_fromdir $tmp_dir

cd ..  # exit temp_dir if there then delete it
#rmdir -Force -r $tmp_dir