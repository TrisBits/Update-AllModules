# Update-AllModules

[![Version Badge](https://img.shields.io/badge/Version-1.0.0-blue)](https://github.com/TrisBits/Update-AllModules/blob/master/src/Update-AllModules.ps1)
<!-- TOC -->

- [Update-AllModules](#update-allmodules)
  - [Description](#description)
  - [Example](#example)
  - [License](#license)

<!-- /TOC -->

## Description

Checks for all installed modules and updates them to the most current version.  The older versions are then uninstalled.

Must be executed with elevated priviledges to update modules for all users.
Will set the PowerShell Gallery as a trusted repository, when run with elevated priviledges.

## Example

Executing the following, will update all currently installed modules.

```powershell
Update-AllModules
```

Will provide Verbose messaging during execution.

```powershell
Update-AllModules -Verbose
```

## License

Copyright (c) TrisBits. All rights reserved.

Licensed under the [MIT](LICENSE) license.
