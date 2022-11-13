Powershell

[string]$dateString = get-date -format o | ForEach-Object {$_ -replace ":", ""}
$savetoPath = "C:\Avanti_Deployment\" + $env:computername + "_" + $dateString
New-Item -ItemType Directory -Force -Path $savetoPath
$Nfolders = "$savetoPath\Windows\Event_Viewer","$savetoPath\Windows\DSC","$savetoPath\Windows\Scheduled_Task","$savetoPath\Avanti_Application\Logs","$savetoPath\Avanti_Application\Settings","$savetoPath\Avanti_Application\BA_Log", "$savetoPath\Avanti_Application\Databases","$savetoPath\Windows\Reboot_Logs"
New-Item -ItemType directory $Nfolders
if(Test-path "C:\Program Files (x86)\"){
    $32ProgramFilesPath = "C:\Program Files (x86)\"
}Else{
    $32ProgramFilesPath = "C:\Program Files\"
}
copy-item -path "$32ProgramFilesPath\Avanti\Marketplace Kiosk\Kiosk\Avanti.Kiosk.exe.config" -destination "$savetoPath\Avanti_Application\Settings"
$capturedate = get-date
$capturedate = $capturedate.addDays(-14)
get-childItem -path "C:\ProgramData\Avanti\Logs\" | Where {$_.lastwriteTime -ge $capturedate} | copy-item -destination "$savetoPath\Avanti_Application\Logs" -force -container
copy-item -path "C:\ProgramData\Avanti\Kiosk\settings.json" -destination "$savetoPath\Avanti_Application\Settings"
copy-item -path "C:\ProgramData\Avanti\Kiosk\Avanti_Kiosk_AppData.db" -destination "$savetoPath\Avanti_Application\Databases"
copy-item -path "C:\ProgramData\Avanti\Transactions\Avanti_Kiosk_SyncData.db" -destination "$savetoPath\Avanti_Application\Databases"
copy-item -path "C:\BillAcceptorLogs\MPOST*.txt" -destination "$savetoPath\Avanti_Application\BA_Log"

$filename = "$savetoPath\Windows\Event_Viewer" + "\" + $dateString + $env:computername + "_application_Log.evtx"
wevtutil epl application  $filename

$filename = "$savetoPath\Windows\Event_Viewer" + "\" + $dateString + $env:computername + "_system_Log.evtx"
wevtutil epl system $filename

$filename = "$savetoPath\Windows\Event_Viewer" + "\" + $dateString + $env:computername + "_security_Log.evtx"
wevtutil epl security $filename

$filename = "$savetoPath\Windows\Event_Viewer" + "\" + $dateString + $env:computername + "_WindowsDefenderOperational_Log.evtx"
wevtutil epl "Microsoft-Windows-Windows Defender/Operational" $filename

$filename = "$savetoPath\Windows\Event_Viewer" + "\" + $dateString + $env:computername + "_WindowsUpdateClientOperational_Log.evtx"
wevtutil epl "Microsoft-Windows-WindowsUpdateClient/Operational" $filename

$filename = "$savetoPath\Windows" + "\" + $dateString + $env:computername + "_SystemInfo.txt"
systeminfo | out-file -FilePath $filename

$filename = "$savetoPath\Windows" + "\" + $dateString + $env:computername + "_Get-Processes.txt"
Get-Process | out-file -FilePath $filename

$filename = "$savetoPath\Windows" + "\" + $dateString + $env:computername + "_TaskList.txt"
tasklist | out-file -FilePath $filename

$filename = "$savetoPath\Windows" + "\" + $dateString + $env:computername + "_Hotfix.txt"
Get-HotFix | select PSComputerName, InstalledOn, Caption, Description, HotFixID, InstalledBy | out-file -FilePath $filename

$filename = "$savetoPath\Windows\DSC" + "\" + $dateString + $env:computername + "_DscConfigurationStatus.txt"
Get-DscConfigurationStatus | Format-List | Format-Table User -wrap | out-file -FilePath $filename

$filename = "$savetoPath\Windows\DSC" + "\" + $dateString + $env:computername + "_MicrosoftWindowsDscOperational.txt"
Get-WinEvent -LogName "Microsoft-Windows-Dsc/Operational" | Format-List | Format-Table User -wrap | out-file -FilePath $filename

$filename = "$savetoPath\Windows\DSC" + "\" + $dateString + $env:computername + "_DscLocalConfigurationManager.txt"
Get-DscLocalConfigurationManager | Format-List | Format-Table User -wrap | out-file -FilePath $filename

$filename = "$savetoPath\Windows\Scheduled_Task" + "\" + $dateString + $env:computername + "_ScheduledTaskList.csv"
Get-ScheduledTask | Where { ($_ -notmatch "Microsoft") -and ($_ -notmatch "OfficeSoftware") } | Export-Csv $filename -NoTypeInformation

$filename = "$savetoPath\Windows\Scheduled_Task" + "\" + $dateString + $env:computername + "_Offline_Payments.txt"
Get-ScheduledTaskInfo -TaskName "\Avanti Process Offline Payments" | Format-List | Format-Table User -wrap | out-file -FilePath $filename

$filename = "$savetoPath\Windows\Scheduled_Task" + "\" + $dateString + $env:computername + "_Pulse_Service_Task.txt"
Get-ScheduledTaskInfo -TaskName "\Avanti Transaction Pulse Service Task" | Format-List | Format-Table User -wrap | out-file -FilePath $filename

$filename = "$savetoPath\Windows\Reboot_Logs" + "\" + $dateString + $env:computername + "_Boot_Times.txt"
Get-WinEvent -FilterHashtable @{logname='System'; id=1074}  | ForEach-Object {
    $rv = New-Object PSObject | Select-Object Date, User, Action, Process, Reason, ReasonCode, Comment
    $rv.Date = $_.TimeCreated
    $rv.User = $_.Properties[6].Value
    $rv.Process = $_.Properties[0].Value
    $rv.Action = $_.Properties[4].Value
    $rv.Reason = $_.Properties[2].Value
    $rv.ReasonCode = $_.Properties[3].Value
    $rv.Comment = $_.Properties[5].Value
    $rv
    }| Select-Object Date, Action, Reason, User | Format-List | Format-Table User -wrap | out-file -FilePath $filename
    
Exit

