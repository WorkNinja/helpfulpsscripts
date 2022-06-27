If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}

#Credit - https://blogs.technet.microsoft.com/fieldcoding/2018/10/10/resetting-wmi-repository-dos-and-donts/
function DisableService([System.ServiceProcess.ServiceController]$svc)
{ Set-Service -Name $svc.Name -StartupType Disabled }
 
function EnableServiceAuto([System.ServiceProcess.ServiceController]$svc)
{ Set-Service -Name $svc.Name -StartupType Automatic }
 
function StopService([System.ServiceProcess.ServiceController]$svc)
{
   [string]$dep = ([string]::Empty)
 
   foreach ($depsvc in $svc.DependentServices)
   { $dep += $depsvc.DisplayName + ", " }
 
   Write-Host "Stopping $($svc.DisplayName) and its dependent services ($dep)"
 
   $svc.Stop()
 
   $svc.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped)
 
   Write-Host "Stopped $($svc.DisplayName)"
}
 
function StartService([System.ServiceProcess.ServiceController]$svc, [bool]$handleDependentServices)
{
   if ($handleDependentServices)
   { Write-Host "Starting $($svc.DisplayName) and its dependent services" }
 
   else
   { Write-Host "Starting $($svc.DisplayName)" }
 
   if (!$svc.Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running)
   {
      try
      {
         $svc.Start()
 
         $svc.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running)
      }
 
      catch { }
   }
 
   Write-Host "Started $($svc.DisplayName)"
    
   if ($handleDependentServices)
   {
       [System.ServiceProcess.ServiceController]$depsvc = $null;
 
      foreach ($depsvc in $svc.DependentServices)
      { 
        if ($depsvc.StartType -eq [System.ServiceProcess.ServiceStartMode]::Automatic)
        { StartService $depsvc $handleDependentServices }
      }
   }
} 
 
function RegSvr32([string]$path)
{
   Write-Host "Registering $path"
 
   regsvr32.exe $path /s
}
 
function RegisterMof([System.IO.FileSystemInfo]$item)
{
   [bool]$register = $true
 
   Write-Host "Inspecting: $($item.FullName)"
 
   if ($item.Name.ToLowerInvariant().Contains('uninstall'))
   {
      $register = $false
      Write-Host "Skipping - uninstall file: $($item.FullName)"
   }
 
   elseif ($item.Name.ToLowerInvariant().Contains('remove'))
   {
      $register = $false
      Write-Host "Skipping - remove file: $($item.FullName)"
   }
 
   else
   {
      $txt = Get-Content $item.FullName
  
      if ($txt.Contains('#pragma autorecover'))
      {
         $register = $false
         Write-Host "Skipping - autorecover: $($item.FullName)"
      }
 
      elseif ($txt.Contains('#pragma deleteinstance'))
      {
         $register = $false
         Write-Host "Skipping - deleteinstance: $($item.FullName)"
      }
 
      elseif ($txt.Contains('#pragma deleteclass'))
      {
         $register = $false
         Write-Host "Skipping - deleteclass: $($item.FullName)"
      }
   }
 
   if ($register)
   {
      Write-Host "Registering $($item.FullName)"
      mofcomp $item.FullName
   }
}
 
function HandleFSO([System.IO.FileSystemInfo]$item, [string]$targetExt)
{
   if ($item.Extension -ne [string]::Empty)
   {
      if ($targetExt -eq 'dll')
      {
         if ($item.Extension.ToLowerInvariant() -eq '.dll')
         { RegSvr32 $item.FullName }
      }
 
      elseif ($targetExt -eq 'mof')
      {
         if (($item.Extension.ToLowerInvariant() -eq '.mof') -or ($item.Extension.ToLowerInvariant() -eq '.mfl'))
         { RegisterMof $item }
      }
   }
}
 
# get Winmgmt service
[System.ServiceProcess.ServiceController]$wmisvc = Get-Service 'winmgmt'
 
# disable winmgmt service
DisableService $wmisvc
 
# stop winmgmt service
StopService $wmisvc
 
# get wbem folder
[string]$wbempath = [Environment]::ExpandEnvironmentVariables("%windir%\system32\wbem")
 
[System.IO.FileSystemInfo[]]$itemlist = Get-ChildItem $wbempath -Recurse | Where-Object { $_.FullName.Contains('AutoRecover') -ne $true}
 
[System.IO.FileSystemInfo]$item = $null
 
