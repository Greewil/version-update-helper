# version-update-helper
[![release](https://badgen.net/github/release/Greewil/version-update-helper)](https://github.com/Greewil/version-update-helper/releases)
[![Last updated](https://img.shields.io/github/release-date/Greewil/version-update-helper?label=updated)](https://github.com/Greewil/version-update-helper/releases)
[![issues](https://badgen.net/github/issues/Greewil/version-update-helper)](https://github.com/Greewil/version-update-helper/issues)

Actions: [create fork](https://github.com/Greewil/version-update-helper/fork), [watch repo](https://github.com/Greewil/version-update-helper/subscription), [create issue](https://github.com/Greewil/version-update-helper/issues/new)

## Overview

vuh script allows you to

- suggest relevant version according to your local and main versions with '***vuh sv***' or '***vuh
  suggesting-version***'
- check is your input version allowed to be new main branch version with '***vuh sv -v=1.6.5***' or '***vuh
  suggesting-version -v=1.6.5***'
- update your local version to suggested version with '***vuh uv***' or '***vuh update-version***'
- easily get local project's version with '***vuh lv***' or '***vuh local-version***'
- easily get version of origin/MAIN_BRANCH_NAME branch with '***vuh mv***' or '***vuh main-version***'

Works only with git projects!

## Requirements

- git version 2.24 (Version 2.24 was tested. You can use lower versions at your own risk)

## Installation

Installing vuh.sh is simple:

    git clone git clone https://github.com/Greewil/version-update-helper.git
    cd version-update-helper
    ./installer.sh

To use default installation start installer with:

    ./installer.sh -d

Default installation selects installation directories automatically. 
It can be useful if you don't want to select installation directories manually.

## Configuring projects

To configure your own project you should select one of the template.conf files and copy it to the root directory of your 
project as vuh.conf. 

To check that your vuh.conf file was configured properly use commands:
1)
    cat (VERSION_FILE_NAME) | grep "(config:TEXT_BEFORE_VERSION_CODE)" | grep '\
    '"(config:TEXT_AFTER_VERSION_CODE)"
2)
    echo YOUR_VERSION_EXAMPLE | grep "(config:VERSION_REG_EXP)"

If all was configured properly the first command will return the line with your version and
the second command should return you the same version as YOUR_VERSION_EXAMPLE.

## Usage

To use vuh with your project you should first create vuh.conf file in root folder of your project 
(read more about configuring in [configuring projects](#Configuring-projects)).

    Usage: vuh [-v | --version] [-h | --help] <command> [<args>]

    Options:
        -h, --help               show help text
        -v, --version            show version
        --configuration          show configuration
        --update                 check for available vuh updates and ask to install latest version
    
    Commands:
        lv, local-version        show local current version (default format)
        mv, main-version         show version of origin/MAIN_BRANCH_NAME
           [-mb=<version>]          to use another main branch (instead of main branch specified in .conf file)
        sv, suggesting-version   show suggesting version which this branch should use
           [-v=<version>]           to specify your own version which also will be taken into account
           [-mb=<version>]          to use another main branch (instead of main branch specified in .conf file)
        uv, update-version       replace your local version with suggesting version which this branch should use
           [-v=<version>]           to specify your own version which also will be taken into account
           [-mb=<version>]          to use another main branch (instead of main branch specified in .conf file)
    
    Suggests relevant version for your local project or even updates your local project's version.
    Script can work with your project's versions from any directory of your local repository.

## License

version-update-helper is licensed under the terms of the MIT License. See [LICENSE] file.

## Contact

* Web: <https://github.com/Greewil/version-update-helper>
* Mail: <shishkin.sergey.d@gmail.com>

[LICENSE]: https://github.com/Greewil/version-update-helper/blob/master/LICENSE