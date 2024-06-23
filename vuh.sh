#!/usr/bin/env bash

#/ Usage: vuh [-v | --version] [-h | --help] <command> [<args>]
#/
#/ Options:
#/     -h, --help               show help text
#/     -v, --version            show version
#/     --configuration          show configuration
#/     --update                 check for available vuh updates and ask to install latest version
#/
#/ Commands:
#/     lv, local-version        show local current version (default format)
#/         [-q | --quiet]           to show only version number (or errors messages if there are so)
#/         [-pm=<project_module>]   to use specified module of your mono repository project (instead of default)
#/     mv, main-version         show version of origin/MAIN_BRANCH_NAME
#/         [-q | --quiet]           to show only version number (or errors messages if there are so)
#/         [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
#/         [-pm=<project_module>]   to use specified module of your mono repository project (instead of default)
#/     sv, suggesting-version   show suggesting version which this branch should use
#/         [-q | --quiet]           to show only version number (or errors messages if there are so)
#/         [-v=<version>]           to specify your own version which also will be taken into account
#/         [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
#/         [-pm=<project_module>]   to use specified module of your mono repository project (instead of default)
#/     uv, update-version       replace your local version with suggesting version which this branch should use
#/         [-v=<version>]           to specify your own version which also will be taken into account
#/         [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file)
#/         [-pm=<project_module>]   to use specified module of mono repository project (instead of default)
#/
#/ This tool suggest relevant version for your current project or even update your local project's version.
#/ Vuh can work with your project's versions from any directory inside of your local repository.
#/ Vuh also can work with monorepos, so you can handle few different modules stored in one mono repository.
#/ Project repository: https://github.com/Greewil/version-update-helper
#
# Written by Shishkin Sergey <shishkin.sergey.d@gmail.com>

# Current vuh version
VUH_VERSION='2.0.0'

# Installation variables (Please don't modify!)
DATA_DIR='<should_be_replace_after_installation:DATA_DIR>'

# Variables for auto updates checking
OFFICIAL_REPO='Greewil/version-update-helper'
OFFICIAL_REPO_FULL="https://github.com/$OFFICIAL_REPO"
AVAILABLE_VERSION=''

# Output colors
APP_NAME='vuh'
NEUTRAL_COLOR='\e[0m'
RED='\e[1;31m'        # for errors
YELLOW='\e[1;33m'     # for warnings
BROWN='\e[0;33m'      # for inputs
LIGHT_CYAN='\e[1;36m' # for changes

# vuh global variables (Please don't modify!)
LOADED_CONF_FILE_VERSION=''
ROOT_REPO_DIR=''
LOCAL_VERSION=''
MAIN_VERSION=''
SUGGESTING_VERSION=''

# variables for handling semantic versions
VERSION_REG_EXP='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)'\
'(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?'\
'(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$'

# Console input variables (Please don't modify!)
COMMAND=''
SPECIFIED_VERSION=''
SPECIFIED_PROJECT_MODULE=''
SPECIFIED_MAIN_BRANCH=''
ARGUMENT_QUIET='false'


function _show_function_title() {
  printf '\n'
  echo "$1"
}

function _show_error_message() {
  message=$1
  echo -en "$RED($APP_NAME : ERROR) $message$NEUTRAL_COLOR\n"
}

function _show_warning_message() {
  message=$1
  echo -en "$YELLOW($APP_NAME : WARNING) $message$NEUTRAL_COLOR\n"
}

function _show_updated_message() {
  message=$1
  echo -en "$LIGHT_CYAN($APP_NAME : CHANGED) $message$NEUTRAL_COLOR\n"
}

function _show_invalid_usage_error_message() {
  message=$1
  _show_error_message "$message"
  echo 'Use "vuh --help" to see available commands and options information'
}

function _exit_if_using_multiple_commands() {
  last_command=$1
  if [ "$COMMAND" != '' ]; then
    _show_invalid_usage_error_message "You can't use both commands: '$COMMAND' and '$last_command'!"
    exit 1
  fi
}

function _check_arg() {
  arg="$1"
  if [ "$COMMAND" = '' ]; then
    _show_invalid_usage_error_message "Parameter '$arg' used without specifying any command!"
    exit 1
  fi
}

