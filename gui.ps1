# PowerShell Drag & Drop sample
# Usage:
#   powershell -sta -file dragdrop.ps1
# (-sta flag is required)
#
Function DragDropSample() {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	$form = New-Object Windows.Forms.Form
	$form.text = "Drag&Drop sample"
	$listBox = New-Object Windows.Forms.ListBox
	$listBox.Dock = [System.Windows.Forms.DockStyle]::Fill
	$handler = {
		if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
			foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
				$listBox.Items.Add($filename)
			}
		}
	}
	$form.AllowDrop = $true
	$form.Add_DragEnter($handler)
	$form.Controls.Add($listBox)
	$form.ShowDialog()
}

DragDropSample | Out-Null