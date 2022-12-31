# Uninstall-Font.ps1
param($file)

$signature = @'
[DllImport("gdi32.dll", CharSet = CharSet.Unicode)]
public static extern bool RemoveFontResource(string lpszFilename);
'@

$type = Add-Type -MemberDefinition $signature `
    -Name FontUtils -Namespace RemoveFontResource `
    -Using System.Text -PassThru
   
$type::RemoveFontResource($file)
#from https://stackoverflow.com/questions/12946384/windows-install-fonts-from-cmd-bat-file/67903796#67903796