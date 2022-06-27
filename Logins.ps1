If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$Days = [Microsoft.VisualBasic.Interaction]::InputBox("Enter number of days to pull","User Logins Report")
$date = (get-date).ToString("MMddyyyy")
$file = "$env:personal\userlogins_$date.txt"
$events = @()
$events += Get-WinEvent -FilterHashtable @{ 
    LogName='Security'
    Id=@(4800,4801)
    StartTime=(Get-Date).AddDays(-$Days) 
}
$events += Get-WinEvent -FilterHashtable @{ 
    LogName='System'
    Id=@(7002,7001)
    StartTime=(Get-Date).AddDays(-$Days) 
}

$type_lu = @{
    7001 = 'Logon'
    7002 = 'Logoff'
    4800 = 'Lock'
    4801 = 'UnLock'
}

If($events) {
    $results = ForEach($event in $events) {
        $xml = $event.ToXml()
       
        Switch -Regex ($event.Id) {
            '4...' {
                $user = $event.properties.value[1]
                Break            
            }
            '7...' {
                $sid = $event.properties.value.value
                $user = (
                    New-Object System.Security.Principal.SecurityIdentifier($sid)
                ).Translate([System.Security.Principal.NTAccount]).Value
                Break
            }
        }

        New-Object -TypeName PSObject -Property @{
            Time = $event.TimeCreated
            Id = $event.Id
            Type = $type_lu[$event.Id]
            User = $user
        }
    }
    If($results) {Add-Content -Path $file -Value $results}
}
# SIG # Begin signature block
# MIIO1QYJKoZIhvcNAQcCoIIOxjCCDsICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+VTfNz8n1lLXfqqMJyhUJ5L2
# AD2gggsnMIIEfTCCA2WgAwIBAgITFwAAAAS71Y6qvamh+QAAAAAABDANBgkqhkiG
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJmGg95+wZaun5OGfFUI
# uqIVH822MA0GCSqGSIb3DQEBAQUABIICABMN1BMRLJQG3f/df95hjkpMSCqKi6sg
# aNmcV7vxFd8Q7nTjk7S+K/N/6ClECwrL1UTbK0gKi+SJ7Z0XkMZUenSug4aDFLQC
# 6C+v1CRX4MYe4NrEHpLlXJ98cKIl0LepZ4bT1Pgs07/gIAPoyNGTC+YbMRyXePBm
# xnjgW5B79QtRQL58aLxMqIcXWaLRkyB+XPHCD/ur6Z0n+uN3kKKtaqcJ8OqQCSzr
# feTOw3jTZ4mnHOMLU5DFt6QFyCMTr01gIAijvHBbUG1KRNRehdUACoQ+2K/GzbTx
# dcf38rCZE5hP6r3RAqcLc8i4hPr9AMutODUxiyM0pm8zb5F2fBAR3/FpzfGAI0+H
# W8vqMSfz8EY1l04Hmx7Cd3cNu8f/AL/8DBOtcbgT3DVcaYnnq/b+4PrTbnoBYn5n
# TK8YEoRxNMwsvh0+SbXgUvBXDZpLSS7vuv1VLml5LHEr2WiJ0nGGoalSTVMXgb9Y
# 3r/WLKngx3+QFMsJ27Imw01IOPvfXq/vDUf9qndRwpUs1PnesE0wHDApoNWjWVFk
# 0pLWdkXQe+pXjk0gSVwE7MO6p8GKIlJME7O/XCc6koB2jy/axN/T/xVwF4XuRibA
# /GecHWBAsnW//ts3IfTch8U8Dd3Tt1X4+gAL+q6r7ZfUfQ/1sddM8wtISiL9nQzi
# tAWJ3R23jHBC
# SIG # End signature block
