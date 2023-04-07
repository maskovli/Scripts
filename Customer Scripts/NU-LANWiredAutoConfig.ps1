get-service -DisplayName "Wired AutoConfig" | Set-Service -StartupType Automatic
get-service -DisplayName "Wired AutoConfig" | Set-Service -Status Running