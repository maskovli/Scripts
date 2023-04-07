try {
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Logitech\LogiOptions\Analytics")){ return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Logitech\LogiOptions\Analytics' -Name 'Enabled' -ea SilentlyContinue) -eq '0') {  } else { return $false };
}
catch { return $false }
return $true