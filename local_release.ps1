#pre-release script
param(
    [switch]$upx,
    [string]$opath="local_release"
    ) 
# before running the script ` pip install  PyQt5 pyqt5-tools  pyinstaller  `
$test_release_path=$opath
mkdir -Force  $test_release_path
#rename this later to abst_cli
ps2exe -longPaths script.ps1 "$test_release_path\abst_cli.exe"
pyuic5 .\gui\abst_ui.ui -o .\gui\abst_ui.py
#compile python GUI to standalone exe here
$original_path = pwd
cd -LiteralPath gui


#compile "abst_gui.py"
$upx_dir="D:\apps\upx-4.0.1-win64"
if (Test-Path -LiteralPath $upx_dir -PathType Container) {
    pyinstaller.exe --onefile --windowed --upx-dir $upx_dir .\abst_gui.py -n ABST
}else{
    # download UPX
    if (($upx.IsPresent)){
        echo "should download UPX"
        $fname="upx-4.0.1-win64.zip"
        $URL="https://github.com/upx/upx/releases/download/v4.0.1/$fname"
        
        # (New-Object System.Net.WebClient).DownloadFile($URL, "./$fname")
        Start-BitsTransfer -Source $URL -Destination "./$fname" 

        Expand-Archive $fname "." 
        # md -Force 
        pyinstaller.exe --onefile --windowed --upx-dir (($fname -split ".zip")[0]) .\abst_gui.py -n ABST
    }else{
        pyinstaller.exe --onefile --windowed .\abst_gui.py -n ABST
    }
    

}
cd -LiteralPath $original_path

cp -r -Force gui\dist\* $test_release_path #move compiled gui to release

mkdir -Force  $test_release_path\lang

# Locate lrelease.exe ourselves instead of trusting an alias pointing at a
# hardcoded Python path. The CI alias pinned Python 3.9.13, but setup-python
# '3.9' installs whatever the newest 3.9.x is, so the path stopped existing.
# Set-Alias does not validate its target and nothing here checked for errors,
# so lrelease quietly did nothing and releases shipped with an empty lang/
# folder: no Arabic, no French.
$lrelease_exe = $null
$lrelease_cmd = Get-Command lrelease -ErrorAction SilentlyContinue
if ($lrelease_cmd -and (Test-Path -LiteralPath $lrelease_cmd.Definition)) {
    $lrelease_exe = $lrelease_cmd.Definition
} else {
    $python_cmd = Get-Command python -ErrorAction SilentlyContinue
    if ($python_cmd) {
        $lrelease_exe = Get-ChildItem -Path (Split-Path $python_cmd.Source) -Filter lrelease.exe -Recurse -ErrorAction SilentlyContinue |
                            Select-Object -First 1 -ExpandProperty FullName
    }
}
if (-not $lrelease_exe) { throw "lrelease.exe not found - the release would ship without translations. Is pyqt5-tools installed?" }
echo "using lrelease: $lrelease_exe"

#could repleace these 2 lines with a loop for each file of lang_src later.
foreach ($lang_name in @("arabic","french")) {
    & $lrelease_exe ".\gui\lang_src\$lang_name.ts" -qm ".\$test_release_path\lang\$lang_name.qm"   # generate distributable lang files
    if (-not (Test-Path -LiteralPath ".\$test_release_path\lang\$lang_name.qm")) {
        throw "failed to build lang\$lang_name.qm - refusing to ship a release without translations"
    }
}

# Copy tools folder to lolal release too
cp -r -Force tools $test_release_path

cp   "load_fonts.exe" $test_release_path
cp   "unload_fonts.exe" $test_release_path

echo "your release is ready in: $test_release_path"
