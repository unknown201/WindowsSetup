# ----------
# Variables
# ----------

# Chocolatey packages
$ChocoPackages = @(         'curl',
                            'discord',
                            'git',
                            'microsoft-windows-terminal',
                            'nodejs',
                            'nvidia-display-driver',
                            'postman',
                            'powershell-core',
                            'powertoys',
                            'streamdeck',
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
                            'unity'
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


# -------
# VS Code
# -------

# Theme
$VsCodeThemes | ForEach-Object { code --install-extension $_ }

# Icons
$VsCodeIcons | ForEach-Object { code --install-extension $_ }

# Extension (MS)
$VsCodeExtensionsMs | ForEach-Object { code --install-extension $_ }

# Extensions (custom)
$VsCodeExtensionsCustom | ForEach-Object { code --install-extension $_ }

# List extensions
code --list-extensions

# Show status
code --status


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
