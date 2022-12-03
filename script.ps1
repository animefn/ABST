param (
        [Parameter(Mandatory)][ValidateRange(0,51)][Int]$crf, 
        [string]$preset='ultrafast',
        [string]$tune='animation',
        #profile and level?
        [ValidateSet("copy","all_to_aac","ac3_to_aac","non_aac_only","disable")][string]$audio="non_aac_only",
        [int]$qaac_quality,
        [Parameter(Mandatory)][ValidateSet("ignore","internal_first","external_first")][string]$subpriority,
        [string]$output_destination,
        [string]$prefix="",
        [string]$suffix="",
        [Parameter(Mandatory)][string[]]$files
        
    )
    


# echo $crf
# echo $preset 
# foreach ($input_video in $files){
#     echo "$input_video .dd"
#     }



$ErrorActionPreference = 'SilentlyContinue'


$mkve_params = "-q" #add -q when dev done
$ffmpeg_param = "-v" , "quiet" ,"-stats";  #add -v quiet -stats  when no longer debugging


$tmp_location = (pwd).Path  #[io.path]::GetTempPath() 
$OS_delim = [IO.Path]::DirectorySeparatorChar


$script_path = split-path -parent $MyInvocation.MyCommand.Definition
$tools_path = (split-path -parent $MyInvocation.MyCommand.Definition) + $OS_delim+"tools"

[version]$my_version_counter = "0.9"

function check_for_update(){
    # get json from ANIMEFN in variable
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
#     $OpenFileDialog.filter = "mkv (*.mkv)| *.mkv"
#     $OpenFileDialog.ShowDialog() | Out-Null
# }
# $fileName = Get-FileName c:\csvs


# https://powershell.org/2019/02/tips-for-writing-cross-platform-powershell-code/ 





############## functions
# Function to convert the codes in mkvextract json to file extension
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
}



# takes full path of file and find a local subtitle next to that file in the same folder
function process_ext_sub($fullpath){
    #strip extension, replace and look for ass, srt, vtt, etc
    $item = (get-item -LiteralPath $fullpath)
    $s_path =  $item.DirectoryName 
    $s_base =  $item.BaseName
    $sub_extensions = @("ass","srt","ssa","sub","vtt","sup","usf","ogx","textst")
    foreach ($ext in $sub_extensions){
        $fullpath_sub= "$s_path" + "$OS_delim" + "$s_base"+".$ext"
        
        $exists = Test-Path -LiteralPath $fullpath_sub
        if ($exists) {
            return $fullpath_sub
        }
    }
    
    
    return "NO_EXT"

}

