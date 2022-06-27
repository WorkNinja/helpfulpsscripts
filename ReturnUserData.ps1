## Script to Put all personal data back to some place

Function Get-Folder { 
 Param ($sDir)
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
 $OpenFileDialog.RootFolder = 'MyComputer'
 if ($sDir) { $OpenFileDialog.SelectedPath = $sDir }
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.SelectedPath
} #end function Get-FileName


## Select folder to save all the shit to
$getFolder = $null
$getFolder = Get-Folder -sDir 'c:\'

If (Test-Path $getFolder) {
    Write-Host "Copying Desktop"
    Copy-Item -Path "$getFolder\Desktop"  -Destination "$env:USERPROFILE\Desktop" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copying Documents"
    Copy-Item -Path "$getFolder\Documents" -Destination "$env:USERPROFILE\Documents" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copying Favorites"
    Copy-Item -Path "$getFolder\Favorites" -Destination "$env:USERPROFILE\Favorites" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copying Downloads"
    Copy-Item -Path "$getFolder\Downloads" -Destination "$env:USERPROFILE\Downloads" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copying AppData Local Outlook"
    Copy-Item -Path "$getFolder\LocalOutlook" -Destination "$env:LOCALAPPDATA\Microsoft\Outlook" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copying AppData Roaming Outlook"
    Copy-Item -Path "$getFolder\RoamingOutlook" -Destination "$env:APPDATA\Microsoft\Outlook" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copying AppData Roaming Signatures"
    Copy-Item -Path "$getFolder\RoamingSignatures" -Destination "$env:APPDATA\Microsoft\Signatures" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copying AppData Roaming Stationary"
    Copy-Item -Path "$getFolder\RoamingStationery" -Destination "$env:APPDATA\Microsoft\Stationery" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "All done"
}
# SIG # Begin signature block
# MIIO1QYJKoZIhvcNAQcCoIIOxjCCDsICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU82y37nZ8/vX5R+2AUzu2+RnI
# FIOgggsnMIIEfTCCA2WgAwIBAgITFwAAAAS71Y6qvamh+QAAAAAABDANBgkqhkiG
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFCGAnE0kh8CUt6KeMQsY
# ppU5BUK5MA0GCSqGSIb3DQEBAQUABIICAG1QeX3ygWhsqMBtbGSoo1pMwhW4mL6S
# nAA4DdhcFAUtMjdISbxsZYQuoa4oxfuCaV9Szv8aeBuH/gVDY+jRJmyxZXjGd8p7
# 6DBGX7aBssortPgZE6TDIABEIPdL3LW9GBPGuIa0K5O6HepQ9KHCclSCzKnKV/kh
# +n+GMR0SHeHnGgQ+X8Ctytnw7lhi9MIGhVl4ODz1koUkVh1kg4hzIvG83MMERa3Z
# 9/hueF56k2QZBWziMaWkwaQHqS9wiUmriW3JH0fldedw5uyP2uqCWIE1OFvpECxg
# rHo2IwrSHhbq9BeMn0SunIqhs/ynyuVA9pbEcbDORd4U28CGZDygDNC3OSgPdvkv
# ZU8BUFJmxX9eISdS0eY79dSpvLhNrJ1FjmAG+CMqXAnn2eUDrYm4VKN8unCugmbx
# CzTZdcgP0jj8NnWyBHroEP6fwI/MqIBaJCMyAsqNYGgtjMWpZ42WRLG+D3JJQQPh
# nWXUgkM8Lr2nRBJzm96BLeV2oJLpIhSnSS8RqUic41up2XFLvhpLUnUcNKY7cA3Y
# ji9XpuxMw31mKpwshkUI7EQFZ5io3Q96I8jHKudzCq95L3WCBW3G42gSUPuwa/AN
# puPzuLbig9DrZX4Ziks8nd17X4juZl1GiCYfXWXvj7dUQLWVhYMg3Papd2ud6VoB
# wobNFtL/3PZ9
# SIG # End signature block