function _yes_no_question() {
  question_text=$1
  command_on_yes=$2
  command_on_no=$3
  asking_question='true'
  while [ "$asking_question" = 'true' ]; do
    read -p "$(echo -e "$BROWN($APP_NAME : INPUT) $question_text (Y/N): $NEUTRAL_COLOR")" -r answer
    case "$answer" in
    y|Y|Yes|yes)
      eval "$command_on_yes"
      asking_question='false'
      ;;
    n|N|No|no)
      eval "$command_on_no"
      asking_question='false'
      ;;
    esac
  done
}

# Changes default configuration values to configuration values of specified module.
# Throws error if module's MAIN_BRANCH_NAME or VERSION_FILE values are empty.
#
# $1 - Module name
function _use_module_configuration() {
  next_handling_module=$1
  eval MAIN_BRANCH_NAME='$'"$next_handling_module"'_MAIN_BRANCH_NAME'
  [ "$MAIN_BRANCH_NAME" == '' ] && _show_error_message "$next_handling_module"'_MAIN_BRANCH_NAME variable is empty!'
  eval VERSION_FILE='$'"$next_handling_module"'_VERSION_FILE'
  [ "$VERSION_FILE" == '' ] && _show_error_message "$next_handling_module"'_VERSION_FILE variable is empty!'
  eval TEXT_BEFORE_VERSION_CODE='$'"$next_handling_module"'_TEXT_BEFORE_VERSION_CODE'
  eval TEXT_AFTER_VERSION_CODE='$'"$next_handling_module"'_TEXT_AFTER_VERSION_CODE'
  if [ "$MAIN_BRANCH_NAME" == '' ] || [ "$VERSION_FILE" == '' ]; then
    _show_error_message "Seems like module '$next_handling_module' don't have correct configuration in .vuh file!"
    return 1
  fi
}

# Changes default configuration values to configuration values of specified module.
# Throws error if module name in function's argument wasn't specified in .vuh file in PROJECT_MODULES.
#
# $1 - Module name
function _use_module_configuration_if_it_exists() {
  next_handling_module=$1
  if [ "$next_handling_module" != "" ]; then
    module_specified='false'
    IFS=',' read -ra ADDR <<< "$PROJECT_MODULES"
    for module in "${ADDR[@]}"; do
      if [ "$next_handling_module" = "$module" ]; then
        _use_module_configuration "$next_handling_module" || return 1
        module_specified='true'
      fi
    done
    if [ "$module_specified" = 'false' ]; then
      _show_error_message "Module '$next_handling_module' wasn't specified in PROJECT_MODULES in .vuh file!"
      return 1
    fi
  fi
}

# Loads all data from configuration file and sets current configuration according to SPECIFIED_PROJECT_MODULE.
#
# $1 - Text of handling configuration file
function _load_project_variables_from_config() {
  config_file=$1
  tmp_conf_file="/tmp/${APP_NAME}_projects_conf_file"
  echo "$config_file" > $tmp_conf_file
  # shellcheck source=/dev/null
  . $tmp_conf_file || {
    rm -f "/tmp/${APP_NAME}_projects_conf_file"
    return 1
  }
  rm -f "/tmp/${APP_NAME}_projects_conf_file"
  _use_module_configuration_if_it_exists "$SPECIFIED_PROJECT_MODULE"
}

function _check_version_syntax() {
  version=$1
  if [ "$version" = "" ] || [[ $(echo "$version" | grep -E "$VERSION_REG_EXP") != "$version" ]]; then
    return 1
  fi || return 1
}

function _get_major_version() {
  full_version=$1
  if [[ $full_version =~ $VERSION_REG_EXP ]]; then
    major_version=${BASH_REMATCH[1]}
    [ "$major_version" != '' ] || return 1
    echo "$major_version"
  else
    return 1
  fi
}

function _get_minor_version() {
  full_version=$1
  if [[ $full_version =~ $VERSION_REG_EXP ]]; then
    minor_version=${BASH_REMATCH[2]}
    [ "$minor_version" != '' ] || return 1
    echo "$minor_version"
  else
    return 1
  fi
}

function _get_patch_version() {
  full_version=$1
  if [[ $full_version =~ $VERSION_REG_EXP ]]; then
    patch_version=${BASH_REMATCH[3]}
    [ "$patch_version" != '' ] || return 1
    echo "$patch_version"
  else
    return 1
  fi
}