# extract default audio and sub, or depending on parameters, may get external sub first  if found/needed
function extract_default_sub_n_audio($file_tracksInfo, $dest, $input_video,$base_input_video, [ref]$full_aud_path, [ref]$full_sub_path){
    $internal_sub_found = $false
    $internal_audio_found = $false
    
    # $full_aud_path =""
    # $full_sub_path=$false
    if ($subpriority -eq "external_first"){
        $full_sub_path.value = process_ext_sub $input_video
    }
    #$look_for_internal_sub $ ! (-not ($subpriority -eq "ignore")) -and 
    foreach ($entry in $file_tracksInfo){
        #write-output $entry.type
        $codec_type= $entry.type
        $var1 =$entry.codec 
        $idx =$entry.id
        $is_default=$entry.properties.default_track  
        $codec = $entry.properties.codec_id
        $ext_from_codec= mkvextract_codecs_to_ext  $codec
        #write-output "   >>   $idx $var1   def: $is_default  extension:$ext_from_codec"
        # if audio param is copy we don't care about this
        if  (($codec_type -eq "audio")  -and $is_default){
            $internal_audio_found = $true
            $aud_codec = $ext_from_codec
            write-output "found default audio $idx"
            if (( $audio -eq "copy") -or  (($audio -eq "non_aac_only") -and ($aud_codec -eq "aac") )  ){
                # do not extract just copy
                $full_aud_path.value = $input_video
            }elseif (( $audio -eq "ac3_to_aac") -and !($aud_codec -eq "ac3") ) {
                #we are asked to encode ac3 only, audio is not ac3 so copy
                $full_aud_path.value = $input_video
            }else{
                # transcode while you extract here
                write-output "Encoding audio..."
                $aud_path = "$dest/$base_input_video.$ext_from_codec"
                $aud_path = "$dest/$base_input_video.m4a"
                # WARNING: using this without checking for failure!
                
                & $tools_path/ffmpeg.exe $ffmpeg_param -i "$input_video" -map 0:"$idx" -acodec aac $aud_path
                # & $tools_path/mkvextract.exe tracks  "$input_video"  "$idx":"$base_input_video.$aud_codec"
                $full_aud_path.value =$aud_path
                
            }
            
        }
        # if sub param is ignore we don't care about extracting sub
        if  ( ($subpriority -eq "internal_first")  -or (  ($subpriority -eq "external_first") -and  ($full_sub_path.value -eq "NO_EXT"))  ) { 
            
            if  (($codec_type -eq "subtitles")  -and $is_default){
                # $full_sub_path  = ... process here and get null or a path
                $internal_sub_found = $true
                #write-output "found default sub"
                
                $sub_dest = "$dest"+ $OS_delim +"$base_input_video.$ext_from_codec"
                # WARNING not ideal because we do not check for failure on extraction and we assign directly the path...
                
                #extract sub file some_file_name.ass hardcoded, what if file is srt/vtt? maybe we will be ok if textsub care not about .extention
                #ffmpeg -i $input_video -map 0:s:0 $base_input_video".ass"

                & $tools_path/mkvextract.exe $mkve_params tracks  "$input_video"  "$idx"":$sub_dest"
                $full_sub_path.value = $sub_dest
            }
        }
       
        

    }
    # here handle internal first but no internal found
    if  ( ($subpriority -eq "internal_first") -and (-not  ($internal_sub_found)) ){
        $full_sub_path.value = process_ext_sub $input_video
    }
    
    
    
}



## extract fonts (on windows call load after)  || move them in ~/.fonts/some_temp_folder on linux and don't call load on linux
function extract_fonts($in, $destination, $nb ){
    $original_path = pwd
    cd -LiteralPath $destination
    
    # add   -q  to hide output later
    
    & $tools_path/mkvextract.exe $mkve_params attachments $in (1..$nb)
    cd -LiteralPath $original_path
}
function loadfonts_fromdir($dir){
    foreach($font in Get-ChildItem -LiteralPath $dir -Recurse -Include *.ttf, *.otf, *.TTF, *.OTF) {
    # [Session]::AddFontResource($font.FullName)
    # error reporting if one font fails, warn about it
        echo "loading" ($font.FullName)
        & $script_path/load_fonts.exe $font.FullName
    }

}

function unloadfonts_fromdir($dir){
    #copy the one above without last line
    foreach($font in Get-ChildItem -LiteralPath $dir -Recurse -Include *.ttf, *.otf, *.TTF, *.OTF) {
        & $script_path/unload_fonts.exe $font.FullName
    }
}



