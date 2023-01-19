[CmdletBinding(DefaultParameterSetName="Default")]
Param( 
    
    [Parameter(ParameterSetName="Default", mandatory=$true)][ValidateRange(0,51)][float]$crf, 
    [parameter(ParameterSetName="Default", mandatory=$false)][string]$preset='ultrafast',
    [parameter(ParameterSetName="Default", mandatory=$false)][string]$tune='animation',
    #[parameter(ParameterSetName="Default", mandatory=$false)]#profile and level?
    [parameter(ParameterSetName="Default", mandatory=$false)][ValidateSet("copy","all_to_aac","ac3_to_aac","non_aac_only","disable")][string]$audio="non_aac_only",
    [parameter(ParameterSetName="Default", mandatory=$false)][ValidateRange(0,127)][int]$qaac_quality=91,
    [parameter(ParameterSetName="Default", mandatory=$true)][ValidateSet("ignore","internal_first","external_first")][string]$subpriority,
    [parameter(ParameterSetName="Default", mandatory=$false)][ValidateSet(360,480,720,1080)][int]$auto_resize,
    [parameter(ParameterSetName="Default", mandatory=$false)][string]$output_destination,
    [parameter(ParameterSetName="Default", mandatory=$false)][string]$fonts_dir,
    [parameter(ParameterSetName="Default", mandatory=$false)][string]$prefix="",
    [parameter(ParameterSetName="Default", mandatory=$false)][string]$suffix="",
    [parameter(ParameterSetName="Default", mandatory=$false)][switch]$testdev,
    [parameter(ParameterSetName="Default", mandatory=$false)][switch]$debug_verbose,
    [Parameter(ParameterSetName="Default", mandatory=$true)][string]$files_str,

    [parameter(ParameterSetName="info", mandatory=$false)][switch]$version,
    [parameter(ParameterSetName="info", mandatory=$false)][switch]$check_update

)
    


$ErrorActionPreference = 'SilentlyContinue'

$mkve_params = "-q" #add -q when dev done
$ffmpeg_param = "-v" , "quiet" , "-y","-nostdin";  #add -v quiet -stats  when no longer debugging #edit: removed -stats


$OS_delim = [IO.Path]::DirectorySeparatorChar
$tmp_location = (pwd).Path  #[io.path]::GetTempPath() 
$tmp_location = $tmp_location + $OS_delim + "temp"


#$script_path = if (-not $PSScriptRoot) { Split-Path -Parent (Convert-Path -LiteralPath ([environment]::GetCommandLineArgs()[0])) } else { $PSScriptRoot }
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript"){ 
    $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition 
} else{ 
    $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) 
    if (!$ScriptPath){ $ScriptPath = "." } 
}

$script_path =[IO.PATH]::GetFullPath($ScriptPath)

$tools_path = $script_path + $OS_delim+"tools"



[version]$my_version_counter = "0.982"



function check_for_update(){
    # get json from ANIMEFN in variable
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $animefn_json = Invoke-WebRequest 'https://animefn.com/abst.json' | ConvertFrom-Json
    [version]$latest_version = $animefn_json."latest_version" #get latest version number from some json web format
    $update_url = $animefn_json."release_url"

    
    if ($latest_version -gt $my_version_counter) {
    # $update_url
    Write-Output "A newer version is available. You need to get the latest version from our github repo"
    # get json.update msg
    # get json.update url
    } elseif ($New_ver -eq $Old_ver) {
        Write-Output "You have the latest version of ABST"
    } 
    
}

function info_group(){
    $exit=$false
    if (($version.IsPresent)){
        echo ([string]$my_version_counter)
        $exit=$true
        
    }
    if (($check_update.IsPresent)){
        check_for_update
        $exit=$true
        
    }
    if ($exit -eq $true){
        exit
    }
    
}
info_group


check_for_update 

if  ($testdev.IsPresent){ write-output "running from $tools_path"}


# https://powershell.org/2019/02/tips-for-writing-cross-platform-powershell-code/ 





############## functions

