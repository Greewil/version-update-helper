# version-update-helper
[![release](https://badgen.net/github/release/Greewil/version-update-helper/stable)](https://github.com/Greewil/version-update-helper/releases)
[![Last updated](https://img.shields.io/github/release-date/Greewil/version-update-helper?label=updated)](https://github.com/Greewil/version-update-helper/releases)
[![issues](https://badgen.net/github/issues/Greewil/version-update-helper)](https://github.com/Greewil/version-update-helper/issues)

Actions: [create fork](https://github.com/Greewil/version-update-helper/fork), [watch repo](https://github.com/Greewil/version-update-helper/subscription), [create issue](https://github.com/Greewil/version-update-helper/issues/new)

## Overview

This project allows you to simplify operations with project's version on dev machines or in CI/CD pipelines.
It can work with every possible type of configuration files, because it simply greps versions from files to get them. 

This tool can help you to:

- update version your local version to specified or autoincrement it
- suggest minimal valid version or check that specified version is valid 
(version supposed to be valid if it's greater than origin/YOUR_MAIN_BRANCH_NAME)
- compare versions from different branches (f.e. current with origin/main)
- get version from any local or remote branch (or branch which you set as main)
- show configuration for each module of your monorepo 
(so you can store them in one place and call them with vuh)

After 2.0.0 vuh also can work with monorepos, so you can handle 
few different modules with their own versions stored in one mono repository.

Runs under any platform which supports bash.
Works only with git projects!

## Requirements

- git version 2.24 (Version 2.24 was tested. You can use lower versions at your own risk.)

## Installation

Default installation supported for linux, solaris, bsd, msys (yes, it will work under gitbash console), cygwin, darwin.

To install vuh you can use one-liner (at any directory):

    bash -c "tmp_dir=/tmp/installation-\$(date +%s%N); start_dir=\$(pwd); trap 'printf \"%b\" \"\n\e[0;31mInstallation failed\e[0m\n\n\"; cd \$start_dir; rm -r \$tmp_dir' ERR; set -e; printf '%b' '\ndownloading vuh packages ...\n\n'; mkdir -p \$tmp_dir; cd \$tmp_dir; curl https://github.com/Greewil/version-update-helper/archive/refs/heads/main.zip -O -J -L; printf '%b' '\nunpacking ...\n\n'; unzip version-update-helper-main.zip; printf '%b' '\ninstalling vuh ...\n\n'; ./version-update-helper-main/installer.sh; cd \$start_dir; rm -r \$tmp_dir; printf '%b' '\nThis installation command generated with \e[1;34mhttps://github.com/Greewil/one-line-installer\e[0m\n\n'"

(one-liner generated with https://github.com/Greewil/one-line-installer)

or you can install vuh manually:

    git clone git clone https://github.com/Greewil/version-update-helper.git
    cd version-update-helper
    ./installer.sh

To use default installation start installer with:

    ./installer.sh -d

Default installation selects installation directories automatically. 
It can be useful if you don't want to select installation directories manually.

### Update

Vuh is automatically checking for updates each day. 
Information about latest update check will be stored in /usr/share/vuh/latest_update_check 
(if you selected default data directory due installation).

If new version released, vuh will ask you to update it.

If you want to update vuh manually to latest version you can run:
```
sudo vuh --update
```

## Usage

To use vuh with your project you should first create .vuh file in root folder of your project 
(read more about configuring in [configuring projects](#Configuring-projects)).

    Usage: vuh [-v | --version] [-h | --help] <command> [<args>]
    
    Options:
        -h, --help               show help text
        -v, --version            show version
        --configuration          show configuration
        --update                 check for available vuh updates and ask to install latest version
    
    Commands:
        lv, local-version            show local current version (default format)
            [-q | --quiet]           to show only version number (or errors messages if there are so)
            [-pm=<project_module>]   to use specified module of your mono repository project (instead of default)
        mv, main-version             show version of origin/MAIN_BRANCH_NAME
            [-q | --quiet]           to show only version number (or errors messages if there are so)
            [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
            [-pm=<project_module>]   to use specified module of your mono repository project (instead of default)
            [--offline
              | --airplane-mode]     to work offline without updating origin/MAIN_BRANCH_NAME
                                     and to stop searching for vuh updates.
        sv, suggesting-version       show suggesting version which this branch should use
            [-q | --quiet]           to show only version number (or errors messages if there are so)
            [-v=<version>]           to specify your own version which also will be taken into account
                                     This parameter can't be use with '-vp' parameter!
            [-vp=<version_part>]     to force increasing specified part of the version ('major', 'minor' or 'patch')
                                     This parameter can't be use with '-v' parameter!
            [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
            [-pm=<project_module>]   to use specified module of your mono repository project (instead of default)
            [--check-git-diff]       to automatically increase version only if current branch has git difference
                                     with HEAD..origin/MAIN_BRANCH_NAME. And if there is no git difference vuh will not 
                                     modify your current version if your current version is the same as main version.
                                     This parameter can't be used with '--dont-check-git-diff'.
            [--dont-check-git-diff]  if this parameter was used vuh will require to increse version anyway. 
                                     Suggesting to use this parameter to force increasing version when your project 
                                     configuration expects to increase versions only when there is git diff.
                                     This parameter can't be used with '--check-git-diff'.
            [--offline
              | --airplane-mode]     to work offline without updating origin/MAIN_BRANCH_NAME
                                     and to stop searching for vuh updates.
        uv, update-version           replace your local version with suggesting version which this branch should use
            [-v=<version>]           to specify your own version which also will be taken into account
                                     This parameter can't be use with '-vp' parameter!
            [-vp=<version_part>]     to force increasing specified part of the version ('major', 'minor' or 'patch')
                                     This parameter can't be use with '-v' parameter!
            [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
            [-pm=<project_module>]   to use specified module of your mono repository project (instead of default)
            [--check-git-diff]       to automatically increase version only if current branch has git difference
                                     with HEAD..origin/MAIN_BRANCH_NAME. And if there is no git difference vuh will not 
                                     modify your current version if your current version is the same as main version.
                                     This parameter can't be used with '--dont-check-git-diff'.
            [--dont-check-git-diff]  if this parameter was used vuh will require to increse version anyway. 
                                     Suggesting to use this parameter to force increasing version when your project 
                                     configuration expects to increase versions only when there is git diff.
                                     This parameter can't be used with '--check-git-diff'.
            [--offline
              | --airplane-mode]     to work offline without updating origin/MAIN_BRANCH_NAME
                                     and to stop searching for vuh updates.
        mrp, module-root-path        show root path of specified module (for monorepos projects)
            [-q | --quiet]           to show only root path (or errors messages if there are so)
            [-pm=<project_module>]   to use specified module of mono repository project (instead of default)
        pm, project-modules          show all project modules of current mono repository that were specified in .vuh
            [-q | --quiet]           to show only project modules (or errors messages if there are so)
    
    This tool suggest relevant version for your current project or even update your local project's version.
    Vuh can work with your project's versions from any directory inside of your local repository.
    Vuh also can work with monorepos, so you can handle few different modules stored in one mono repository.
    Project repository: https://github.com/Greewil/version-update-helper

## Configuring projects

List of basic .vuh config variables for your project:

| Variable                              | Vuh version supporting | Required always | Description                                                                                                                                                                                                                                                                                                                                                                                                                             | Example                                                                                                         |
|---------------------------------------|:----------------------:|:---------------:|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| MAIN_BRANCH_NAME                      |         0.1.0          |       Yes       | The name of the main project's branch.                                                                                                                                                                                                                                                                                                                                                                                                  | 'main' or 'master'                                                                                              |
| VERSION_FILE                          |         0.1.0          |       Yes       | File which contains version information.                                                                                                                                                                                                                                                                                                                                                                                                | 'package.json' <br/> (for node.js application)                                                                  |
| TEXT_BEFORE_VERSION_CODE              |         0.1.0          |       Yes       | Unique text which will be just before version number including spaces.                                                                                                                                                                                                                                                                                                                                                                  | '"version": "' <br/> (for variable "version" in json files so it can find line "version": "version_number")     |
| TEXT_AFTER_VERSION_CODE               |         0.1.0          |       Yes       | Unique text which will be just after version number including spaces.                                                                                                                                                                                                                                                                                                                                                                   | '",' <br/> (for variable "version" in json files so it can find line "version": "version_number")               |
| MODULE_ROOT_PATH                      |         2.2.0          |       No        | Root path of the project code directory relative to the repository root (this variable can be used in git diff if IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES equals 'true').                                                                                                                                                                                                                                                                 | 'src' (for src directory in the repository root)                                                                |
| IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES |         2.2.0          |       No        | If this variable set to 'true' and current branch has no difference with HEAD..origin/MAIN_BRANCH_NAME, vuh will not modify your current version if your current version is the same as main version. If this variable is 'false' (which is by default) vuh will suggest you to increase your current version.                                                                                                                          | 'true' or 'false' ('false' by default)                                                                          |
| \<VERSION_PART>_CHANGING_LOCATIONS    |         2.3.0          |       No        | If there are changes between HEAD..origin/MAIN_BRANCH_NAME and current branch in this files or directories, <VERSION_PART> version should be increased. Works only if you checking git diff (you configured your .vuh config such way or you using --check-git-diff parameter). Locations should be separated with spaces. Empty variable means there is no locations which leads to <VERSION_PART> increasing on every change in them. | 'openapi/schema.yaml very/important/directory' <br/> (for 'openapi/schema.yaml' and 'very/important/directory') |

If you want to work with versions for multiple modules in one monorepo you should specify in config few more variables.
Variables which corresponds to modules should be started with module name
(So they should be named like: <MODULE_NAME>_<VARIABLE_NAME>).

List of all config variables for monorepos:

| Variable                                        | Vuh version supporting | Required always | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Example                                                                                                         |
|-------------------------------------------------|:----------------------:|:---------------:|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| PROJECT_MODULES                                 |         2.0.0          |       No        | List of all modules in your mono repository that will have different versioning mechanisms. <br/>You can leave this variable empty if your repository contains only one project. <br/>For each specified module you should specify configuration for this module down below.                                                                                                                                                                                        | 'BACKEND,FRONTEND' (for mono repository with two modules: BACKEND and FRONTEND)                                 |
| \<MODULE>_MAIN_BRANCH_NAME                      |         2.0.0          |       No        | The name of the main project's branch (for specific \<MODULE>). By default this value will be equal to MAIN_BRANCH_NAME variable.                                                                                                                                                                                                                                                                                                                                   | 'main' or 'master'                                                                                              |
| \<MODULE>_VERSION_FILE                          |         2.0.0          |       No        | File which contains version information (for specific \<MODULE>).                                                                                                                                                                                                                                                                                                                                                                                                   | 'package.json' <br/> (for node.js application)                                                                  |
| \<MODULE>_TEXT_BEFORE_VERSION_CODE              |         2.0.0          |       No        | Unique text which will be just before version number including spaces (for specific \<MODULE>).                                                                                                                                                                                                                                                                                                                                                                     | '"version": "' <br/> (for variable "version" in json files so it can find line "version": "version_number")     |
| \<MODULE>_TEXT_AFTER_VERSION_CODE               |         2.0.0          |       No        | Unique text which will be just after version number including spaces (for specific \<MODULE>).                                                                                                                                                                                                                                                                                                                                                                      | '",' <br/> (for variable "version" in json files so it can find line "version": "version_number")               |
| \<MODULE>_MODULE_ROOT_PATH                      |         2.0.0          |       No        | Root path of the project module code directory relative to the repository root (this variable can be used in git diff if \<MODULE>_IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES equals 'true').                                                                                                                                                                                                                                                                            | 'frontend' (for frontend directory in the repository root)                                                      |
| \<MODULE>_IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES |         2.2.0          |       No        | If this variable set to 'true' and current branch has no difference with HEAD..origin/\<MODULE>_MAIN_BRANCH_NAME, vuh will not modify your current version if your current version is the same as main version. If this variable is 'false' (which is by default) vuh will suggest you to increase your current version.                                                                                                                                            | 'true' or 'false' ('false' by default)                                                                          |
| \<MODULE>_<VERSION_PART>_CHANGING_LOCATIONS     |         2.3.0          |       No        | If there are changes between HEAD..origin/\<MODULE>MAIN_BRANCH_NAME and current branch in this files or directories, <VERSION_PART> version should be increased. Works only if you checking git diff (you configured your .vuh config such way for this \<MODULE> or you using --check-git-diff parameter). Locations should be separated with spaces. Empty variable means there is no locations which leads to <VERSION_PART> increasing on every change in them. | 'openapi/schema.yaml very/important/directory' <br/> (for 'openapi/schema.yaml' and 'very/important/directory') |

To configure your own project you should select one of the configuration template from [project-config-templates]
and copy it to the root directory of your project as '.vuh'.

To check that your '.vuh' file was configured properly use commands (from the root your repo):
1) make sure next command will return only one single line which will contain your projects/module version:
```
cat "<config:VERSION_FILE_NAME>" | grep -E "<config:TEXT_BEFORE_VERSION_CODE>" | grep -E "<config:TEXT_AFTER_VERSION_CODE>"
```
If you are struggling to grep the only one line with needed version, you can add comment on that line.
2) If .vuh file was configured properly vuh should show you suggesting version for your project/module:
```
vuh sv
vuh sv -pm=YOUR_PROJECT_MODULE  # in case you have monorepository with multiple modules
```

[//]: # (TODO link to example js repo, python repo, java repo, ...)
[//]: # (TODO link to example monorepo, f.e. with WEB, BACKEND, OPENAPI_SCHEMA)

## Version comparing logic

When comparing versions by default vuh will use this logic:
if versions are the same except prerelease info the largest version will be the one without any prerelease info
and other will be treated as equals.
But you can override get_larger_prerelease_info function in .vuh file if you want to use
your own function for comparing prerelease information for your project.

## License

version-update-helper is licensed under the terms of the MIT License. See [LICENSE] file.

## Contact

* Web: <https://github.com/Greewil/version-update-helper>
* Mail: <shishkin.sergey.d@gmail.com>

[LICENSE]: https://github.com/Greewil/version-update-helper/blob/main/LICENSE
[project-config-templates]: https://github.com/Greewil/version-update-helper/blob/main/project-config-templates