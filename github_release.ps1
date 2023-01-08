# you have to run local_release first and try the version!

param(
    [string]$opath="local_release"
    ) 

#$original_path = pwd
#cd -LiteralPath $opath

$Vc =  & "$opath\abst_cli.exe" -v
$Vg= ((python .\gui\abst_gui.py  -v) -split ":")[1].replace(' ','')



"Ver=${Vc}g${Vg}" >.github/ver.env
#echo  "${Vc}g${Vg}"