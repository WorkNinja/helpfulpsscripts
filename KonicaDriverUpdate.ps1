If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}

$dFolder = "C:\windows\Drivers\Px64\KMUD_PS"
$dUNC = "\\corp.crye-leike.com\Software\Drivers\Konica\KMUD_PS"

Function iDriver($driverName) {
    $dFolder = "C:\windows\Drivers\Px64\KMUD_PS"
    if (!(Test-Path $dFolder)) {
        New-Item -ItemType Directory -Path $dFolder -Force
        Copy-Item -Path $dUNC\* -Destination $dFolder -Force
    }
    $infPath = $dFolder + "\KOAX8A__.inf"
    pnputil.exe -a $infPath
    Add-PrinterDriver -Name $driverName
}

Function DriverVer ($dVer){
    $rev = $dVer -band 0xffff
    $build = ($dVer -shr 16) -band 0xffff
    $minor = ($dVer -shr 32) -band 0xffff
    $major = ($dVer -shr 48) -band 0xffff
    $dVersion = "$major.$minor.$build.$rev"
    return $dVersion
}

$wut = $false
$pDrivers = Get-PrinterDriver -Name "KONICA MINOLTA *"
$nDvr = 'KONICA MINOLTA Universal PS'
$nDvr2 = 'KONICA MINOLTA Universal PS v3.9.1'
foreach ($d in $pDrivers) {
    if (($d.name -eq $nDvr) -or ($d.name -eq $nDvr2)){
        $ver = DriverVer $d.DriverVersion
        If ($ver -eq '3.9.117.0') {$wut = $true}
        #$driverName = $d.name
        #Add-PrinterDriver -Name $driverName
    }
}
if ($wut -eq $false) {iDriver $nDvr}

$oDvr = @(
    'KONICA MINOLTA C364SeriesPCL',
    'KONICA MINOLTA 423SeriesPCL-8',
    'KONICA MINOLTA C364SeriesPS'
    )

$pp = Get-Printer
foreach ($p in $pp) {
    foreach ($d in $oDvr) {
        if ($p.DriverName -eq $d) {
            Set-Printer -Name $p.Name -DriverName $nDvr
        }
    }
}


# SIG # Begin signature block
# MIIO1QYJKoZIhvcNAQcCoIIOxjCCDsICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhnCdRK34gWf6Ct6AdHYbhI8z
# T6egggsnMIIEfTCCA2WgAwIBAgITFwAAAAS71Y6qvamh+QAAAAAABDANBgkqhkiG
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJpr4br5V6l+tP1boZrP
# q8t4pGDzMA0GCSqGSIb3DQEBAQUABIICAFIesfPfOIVFxBaSDP86NQN9Ab2ZSVqF
# MpBxa4Tc9aqypcyYBv6C6YjHhUPR/S503L1bv9lEWH8mylr2sXLBqISvkBcmlSoh
# H8/KM5sOO/Il0WVufRYrHbsZ/3R/JMHBCnSuEJw5vgvPhyOD9jX/g6mrlQJ1qBoh
# KygxW6BHJCpFon7YLGvIQUwpCp/NmCZT0nnbOjw7mv9AfIsRS7ccZij5NWC1KyNy
# 9HdOVudcRyrpRF3t0E5BFLISx4dY3bzn2torKmCGwJe9U/Bpe6j1mWmANTSdZQIX
# BTof8is9oWIKvGwSOUBITXWELbVW3VVzNna3ZCqsfr/O1G8tqURNwiE/VQAFwNrP
# oq1712x1k5cEELhNw7HGUrvFNVUOZrSLxFY/S997ruV8+U7y1cfg0dCQiXWIoSQN
# kOtNLV+E/x9HOfmGpguwB4yFvazLP6jUFNPTXSMcFKA2JmmKvJpzXpD714Ee7e5e
# OpMqchMWPmG1Fix+hFaCnT3ZbBEbKk3dqBi5i9E4wpPdvL/k25CeYkvdzH4GdW12
# 2YTX9eVAT9RvDrjKQbJNkkdLxlYVqhlR9vMZqFgzYDUsTRqQmz9vRZSaybw6t1X3
# z54r1+j1RZwoLoGVVH8Y8V8fOlbQJ9i8iy07nzmDVCUcpLUmGRilQbicOFbRvOn6
# j5y4cDifuFww
# SIG # End signature block
