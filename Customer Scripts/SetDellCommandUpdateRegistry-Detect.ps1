try {
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule")){ return $false };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\UpdateFilter\UpdateType")){ return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'RebootWait' -ea SilentlyContinue) -eq 'Never') {  } else { return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'AutomationMode' -ea SilentlyContinue) -eq 'ScanDownloadApplyNotify') {  } else { return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'ScheduleMode' -ea SilentlyContinue) -eq 'Daily') {  } else { return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\UpdateFilter\UpdateType' -Name 'IsBiosSelected' -ea SilentlyContinue) -eq 0) {  } else { return $false };
}
catch { return $false }
return $true	