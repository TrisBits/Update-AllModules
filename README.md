# Update-AllModules

![PSScriptAnalyzer](https://github.com/TrisBits/Update-AllModules/actions/workflows/powershell-analysis.yml/badge.svg)

<!-- TOC -->

- [Update-AllModules](https://github.com/TrisBits/Update-AllModules/blob/master/src/Update-AllModules.ps1)
  - [Description](#description)
  - [Example](#example)
  - [Notes](#notes)
  - [License](#license)

<!-- /TOC -->

## Description

Checks for all installed modules and updates them to the most current version.  The older versions are then uninstalled.

Must be executed with elevated priviledges to update modules for all users.
Will set the PowerShell Gallery as a trusted repository, when run with elevated priviledges.

## Example

Executing the following, will update all currently installed modules.

```powershell
.\Update-AllModules.ps1
```

Will provide Verbose messaging during execution.

```powershell
.\Update-AllModules -Verbose
```

## Notes

If you've downloaded the PowerShell script (or any other) and recieve a "not digitally signed" error due to your execution policy.
A simple solution is to execute the PowerShell command **[Unblock-File -Path](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file?view=powershell-7) `<ScriptPath>`**

## License

Copyright (c) TrisBits. All rights reserved.

Licensed under the [MIT](LICENSE) license.
