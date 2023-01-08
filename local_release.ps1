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
$upx_dir="D:\apps\upx-4.0.1-win644"
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

# Copy tools folder to lolal release too
cp -r -Force tools $test_release_path

cp   "load_fonts.exe" $test_release_path
cp   "unload_fonts.exe" $test_release_path

echo "your release is ready in: $test_release_path"
