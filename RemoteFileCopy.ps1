## copy files from network share to remote pc

$wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$RemotePC = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Remote Computer Name ","Remote File Copy")
$source = [Microsoft.VisualBasic.Interaction]::InputBox("Enter full UNC path to source folder","Remote File Copy")
$file = [Microsoft.VisualBasic.Interaction]::InputBox("Enter file name(s) (can include wildcards)","Remote File Copy")
$dest = [Microsoft.VisualBasic.Interaction]::InputBox("Enter destination folder","Remote File Copy")

$user = $env:userdomain + "\" + $env:username
$creds = Get-Credential -UserName $user -Message "Enter yo shit"

$SB = {New-PSDrive -Name "FileCopy" -PSProvider FileSystem -Root $Using:source -Credential $Using:creds}
Invoke-Command -ComputerName $RemotePC -ScriptBlock $SB -Credential $creds
$copyfile = $source + "\" + $file
$SB = {Copy-Item -Path $Using:copyfile -Destination $Using:dest -Force}
Invoke-Command -ComputerName $RemotePC -ScriptBlock $SB -Credential $creds

if ($?) {$wshell.Popup("Looks like the file copied ok",10,"Remote File Copy",0+64)}
else {$wshell.Popup("File copy failed",0,"Remote File Copy",0+16)}


