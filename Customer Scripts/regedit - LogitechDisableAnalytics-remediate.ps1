if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Logitech\LogiOptions\Analytics") -ne $true) {  New-Item "HKLM:\SOFTWARE\Logitech\LogiOptions\Analytics" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Logitech\LogiOptions\Analytics' -Name 'Enabled' -Value '0' -PropertyType String -Force -ea SilentlyContinue;
