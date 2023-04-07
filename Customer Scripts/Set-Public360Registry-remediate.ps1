if((Test-Path -LiteralPath "HKLM:\Software\Software Innovation\360") -ne $true) {  New-Item "HKLM:\Software\Software Innovation\360" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\Software\Software Innovation\360\Sites\nord.public360online.com") -ne $true) {  New-Item "HKLM:\Software\Software Innovation\360\Sites\nord.public360online.com" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\Software\Software Innovation\360' -Name 'DefaultSite' -Value 'nord.public360online.com' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\Software\Software Innovation\360\Sites\nord.public360online.com' -Name 'Web Application Url' -Value 'https://nord.public360online.com' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\Software\Software Innovation\360\Sites\nord.public360online.com' -Name 'Support Site Url' -Value 'http://FARM728WFE1:8382' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\Software\Software Innovation\360\Sites\nord.public360online.com' -Name 'LCIDS' -Value '1044' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\Software\Software Innovation\360\Sites\nord.public360online.com' -Name 'Standard Text Path' -Value '\\Farm728WFE1\docprod_4ff12599-d936-42cd-bd65-ef3c296a995a\templates\standardtext' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\Software\Software Innovation\360\Sites\nord.public360online.com' -Name 'Is Upgrade From 4.0' -Value '1' -PropertyType String -Force -ea SilentlyContinue;