# SIG # Begin signature block
# MIIO1QYJKoZIhvcNAQcCoIIOxjCCDsICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbVzlwsqgMYv6+iGkVf62Vnoe
# M4agggsnMIIEfTCCA2WgAwIBAgITFwAAAAS71Y6qvamh+QAAAAAABDANBgkqhkiG
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
# H4B3SBMZszCCBqIwggWKoAMCAQICExAAAACq0AD97ckGUTkAAAAAAKowDQYJKoZI
# hvcNAQENBQAwYDETMBEGCgmSJomT8ixkARkWA2NvbTEaMBgGCgmSJomT8ixkARkW
# CmNyeWUtbGVpa2UxFDASBgoJkiaJk/IsZAEZFgRjb3JwMRcwFQYDVQQDEw5TdWIg
# SXNzdWluZyBDQTAeFw0yMTAxMDQxNzQyMzRaFw0yMzAxMDQxNzQyMzRaMG0xEzAR
# BgoJkiaJk/IsZAEZFgNjb20xGjAYBgoJkiaJk/IsZAEZFgpjcnllLWxlaWtlMRQw
# EgYKCZImiZPyLGQBGRYEY29ycDEOMAwGA1UEAxMFVXNlcnMxFDASBgNVBAMTC01h
# cmMgRnJlbnR6MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAmNhneAG3
# a5aX9WzKlfjHbHRsYeNkgi2WsN6PYB/ESm6IzTEOhXuntgWnVVh5IG5rkY/doIXH
# i4tWxT069l60M5HTZSc95WAn0x1JcfLcRxpDFBE/Y8j3XiHbuxTlb/Pmrb0bvAvF
# KpVgyi6YtA6bziZJ83JzyjsAgV0+2G1nEd6GkRDh8n0TY5rBCrn1RJ+tBwuPSvo4
# LkstA8IwizGsM0ksLYxtnXRZJGWMhtTeR/Kj7PIQTXjGC3wAdCk7OFOntThXB2QE
# QIm9LIQt65aOFpvryfWLA8RyZ6O2mH0yYitnSZOkIm/yUYMOV4AAr+/3LCpOFY1O
# QJiKREu7ZMOnKadTd+1SZjm7Jqf4K0F8qdJJh4iXs6XPTGBqphGzMXuQN6h1MvXx
# nX6yySl0fvjG+IUYFEvt5k/j9plNdUx0AU54MELY0XBRVkhTSrVZIlSg8CXaioyG
# Lw4/5ZhosuV3AF3o71dGQrT7SNbi3FLVByFnF4M7cqE9t5//zUQ1vjYbmJnXSo8l
# rQQxHuCbqqVbMEbhiZ07oxrs7W6bCPpBk0E0Y55Cnrsy2be+CJ/vk7KHuIUCvynB
# 1DBRbkUVjgMmQ+aq5Qq3wuNqG7lKb13OkMYLOegv+Sc4tBNB3W5i0wfQ1tKNU7qj
# RZKgCxwY5rhSnBgcN0xZIApi3L/BnD5I1w0CAwEAAaOCAkYwggJCMD4GCSsGAQQB
# gjcVBwQxMC8GJysGAQQBgjcVCITH2nKC/pkgg8mPNYKG8COB1dghgTCB8volgq7Z
# YAIBZAIBDDATBgNVHSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwGwYJ
# KwYBBAGCNxUKBA4wDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUIn/4JSrZFiH/jz5z
# CnDxHARRwyswHwYDVR0jBBgwFoAUUb57i/2C9M2zDw6CKobCNkGYZGowggFABggr
# BgEFBQcBAQSCATIwggEuMIG8BggrBgEFBQcwAoaBr2xkYXA6Ly8vQ049U3ViJTIw
# SXNzdWluZyUyMENBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxD
# Tj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNvcnAsREM9Y3J5ZS1sZWlr
# ZSxEQz1jb20/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmlj
# YXRpb25BdXRob3JpdHkwbQYIKwYBBQUHMAKGYWh0dHA6Ly9jcmwuY29ycC5jcnll
# LWxlaWtlLmNvbS9DZXJ0RW5yb2xsL01FTS1WTS1TVUJDQS5jb3JwLmNyeWUtbGVp
# a2UuY29tX1N1YiUyMElzc3VpbmclMjBDQS5jcnQwOgYDVR0RBDMwMaAvBgorBgEE
# AYI3FAIDoCEMH21hcmMuZnJlbnR6QGNvcnAuY3J5ZS1sZWlrZS5jb20wDQYJKoZI
# hvcNAQENBQADggEBAJyNrV+mlMRcilv4FKdvldMiou4gsDle92+BJFG1CaMnQKkm
# kegxoOHGPw3xzYG2O9sTEwsnvWkhO6wFom6vS97UKuSe3rtCJ5HibDePdHuT5mpT
# IeDZpDYKYzjXySXUHx508fy4EFvNVljYaydu6AzwEzYgJGsV5C02CvW8he8CtbE6
# 7qXs3arm/41urIINYhmsfa7VM9W3nugQe7CGA2dLqPpp9cFH89BGUWHorO8dXtas
# gyJ1Bu1XE9abS2Ti15MX4/GIFB3Nlnsvj7unJO0W++SC7lnHGuO1TpGXO7YeIBEM
# Nj6f1rW/QrJWMZFXpafl9jXC3vYXBTpTdxXKmxExggMYMIIDFAIBATB3MGAxEzAR
# BgoJkiaJk/IsZAEZFgNjb20xGjAYBgoJkiaJk/IsZAEZFgpjcnllLWxlaWtlMRQw
# EgYKCZImiZPyLGQBGRYEY29ycDEXMBUGA1UEAxMOU3ViIElzc3VpbmcgQ0ECExAA
# AACq0AD97ckGUTkAAAAAAKowCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGDLze0qarqHqyu0YMEV
# ybx1NS1VMA0GCSqGSIb3DQEBAQUABIICACRMXjzTdl6pLt5PRoAsnskktiiWAwak
# iWuHA9oQ2uX4f8sBjPz9GRbmenFyzyhMyTQclql2Ao+dd9q1G+ZwXo2mumvrohIn
# 6kl+5R7AiJfugY9PmR7IuN5cK4X5AHa7m1C7l5ZxtKbDpo+OgUzdYQg0jlwQ0x3B
# TX7I1ZqqC8BXC6Wa8c96Se8Rbp1V62Tqwrh1L2ZfVHa7B8QLMYD+76dss3DcH53y
# YwETMgyv3Reh4fasA9RSqvXfB1ry90AhC8gBu54C5HwvuRWzCFTootVuWb4T6KQF
# sjbHVVAItoRBqpuyexTLSsnhsZT2+XMlzCgvfISMrO7N2Si3si2Fi6g3tflZCeyT
# Y+KMFutIn2kFxXub3Vdp9yWjnFMMVnMNTwtb2xxYFSJzhRlgu30TCrl1hStooyP3
# g7v45fCDDaxEA7e5TyY1vlhzNXW2bxOYpHAajfkua83iGGQHb6SPtm4t6XZBXsRz
# 5cVRjfGi3ggDnFX8+/Mg+3idJZhHUtwAwxUQ3jWT5N+fDYqfCw52Kr/CBieVJycC
# /c+/aKGkGg4/lFXdvEeWdat8larE6CCxyRjTQa7bZC1GuWg6zznhnhExO3nd7A6y
# 6jrQzPWV1Ilnsmtaj3Xnmh1lMXjgi4A51xQYaRrB0L2Fx3BMqhvvawY4FGn2J6vu
# 5fU3GyLA5sfk
# SIG # End signature block