function _get_prerelease() {
  full_version=$1
  if [[ $full_version =~ $VERSION_REG_EXP ]]; then
    patch_version=${BASH_REMATCH[5]}
    echo "$patch_version"
  else
    return 1
  fi
}

function _get_metadata() {
  full_version=$1
  if [[ $full_version =~ \+ ]]; then
    metadata="+${full_version#*+}"
  else
    metadata=''
  fi
  echo "$metadata"
}

# This is default function but it can be overridden from .vuh confing!
#
# $1 - Prerelease information of the first version to compare
# $2 - Prerelease information of the second version to compare
#
# Returns larger prerelease version or '=' if inputs are treated as equal.
function get_larger_prerelease_info() {
  prerelease_1=$1
  prerelease_2=$2
  [ "$prerelease_1" = "$prerelease_2" ] && { echo '='; return 0; }
  [ "$prerelease_1" = '' ] && { echo "$prerelease_1"; return 0; }
  [ "$prerelease_2" = '' ] && { echo "$prerelease_2"; return 0; }
  echo '='
}

# Compares two versions and returns the largest one. If input versions are equal returns '='.
#
# $1 - First version to compare
# $2 - Second version to compare
#
# Returns larger version or '=' if input versions are treated as equal.
function _get_largest_version() {
  v1=$1
  v2=$2
  if [ "$v1" = "$v2" ]; then
    echo '='
    return 0
  fi
  v1_major=$(_get_major_version "$v1") || return 1
  v2_major=$(_get_major_version "$v2") || return 1
  v1_minor=$(_get_minor_version "$v1") || return 1
  v2_minor=$(_get_minor_version "$v2") || return 1
  v1_patch=$(_get_patch_version "$v1") || return 1
  v2_patch=$(_get_patch_version "$v2") || return 1
  v1_prerelease=$(_get_prerelease "$v1") || return 1
  v2_prerelease=$(_get_prerelease "$v2") || return 1
  if (( "$v1_major" == "$v2_major" )); then
    if (( "$v1_minor" == "$v2_minor" )); then
      if (( "$v1_patch" == "$v2_patch" )); then
        prerelease_comparison=$(get_larger_prerelease_info "$v1_prerelease" "$v2_prerelease")
        [ "$prerelease_comparison" = '=' ] && { echo '='; return 0; }
        [ "$prerelease_comparison" = "$v1_prerelease" ] && { echo "$v1"; return 0; }
        [ "$prerelease_comparison" = "$v2_prerelease" ] && { echo "$v2"; return 0; }
      elif (( "$v1_patch" > "$v2_patch" )); then
        echo "$v1"
      elif (( "$v1_patch" < "$v2_patch" )); then
        echo "$v2"
      fi
    elif (( "$v1_minor" > "$v2_minor" )); then
      echo "$v1"
    elif (( "$v1_minor" < "$v2_minor" )); then
      echo "$v2"
    fi
  elif (( "$v1_major" > "$v2_major" )); then
    echo "$v1"
  elif (( "$v1_major" < "$v2_major" )); then
    echo "$v2"
  fi || return 1
}

function _get_incremented_version() {
  v=$1
  if [[ $v =~ $VERSION_REG_EXP ]]; then
    prerelease_info=${BASH_REMATCH[4]}
    metadata=$(_get_metadata "$v") || return 1
    major_version=$(_get_major_version "$v") || return 1
    minor_version=$(_get_minor_version "$v") || return 1
    patch_version=$(( $(_get_patch_version "$v") + 1 )) || return 1
    echo "$major_version.$minor_version.$patch_version$prerelease_info$metadata"
  else
    return 1
  fi
}

function _get_root_repo_dir() {
  ROOT_REPO_DIR=$(git rev-parse --show-toplevel) || {
    _show_error_message "Can't find root repo directory!"
    echo
    return 1
  }
}

