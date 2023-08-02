# ----------
# Variables
# ----------
Function Log([String] $Message)
{
    If (($Message -ne $null) -and ($Message.Length -gt 0))
    {
        $Time = Get-Date -DisplayHint Time
        Write-Host "[$Time] [LOG] > $Message" -ForegroundColor Cyan
    }
}

# Chocolatey packages
$ChocoPackages = @(         'curl',
                            'git',
                            'microsoft-windows-terminal',
                            'nodejs',
                            'nvidia-display-driver',
                            'postman',
                            'powershell-core',
                            'powertoys',
                            'spotify',
                            'vlc',
                            'vscode',
                            'windirstat',
                            'visualstudio2022professional',
                            'notepadplusplus',
                            'winscp',
                            'putty',
                            'winrar',
                            'googlechrome',
                            'qgis',
                            'steam',
                            'unity',
                            'paint.net'
                            )

# PowerShell modules
$PwshModules = @(           'PSReadLine',
                            'Terminal-Icons',
                            'oh-my-posh',
                            'posh-git')

# VS Code extensions
$VsCodeThemes = @(          'GitHub.github-vscode-theme')

$VsCodeIcons = @(           'vscode-icons-team.vscode-icons')

$VsCodeExtensionsMs = @(    'docsmsft.docs-markdown',
                            'ms-dotnettools.csharp',
                            'ms-dotnettools.vscode-dotnet-runtime',
                            'ms-vscode-remote.remote-containers',
                            'ms-vscode-remote.remote-ssh',
                            'ms-vscode-remote.remote-ssh-edit',
                            'ms-vscode-remote.remote-wsl',
                            'ms-vscode-remote.vscode-remote-extensionpack',
                            'ms-vscode.powershell')

$VsCodeExtensionsCustom = @('DavidAnson.vscode-markdownlint',
                            'streetsidesoftware.code-spell-checker')

         
# ----------
# Chocolatey
# ----------

# Install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Show version
choco info
choco list -li

# Confirm future prompts automatically
choco feature enable -n allowGlobalConfirmation

# Show preinstalled apps
Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName, Version, NonRemovable, SignatureKind | Format-Table

# Uninstall Edge stable channel
$EdgeVersion = (Get-AppxPackage "Microsoft.MicrosoftEdge.Stable" -AllUsers).Version
$EdgeSetupPath = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + '\Microsoft\Edge\Application\' + $EdgeVersion + '\Installer\setup.exe'
& $EdgeSetupPath --uninstall --system-level --verbose-logging --force-uninstall

# Uninstall Windows Terminal, manage it through Chocolatey
Get-AppxPackage Microsoft.WindowsTerminal | Remove-AppPackage

# Install choco packages
$ChocoPackages | ForEach-Object { choco install $_ }

# Show installed packages
choco list -li

# ----------
# PowerShell
# ----------

# Install Package Management provider
Install-PackageProvider -Name NuGet -Force;

# Install modules
$PwshModules | ForEach-Object { Install-Module -Name $_ -Force -Verbose }

# Import modules
$PwshModules | ForEach-Object { Import-Module -Name $_  -Force -Verbose }

# List installed modules
Get-Module

