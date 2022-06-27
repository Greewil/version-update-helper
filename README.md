# version-update-helper

## Overview

vuh script allows you to

- suggest relevant version according to your local and main versions with '***vuh sv***' or '***vuh
  suggesting-version***'
- check is your input version allowed to be new main branch version with '***vuh sv -v=1.6.5***' or '***vuh
  suggesting-version -v=1.6.5***'
- easily get local project's version with '***vuh lv***' or '***vuh local-version***'
- easily get version of origin/MAIN_BRANCH_NAME branch with '***vuh lv***' or '***vuh main-version***'

## Requirements

git version 2.24

## Installation

Installing vuh.bash is simple:

    $ git clone git clone https://github.com/Greewil/version-update-helper.git
    $ cd version-update-helper
    $ ./installer.sh

That will install vuh to `$HOME/bin` by default.

## Usage

    Usage: vuh [-v | --version] [-h | --help] <command> [<args>]

    Options:
        -h, --help               show help text
        -v, --version            show version
    
    Commands:
        lv, local-version        show local current version (default format)
        mv, main-version         show version of origin/MAIN_BRANCH_NAME
        sv, suggesting-version   show suggesting version which this branch should use
           [-v=<version>]           to specify your own version which also will be taken into account
    
    Suggests relevant version for your local project or even updates your local project's version.
    Script can work with your project's versions from any directory of your local repository.

## License

version-update-helper is licensed under the terms of the MIT License. See [LICENSE] file.

## Contact

* Web: <https://github.com/Greewil/version-update-helper>
* Mail: <shishkin.sergey.d@gmail.com>

[LICENSE]: https://github.com/Greewil/version-update-helper/blob/master/LICENSE