# walk dlls
foreach ($item in $itemlist)
{ HandleFSO $item 'dll' }
 
# call /regserver method on WMI private server executable
wmiprvse /regserver
 
# call /resetrepository method on WinMgmt service executable
winmgmt /resetrepository
 
# enable winmgmt service
EnableServiceAuto $wmisvc
 
# start winmgmt service
StartService $wmisvc $true
 
# walk MOF / MFLs
foreach ($item in $itemlist)
{ HandleFSO $item 'mof' }
# SIG # Begin signature block
# MIId2wYJKoZIhvcNAQcCoIIdzDCCHcgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUm9kZkbLFbgyTJ7oh12NhhJAt
# TkCgghgeMIIDJzCCAg+gAwIBAgIQa066y01m+bBONwK13T0+hTANBgkqhkiG9w0B
# AQ0FADAmMSQwIgYDVQQDExtjb3JwLmNyeWUtbGVpa2UuY29tIFJvb3QgQ0EwHhcN
# MTgxMjA0MjMxMTM1WhcNMjgxMjA0MjMyMTM1WjAmMSQwIgYDVQQDExtjb3JwLmNy
# eWUtbGVpa2UuY29tIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCpagW9HYtA8VXXxamY01hmJrjULKRbn0S/V6JIx58cp1NJ9glOuzUJq96B
# VGWVqOsj3sj86mxv72gn7Eem9jrPIaE/2JaexsQfddPf9iJVtvfb99Rr2lZMKX6p
# nacLgzNUTfCyGHIMgmPlEwtq9gQ4sOXcgE/i/ntI3SM7fnsvft1VIfMelK4Y1s93
# hMzDvhXPIak0Fg3bbTlBzYBtmtntPD+PhqtT8bDnb5OOAnt4ZU43pUIHgUe48q9A
# hKHbx9LlqgXRa7Sliqwoq6b/yc2XEYTUGyzxyd1VQYSDc5uBXCO/E9cvuYFs1Q+a
# wjVCdKYtTAJX+yMRCYOthO1luIoBAgMBAAGjUTBPMAsGA1UdDwQEAwIBhjAPBgNV
# HRMBAf8EBTADAQH/MB0GA1UdDgQWBBTRu7cWbuKuRWbvsM1q4i3XjnWN8jAQBgkr
# BgEEAYI3FQEEAwIBADANBgkqhkiG9w0BAQ0FAAOCAQEACrXHP6vqZndKy2KwMbWc
# YzyQfNb8rxEJr0/aI4CkFJP0bAAMW+7ycPNocqrfcmPVRRNEVvZZVf//x7iRVwT6
# fuG7psLjiHXleJ6sakg2OsCiD4nI3/f86etXKqkf/yCLjA6aLwr3g4BT7lZTMYXQ
# 0ekjzMrwCM3x7NEN5Fpmw8nzZhiY02e2bEeyYRBfkcgNY/GG8DKxDK5nDrLtEwnv
# KargK4N7R6nzuERiTQh6TVksqSD57S15d7IGL9Y1IO7sfVrd02je+5tjmdy9yxO6
# cryzSMbYKmVY+lkSZx5PibkxiIONFM8eVc5VvVwnWZbWcSQkLQBXlhC5kAs7/WUU
# izCCA+4wggNXoAMCAQICEH6T6/t8xk5Z6kuad9QG/DswDQYJKoZIhvcNAQEFBQAw
# gYsxCzAJBgNVBAYTAlpBMRUwEwYDVQQIEwxXZXN0ZXJuIENhcGUxFDASBgNVBAcT
# C0R1cmJhbnZpbGxlMQ8wDQYDVQQKEwZUaGF3dGUxHTAbBgNVBAsTFFRoYXd0ZSBD
# ZXJ0aWZpY2F0aW9uMR8wHQYDVQQDExZUaGF3dGUgVGltZXN0YW1waW5nIENBMB4X
# DTEyMTIyMTAwMDAwMFoXDTIwMTIzMDIzNTk1OVowXjELMAkGA1UEBhMCVVMxHTAb
# BgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBU
# aW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQCxrLNJVEuXHBIK2CV5kSJXKm/cuCbEQ3Nrwr8uUFr7FMJ2
# jkMBJUO0oeJF9Oi3e8N0zCLXtJQAAvdN7b+0t0Qka81fRTvRRM5DEnMXgotptCvL
# mR6schsmTXEfsTHd+1FhAlOmqvVJLAV4RaUvic7nmef+jOJXPz3GktxK+Hsz5HkK
# +/B1iEGc/8UDUZmq12yfk2mHZSmDhcJgFMTIyTsU2sCB8B8NdN6SIqvK9/t0fCfm
# 90obf6fDni2uiuqm5qonFn1h95hxEbziUKFL5V365Q6nLJ+qZSDT2JboyHylTkhE
# /xniRAeSC9dohIBdanhkRc1gRn5UwRN8xXnxycFxAgMBAAGjgfowgfcwHQYDVR0O
# BBYEFF+a9W5czMx0mtTdfe8/2+xMgC7dMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEF
# BQcwAYYWaHR0cDovL29jc3AudGhhd3RlLmNvbTASBgNVHRMBAf8ECDAGAQH/AgEA
# MD8GA1UdHwQ4MDYwNKAyoDCGLmh0dHA6Ly9jcmwudGhhd3RlLmNvbS9UaGF3dGVU
# aW1lc3RhbXBpbmdDQS5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/
# BAQDAgEGMCgGA1UdEQQhMB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC0x
# MA0GCSqGSIb3DQEBBQUAA4GBAAMJm495739ZMKrvaLX64wkdu0+CBl03X6ZSnxaN
# 6hySCURu9W3rWHww6PlpjSNzCxJvR6muORH4KrGbsBrDjutZlgCtzgxNstAxpghc
# Knr84nodV0yoZRjpeUBiJZZux8c3aoMhCI5B6t3ZVz8dd0mHKhYGXqY4aiISo1EZ
# g362MIIEfTCCA2WgAwIBAgITFwAAAAS71Y6qvamh+QAAAAAABDANBgkqhkiG9w0B
# AQ0FADAmMSQwIgYDVQQDExtjb3JwLmNyeWUtbGVpa2UuY29tIFJvb3QgQ0EwHhcN
# MTgxMjA2MjI1NjE4WhcNMjMxMjA2MjMwNjE4WjBgMRMwEQYKCZImiZPyLGQBGRYD
# Y29tMRowGAYKCZImiZPyLGQBGRYKY3J5ZS1sZWlrZTEUMBIGCgmSJomT8ixkARkW
# BGNvcnAxFzAVBgNVBAMTDlN1YiBJc3N1aW5nIENBMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEAzzOZprhwPLPE2E9DuSVTk9b4Ok8yl8Vu0BBvYiuzkVGg
# 7NSPGCE6vyZrgjQP2AySPA9xHHZLZnlarDPdmB/5gL4YdP6nBG7hTFz+SSQjbYIY
# E0MgIafSwbhRfhb2vTRFU3UbDb+1XXy9FT7VMuxnWpocmvk52Q04AxXL4UMsbYjA
# ZaQ5Ezf77JrPQxtGV/eCCTrafRuy7n5XyfYNR89fS3CnLGvCa+2amn1G29XDoZlm
# lSWoaHMI1IuH9BZ6hHz0poWAQMG5c3PrRZuBIM+wK3hbXBpyikNkLjofi3D+uOq5
# FBL+J4nnrsfRuNmIFfgTCNi9QO31I+aceKegRX8WtwIDAQABo4IBaDCCAWQwEAYJ
# KwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFFG+e4v9gvTNsw8OgiqGwjZBmGRqMBkG
# CSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8E
# BTADAQH/MB8GA1UdIwQYMBaAFNG7txZu4q5FZu+wzWriLdeOdY3yMF4GA1UdHwRX
# MFUwU6BRoE+GTWh0dHA6Ly9jcmwuY29ycC5jcnllLWxlaWtlLmNvbS9DZXJ0RW5y
# b2xsL2NvcnAuY3J5ZS1sZWlrZS5jb20lMjBSb290JTIwQ0EuY3JsMHcGCCsGAQUF
# BwEBBGswaTBnBggrBgEFBQcwAoZbaHR0cDovL2NybC5jb3JwLmNyeWUtbGVpa2Uu
# Y29tL0NlcnRFbnJvbGwvTUVNLVZNLVJPT1RDQV9jb3JwLmNyeWUtbGVpa2UuY29t
# JTIwUm9vdCUyMENBLmNydDANBgkqhkiG9w0BAQ0FAAOCAQEACRsrA2SMcZ+bSNWs
# SQajq2b/03Whv52sxQ9OScWf1181sRxkPtQCxCj8Y3T6iq3iV4nPqyisvdBwj25i
# 50mROlVxDWpl9GnHpIg3Q+HPJf5NFFNK1cluoAgUMifh/usthvoF9DNFHOwl8aBe
# QCP+8P+oVFQIJiwnz7azKREiqeJfSTPk+nzQvsc5dpUw/GdIA2pq8nlaIiLSvllT
# Ryr1KLfi22T/UnTB8Pa89j4VfMUMLWXldirpqgl1CSE2dxo+qgpho7xfb8R/ozno
# UeMpbC4h2Y1CcRRToy4rHJMblr5mgqIw5tmYOlSbeBKIqWoyLOtXvt0JLA5mH4B3
# SBMZszCCBKMwggOLoAMCAQICEA7P9DjI/r81bgTYapgbGlAwDQYJKoZIhvcNAQEF
# BQAwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9u
# MTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0g
# RzIwHhcNMTIxMDE4MDAwMDAwWhcNMjAxMjI5MjM1OTU5WjBiMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xNDAyBgNVBAMTK1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgU2lnbmVyIC0gRzQwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCiYws5RLi7I6dESbsO/6HwYQpTk7CY260s
# D0rFbv+GPFNVDxXOBD8r/amWltm+YXkLW8lMhnbl4ENLIpXuwitDwZ/YaLSOQE/u
# hTi5EcUj8mRY8BUyb05Xoa6IpALXKh7NS+HdY9UXiTJbsF6ZWqidKFAOF+6W22E7
# RVEdzxJWC5JH/Kuu9mY9R6xwcueS51/NELnEg2SUGb0lgOHo0iKl0LoCeqF3k1tl
# w+4XdLxBhircCEyMkoyRLZ53RB9o1qh0d9sOWzKLVoszvdljyEmdOsXF6jML0vGj
# G/SLvtmzV4s73gSneiKyJK4ux3DFvk6DJgj7C72pT5kI4RAocqrNAgMBAAGjggFX
# MIIBUzAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4GA1Ud
# DwEB/wQEAwIHgDBzBggrBgEFBQcBAQRnMGUwKgYIKwYBBQUHMAGGHmh0dHA6Ly90
# cy1vY3NwLndzLnN5bWFudGVjLmNvbTA3BggrBgEFBQcwAoYraHR0cDovL3RzLWFp
# YS53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNlcjA8BgNVHR8ENTAzMDGgL6At
# hitodHRwOi8vdHMtY3JsLndzLnN5bWFudGVjLmNvbS90c3MtY2EtZzIuY3JsMCgG
# A1UdEQQhMB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC0yMB0GA1UdDgQW
# BBRGxmmjDkoUHtVM2lJjFz9eNrwN5jAfBgNVHSMEGDAWgBRfmvVuXMzMdJrU3X3v
# P9vsTIAu3TANBgkqhkiG9w0BAQUFAAOCAQEAeDu0kSoATPCPYjA3eKOEJwdvGLLe
# Jdyg1JQDqoZOJZ+aQAMc3c7jecshaAbatjK0bb/0LCZjM+RJZG0N5sNnDvcFpDVs
# fIkWxumy37Lp3SDGcQ/NlXTctlzevTcfQ3jmeLXNKAQgo6rxS8SIKZEOgNER/N1c
# dm5PXg5FRkFuDbDqOJqxOtoJcRD8HHm0gHusafT9nLYMFivxf1sJPZtb4hbKE4Ft
# AC44DagpjyzhsvRaqQGvFZwsL0kb2yK7w/54lFHDhrGCiF3wPbRRoXkzKy57udwg
# CRNx62oZW8/opTBXLIlJP7nPf8m/PiJoY1OavWl0rMUdPH+S4MO8HNgEdTCCB9Uw
# gga9oAMCAQICExAAAAASNADQv56BQ1AAAAAAABIwDQYJKoZIhvcNAQENBQAwYDET
# MBEGCgmSJomT8ixkARkWA2NvbTEaMBgGCgmSJomT8ixkARkWCmNyeWUtbGVpa2Ux
# FDASBgoJkiaJk/IsZAEZFgRjb3JwMRcwFQYDVQQDEw5TdWIgSXNzdWluZyBDQTAe
# Fw0xOTAxMTAyMTAzMzdaFw0yMTAxMDkyMTAzMzdaMHExEzARBgoJkiaJk/IsZAEZ
# FgNjb20xGjAYBgoJkiaJk/IsZAEZFgpjcnllLWxlaWtlMRQwEgYKCZImiZPyLGQB
# GRYEY29ycDEOMAwGA1UEAxMFVXNlcnMxGDAWBgNVBAMTD0Nhc2V5IEtyb2xld2lj
# ejCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMxG7/qJ0RJA2TZhrkgl
# gs9uVQ+dwNSM5AUdQGps0VORYLly9dk3ZiMVwHvkXIS6SJp8dkOhYKeTj+dBKA6k
# McRUqdd7wGOoAYCWsyDs2DCzqlkECAYPy6olPitvav/Bl1Yw3hdS8VCwANgPyv14
# lyhKeRlSuYjgRHfPC3UmFdTlSTjHMYazMqdukJAvvWxuI3dbSCvOCp5KXePr2iFz
# W8Ap9OygIwa1MHDVAELxwT+RL/US/cdcED8wMgR/wf1d3ZgrZ7aYbX79jKvWzqf7
# JRwgFfJitDDkthmBDhsmmNkKWZdJDd73veQwyv/iraRw4ifrPya0HUgU39OOaIzA
# 4CMfqlcUjGL1ajB6Qp7F38mx7DTj2aDM4wk1D48puaM5kCFR4s69dtKb8fNZcTKW
# yTJgn6Tmdqa9sdDEI+412XAkRuOk94szweYk/tIznUX21Ro9epdMpiPPmXTgFW/5
# IS+RTa4ykOGikTGl0AVYEQDlSrv4x1QSDNyw8GsLxYRREVGmJhR+KyO5Fz9YGzBy
# 8Trr6JHaB90DSz8HOgTrQI0yUWB5wtyYSyG/ADIheYOSy0jFXKg/7iD8w7AOYvS4
# Byfr1ygdGBFV0ATHRg9uUkzq2iYHMsVtHCvAGmzod1sqjIEzRSmcnVi8YvpSZxWL
# nszA2TNCIlgcIJrtbxxnfQhTAgMBAAGjggN1MIIDcTA+BgkrBgEEAYI3FQcEMTAv
# BicrBgEEAYI3FQiEx9pygv6ZIIPJjzWChvAjgdXYIYEwgfL6JYKu2WACAWQCAQcw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsGCSsGAQQBgjcV
# CgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFJzkPRe1JPqsh03J6/i/Wli1vsoL
# MB8GA1UdIwQYMBaAFFG+e4v9gvTNsw8OgiqGwjZBmGRqMIIBJwYDVR0fBIIBHjCC
# ARowggEWoIIBEqCCAQ6GgclsZGFwOi8vL0NOPVN1YiUyMElzc3VpbmclMjBDQSxD
# Tj1NRU0tVk0tU1VCQ0EsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2Vz
# LENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Y29ycCxEQz1jcnllLWxl
# aWtlLERDPWNvbT9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0
# Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnSGQGh0dHA6Ly9jcmwuY29ycC5jcnll
# LWxlaWtlLmNvbS9DZXJ0RW5yb2xsL1N1YiUyMElzc3VpbmclMjBDQS5jcmwwggFA
# BggrBgEFBQcBAQSCATIwggEuMIG8BggrBgEFBQcwAoaBr2xkYXA6Ly8vQ049U3Vi
# JTIwSXNzdWluZyUyMENBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNl
# cyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNvcnAsREM9Y3J5ZS1s
# ZWlrZSxEQz1jb20/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRp
# ZmljYXRpb25BdXRob3JpdHkwbQYIKwYBBQUHMAKGYWh0dHA6Ly9jcmwuY29ycC5j
# cnllLWxlaWtlLmNvbS9DZXJ0RW5yb2xsL01FTS1WTS1TVUJDQS5jb3JwLmNyeWUt
# bGVpa2UuY29tX1N1YiUyMElzc3VpbmclMjBDQS5jcnQwPgYDVR0RBDcwNaAzBgor
# BgEEAYI3FAIDoCUMI2Nhc2V5Lmtyb2xld2ljekBjb3JwLmNyeWUtbGVpa2UuY29t
# MA0GCSqGSIb3DQEBDQUAA4IBAQBnr2wEGPz3JUOpqKSCV4jBRe9MUCwKEzgM5/9z
# 6XcH8a32/sOcJVNP93JMzqjqAP2m4NZo1QUjewAoIC+nilO0b8EF1xWbXEWqQm2w
# 4E13MmO8kSKfIXXl0tNB+JEZr35fAZ1wiXSrmaUpSDOsjMobE3YqqBxHye+viJEe
# GCTXWgxcgb6fwEl4ydrXr2I1LCHLH1Ff5SF3scsVXMT1PjWBfMGPac8L0UXcBzIc
# rjzfvZwqde8lTqd88s3Ba2bLWvOU0o95Y1EIk+QkclGkYfZKE5e6qYSuyXvpmb3+
# k8xzCLG25RoV1GW3eNuUH5UUUBzDlv9uOsrrYLCExPkUEM2QMYIFJzCCBSMCAQEw
# dzBgMRMwEQYKCZImiZPyLGQBGRYDY29tMRowGAYKCZImiZPyLGQBGRYKY3J5ZS1s
# ZWlrZTEUMBIGCgmSJomT8ixkARkWBGNvcnAxFzAVBgNVBAMTDlN1YiBJc3N1aW5n
# IENBAhMQAAAAEjQA0L+egUNQAAAAAAASMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3
# AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS/c6q1MNEx
# pdxaTij6HseAk2JjQDANBgkqhkiG9w0BAQEFAASCAgCkaqeHo5uyb2/uXGRZSLum
# JUUMEBZZmBU6189wywyDB4YUXIEyBr/CEC+HMCfJXodwU2qRMjoP52NXbD+dfWpp
# nyBuD3b+Dy75GDvRPOaF8b1U4nxMnPRlEgpaGHasb97d3mMDt6OkfjcHFdxzixCq
# 1ZuhyxYG9R7REG72HpdPFLsATIEf3cElY4yUjy71rLr0Z6OzK5s175q+U6VPA9ze
# j8CyGns3TSYMQVQ4ev3YtdUs6ObER9vn0FGcV5cEAvxFg2ip/hIgVZreii7rjAyP
# GqyDwThn4JbfGJsnhlPww/mU6ZObm3XfOdWKS6PeAw/npWcFz+ZEkLapDKoVHaSX
# 32BisU/GBJISHtu+fNqrLPIF+v06u3s0jRL5tOeBvHogAFe1TcXDZlRALemenCE8
# S9IH374fh1bXAZr37lLquwD6DyuUYRwtQXviiHq8NlGt2DM7Gc3Qxda4hw84HrCo
# 6jFP27xt2OcXV4BZGCzz1muf2XktN3+4Nns3c6AJ3XSZWeYi++gNuNrElf9AyQyZ
# 5uQxr1ScNQbXeDMUQcr3ARV2BTCxxHAibylRoZgHW5RUpZ8P5IMWEEYpm3Eyf4XK
# hBiv31NEpuObUe1N1SXnXMjfxk6m2TjSlpVmp/EszgFDT4Qv9nuVyLiMzCUOAElH
# WOVEFIhkhn5hRF6KnTns9aGCAgswggIHBgkqhkiG9w0BCQYxggH4MIIB9AIBATBy
# MF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEw
# MC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcy
# AhAOz/Q4yP6/NW4E2GqYGxpQMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJ
# KoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xOTEyMDUyMDEzMDRaMCMGCSqGSIb3
# DQEJBDEWBBR/CQ9eciqsjVzzz4hn13F7ZXRiiTANBgkqhkiG9w0BAQEFAASCAQBL
# fFCMD9atjofKmlsln8x8Wk55hq3gZ/h2FTMoSsogCxJJTz1oYPKyfHC6Hz/WL53B
# vZEqolRQ7uqpxTkXbuEIzJBNBkdB6i/VBcKTM4CLlys0011xGrqrbvI+loEAtrVI
# 5/csE2lAUHTgcfr/uLvvPQvPJkoJqTwQCY8Wlr+Y1Cco9lVqH1YI7nbpi6mRlJd1
# TO7gunU4Qd7HsqjzsXKJIO+bVnfNOrCWx7a0mhWWx7dWKHZ55NKsLQbSKA9/iOML
# fPZHa0Q+G4UFsgILVL7CLdaMewNVVVsSuA0gkTuiLtinztddYEhZzqK12weGGg/5
# E/oX5Nha3PO5xmJIBygB
# SIG # End signature block