Add-WUServiceManager -MicrosoftUpdate
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot -Force


    Log("Disabling Bing Search in Start Menu...")
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
    Log("Stopping and disabling Windows Search indexing service...")
    Stop-Service "WSearch" -WarningAction SilentlyContinue
    Set-Service "WSearch" -StartupType Disabled
    Log("Hiding Taskbar Search icon / box...")
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
    Log("Disabling Cortana...")
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
    Stop-Process -Name SearchApp -Force
    Stop-Process -Name explorer -Force
    Log("Disabled Cortana")

    Log("Disabling OneDrive...")
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
    Log("Uninstalling OneDrive...")
    Stop-Process -Name *onedrive* -ErrorAction SilentlyContinue -Force
    Start-Sleep -Seconds 2
    $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
    If (!(Test-Path $onedrive)) {
        $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
    }
    Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
    Start-Sleep -Seconds 2
    Restart-Process -Process "explorer" -Restart -RestartDelay 5
    Start-Sleep -Seconds 2
    If (!(Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    }
    Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
    If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -gt 0) {
        [Void][System.Windows.Forms.MessageBox]::Show(
            "Hey, you still have your files in OneDrive folder!", "", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }
    Log("Disabled OneDrive")
    
# Disable Tailored Experiences With Diagnostic Data
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -type "Dword" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value "0"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -type "Dword" -Name "HideFileExt" -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -type "Dword" -Name "SearchboxTaskbarMode" -Value "0"

$ProgressPreference = 'SilentlyContinue'
Get-AppxPackage -allusers *WindowsStore* | Remove-AppxPackage -allusers
Invoke-WebRequest -Uri  https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile .\Microsoft.VCLibs.x64.14.00.Desktop.appx 
Invoke-WebRequest -Uri  https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3 -OutFile .\microsoft.ui.xaml.2.7.3.nupkg.zip  
Expand-Archive -Path .\microsoft.ui.xaml.2.7.3.nupkg.zip -Force 
Add-AppXPackage -Path .\microsoft.ui.xaml.2.7.3.nupkg\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx; Add-AppXPackage -Path .\Microsoft.VCLibs.x64.14.00.Desktop.appx
Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile .\MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Add-AppXPackage -Path .\MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle

winget uninstall cortana --accept-source-agreements --silent

::Skype
winget uninstall skype --accept-source-agreements --silent

::Camera
winget uninstall Microsoft.WindowsCamera_8wekyb3d8bbwe --accept-source-agreements --silent

::Sketch
::winget uninstall Microsoft.ScreenSketch_8wekyb3d8bbwe --accept-source-agreements --silent

::Xbox Applications
winget uninstall Microsoft.GamingApp_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxApp_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.Xbox.TCUI_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxIdentityProvider_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxGamingOverlay_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxGameOverlay_8wekyb3d8bbwe --accept-source-agreements --silent

::Groove Music
winget uninstall Microsoft.ZuneMusic_8wekyb3d8bbwe --accept-source-agreements --silent

::Feedback Hub
winget uninstall Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe --accept-source-agreements --silent

::Microsoft-Tips...
winget uninstall Microsoft.Getstarted_8wekyb3d8bbwe --accept-source-agreements --silent

::3D Viewer
winget uninstall 9NBLGGH42THS --accept-source-agreements --silent

:: 3D Builder
winget uninstall Microsoft.3DBuilder_8wekyb3d8bbwe --accept-source-agreements --silent

::MS Solitaire
winget uninstall Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe --accept-source-agreements --silent

::Paint-3D
winget uninstall 9NBLGGH5FV99 --accept-source-agreements --silent

::Weather 
winget uninstall Microsoft.BingWeather_8wekyb3d8bbwe --accept-source-agreements --silent

::Mail / Calendar
winget uninstall microsoft.windowscommunicationsapps_8wekyb3d8bbwe --accept-source-agreements --silent

::Your Phone
winget uninstall Microsoft.YourPhone_8wekyb3d8bbwe --accept-source-agreements --silent

::People
winget uninstall Microsoft.People_8wekyb3d8bbwe --accept-source-agreements --silent

::MS Pay 
winget uninstall Microsoft.Wallet_8wekyb3d8bbwe --accept-source-agreements --silent

::MS Maps
winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe --accept-source-agreements --silent

::OneNote
winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe --accept-source-agreements --silent

::MS Office
winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe --accept-source-agreements --silent

::Voice Recorder
winget uninstall Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe --accept-source-agreements --silent

::Movies
winget uninstall Microsoft.ZuneVideo_8wekyb3d8bbwe --accept-source-agreements --silent

::Mixed Reality-Portal
winget uninstall Microsoft.MixedReality.Portal_8wekyb3d8bbwe --accept-source-agreements --silent

::Sticky Notes...
winget uninstall Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe --accept-source-agreements --silent

::Get Help
winget uninstall Microsoft.GetHelp_8wekyb3d8bbwe --accept-source-agreements --silent

::OneDrive
winget uninstall Microsoft.OneDrive --accept-source-agreements --silent

::Windows 11 Bloatware
:: Messages opérateur Windows
winget uninstall Microsoft.Messaging_8wekyb3d8bbwe --accept-source-agreements --silent
:: print 3D
winget uninstall Microsoft.Print3D_8wekyb3d8bbwe --accept-source-agreements --silent
:: One Connect
winget uninstall Microsoft.OneConnect_8wekyb3d8bbwe --accept-source-agreements --silent																   
::Microsoft TO Do
winget uninstall Microsoft.Todos_8wekyb3d8bbwe --accept-source-agreements --silent
::Power Automate
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent
::Bing News
winget uninstall Microsoft.BingNews_8wekyb3d8bbwe --accept-source-agreements --silent
::Microsoft Teams
winget uninstall MicrosoftTeams_8wekyb3d8bbwe --accept-source-agreements --silent
::Microsoft Family
winget uninstall MicrosoftCorporationII.MicrosoftFamily_8wekyb3d8bbwe --accept-source-agreements --silent
::Quick Assist
winget uninstall MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe --accept-source-agreements --silent
::Third-Party Preinstalled bloat
winget uninstall disney+ --accept-source-agreements --silent
winget uninstall Clipchamp.Clipchamp_yxz26nhyzhsrt --accept-source-agreements --silent
::WhatsApp
winget uninstall 5319275A.WhatsAppDesktop_cv1g1gvanyjgm --accept-source-agreements --silent
::Microsoft Store
winget uninstall Microsoft.WindowsStore_8wekyb3d8bbwe --accept-source-agreements --silent
:: Other stuff
winget uninstall Microsoft.HEVCVideoExtension_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.LanguageExperiencePackfr-FR_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.RawImageExtension_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.StorePurchaseApp_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.VP9VideoExtensions_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.WebMediaExtensions_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.WindowsAlarms_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.WindowsCamera_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall MicrosoftWindows.Client.WebExperiencecw5n1h2txyewy --accept-source-agreements --silent

:: Sometimes it is not installed
:: Screen Capture
winget install --id 9MZ95KL8MR0L --accept-source-agreements --silent --accept-package-agreements
::Photo
winget install --id 9WZDNCRFJBH4 --accept-source-agreements --silent --accept-package-agreements
