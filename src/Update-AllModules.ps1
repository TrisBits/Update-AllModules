<#
    .SYNOPSIS
    Updates all installed modules and then uninstalls previous versions

    .DESCRIPTION
    Checks for all installed modules and updates them to the most current version.  The older versions are then uninstalled.
    Will set the PowerShell Gallery as a trusted repository if run with elevated priviledges.

     .INPUTS
    None

    .OUTPUTS
    None

    .EXAMPLE

    .NOTES
    Author: TrisBits
    GitHub: https://github.com/TrisBits/Update-AllModules
    Created: 2020-07-26
    License: MIT
    Version: 1.0.0
#>

[CmdletBinding()]
param (
)

BEGIN {
    # Checks if any additonal PowerShell sessions are running, as they can prevent modules from being uninstalled.  Will terminate script if extra sessions found.
    if ((Get-Process -Name powershell, pwsh -OutVariable Sessions -ErrorAction SilentlyContinue).Count -gt 1) {
        Write-Error -Message "Update of Modules Aborted. Please close all other PowerShell sessions before continuing. There are currently $($Sessions.Count) PowerShell sessions running."
        Exit
    }

    # Check if the current user is elevated.
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    Write-Verbose -Message "Current session elevated: $isAdmin"

    # If an elevated user, checks if PSGallery is trusted.  If not PSGallery will be set to Trusted, so Update module will not prompt (Force would reinstall reguardless of version).
    $repository = Get-PSRepository
    if (($isAdmin -eq $true) -and ($repository.Name -eq 'PSGallery' -and $repository.InstallationPolicy -eq 'Untrusted')) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        Write-Verbose -Message "Set PSGallery as Trusted Repository"
    }
}

PROCESS {
    $allInstalledModules = Get-InstalledModule
    [int]$i = 100 / $allInstalledModules.Count

    foreach ($installedModule in $allInstalledModules) {
        Write-Progress -Activity 'Update All Modules in Progress' -Status "$i% Complete:" -PercentComplete $i -CurrentOperation "Processing Module: $($installedModule.Name)"
        $i++

        # Get information about the newest version in the repository
        if (-not(Find-Module -Name $installedModule.Name -ErrorAction SilentlyContinue)) {
            Write-Warning -Message "Module $($installedModule.Name) is no longer available or Repository missing."
        }
        else {
            $repositoryModule = Find-Module -Name $installedModule.Name
            Write-Verbose -Message "Processing Module: $($installedModule.Name),  Current Installed Version: $($installedModule.Version), Latest Available Version: $($repositoryModule.Version)"

            # Skip the module if it is already the latest version
            if ($installedModule.Version -ne $repositoryModule.Version) {
                if (($installedModule.InstalledLocation -notlike "*$env:USERPROFILE*") -and ($isAdmin -eq $false)) {
                    Write-Warning -Message "Module Update aborted. $($installedModule.Name) exists in a system path. PowerShell must be run elevated as an admin to update it."
                }
                else {
                    Write-Verbose -Message "Updating Module: $($installedModule.Name) to Version $($repositoryModule.Version)"
                    Update-Module -Name $installedModule.Name
                }


                if (-not(Get-InstalledModule -Name $installedModule.Name -RequiredVersion $installedModule.Version -ErrorAction SilentlyContinue)) {
                    Write-Warning -Message "Module Uninstall aborted. $($installedModule.Name) version $($installedModule.Version) not found."
                }
                elseif (($installedModule.InstalledLocation -notlike "*$env:USERPROFILE*") -and ($isAdmin -eq $false)) {
                    Write-Warning -Message "Module Uninstall aborted. $($installedModule.Name) version $($installedModule.Version) exists in a system path. PowerShell must be run elevated as an admin to remove it."
                }
                else {
                    Write-Verbose -Message "Uninstalling Old Versions for Module: $($installedModule.Name)"
                    Try {
                        # ErrorAction Stop is used for Uninstall-Module to Catch any non-terminating errors due to an in use module
                        Get-InstalledModule -Name $installedModule.Name -AllVersions | Where-Object { $_.Version -ne $repositoryModule.Version } | Uninstall-Module -Force -ErrorAction Stop
                    }
                    Catch {
                        Write-Warning -Message "$($installedModule.Name) version: $($installedModule.Version) may require manual uninstallation."
                    }
                }
            }
        }
    }
}