############### Main program
$count_files = 0
foreach ($input_file in $files){
    $input_video = Convert-Path  -LiteralPath  $input_file #get abs path of file
    $count_files += 1
    $base_input_video = ([io.fileinfo]$input_video).basename
    
    
    
    #$tmp_dir = "tmp_location"+"abst"somerandom  hash-name to avoid collision
    $tmp_dir = "$tmp_location"+ $OS_delim +"$base_input_video"
    
    

    $avs_script_path = "$tmp_dir"+$OS_delim+"${base_input_video}_script.avs"
    

    #create temp directory - works
    $tp = mkdir $tmp_dir

    ## get file info (nb of fonts/attachements)
    $info_array = & $tools_path/mkvmerge.exe  --identification-format json --identify $input_video | ConvertFrom-Json
    #$ff_info_array = & $tools_path/ffprobe.exe  -v quiet  -print_format json -show_format -show_streams $input_video | ConvertFrom-Json
    $nb_fonts= $info_array.attachments.count
    echo "$base_input_video has: $nb_fonts fonts"
    

    
    $final_subpath=$false
    $final_audiopath = $false
    extract_default_sub_n_audio  $info_array.tracks $tmp_dir $input_video $base_input_video ([ref]$final_audiopath) ([ref]$final_subpath)
    write-output "done with extraction of Audio and sub"
    
    #write-output $final_subpath
    #write-output $final_audiopath
    #write-output $final_subpath
    
    
    echo "extracting fonts..."
    extract_fonts $input_video $tmp_dir $nb_fonts
    echo "loading fonts..."
    loadfonts_fromdir $tmp_dir


    #write avs script
    # Important our ffms2 command has audio... what if... vfr and stuff like that :thinking:
    $filters_dir = $script_path+$OS_delim
    Set-Content -LiteralPath "$avs_script_path" -Value '# autogenerated avs script by ABST tool' 
    Add-Content -LiteralPath "$avs_script_path" -Value "LoadPlugin(`"${filters_dir}ffms2.dll`")"   #replace with ffms2 variable
    Add-Content -LiteralPath "$avs_script_path" -Value "LoadPlugin(`"${filters_dir}vsfilter.dll`")"  #replace with vsfilter variable
    Add-Content -LiteralPath "$avs_script_path" -Value "ffms2(`"$input_video`",atrack=-1, fpsnum=24000, fpsden=1001)  # convert to CFR"
    Add-Content -LiteralPath "$avs_script_path" -Value "convertbits(8, dither=0)"
    Add-Content -LiteralPath "$avs_script_path" -Value "#ConvertToYV12()"
    if (-not($final_subpath -eq $false)) {
        Add-Content -LiteralPath "$avs_script_path" -Value "textsub(`"$final_subpath`" )" #replace with subtitles variable
    }
    # Add-Content -LiteralPath "$avs_script_path" -Value "version()"

    
    # Last and not least, encode the episode!!!!!! Yayyy
    # FFMPEG encode command goes here $ffmpeg_param

    
    # CREATE DESTINATION FILE name
    
    # if not destination provided we use the same as input
    if ($output_destination.length -eq 0){
        #then make the out dest the same as source

        $output_destination =(get-item -LiteralPath $input_video).DirectoryName
        
    }
    # if the user provider (via CLI) a non-existing destination create it
    if ((Test-Path -PathType Container  -LiteralPath $output_destination) -eq $false ){
        
        mkdir $output_destination
    }

    # [string]$preset='ultrafast',
    #     [string]$tune='animation',
    if ($audio -eq "disable"){ $final_audiopath = $false }
    $outfile = $output_destination + $OS_delim + $prefix+ $base_input_video +"_out_"+ $suffix+".mkv"
    
    if ($final_audiopath -ne $false){
        #-profile:v high -level 4  removed after preset
        & $tools_path/ffmpeg.exe -i "$avs_script_path" -i $final_audiopath -map 0:0  -map 1:a:0  -c:v libx264 -pix_fmt yuv420p -crf $crf -preset $preset -c:a copy  $outfile
    }else{
        & $tools_path/ffmpeg.exe -i "$avs_script_path" -c:v libx264 -pix_fmt yuv420p -crf $crf -preset $preset -an $outfile
    } 
    ## 
    # else if final audio path is empty
    # do command without audio here
    #unload fonts and clear temp directory
    # unload fonts
    echo "removing fonts"
    unloadfonts_fromdir $tmp_dir

    #cd ..  # exit temp_dir (if there) then delete it
    rmdir -Force -r -LiteralPath $tmp_dir

}

echo "all tasks finished"
echo "processed $count_files tasks"










