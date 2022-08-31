# version-update-helper
[![release](https://badgen.net/github/release/Greewil/version-update-helper/stable)](https://github.com/Greewil/version-update-helper/releases)
[![Last updated](https://img.shields.io/github/release-date/Greewil/version-update-helper?label=updated)](https://github.com/Greewil/version-update-helper/releases)
[![issues](https://badgen.net/github/issues/Greewil/version-update-helper)](https://github.com/Greewil/version-update-helper/issues)

Actions: [create fork](https://github.com/Greewil/version-update-helper/fork), [watch repo](https://github.com/Greewil/version-update-helper/subscription), [create issue](https://github.com/Greewil/version-update-helper/issues/new)

## Overview

vuh script allows you to

- suggest relevant version according to your local and main versions

  ('***vuh sv***' or '***vuh suggesting-version***')

- check is your input version allowed to be new main branch version

  ('***vuh sv -v=1.6.5***' or '***vuh suggesting-version -v=1.6.5***')

- update your local version to suggested version

  ('***vuh uv***' or '***vuh update-version***')

- easily get local project's version

  ('***vuh lv***' or '***vuh local-version***')

- easily get version from origin/MAIN_BRANCH_NAME branch

  ('***vuh mv***' or '***vuh main-version***')

- easily get version from specified branch

  ('***vuh mv -mb=<YOUR_BRANCH>***' or '***vuh main-version -mb=<YOUR_BRANCH>***')

Works only with git projects!

## Requirements

- git version 2.24 (Version 2.24 was tested. You can use lower versions at your own risk)

## Installation

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

## Configuring projects

To configure your own project you should select one of the configuration template from [project-config-templates] 
and copy it to the root directory of your project as '.vuh'. 

To check that your '.vuh' file was configured properly use commands (from the root your repo):
1) cat "<config:VERSION_FILE_NAME>" | grep -E "<config:TEXT_BEFORE_VERSION_CODE>" | grep -E "<config:TEXT_AFTER_VERSION_CODE>"
2) vuh sv

If all was configured properly the first command will return the line with your version.
The second command should return you local version of the project, main version and next suggesting version.

When comparing versions by default vuh will use this logic: 
if versions are the same except prerelease info the largest version will be the one without any prerelease info 
and other will be treated as equals. 
But you can override get_larger_prerelease_info function in .vuh file
if you want to use your own function for comparing prerelease information for your project. 

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
        lv, local-version        show local current version (default format)
            [-q | --quiet]           to show only version number (or errors messages if there are so)
        mv, main-version         show version of origin/MAIN_BRANCH_NAME
            [-q | --quiet]           to show only version number (or errors messages if there are so)
            [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
        sv, suggesting-version   show suggesting version which this branch should use
            [-q | --quiet]           to show only version number (or errors messages if there are so)
            [-v=<version>]           to specify your own version which also will be taken into account
            [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
        uv, update-version       replace your local version with suggesting version which this branch should use
            [-v=<version>]           to specify your own version which also will be taken into account
            [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
    
    Suggest relevant version for your current project or even update your local project's version.
    Script can work with your project's versions from any directory inside of your local repository.
    Project repository: https://github.com/Greewil/version-update-helper

## License

version-update-helper is licensed under the terms of the MIT License. See [LICENSE] file.

## Contact

* Web: <https://github.com/Greewil/version-update-helper>
* Mail: <shishkin.sergey.d@gmail.com>

[LICENSE]: https://github.com/Greewil/version-update-helper/blob/main/LICENSE
[project-config-templates]: https://github.com/Greewil/version-update-helper/blob/main/project-config-templates