# Function to convert the codes in json created by mkvextract to file extension
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
    $sub_extensions = @("ass","srt","ssa","sub","idx","vtt","sup","usf","ogx","textst")
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
    
    if ($subpriority -eq "external_first"){
        $full_sub_path.value = process_ext_sub $input_video
    }
    
    $audios =  (& $tools_path/mediainfo.exe --Output='Audio;%Duration% ' $input_video).split(" ")
    $audio_duration=$audios[0] # this is the audio duration in ms
    $nb_audios = $audios.count -1
    $is_unique_aud = (1 -eq $nb_audios)
    #do same for subs
    $nb_subs = ((& $tools_path/mediainfo.exe --Output='Text;%ID% ' $input_video).split(" ")).count -1
    $is_unique_sub = (1 -eq $nb_subs)
    if ($debug_verbose.IsPresent){ echo "  file has $nb_audios audios and $nb_subs internal subs "}
    foreach ($entry in $file_tracksInfo){
        #write-output $entry.type
        
        $codec_type= $entry.type
        $var1 =$entry.codec 
        $idx =$entry.id
        $is_default=$entry.properties.default_track  
        $codec = $entry.properties.codec_id
        $ext_from_codec= mkvextract_codecs_to_ext  $codec
        # write-output "   >>   $idx $var1   def: $is_default  extension:$ext_from_codec"
        # if audio param is copy we don't care about this
        # FIX HERE IF audio def or unique
        if  (($codec_type -eq "audio")  -and ( $is_default -or $is_unique_aud)){
            $internal_audio_found = $true
            $aud_codec = $ext_from_codec
            #write-output "found default audio $idx"
            if (( $audio -eq "copy") -or  (($audio -eq "non_aac_only") -and ($aud_codec -eq "aac") )  ){
                # do not extract just copy
                $print_mode = ""
                if  ($testdev.IsPresent){ $print_mode="echo non_aac_only & copy"}
                echo "  Audio does not need to be re-encoded $print_mode"
                
                $full_aud_path.value = $input_video
            }elseif (( $audio -eq "ac3_to_aac") -and !($aud_codec -eq "ac3") ) {
                #we are asked to encode ac3 only, audio is not ac3 so copy
                echo "  Audio is not AC-3, copying losslessly"
                $full_aud_path.value = $input_video
            }elseif ($audio -ne "disable"){
                # transcode while you extract here
                
                $aud_path = "$dest/$base_input_video.$ext_from_codec"
                $aud_path = "$dest/$base_input_video.m4a"
                write-output "  Encoding audio..."
                # WARNING: using this without checking for failure!
                
                # #& $tools_path/ffmpeg.exe $ffmpeg_param -progress pipe:1 -i "$input_video" -map 0:"$idx" -acodec aac $aud_path
                # & $tools_path/ffmpeg.exe $ffmpeg_param -progress pipe:1 -i "$input_video" -map 0:"$idx" -acodec aac $aud_path | Select-String 'out_time_ms=(\d+)' | ForEach-Object {
                #     $time_ms = [int] $_.Matches.Groups[1].Value
                #     $tt=[math]::Round($time_ms/10)
        
                #     $a= [math]::Round($tt / $audio_duration) 
                    
             
                #     $str = "#"*$a
                #     $str2 = "-"*(100-$a)
                #     Write-Host -NoNewLine "`r$a% complete | $str $str2|"
                # }
                $env:qpath = "$tools_path\qaac\qaac.exe"
                $env:qparam = "-V $qaac_quality"
                $env:qout = $aud_path

                $env:ffpath = "$tools_path\ffmpeg.exe"
                $env:ffintput = $input_video
                $env:ffparam = "-v quiet"
                $env:ffmap = "-map 0:$idx"
                
                #.\qaac.exe --verbose -V 94 .\aud.m4a  2>$NULL
                #$myCMD= 
                # cmd /s /c --% " echo %ffintput% "
                # cmd /s /c --% " echo %ffpath% '%ffintput%' %ffmap%"
                # cmd /s /c --% " echo %ffpath%  "%ffintput%" %ffmap%  %qpath% %qparam%  %qout%  "
                # echo "-------------------------------------------"
                cmd /s /c --% " "%ffpath%" %ffparam% -i "%ffintput%" %ffmap% -f wav - | "%qpath%" %qparam% - -o "%qout%" " 2>&1 | Select-String '(\d+:\d+.+) '| ForEach-Object {
                    
                $prog,$speed=(($_.Matches.Groups[0].Value) -split(" "))
                #$conv = ([TimeSpan]$prog).TotalMilliseconds
                
                $ts =  [timespan]::FromMilliseconds($audio_duration)
                $tss = ("{0:hh\:mm\:ss\.fff}" -f $ts)
                
                $colonCount = ($prog -replace '[^:]').Length
                
                $time_ms = ([timespan] ('0:' * [math]::Max(0, (3 - $colonCount - 1)) + $prog)).TotalMilliseconds
                $tt=[math]::Min($audio_duration,$time_ms)
        
                $perc=   ([math]::Round($tt*100 / $audio_duration) ) 
                Write-Host -NoNewLine "`r[$perc%]$prog out of $tss complete || $speed"
                }
                Write-Host ""
                $full_aud_path.value =$aud_path
                
            }
            
        }
        # if sub param is ignore we don't care about extracting sub
        if  ( ($subpriority -eq "internal_first")  -or (  ($subpriority -eq "external_first") -and  ($full_sub_path.value -eq "NO_EXT"))  ) { 
            
            if  (($codec_type -eq "subtitles")  -and ($is_default -or $is_unique_sub)){
                
                # $full_sub_path  = ... process here and get null or a path
                $internal_sub_found = $true
                #write-output "found default sub"
                
                $sub_dest = "$dest"+ $OS_delim +"$base_input_video.$ext_from_codec"
                # WARNING not ideal because we do not check for failure on extraction and we assign directly the path...
                
                #ffmpeg -i $input_video -map 0:s:0 $base_input_video".ass"
                #TODO update mkvextract when next version is released for long paths support with unc format \\?\
                & $tools_path/mkvextract.exe $mkve_params tracks  "$input_video"  "$idx"":$sub_dest"
                $full_sub_path.value = $sub_dest
            }
        }
       
        

    }
    # here handle internal first but no internal found
    if  ( ($subpriority -eq "internal_first") -and (-not  ($internal_sub_found)) ){
        #echo "found no internal despite internal first, gonna look for ext"
        $ext_location = process_ext_sub $input_video 
        if ($ext_location -ne "NO_EXT"){
            $full_sub_path.value = $ext_location
        }
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
    #foreach($font in Get-ChildItem -LiteralPath $dir -Recurse -Include *.ttf, *.otf, *.TTF, *.OTF) {
    foreach($font in  (Get-ChildItem -LiteralPath $dir -Recurse  | Where-Object {$_.extension -in ".ttf", ".otf"}) ) {    
    # [Session]::AddFontResource($font.FullName)
    # error reporting if one font fails, warn about it
        $ffn= $font.FullName
        # echo "loading($font)" 
        Write-Host -NoNewLine "`r    loading($font):"
        & $script_path/load_fonts.exe $font.FullName
    }

}

