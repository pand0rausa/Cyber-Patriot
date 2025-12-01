Write-Host "`n=== Local Users ===" -ForegroundColor Cyan
Get-LocalUser | ft Name,Enabled,PasswordLastSet,PasswordExpires

Write-Host "`n=== Users with password NEVER set ===" -ForegroundColor Red
Get-LocalUser | ? {!$_.PasswordLastSet} | select -ExpandProperty Name

Write-Host "`n=== Users allowed simple passwords (no complexity) ===" -ForegroundColor Red
([ADSI]"WinNT://$env:COMPUTERNAME").Children | ? {$_.SchemaClassName -eq 'User' -and ($_.UserFlags.Value -band 0x40000)} | select -ExpandProperty Name

Write-Host "`n=== Local Administrators ===" -ForegroundColor Yellow
([ADSI]"WinNT://./Administrators,group").Members() | % { $_.GetType().InvokeMember("Name", "GetProperty", $null, $_, $null) }

Write-Host "`n=== RDP Allowed (Remote Desktop Users group) ===" -ForegroundColor Yellow
([ADSI]"WinNT://./Remote Desktop Users,group").Members() | % { $_.GetType().InvokeMember("Name", "GetProperty", $null, $_, $null) }
Write-Host "(All Administrators also have RDP access)" -ForegroundColor Gray

Write-Host "`n=== Installed Software (basic list) ===" -ForegroundColor Green
gp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | ? DisplayName | sort DisplayName | ft DisplayName,DisplayVersion,Publisher -AutoSize

Write-Host "`n=== Pending Windows Updates ===" -ForegroundColor Magenta
$Session=New-Object -ComObject Microsoft.Update.Session
$Searcher=$Session.CreateUpdateSearcher()
$Pending=$Searcher.Search("IsInstalled=0").Updates
if($Pending.Count -eq 0){ "No pending updates" } else { $Pending | select Title,IsDownloaded }
