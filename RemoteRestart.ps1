## Remote Restart
$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$RemotePC = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Remote Computer Name ","Remote System Restart")
$creds = Get-Credential
If (Test-Connection $RemotePC) {Invoke-Command -ComputerName $RemotePC -ScriptBlock { Restart-Computer -Wait 0 -Delay 10 -Force } -Credential $creds}
Else {
	$blah = $wshell.Popup("$RemotePC is not online.  Go Check it!",0,"Remote System Restart",0+0)
	Exit
}

$wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
$blah = $wshell.Popup("$RemotePC should restart in 10 seconds",5,"Remote System Restart",0+0)

Sleep 30

$i = $false
$ii = 0
$done = $false
Do {
	sleep 5
	$i = (Test-NetConnection -ComputerName $RemotePC).PingSucceeded
	If ($i -eq $true) {$done = $true}
	$ii = $ii + 1
	If ($ii -ge 24) {
		#$done = $true
		$blah = $wshell.Popup("$RemotePC is taking a long time to come back up.  Go Check it!",0,"Remote System Restart",0+0)
		Exit
	}
} Until ($done -eq $true)

$blah = $wshell.Popup("$RemotePC finished rebooting and it available to remote in again",0,"Remote System Restart",0+0)


# SIG # Begin signature block
# MIIQJAYJKoZIhvcNAQcCoIIQFTCCEBECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAbtpmJWM0/D2sfgJMInsdv6z
# efmgggx2MIIEfTCCA2WgAwIBAgITFwAAAAS71Y6qvamh+QAAAAAABDANBgkqhkiG
# 9w0BAQ0FADAmMSQwIgYDVQQDExtjb3JwLmNyeWUtbGVpa2UuY29tIFJvb3QgQ0Ew
# HhcNMTgxMjA2MjI1NjE4WhcNMjMxMjA2MjMwNjE4WjBgMRMwEQYKCZImiZPyLGQB
# GRYDY29tMRowGAYKCZImiZPyLGQBGRYKY3J5ZS1sZWlrZTEUMBIGCgmSJomT8ixk
# ARkWBGNvcnAxFzAVBgNVBAMTDlN1YiBJc3N1aW5nIENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAzzOZprhwPLPE2E9DuSVTk9b4Ok8yl8Vu0BBvYiuz
# kVGg7NSPGCE6vyZrgjQP2AySPA9xHHZLZnlarDPdmB/5gL4YdP6nBG7hTFz+SSQj
# bYIYE0MgIafSwbhRfhb2vTRFU3UbDb+1XXy9FT7VMuxnWpocmvk52Q04AxXL4UMs
# bYjAZaQ5Ezf77JrPQxtGV/eCCTrafRuy7n5XyfYNR89fS3CnLGvCa+2amn1G29XD
# oZlmlSWoaHMI1IuH9BZ6hHz0poWAQMG5c3PrRZuBIM+wK3hbXBpyikNkLjofi3D+
# uOq5FBL+J4nnrsfRuNmIFfgTCNi9QO31I+aceKegRX8WtwIDAQABo4IBaDCCAWQw
# EAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFFG+e4v9gvTNsw8OgiqGwjZBmGRq
# MBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMB
# Af8EBTADAQH/MB8GA1UdIwQYMBaAFNG7txZu4q5FZu+wzWriLdeOdY3yMF4GA1Ud
# HwRXMFUwU6BRoE+GTWh0dHA6Ly9jcmwuY29ycC5jcnllLWxlaWtlLmNvbS9DZXJ0
# RW5yb2xsL2NvcnAuY3J5ZS1sZWlrZS5jb20lMjBSb290JTIwQ0EuY3JsMHcGCCsG
# AQUFBwEBBGswaTBnBggrBgEFBQcwAoZbaHR0cDovL2NybC5jb3JwLmNyeWUtbGVp
# a2UuY29tL0NlcnRFbnJvbGwvTUVNLVZNLVJPT1RDQV9jb3JwLmNyeWUtbGVpa2Uu
# Y29tJTIwUm9vdCUyMENBLmNydDANBgkqhkiG9w0BAQ0FAAOCAQEACRsrA2SMcZ+b
# SNWsSQajq2b/03Whv52sxQ9OScWf1181sRxkPtQCxCj8Y3T6iq3iV4nPqyisvdBw
# j25i50mROlVxDWpl9GnHpIg3Q+HPJf5NFFNK1cluoAgUMifh/usthvoF9DNFHOwl
# 8aBeQCP+8P+oVFQIJiwnz7azKREiqeJfSTPk+nzQvsc5dpUw/GdIA2pq8nlaIiLS
# vllTRyr1KLfi22T/UnTB8Pa89j4VfMUMLWXldirpqgl1CSE2dxo+qgpho7xfb8R/
# oznoUeMpbC4h2Y1CcRRToy4rHJMblr5mgqIw5tmYOlSbeBKIqWoyLOtXvt0JLA5m
# H4B3SBMZszCCB/EwggbZoAMCAQICExAAAAAPV0PwhE0n3b4AAAAAAA8wDQYJKoZI
# hvcNAQENBQAwYDETMBEGCgmSJomT8ixkARkWA2NvbTEaMBgGCgmSJomT8ixkARkW
# CmNyeWUtbGVpa2UxFDASBgoJkiaJk/IsZAEZFgRjb3JwMRcwFQYDVQQDEw5TdWIg
# SXNzdWluZyBDQTAeFw0xOTAxMDMyMzEyNThaFw0yMTAxMDIyMzEyNThaMIGQMRMw
# EQYKCZImiZPyLGQBGRYDY29tMRowGAYKCZImiZPyLGQBGRYKY3J5ZS1sZWlrZTEU
# MBIGCgmSJomT8ixkARkWBGNvcnAxCzAJBgNVBAsTAklUMRQwEgYDVQQLEwtMaXR0
# bGUgUm9jazEOMAwGA1UECxMFVXNlcnMxFDASBgNVBAMTC01hcmMgRnJlbnR6MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtICsfBj2pZlljcicpOLk4zGz
# L9LUhrWztd3nrdaJD3SyCmK2Csr5JuW3D5cWYHDJ2iPV3J9egusNnChxyAPL4xzM
# xrNMLacV1Ets/KJBcTjGWY9q9676yGUUWp0a5nK3zLFNLed7w+lRVNgj6sBwEHOJ
# +QH7it+gny7QaTSmPwlBG8xwKyG4Q671XvqCNqlEEkG2m/2oTLbQjfxEYViGsuhc
# mqTB+XQkB+ukYdb81xkAtT/BwHj7qv8ltqaJNYC3O8bSKS9KCrJvllp/ZTbWYQGj
# BYfvWNN9As3az6iRrYtDiO3clmtiLyGaVAI8JfHMlaE64OTo1aAJPzaNQHk9HZmA
# V56UhKMgYo8ySNIiUkVqMFv13N3yiYOFbKVegIqwjjBLYmp8b44kbsUeSUIjVABI
# wnIlytbB6hgmUZIVJN6A3YzBaxKADeJCEJvJoQCPjAR+EzeYnuDMzMz+TVrhu7D2
# U6AJM7eMpu+lWm1m1dL+T4fE6A2FQnDr71pbzWi040oW1mVShcXExEh/FNdg/jQp
# XdRAqPFqltFxeOQLJQxnYSfwVc6OxahHDDf2ZRNw+Z3OhlhdM7+2BzOUguZc/nQf
# LJBg9lb97JFue4f4shoA91xNCqYs784Op4jy7OP+BqArW7EUtj8pqGKbPUAzsTE9
# KyZepJA/OsM8XLGwG/kCAwEAAaOCA3EwggNtMD4GCSsGAQQBgjcVBwQxMC8GJysG
# AQQBgjcVCITH2nKC/pkgg8mPNYKG8COB1dghgTCB8volgq7ZYAIBZAIBAzATBgNV
# HSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwGwYJKwYBBAGCNxUKBA4w
# DDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUsM1G4y/ZZEGnRu/FltOEHvfXzPwwHwYD
# VR0jBBgwFoAUUb57i/2C9M2zDw6CKobCNkGYZGowggEnBgNVHR8EggEeMIIBGjCC
# ARagggESoIIBDoaByWxkYXA6Ly8vQ049U3ViJTIwSXNzdWluZyUyMENBLENOPU1F
# TS1WTS1TVUJDQSxDTj1DRFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049
# U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1jb3JwLERDPWNyeWUtbGVpa2Us
# REM9Y29tP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFz
# cz1jUkxEaXN0cmlidXRpb25Qb2ludIZAaHR0cDovL2NybC5jb3JwLmNyeWUtbGVp
# a2UuY29tL0NlcnRFbnJvbGwvU3ViJTIwSXNzdWluZyUyMENBLmNybDCCAUAGCCsG
# AQUFBwEBBIIBMjCCAS4wgbwGCCsGAQUFBzAChoGvbGRhcDovLy9DTj1TdWIlMjBJ
# c3N1aW5nJTIwQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENO
# PVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Y29ycCxEQz1jcnllLWxlaWtl
# LERDPWNvbT9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNh
# dGlvbkF1dGhvcml0eTBtBggrBgEFBQcwAoZhaHR0cDovL2NybC5jb3JwLmNyeWUt
# bGVpa2UuY29tL0NlcnRFbnJvbGwvTUVNLVZNLVNVQkNBLmNvcnAuY3J5ZS1sZWlr
# ZS5jb21fU3ViJTIwSXNzdWluZyUyMENBLmNydDA6BgNVHREEMzAxoC8GCisGAQQB
# gjcUAgOgIQwfbWFyYy5mcmVudHpAY29ycC5jcnllLWxlaWtlLmNvbTANBgkqhkiG
# 9w0BAQ0FAAOCAQEAF1LLEUpx4RmnFuKoLpqnxvk84C3E5kDdavH88SkpFaN6/rY5
# a64nC41Gyj3N5M7XqrfMvLvum0gSAIwuMmWZg2TljmeFwKZfDs0qgvZbgdfg/68s
# Pp0B4WxSaiiA4QSyAVQUsi0p6MjtIpXdDHHj5XF4ulO/Cahxw4oDl2n9YSFf0bQ0
# N45FmtUrxbbbolvE7ZMKEO9CDjms4pt7p558yzZ0Q5x8d2R/2iXOAK68jzOgFmOv
# N3p/k8jCB9k/3otPP5Tjt33kZyeH1jF8YE36EaKRYZIHNnZupJhUTo8MG0t8ecAW
# hXLGRVd+pnv8VbaqYtoFdodujbdy1S0pyZc8uzGCAxgwggMUAgEBMHcwYDETMBEG
# CgmSJomT8ixkARkWA2NvbTEaMBgGCgmSJomT8ixkARkWCmNyeWUtbGVpa2UxFDAS
# BgoJkiaJk/IsZAEZFgRjb3JwMRcwFQYDVQQDEw5TdWIgSXNzdWluZyBDQQITEAAA
# AA9XQ/CETSfdvgAAAAAADzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUw5Io+yzWn6hmngj+j0LQ
# 9p8smjgwDQYJKoZIhvcNAQEBBQAEggIAUTxpWUTeCuJ6JGWzl19bH43KXPf4iFmJ
# iOcJ+gshYqL4zN2WzV2ZKSCySbHATn6httFpuYii/pJnNZMn6+trnz7i066FTkCV
# GG6CovrCQwt6DybHlBtpDIiw8fKxyaN7yU6lZnDqQsAku2mMAyUsvCq1gzmn6QOh
# y65+DpIKZV2b36kZ6kAWQhsrRKbqZf652eCZzwvHzHVh2GRq/J/D1nGXeNEknWZ1
# fbOHXGYHJiOwYNJJzM76ouEMPSee9tKpkUetPcBeEfkFVi38dVjUOWoT15VbO5JT
# ssggVgOf3p2bJJxloqu/rVLNQYSWQ0sego/KomjrRdsuUx3a1wtHXE8+bpRb0gXx
# G/CnkG61zfpzkdU6q1LZ0+HTbC0QtXVp95O0y1cyNMz0TqdrNqsLf1gEPpZcS58I
# VUrMGzHOg79Ou3ZQ9Z4dYvtCBuDj4ocfAHc3m/NlVvhqJgb/8ChYCraY+XJEexwW
# GCmTUFsy2/SVMSNfaBHFY23MlfA3W1XieYfQ7BDGonnXdbDL3mv3+P8zhtNkBU65
# OQdin63tD0L+RYeAkVafJds4EVoOg1Zcb96uYaM7nqOAuMc3z3MVwJQDuvpGaD+O
# gKw05u+evrZx8q0/JuQqkkO/yQr9jZPJkgn2rbycCcH9Lsu0v+ICsWjlGozvRPp2
# aD9cBkQ1ud0=
# SIG # End signature block