function unloadfonts_fromdir($dir){
    #copy the one above without last line
    foreach($font in  (Get-ChildItem -LiteralPath $dir -Recurse  | Where-Object {$_.extension -in ".ttf", ".otf"}) ) {
        & $script_path/unload_fonts.exe $font.FullName
    }
}



############### Main program
$files = $files_str -split "::"  #parse files
$save_in_inputDir=($output_destination.length -eq 0) #or coulse use .ispresent
$count_files = 0
foreach ($input_file in $files){
    #check if input file exists, if not continue
    $input_video = Convert-Path  -LiteralPath  $input_file #get abs path of file
    $input_video_exists = Test-Path -LiteralPath $input_video -PathType Leaf

    if (!$input_video_exists) {
        echo "$input_video does not Exist! skipping"
        continue
    }
    
    Write-Host "## Processing $input_video" -ForegroundColor white -BackgroundColor blue
    $count_files += 1
    $base_input_video = ([io.fileinfo]$input_video).basename
    $input_ext = ([System.IO.Path]::GetExtension($input_video)).ToLower()
    
    
    
    #$tmp_dir = "tmp_location"+"abst"somerandom  hash-name to avoid collision
    $t_biv=$base_input_video
    if ($base_input_video.length -gt 100){
        $rand_hash=-join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 12 |%{[char]$_})
        $t_biv=$base_input_video.SubString(0,90)+$rand_hash
    }
    $tmp_dir = "$tmp_location"+ $OS_delim +"$t_biv"
    
    

    # $avs_script_path = "$tmp_dir"+$OS_delim+"${base_input_video}_script.avs"
    $avs_script_path = "\\?\"+"$tmp_dir"+$OS_delim+"${base_input_video}_script.avs"
    

    #create temp directory - works
    mkdir $tmp_dir | Out-Null

    ## get file info (nb of fonts/attachements)
    $info_array = & $tools_path/mkvmerge.exe  --identification-format json --identify $input_video | ConvertFrom-Json
    #$ff_info_array = & $tools_path/ffprobe.exe  -v quiet  -print_format json -show_format -show_streams $input_video | ConvertFrom-Json
    # echo $info_array.attachements
    $nb_fonts= $info_array.attachments.count
    echo "  $base_input_video has: $nb_fonts fonts"
    $maxFrames = & $tools_path/mediainfo.exe --Output="Video;%FrameCount%" $input_video
    $source_dimW,$source_dimH =  (& $tools_path/mediainfo.exe  --Inform="Video;%Width%x%Height%" $input_video).split("x")
    $ff_btconv=""
    
    #if set resize option

    #$audio_duration=$audios_dur.split(" ")
     
    if ($auto_resize -ne 0){
        $resize_dimH=$auto_resize
        if ($testdev.IsPresent){
            echo "you req. to change $source_dimH p to $resize_dimH ($some_bool)"
        }
        
        if ([int]$source_dimH -gt $resize_dimH){
            $enable_resize = $true
            $resize_dimW = [math]::ceiling($resize_dimH*($source_dimW/$source_dimH))
            echo "downscaling to $resize_dimH x $resize_dimW" 
            $bt_conv = ($resize_dimH -le 480 ) -and ($source_dimH -ge 720) #it means we're converting FHD or HD to SD--> so BT conversion
            if ($bt_conv ) {$ff_btconv = "-vf", "colormatrix=bt709:bt601";}

        }else{
            echo "you did not request a downscale, you requested dimensions that are the same or bigger than input's dimension. Upscale not supported. output will have the original dimension"
        }
    }
    
    
    $final_subpath=$false
    $final_audiopath = $false
    #handle here unique audio /unique sub (without default)
    extract_default_sub_n_audio  $info_array.tracks $tmp_dir $input_video $base_input_video ([ref]$final_audiopath) ([ref]$final_subpath)
    if ($debug_verbose.IsPresent){ write-output "  Audio and subtitles handling done"}
    
    #write-output $final_subpath
    #write-output $final_audiopath
    #write-output $final_subpath
    
    #if ($input_ext -eq ".mkv"){   #maybe better to do on nb fonts
    if ($nb_fonts -gt 0){
        #if ($input_ext -eq ".mkv"){
        echo "  extracting fonts..."
        extract_fonts $input_video $tmp_dir $nb_fonts
        #}
        
        
        echo "  loading fonts..."
        if (-not ($testdev.IsPresent)){
            loadfonts_fromdir $tmp_dir
            loadfonts_fromdir $fonts_dir
        }else{
            echo "skipped fonts installation bcz dev mode"
        }
    }
    
    
    


    #write avs script
    # Important our ffms2 command has audio... what if... vfr and stuff like that :thinking:
    $filters_dir = $tools_path+$OS_delim+"plugins"+$OS_delim
    Set-Content -LiteralPath "$avs_script_path" -Value '# autogenerated avs script by ABST tool' 
    Add-Content -LiteralPath "$avs_script_path" -Value "LoadPlugin(`"${filters_dir}ffms2.dll`")"   #replace with ffms2 variable
    Add-Content -LiteralPath "$avs_script_path" -Value "LoadPlugin(`"${filters_dir}vsfilter.dll`")"  #replace with vsfilter variable
    # if ($bt_conv){
    #     Add-Content -LiteralPath "$avs_script_path" -Value "LoadPlugin(`"${filters_dir}ColorMatrix32.dll`")"  #replace with vsfilter variable

    # }
    
    
    # if ($final_audiopath -eq $false){
    #     Add-Content -LiteralPath "$avs_script_path" -Value "ffms2(`"$input_video`", fpsnum=24000, fpsden=1001,cache=false)  # convert to CFR"    
    # }else{
    #     Add-Content -LiteralPath "$avs_script_path" -Value "ffms2(`"$input_video`",atrack=-1, fpsnum=24000, fpsden=1001,cache=false)  # convert to CFR"
    # }
    Add-Content -LiteralPath "$avs_script_path" -Value "ffms2(`"$input_video`", fpsnum=24000, fpsden=1001,cache=false)  # convert to CFR"    
    Add-Content -LiteralPath "$avs_script_path" -Value "convertbits(8, dither=0)"
    Add-Content -LiteralPath "$avs_script_path" -Value "ConvertToYV12()"
    if (-not($final_subpath -eq $false)) {
        $sub_ext = ([System.IO.Path]::GetExtension($final_subpath)).ToLower() 
        $sub_filter="textsub"
        if ($sub_ext -eq ".idx" -or $sub_ext -eq ".sub"){
            $sub_filter="vobsub"
        }
            
        Add-Content -LiteralPath "$avs_script_path" -Value "$sub_filter(`"$final_subpath`" )" 
    }
    
    if ($enable_resize){
        # if ($bt_conv){ Add-Content -LiteralPath "$avs_script_path" -Value "ColorMatrix(mode=`"Rec.709->Rec.601`", threads=0)"}
        
        Add-Content -LiteralPath "$avs_script_path" -Value "Spline36Resize($resize_dimW,$resize_dimH )"
    }
    
    # Add-Content -LiteralPath "$avs_script_path" -Value "version()"

    
    # Last and not least, encode the episode!!!!!! Yayyy
    # FFMPEG encode command goes

    
    # CREATE DESTINATION FILE name
    
    ## if destination is not provided then we use the same dest as input
    if ($save_in_inputDir){
        #then make the out dest the same as source

        $output_destination =(get-item -LiteralPath $input_video).DirectoryName
        
    }
    ## if the user provided (via CLI) a non-existing destination create it
    if ((Test-Path -PathType Container  -LiteralPath $output_destination) -eq $false ){
        
        mkdir $output_destination
    }


    if ($audio -eq "disable"){ $final_audiopath = $false }
    if ($enable_resize){$rsz="[$resize_dimH]"}
    $outfile = $output_destination + $OS_delim + $prefix+ $base_input_video +"_out"+$rsz+"_"+ $suffix+".mp4"
    
    echo "  encoding final output for `"$base_input_video`"..."
    
    
    
    if ($final_audiopath -ne $false){
        #-profile:v high -level 4  removed after preset
        if ($testdev.IsPresent){
            
            echo "$tools_path/ffmpeg.exe $ffmpeg_param -i `"$avs_script_path`" -i `"$final_audiopath`" -map 0:0  -map 1:a:0  -c:v libx264 -pix_fmt yuv420p $ff_btconv -crf $crf -preset $preset -c:a copy  `"$outfile`""
        }
        & $tools_path/ffmpeg.exe $ffmpeg_param  -progress pipe:1 -i "$avs_script_path" -i "$final_audiopath" -map 0:0  -map 1:a:0  -c:v libx264 -pix_fmt yuv420p $ff_btconv -crf $crf -preset $preset -c:a copy  "$outfile"   | Select-String 'frame=(\d+)' | ForEach-Object {
            $frame = [int] $_.Matches.Groups[1].Value
            
            #Write-Progress -Activity 'ffmpeg' -Status 'Converting' -PercentComplete ($frame * 100 / $maxFrames)
            if ([int] $maxFrames -eq 0){
                Write-Host -NoNewLine "`r  >>can't report progress: $frame frames completed"
            }
            else{
                $a=($frame * 100 / $maxFrames)
                $a=[math]::Round($a)
                $str = "#"*$a
                $str2 = "-"*(100-$a)
                Write-Host -NoNewLine "`r$a% complete | $str $str2|"
            }
            
        }

    }else{
        # else if final audio path is empty  do command without audio here
        # echo "disable audio feature not yet implemented EXP version"
         #
        & $tools_path/ffmpeg.exe $ffmpeg_param -progress pipe:1 -i "$avs_script_path" -i "$input_video" -map 0:0  -map_metadata 1:s:0 -c:v libx264 -pix_fmt yuv420p $ff_btconv -crf $crf -preset $preset -an "$outfile"   | Select-String 'frame=(\d+)' | ForEach-Object {
            $frame = [int] $_.Matches.Groups[1].Value
            
            #Write-Progress -Activity 'ffmpeg' -Status 'Converting' -PercentComplete ($frame * 100 / $maxFrames)
            # echo "$frame out of $maxFrames"
            if ([int] $maxFrames -eq 0){
                Write-Host -NoNewLine "`r  >>can't report progress: $frame frames completed"
            }
            else{
                $a=($frame * 100 / $maxFrames)
                $a=[math]::Round($a)
                $str = "#"*$a
                $str2 = "-"*(100-$a)
                Write-Host -NoNewLine "`r$a% complete | $str $str2|"
            }
            
        }
    } 
    ## 
    if ([int] $maxFrames -ne 0){
        $str = "#"*100
        Write-Host -NoNewLine "`r100% complete | $str |"
    }
    
    Write-Host ""
    #unload fonts and clear temp directory
    # unload fonts
    if ($nb_fonts -gt 0){
        echo "removing fonts..."
        if (-not ($testdev.IsPresent)){
            unloadfonts_fromdir $tmp_dir
            unloadfonts_fromdir $fonts_dir
        }else{
                echo "skipped fonts uninstall bcz dev mode"
            }
    }
    #cd ..  # exit temp_dir (if there) then delete it
    if (-not ($testdev.IsPresent)){
        rmdir -Force -r -LiteralPath "\\?\$tmp_dir"
    }

}

echo "all tasks finished"
echo "processed $count_files tasks"