function _get_version_from_file() {
  version_file=$1
  version_line=$(echo "$version_file" | grep -E "$TEXT_BEFORE_VERSION_CODE" | grep -E "$TEXT_AFTER_VERSION_CODE")
  if [ "$version_line" = '' ]; then
    _show_error_message "Failed to get line, containing version from file $handling_file!"
    return 1
  fi
  version_prefix=$(sed -r "s/($TEXT_BEFORE_VERSION_CODE).*/\1/" <<< "$version_line") || return 1
  version=${version_line##*$version_prefix} || return 1
  if [[ "$TEXT_AFTER_VERSION_CODE" != '' ]]; then
    version_postfix=$(sed -r "s/.*($TEXT_AFTER_VERSION_CODE)/\1/" <<< "$version") || return 1
    version=${version%%$version_postfix*} || return 1
  fi
  _check_version_syntax "$version" || return 1
  echo "$version"
}

function _fetch_remote_branches() {
  git fetch -q || {
    _show_error_message 'Failed to use "git fetch" to update information about remote branches!'
    _show_error_message 'If git threw "Permission denied (publickey)" then maybe you should configure public keys.'
    return 1
  }
}

function _unset_conf_variables() {
  # vuh-0.1.0
  MAIN_BRANCH_NAME='NO_MAIN_BRANCH_NAME'
  VERSION_FILE='NO_VERSION_FILE'
  TEXT_BEFORE_VERSION_CODE='NO_TEXT_BEFORE_VERSION_CODE'
  TEXT_AFTER_VERSION_CODE='NO_TEXT_AFTER_VERSION_CODE'
}

# Checks compatibility of vuh and loaded configuration file.
# Throws an error if some of default variables wasn't loaded at all.
#
# Returns nothing.
function _check_conf_data_version() {
  # vuh-0.1.0
  if [ "$MAIN_BRANCH_NAME" = 'NO_MAIN_BRANCH_NAME' ] ||
      [ "$VERSION_FILE" = 'NO_VERSION_FILE' ] ||
      [ "$TEXT_BEFORE_VERSION_CODE" = 'NO_TEXT_BEFORE_VERSION_CODE' ] ||
      [ "$TEXT_AFTER_VERSION_CODE" = 'NO_TEXT_AFTER_VERSION_CODE' ]; then
    _show_error_message "Configuration test failed! Configuration variables were empty or weren't loaded at all!"
    return 1
  else
    LOADED_CONF_FILE_VERSION='0.1.0'
  fi
}

function _load_local_conf_file() {
  _unset_conf_variables || return 1
  _get_root_repo_dir || return 1
  conf_file=$(<"$ROOT_REPO_DIR/.vuh") || {
    _show_error_message "Failed to read local configuration file $ROOT_REPO_DIR/.vuh!"
    return 1
  }
  _load_project_variables_from_config "$conf_file" || {
    _show_error_message "Failed to load variables from local configuration file $ROOT_REPO_DIR/.vuh!"
    return 1
  }
  _check_conf_data_version || return 1
}

function _load_remote_conf_file() {
  _unset_conf_variables || return 1
  branch_name=$1
  main_branch_config_file=$(git show "origin/$branch_name:.vuh") || {
    _show_error_message "Failed to read remote configuration file origin/$branch_name:.vuh!"
    return 1
  }
  _load_project_variables_from_config "$main_branch_config_file" || {
    _show_error_message "Failed to load variables from remote configuration file origin/$branch_name:.vuh!"
    return 1
  }
  _check_conf_data_version || return 1
}

function _get_latest_available_vuh_version() {
  _unset_conf_variables || return 1
  main_vuh_branch='main'
  vuh_conf_file=$(curl -s "https://raw.githubusercontent.com/$OFFICIAL_REPO/$main_vuh_branch/.vuh") || return 1
  _load_project_variables_from_config "$vuh_conf_file" || return 1
  _check_conf_data_version || return 1
  vuh_version_file=$(curl -s "https://raw.githubusercontent.com/$OFFICIAL_REPO/$main_vuh_branch/$VERSION_FILE") || return 1
  AVAILABLE_VERSION=$(_get_version_from_file "$vuh_version_file") || return 1
}

function _check_auto_update_logs() {
  update_log_file=$1
  logs=$(<"$update_log_file")
  [[ "$logs" == *'Installation failed'* ]] && _show_error_message 'Failed to install update!'
  [[ "$logs" == *'ermission denied'* ]] && _show_error_message "Permission denied so try 'sudo vuh --update' to start update!"
}

function _install_latest_vuh_version() {
  _show_function_title 'Installing latest vuh version ...'
  auto_updater_path="$OFFICIAL_REPO/$main_vuh_branch/auto_update.sh"
  vuh_auto_updater_file=$(curl -s "https://raw.githubusercontent.com/$auto_updater_path") || {
    _show_error_message "Failed to download vuh updater!"
    exit 1
  }
  update_log_file='/tmp/vuh_update_log.txt'
  echo '' > "$update_log_file"
  eval "$vuh_auto_updater_file" |& tee /dev/fd/3 3>&1 1>>${update_log_file} 2>&1
  _check_auto_update_logs "$update_log_file" || {
    rm "$update_log_file"
    exit 1
  }
  rm "$update_log_file"
}

function _regular_check_available_updates() {
  configuration_file="$DATA_DIR/.installation_info"
  if [[ ! -f "$configuration_file" ]]; then
    _show_warning_message "vuh wasn't installed properly!"
    _show_warning_message "If you want to install vuh properly read more in $OFFICIAL_REPO_FULL."
    return 1
  fi
  cur_date=$(date +%Y-%j)
  last_update_check='0-0' # dates like: 'date +%Y-%j' (f.e. 2022-213)
  update_info_file="$DATA_DIR/latest_update_check"
  if [[ -d "$update_info_file" ]] || [[ -s "$update_info_file" ]]; then
    last_update_check=$(<"$DATA_DIR/latest_update_check")
  else
    echo "$cur_date" > "$update_info_file"
  fi
  if [[ "$cur_date" != "$last_update_check" ]]; then
    echo "$cur_date" > "$update_info_file"
    _get_latest_available_vuh_version || {
      _show_warning_message "Failed to get latest available version from $OFFICIAL_REPO_FULL repository!"
    }
    largest_version=$(_get_largest_version "$VUH_VERSION" "$AVAILABLE_VERSION") || exit 1
    if [[ "$largest_version" != "$VUH_VERSION" ]] && [[ "$largest_version" != "=" ]]; then
      echo "your current vuh version: $VUH_VERSION"
      echo "latest vuh available version: $AVAILABLE_VERSION"
      _yes_no_question "Do you want to get update?" "_install_latest_vuh_version" "echo 'Update canceled'"
    fi
  fi
}

function _show_suggested_versions_comparison() {
  if [ "$SUGGESTING_VERSION" = "$LOCAL_VERSION" ]; then
    echo "(your local version seems to be ok)"
  elif [ "$SUGGESTING_VERSION" = "$SPECIFIED_VERSION" ]; then
    echo "(specified version seems to be ok)"
  else
    echo "(suggested to use new version)"
  fi
}

function read_local_version() {
  [ "$ARGUMENT_QUIET" = 'false' ] && _show_function_title 'getting local version'
  _load_local_conf_file || exit 1
  version_file=$(<"$ROOT_REPO_DIR/$VERSION_FILE") || {
    _show_error_message "Failed to load file $ROOT_REPO_DIR/$VERSION_FILE!"
    exit 1
  }
  LOCAL_VERSION=$(_get_version_from_file "$version_file") || {
    _show_error_message "Failed to get local version from $ROOT_REPO_DIR/$VERSION_FILE!"
    cat_version_file_cmd='cat "<config:VERSION_FILE>"'
    grep_text_before_cmd='grep -E "<config:TEXT_BEFORE_VERSION_CODE>"'
    grep_text_after_cmd='grep -E "<config:TEXT_AFTER_VERSION_CODE>"'
    check_line_command="$cat_version_file_cmd | $grep_text_before_cmd | $grep_text_after_cmd"
    _show_error_message "Make sure that command '$check_line_command' will throw the line with your version."
    exit 1
  }
  if [ "$ARGUMENT_QUIET" = 'false' ]; then
    echo "local: $LOCAL_VERSION"
  elif [ "$ARGUMENT_QUIET" = 'true' ] && [ "$COMMAND" = 'local-version' ]; then
    echo "$LOCAL_VERSION"
  fi
}

function read_main_version() {
  [ "$ARGUMENT_QUIET" = 'false' ] && _show_function_title 'getting main version'
  _load_local_conf_file || exit 1
  remote_branch=$MAIN_BRANCH_NAME
  if [[ "$SPECIFIED_MAIN_BRANCH" != '' ]]; then
    remote_branch="$SPECIFIED_MAIN_BRANCH" || {
      _show_error_message "Failed to set specified main branch '$SPECIFIED_MAIN_BRANCH'!"
      exit 1
    }
  fi
  _fetch_remote_branches || exit 1
  handling_file="origin/$remote_branch:$VERSION_FILE"
  if [ "$ARGUMENT_QUIET" = 'false' ]; then
    _load_remote_conf_file "$remote_branch" || {
      _show_warning_message "vuh will use local configuration to get remote version from origin/$remote_branch"
      _load_local_conf_file || exit 1
    }
  elif [ "$ARGUMENT_QUIET" = 'true' ]; then
    {
      _load_remote_conf_file "$remote_branch" || {
        _show_warning_message "vuh will use local configuration to get remote version from origin/$remote_branch"
        _load_local_conf_file || exit 1
      }
    } > /dev/null
  fi
  main_branch_file=$(git show "$handling_file") || {
    _show_error_message "Failed to load file $handling_file"
    exit 1
  }
  MAIN_VERSION=$(_get_version_from_file "$main_branch_file") || {
    _show_error_message "Failed to get main version from $handling_file!"
    check_line_command='cat "<config:VERSION_FILE>" | grep -E "<config:TEXT_BEFORE_VERSION_CODE>" | grep -E '\
'"<config:TEXT_AFTER_VERSION_CODE>"'
    _show_error_message "Make sure that command '$check_line_command' will throw the line with your version."
    _show_error_message "Also make sure that origin/$remote_branch has the same structure as your local version file."
    make_sure_message="If your origin/$remote_branch branch has different version storage logic make sure that if "\
'has different .vuh configuration.'
    _show_error_message "$make_sure_message"
    exit 1
  }
  if [ "$ARGUMENT_QUIET" = 'false' ]; then
    echo "origin/$remote_branch: $MAIN_VERSION"
  elif [ "$ARGUMENT_QUIET" = 'true' ] && [ "$COMMAND" = 'main-version' ]; then
    echo "$MAIN_VERSION"
  fi
}

function get_suggesting_version() {
  read_local_version || exit 1
  read_main_version || exit 1
  [ "$ARGUMENT_QUIET" = 'false' ] && _show_function_title 'suggesting relevant version'
  largest_version=$(_get_largest_version "$MAIN_VERSION" "$LOCAL_VERSION") || {
    _show_error_message "Failed to select larger version between '$MAIN_VERSION' and '$LOCAL_VERSION'!"
    exit 1
  }
  if [ "$largest_version" = '=' ]; then
    fair_largest_version="$MAIN_VERSION"
  else
    fair_largest_version="$largest_version"
  fi
  if [[ "$SPECIFIED_VERSION" != '' ]]; then
    largest_version=$(_get_largest_version "$fair_largest_version" "$SPECIFIED_VERSION") || {
      _show_error_message "Failed to select larger version between '$fair_largest_version' and '$SPECIFIED_VERSION'!"
      exit 1
    }
  fi
  if [ "$largest_version" = '=' ]; then
    if [ "$fair_largest_version" = "$MAIN_VERSION" ]; then
      SUGGESTING_VERSION=$(_get_incremented_version "$MAIN_VERSION") || {
        _show_error_message "Failed to increment patch version of '$MAIN_VERSION'!"
        exit 1
      }
    elif [ "$fair_largest_version" = "$LOCAL_VERSION" ]; then
      SUGGESTING_VERSION=$LOCAL_VERSION
    else
      SUGGESTING_VERSION=$(_get_incremented_version "$MAIN_VERSION") || {
        _show_error_message "Failed to increment patch version of '$MAIN_VERSION'!"
        exit 1
      }
    fi
  elif [ "$largest_version" = "$MAIN_VERSION" ]; then
    SUGGESTING_VERSION=$(_get_incremented_version "$MAIN_VERSION") || {
      _show_error_message "Failed to increment patch version of '$MAIN_VERSION'!"
      exit 1
    }
  elif [ "$largest_version" = "$SPECIFIED_VERSION" ]; then
    SUGGESTING_VERSION=$SPECIFIED_VERSION
  else
    SUGGESTING_VERSION=$LOCAL_VERSION
  fi
  if [ "$ARGUMENT_QUIET" = 'false' ]; then
    _show_suggested_versions_comparison
    echo "suggesting: $SUGGESTING_VERSION"
  elif [ "$ARGUMENT_QUIET" = 'true' ] && [ "$COMMAND" = 'suggest-version' ]; then
    echo "$SUGGESTING_VERSION"
  fi
  _check_version_syntax "$SUGGESTING_VERSION" || {
    _show_error_message "Suggesting version format is incorrect! Something went wrong ..."
    exit 1
  }
}

function update_version() {
  new_version=$1
  _show_function_title 'updating local version'
  _load_local_conf_file || exit 1
  version_file=$(<"$ROOT_REPO_DIR/$VERSION_FILE") || {
    _show_error_message "Failed to load file $ROOT_REPO_DIR/$VERSION_FILE!"
    exit 1
  }
  if [ "$LOCAL_VERSION" != "$new_version" ]; then
    old_version_string="$TEXT_BEFORE_VERSION_CODE$LOCAL_VERSION$TEXT_AFTER_VERSION_CODE"
    new_version_string="$TEXT_BEFORE_VERSION_CODE$new_version$TEXT_AFTER_VERSION_CODE"
    echo "${version_file/$old_version_string/$new_version_string}" > "$ROOT_REPO_DIR/$VERSION_FILE"
    _show_updated_message "local version updated: $LOCAL_VERSION -> $new_version"
  else
    echo "your local version already up to date: $LOCAL_VERSION"
  fi
}

function show_vuh_version() {
  echo "vuh version: $VUH_VERSION"
}

function show_vuh_configuration() {
  configuration_file="$DATA_DIR/.installation_info"
  if [ -f "$configuration_file" ]; then
    cat $configuration_file
  else
    _show_error_message "vuh wasn't installed properly!"
    exit 1
  fi
}

function check_available_updates() {
  _get_latest_available_vuh_version || {
    _show_error_message "Failed to get latest available version from $OFFICIAL_REPO_FULL repository!"
    exit 1
  }
  largest_version=$(_get_largest_version "$VUH_VERSION" "$AVAILABLE_VERSION") || exit 1
  if [ "$largest_version" = "$VUH_VERSION" ]; then
    echo "you already have the latest vuh version: $VUH_VERSION"
  else
    echo "your current vuh version: $VUH_VERSION"
    echo "latest vuh available version: $AVAILABLE_VERSION"
    _yes_no_question "Do you want to get update?" "_install_latest_vuh_version" "echo 'Update canceled'"
  fi
}

function show_help() {
  grep '^#/' <"$0" | cut -c4-
}


_unset_conf_variables

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h|--help)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--help'
    shift ;;
  -v|--version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--version'
    shift ;;
  --configuration)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--configuration'
    shift ;;
  --update)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--update'
    shift ;;
  lv|local-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='local-version'
    shift ;;
  mv|main-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='main-version'
    shift ;;
  sv|suggest-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='suggest-version'
    shift ;;
  uv|update-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='update-version'
    shift ;;
  -v=*)
    _check_arg "$1"
    SPECIFIED_VERSION=${1#*=}
    shift ;;
  -pm=*)
    _check_arg "$1"
    SPECIFIED_PROJECT_MODULE=${1#*=}
    shift ;;
  -q|--quiet)
    _check_arg "$1"
    ARGUMENT_QUIET='true'
    shift ;;
  -mb=*)
    _check_arg "$1"
    SPECIFIED_MAIN_BRANCH=${1#*=}
    shift ;;
  -*)
    _show_invalid_usage_error_message "Unknown option '$1'!"
    exit 1 ;;
  *)
    _show_invalid_usage_error_message "Unknown command '$1'!"
    exit 1 ;;
  esac
done

if [[ "$COMMAND" != '--help' ]] && [[ "$COMMAND" != '--version' ]] &&
    [[ "$COMMAND" != '--configuration' ]] && [[ "$COMMAND" != '--update' ]] &&
    [[ "$ARGUMENT_QUIET" != 'true' ]]; then
  _regular_check_available_updates
fi

case "$COMMAND" in
--help)
  show_help
  exit 0
  ;;
--version)
  show_vuh_version
  exit 0
  ;;
--configuration)
  show_vuh_configuration
  exit 0
  ;;
--update)
  check_available_updates
  exit 0
  ;;
local-version)
  read_local_version
  exit 0
  ;;
main-version)
  read_main_version
  exit 0
  ;;
suggest-version)
  get_suggesting_version
  exit 0
  ;;
update-version)
  get_suggesting_version
  update_version "$SUGGESTING_VERSION"
  exit 0
  ;;
esac
