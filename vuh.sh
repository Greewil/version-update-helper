#!/usr/bin/env bash

#/ Usage: vuh [-v | --version] [-h | --help] [--configuration] [--update] <command> [<args>]
#/
#/ Standalone commands:
#/     -h, --help               show help text
#/     -v, --version            show version
#/     --configuration          show configuration
#/     --update                 check for available vuh updates and ask to install latest version
#/
#/ Commands:
#/
#/     lv, local-version            Show local current version (default format).
#/
#/         [-q | --quiet]           to show only version number (or errors messages if there are so).
#/
#/         [-pm=<project_module>]   to use specified module of your mono repository project (instead of default).
#/
#/         [--dont-use-git]         don't use any git commands.
#/                                  In this case you should run vuh in root directory (which contains .vuh)
#/                                  or specify path to it using '--config-path=<path>' parameter.
#/
#/         [--config-dir=<path>]    Search for .vuh configuration file in another directory.
#/                                  You don't need to specify it if you are working with git repository.
#/                                  Suggesting to use this parameter with '--dont-use-git' parameter.
#/
#/     mv, main-version             Show version of origin/MAIN_BRANCH_NAME.
#/
#/         [-q | --quiet]           to show only version number (or errors messages if there are so).
#/
#/         [-mb=<version>]          to use another main branch (instead of main branch specified in .vuh file).
#/                                  This parameter overrides MAIN_BRANCH_NAME configuration variable from .vuh file.
#/
#/         [-pm=<project_module>]   to use specified module of your mono repository project (instead of default).
#/
#/         [--offline | --airplane-mode]
#/                                  to work offline without updating origin/MAIN_BRANCH_NAME
#/                                  and to stop searching for vuh updates.
#/
#/     sv, suggesting-version       Show suggesting version which this branch should use.
#/
#/         [-q | --quiet]           to show only version number (or errors messages if there are so).
#/
#/         [-v=<version>]           to specify your own version which also will be taken into account.
#/                                  This parameter can't be use with '-vp' parameter!
#/
#/         [-vp=<version_part>]     to force increasing specified part of the version ('major', 'minor' or 'patch').
#/                                  This parameter can't be use with '-v' parameter!
#/
#/         [-mb=<main_branch_name>] to use another main branch (instead of main branch specified in .vuh file).
#/                                  This parameter overrides MAIN_BRANCH_NAME configuration variable from .vuh file.
#/
#/         [-pm=<project_module>]   to use specified module of your mono repository project (instead of default).
#/
#/         [--check-git-diff]       to automatically increase version only if current branch has git difference
#/                                  with HEAD..origin/MAIN_BRANCH_NAME. And if there is no git difference vuh will not
#/                                  modify your current version if your current version is the same as main version.
#/                                  This parameter overrides IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES
#/                                  configuration variable from .vuh file.
#/                                  This parameter can't be used with '--dont-check-git-diff'.
#/                                  This parameter can't be used with '--dont-use-git'.
#/
#/         [--dont-check-git-diff]  to increase anyway either there are changes or not.
#/                                  Suggesting to use this parameter to force increasing version when your project
#/                                  configuration expects to increase versions only when there is git diff.
#/                                  This parameter overrides IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES
#/                                  configuration variable from .vuh file.
#/                                  This parameter can't be used with '--check-git-diff'.
#/                                  This parameter can't be used with '--dont-use-git'.
#/
#/         [--offline | --airplane-mode]
#/                                  to work offline without updating origin/MAIN_BRANCH_NAME
#/                                  and to stop searching for vuh updates.
#/
#/         [--dont-use-git]         don't use any git commands.
#/                                  In this case you should run vuh in root directory (which contains .vuh)
#/                                  or specify path to it using '--config-path=<path>' parameter.
#/                                  This parameter can't be used with '--check-git-diff'.
#/                                  This parameter can't be used with '--dont-check-git-diff'.
#/
#/         [--config-dir=<path>]    Search for .vuh configuration file in another directory.
#/                                  You don't need to specify it if you are working with git repository.
#/                                  Suggesting to use this parameter with '--dont-use-git' parameter.
#/
#/     uv, update-version           Replace your local version with suggesting version which this branch should use.
#/
#/         [-q | --quiet]           to show only version number (or errors messages if there are so).
#/
#/         [-v=<version>]           to specify your own version which also will be taken into account.
#/                                  This parameter can't be use with '-vp' parameter!
#/
#/         [-vp=<version_part>]     to force increasing specified part of the version ('major', 'minor' or 'patch').
#/                                  This parameter can't be use with '-v' parameter!
#/
#/         [-mb=<main_branch_name>] to use another main branch (instead of main branch specified in .vuh file).
#/                                  This parameter overrides MAIN_BRANCH_NAME configuration variable from .vuh file.
#/
#/         [-pm=<project_module>]   to use specified module of mono repository project (instead of default).
#/
#/         [--check-git-diff]       to automatically increase version only if current branch has git difference
#/                                  with HEAD..origin/MAIN_BRANCH_NAME. And if there is no git difference vuh will not
#/                                  modify your current version if your current version is the same as main version.
#/                                  This parameter overrides IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES
#/                                  configuration variable from .vuh file.
#/                                  This parameter can't be used with '--dont-check-git-diff'.
#/                                  This parameter can't be used with '--dont-use-git'.
#/
#/         [--dont-check-git-diff]  to increase anyway either there are changes or not.
#/                                  Suggesting to use this parameter to force increasing version when your project
#/                                  configuration expects to increase versions only when there is git diff.
#/                                  This parameter overrides IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES
#/                                  configuration variable from .vuh file.
#/                                  This parameter can't be used with '--check-git-diff'.
#/                                  This parameter can't be used with '--dont-use-git'.
#/
#/         [--offline | --airplane-mode]
#/                                  to work offline without updating origin/MAIN_BRANCH_NAME
#/                                  and to stop searching for vuh updates.
#/
#/         [--dont-use-git]         don't use any git commands.
#/                                  In this case you should run vuh in root directory (which contains .vuh)
#/                                  or specify path to it using '--config-path=<path>' parameter.
#/                                  This parameter can't be used with '--check-git-diff'.
#/                                  This parameter can't be used with '--dont-check-git-diff'.
#/
#/         [--config-dir=<path>]    Search for .vuh configuration file in another directory.
#/                                  You don't need to specify it if you are working with git repository.
#/                                  Suggesting to use this parameter with '--dont-use-git' parameter.
#/
#/     mrp, module-root-path        Show root path of specified module (for monorepos projects).
#/
#/         [-q | --quiet]           to show only root path (or errors messages if there are so).
#/
#/         [-pm=<project_module>]   to use specified module of mono repository project (instead of default).
#/
#/         [--dont-use-git]         don't use any git commands.
#/                                  In this case you should run vuh in root directory (which contains .vuh)
#/                                  or specify path to it using '--config-path=<path>' parameter.
#/
#/         [--config-dir=<path>]    Search for .vuh configuration file in another directory.
#/                                  You don't need to specify it if you are working with git repository.
#/                                  Suggesting to use this parameter with '--dont-use-git' parameter.
#/
#/     pm, project-modules          Show all project modules of current mono repository
#/                                  that were specified in .vuh file.
#/
#/         [-q | --quiet]           to show only project modules (or errors messages if there are so).
#/
#/         [--dont-use-git]         don't use any git commands.
#/                                  In this case you should run vuh in root directory (which contains .vuh)
#/                                  or specify path to it using '--config-path=<path>' parameter.
#/
#/         [--config-dir=<path>]    Search for .vuh configuration file in another directory.
#/                                  You don't need to specify it if you are working with git repository.
#/                                  Suggesting to use this parameter with '--dont-use-git' parameter.
#/
#/ This tool suggest relevant version for your current project or even update your local project's version.
#/ Vuh can work with your project's versions from any directory inside of your local repository.
#/ Vuh also can work with monorepos, so you can handle few different modules stored in one mono repository.
#/ Project repository: https://github.com/Greewil/version-update-helper
#
# Written by Shishkin Sergey <shishkin.sergey.d@gmail.com>

# Current vuh version
VUH_VERSION='2.10.0'

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
VIOLATE='\e[38;5;61m' # for changes
#\[\e[38;5;61m\]

# vuh global variables (Please don't modify!)
ROOT_REPO_DIR=''
CUR_DIR=''
LOCAL_VERSION=''
MAIN_VERSION=''
SUGGESTING_VERSION=''
SPECIFIED_MULTIPLE_PROJECT_MODULES='false'
INCREASING_VERSION_PART='patch'

# variables for handling semantic versions
VERSION_REG_EXP='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)'\
'(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?'\
'(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$'

# Console input variables (Please don't modify!)
COMMAND=''
STANDALONE_COMMAND='false'
SPECIFIED_VERSION=''
SPECIFIED_INCREASING_VERSION_PART='patch'
SPECIFIED_PROJECT_MODULE=''
SPECIFIED_MAIN_BRANCH=''
SPECIFIED_CONFIG_DIR=''
ARGUMENT_QUIET='false'
ARGUMENT_CHECK_GIT_DIFF='false'
ARGUMENT_DONT_CHECK_GIT_DIFF='false'
ARGUMENT_OFFLINE='false'
ARGUMENT_DONT_USE_GIT='false'


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

function _show_recursion_message() {
  message=$1
  echo -en "$VIOLATE($APP_NAME : RECURSION) $message$NEUTRAL_COLOR\n"
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

function _show_cant_use_both_arguments() {
  arg1_name=$1
  arg2_name=$2
  checking_arg_value=$3
  checking_arg_default_value=$4
  if [ "$checking_arg_value" != "$checking_arg_default_value" ]; then
    _show_invalid_usage_error_message "You can't use both parameters: '$arg1_name' and '$arg2_name'!"
    exit 1
  fi
}

function _show_try_grep_command_message() {
  module_name_prefix=''
  if [ "$SPECIFIED_PROJECT_MODULE" != '' ]; then
    module_name_prefix="$SPECIFIED_PROJECT_MODULE"'_'
  fi
  # shellcheck disable=SC2016
  cat_version_file_cmd='cat "$'"$module_name_prefix"'VERSION_FILE"'
  # shellcheck disable=SC2016
  grep_text_before_cmd='grep -E "$'"$module_name_prefix"'TEXT_BEFORE_VERSION_CODE"'
  # shellcheck disable=SC2016
  grep_text_after_cmd='grep -E "$'"$module_name_prefix"'TEXT_AFTER_VERSION_CODE"'
  check_line_command="source .vuh; $cat_version_file_cmd | $grep_text_before_cmd | $grep_text_after_cmd"
  make_sure_message_1="Run command '$check_line_command' and make sure that first output line contains your version. "
  special_symbols="'/', '\', '^', '$', '*', '(', ')', '{', '}', '[', ']'"
  grep_vars="$module_name_prefix"'TEXT_BEFORE_VERSION_CODE and '"$module_name_prefix"'TEXT_AFTER_VERSION_CODE variables'
  make_sure_message_2="Also make sure you escaped all special symbols ($special_symbols) with '\' symbol in $grep_vars."
  tip_message="If you are struggling to grep the only one line with needed version, you can add comment on that line."
  _show_error_message "$make_sure_message_1 \n$make_sure_message_2 \nTip: $tip_message"
}

function _show_git_diff_result() {
  result_successful=$1
  handling_revision=$2
  handling_location=$3
  comment_on_success=$4
  if [ "$ARGUMENT_QUIET" = 'false' ]; then
    if [ "$result_successful" = 'true' ]; then
      echo "Git diff with '$handling_revision' was not empty (location: '$handling_location'). $comment_on_success"
    else
      echo "Location '$handling_location' has no difference with '$handling_revision'."
    fi
  fi
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

# This function calls after each successful version update.
# This is default function but it can be overridden from .vuh config!
#
# $1 - Version before update
# $2 - New version after update
function after_successful_version_update() {
  # shellcheck disable=SC2034
  old_version=$1
  new_version=$2
}

# Changes default configuration values to configuration values of specified module.
# Throws error if module's MAIN_BRANCH_NAME or VERSION_FILE values are empty.
#
# $1 - Module name
function _use_module_configuration() {
  next_handling_module=$1
  cur_module_main_branch_name=''  # just for shellcheck
  eval cur_module_main_branch_name='$'"$next_handling_module"'_MAIN_BRANCH_NAME'
  if [ "$cur_module_main_branch_name" != '' ]; then
    MAIN_BRANCH_NAME="$cur_module_main_branch_name"
  fi
  eval VERSION_FILE='$'"$next_handling_module"'_VERSION_FILE'
  eval TEXT_BEFORE_VERSION_CODE='$'"$next_handling_module"'_TEXT_BEFORE_VERSION_CODE'
  eval TEXT_AFTER_VERSION_CODE='$'"$next_handling_module"'_TEXT_AFTER_VERSION_CODE'
  eval MODULE_ROOT_PATH='$'"$next_handling_module"'_MODULE_ROOT_PATH'
  eval IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES='$'"$next_handling_module"'_IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES'
  for var in $(compgen -v | grep "$next_handling_module\_.*_CHANGING_LOCATIONS"); do
    global_var_name=${var##*"$next_handling_module"\_}
    global_var_value=''
    eval global_var_value='$'"$var"
    eval "${global_var_name}"="${global_var_value}"
  done
  [ "$IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES" == '' ] && IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES='false'
  [ "$MAIN_BRANCH_NAME" == '' ] && _show_error_message "$next_handling_module"'_MAIN_BRANCH_NAME variable is empty!'
  [ "$VERSION_FILE" == '' ] && _show_error_message "$next_handling_module"'_VERSION_FILE variable is empty!'
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
    project_modules_without_spaces=$(echo "$PROJECT_MODULES" | tr -d "[:space:]")
    IFS=',' read -ra ADDR <<< "$project_modules_without_spaces"
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
  [ "$SPECIFIED_MULTIPLE_PROJECT_MODULES" = 'true' ] || _use_module_configuration_if_it_exists "$SPECIFIED_PROJECT_MODULE"
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

# This is default function but it can be overridden from .vuh config!
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

function _get_incremented_patch_version() {
  v_major=$1
  v_minor=$2
  v_patch=$3
  v_prerelease_info=$4
  v_metadata=$5
  v_patch=$(( v_patch + 1 )) || return 1
  echo "$v_major.$v_minor.$v_patch$v_prerelease_info$v_metadata"
}

function _get_incremented_minor_version() {
  v_major=$1
  v_minor=$2
  v_patch=$3
  v_prerelease_info=$4
  v_metadata=$5
  v_minor=$(( v_minor + 1 )) || return 1
  echo "$v_major.$v_minor.0$v_prerelease_info$v_metadata"
}

function _get_incremented_major_version() {
  v_major=$1
  v_minor=$2
  v_patch=$3
  v_prerelease_info=$4
  v_metadata=$5
  v_major=$(( v_major + 1 )) || return 1
  echo "$v_major.0.0$v_prerelease_info$v_metadata"
}

function _get_incremented_version() {
  v=$1
  if [[ $v =~ $VERSION_REG_EXP ]]; then
    prerelease_info=${BASH_REMATCH[4]}
    metadata=$(_get_metadata "$v") || return 1
    major_version=$(_get_major_version "$v") || return 1
    minor_version=$(_get_minor_version "$v") || return 1
    patch_version=$(_get_patch_version "$v") || return 1
    if [ "$INCREASING_VERSION_PART" = "patch" ]; then
      _get_incremented_patch_version "$major_version" "$minor_version" "$patch_version" "$prerelease_info" "$metadata" || return 1
    elif [ "$INCREASING_VERSION_PART" = "minor" ]; then
      _get_incremented_minor_version "$major_version" "$minor_version" "$patch_version" "$prerelease_info" "$metadata" || return 1
    elif [ "$INCREASING_VERSION_PART" = "major" ]; then
      _get_incremented_major_version "$major_version" "$minor_version" "$patch_version" "$prerelease_info" "$metadata" || return 1
    fi
  else
    return 1
  fi
}

# Compares two versions and returns the largest one. If input versions are equal returns '='.
#
# $1 - Version to handle
# $2 - Is increasing allowed
#
# Returns input version if increasing not allowed or increased version otherwise.
function _get_incremented_version_if_allowed() {
  v=$1
  is_operation_allowed=$2
  output_version="$v"
  if [ "$is_operation_allowed" = 'true' ]; then
    output_version=$(_get_incremented_version "$v") || {
      _show_error_message "Failed to increment $INCREASING_VERSION_PART version of '$v'!"
      exit 1
    }
  fi
  echo "$output_version"
}

function _update_increasing_version_part() {
  suggesting_version_part=$1
  if [ "$suggesting_version_part" != 'patch' ] &&
      [ "$suggesting_version_part" != 'minor' ] &&
      [ "$suggesting_version_part" != 'major' ]; then
    _show_error_message "Unknown type of version part: '$suggesting_version_part'!"
    exit 1
  fi
  if [ "$INCREASING_VERSION_PART" = '' ]; then
    INCREASING_VERSION_PART="$suggesting_version_part"
  fi
  if [ "$suggesting_version_part" = 'major' ] || [ "$INCREASING_VERSION_PART" = 'major' ]; then
    INCREASING_VERSION_PART='major'
  elif [ "$suggesting_version_part" = 'minor' ] || [ "$INCREASING_VERSION_PART" = 'minor' ]; then
    INCREASING_VERSION_PART='minor'
  elif [ "$suggesting_version_part" = 'patch' ] || [ "$INCREASING_VERSION_PART" = 'patch' ]; then
    INCREASING_VERSION_PART='patch'
  fi
}

function _is_git_diff_in_location() {
  location_for_git_diff=$1
  git_diff=$(git diff --name-only "$main_branch_path" "$location_for_git_diff") || {
    _show_error_message "Failed to get git diff with branch '$main_branch_path' for directory '$MODULE_ROOT_PATH'!"
    exit 1
  }
  if [ "$git_diff" = '' ]; then
    echo 'false'
  else
    echo 'true'
  fi
}

function _get_root_repo_dir() {
  if [ "$ARGUMENT_DONT_USE_GIT" = 'true' ]; then
    if [ "$SPECIFIED_CONFIG_DIR" = '' ]; then
      ROOT_REPO_DIR="$CUR_DIR"
    else
      ROOT_REPO_DIR="$SPECIFIED_CONFIG_DIR"
    fi
  else
    ROOT_REPO_DIR=$(git rev-parse --show-toplevel) || {
      _show_error_message "Can't find root repo directory!"
      return 1
    }
  fi
}

function _get_version_line_from_file() {
  version_file=$1
  version_line=$(echo "$version_file" | grep -E "$TEXT_BEFORE_VERSION_CODE" | grep -E "$TEXT_AFTER_VERSION_CODE" | sed 1q)
  if [ "$version_line" = '' ]; then
    _show_error_message "Failed to get line, containing version from version file!"
    return 1
  fi
  echo "$version_line"
}

function _get_version_from_file() {
  version_file=$1
  version_line=$(_get_version_line_from_file "$version_file") || return 1
  version_prefix=$(sed -r "s/($TEXT_BEFORE_VERSION_CODE).*/\1/" <<< "$version_line") || return 1
  if [[ "$TEXT_BEFORE_VERSION_CODE" != '' ]]; then
    version=${version_line##*"$version_prefix"} || return 1
  else
    version="$version_line"
  fi
  if [[ "$TEXT_AFTER_VERSION_CODE" != '' ]]; then
    version_postfix=$(sed -r "s/.*($TEXT_AFTER_VERSION_CODE)/\1/" <<< "$version") || return 1
    version=${version%%"$version_postfix"*} || return 1
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

function _get_file_from_another_branch() {
  branch_name=$1
  file_path=$2
  cd "$ROOT_REPO_DIR" || return 1
  git show "$branch_name:./$file_path"
  cd "$CUR_DIR" || return 1
}

function _remove_tmp_dir() {
  dir_to_remove=$1
  [ "$dir_to_remove" != '' ] && rm -rf "/tmp/$dir_to_remove"
}

function _unset_conf_variables() {
  # unset module variables
  PROJECT_MODULES=''
  declare -a module_variable_suffixes=('MAIN_BRANCH_NAME' 'VERSION_FILE' 'TEXT_BEFORE_VERSION_CODE'
                                       'TEXT_AFTER_VERSION_CODE' 'MODULE_ROOT_PATH'
                                       'IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES' '_CHANGING_LOCATIONS')
  for module_variable_suffix in "${module_variable_suffixes[@]}"; do
    for var in $(compgen -v | grep ".*$module_variable_suffix"); do
      eval "${var}"=''
    done
  done

  # unset basic variables
  # vuh-0.1.0
  MAIN_BRANCH_NAME='NO_MAIN_BRANCH_NAME'
  VERSION_FILE='NO_VERSION_FILE'
  TEXT_BEFORE_VERSION_CODE='NO_TEXT_BEFORE_VERSION_CODE'
  TEXT_AFTER_VERSION_CODE='NO_TEXT_AFTER_VERSION_CODE'
  # vuh-2.2.0
  MODULE_ROOT_PATH=''
  IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES='false'
}

# Checks compatibility of vuh and loaded configuration file.
# Throws an error if some of default variables wasn't loaded at all.
#
# Returns nothing.
function _check_conf_data_loaded_properly() {
  if [ "$SPECIFIED_MULTIPLE_PROJECT_MODULES" = 'true' ] || [ "$COMMAND" = 'project-modules' ]; then
    return 0
  fi
  if { [ "$ARGUMENT_DONT_USE_GIT" != 'true' ] && [ "$MAIN_BRANCH_NAME" = 'NO_MAIN_BRANCH_NAME' ]; } ||
      [ "$VERSION_FILE" = 'NO_VERSION_FILE' ] ||
      [ "$TEXT_BEFORE_VERSION_CODE" = 'NO_TEXT_BEFORE_VERSION_CODE' ] ||
      [ "$TEXT_AFTER_VERSION_CODE" = 'NO_TEXT_AFTER_VERSION_CODE' ]; then
    if [ "$PROJECT_MODULES" != '' ] && [ "$SPECIFIED_PROJECT_MODULE" = '' ]; then
      this_is_monorepo_message="This repository was configured as mono repository with multiple modules."
      specify_module_message="So you should specify module with which you want to work in parameter '-pm=MODULE_NAME'."
      available_modules_message="Here is the list of available modules for this repository: '$PROJECT_MODULES'"
      _show_error_message "$this_is_monorepo_message $specify_module_message $available_modules_message"
    else
      _show_error_message "Configuration test failed! Configuration variables were empty or weren't loaded at all!"
    fi
    return 1
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
  _check_conf_data_loaded_properly || return 1
}

function _load_remote_conf_file() {
  _unset_conf_variables || return 1
  branch_name=$1
  handling_config_file="origin/$branch_name:.vuh"
  main_branch_config_file=$(_get_file_from_another_branch "origin/$branch_name" ".vuh") || {
    _show_error_message "Failed to read remote configuration file $handling_config_file!"
    return 1
  }
  _load_project_variables_from_config "$main_branch_config_file" || {
    _show_error_message "Failed to load variables from remote configuration file $handling_config_file!"
    return 1
  }
  _check_conf_data_loaded_properly || return 1
}

function _get_latest_available_vuh_version() {
  _unset_conf_variables || return 1
  main_vuh_branch='main'
  vuh_conf_file=$(curl -s "https://raw.githubusercontent.com/$OFFICIAL_REPO/$main_vuh_branch/.vuh") || return 1
  _load_project_variables_from_config "$vuh_conf_file" || return 1
  _check_conf_data_loaded_properly || return 1
  vuh_version_file=$(curl -s "https://raw.githubusercontent.com/$OFFICIAL_REPO/$main_vuh_branch/$VERSION_FILE") || return 1
  AVAILABLE_VERSION=$(_get_version_from_file "$vuh_version_file") || return 1
}

function _check_auto_update_logs() {
  update_log_file=$1
  logs=$(<"$update_log_file")
  [[ "$logs" == *'was successfully installed'* ]] || _show_error_message 'Failed to install update!'
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

function _get_additional_arguments_from_variables() {
  args_str=''
  [ "$ARGUMENT_QUIET" = 'true' ] && args_str="$args_str -q"
  [ "$ARGUMENT_CHECK_GIT_DIFF" = 'true' ] && args_str="$args_str --check-git-diff"
  [ "$ARGUMENT_DONT_CHECK_GIT_DIFF" = 'true' ] && args_str="$args_str --dont-check-git-diff"
  [ "$ARGUMENT_OFFLINE" = 'true' ] && args_str="$args_str --offline"
  [ "$ARGUMENT_DONT_USE_GIT" = 'true' ] && args_str="$args_str --dont-use-git"
  [ "$SPECIFIED_INCREASING_VERSION_PART" != 'patch' ] && args_str="$args_str -vp=$SPECIFIED_INCREASING_VERSION_PART"
  [ "$SPECIFIED_VERSION" != '' ] && args_str="$args_str -v=$SPECIFIED_VERSION"  # TODO maybe throw warning if ALL modules
  [ "$SPECIFIED_MAIN_BRANCH" != '' ] && args_str="$args_str -mb=$SPECIFIED_MAIN_BRANCH"
  [ "$SPECIFIED_CONFIG_DIR" != '' ] && args_str="$args_str --config-dir=$SPECIFIED_CONFIG_DIR"
  echo "$args_str"
}

function _handle_multiple_modules_call() {
  if [ "$SPECIFIED_PROJECT_MODULE" = "ALL" ]; then
    _load_local_conf_file || exit 1
    project_modules_without_spaces=$(echo "$PROJECT_MODULES" | tr -d "[:space:]")
    IFS=',' read -ra ADDR <<< "$project_modules_without_spaces"
    for module in "${ADDR[@]}"; do
      echo ""
      _show_recursion_message "Handling module: $module"
      vuh_cmd="${BASH_SOURCE[0]}"
      additional_params=$(_get_additional_arguments_from_variables)
      $vuh_cmd "$COMMAND" -pm="$module" --offline $additional_params
    done
    exit 0
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
    _show_try_grep_command_message
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
  [ "$ARGUMENT_OFFLINE" = 'true' ] || _fetch_remote_branches || exit 1
  _load_local_conf_file || exit 1
  remote_branch=$MAIN_BRANCH_NAME
  if [[ "$SPECIFIED_MAIN_BRANCH" != '' ]]; then
    remote_branch="$SPECIFIED_MAIN_BRANCH" || {
      _show_error_message "Failed to set specified main branch '$SPECIFIED_MAIN_BRANCH'!"
      exit 1
    }
  fi
  if [ "$ARGUMENT_QUIET" = 'true' ]; then
    {
      _load_remote_conf_file "$remote_branch" || {
        _show_warning_message "vuh will use local configuration to get remote version from origin/$remote_branch"
        _load_local_conf_file || exit 1
      }
    } > /dev/null
  else
    _load_remote_conf_file "$remote_branch" || {
      _show_warning_message "vuh will use local configuration to get remote version from origin/$remote_branch"
      _load_local_conf_file || exit 1
    }
  fi
  handling_file="origin/$remote_branch:$VERSION_FILE"
  main_branch_file=$(_get_file_from_another_branch "origin/$remote_branch" "$VERSION_FILE") || {
    _show_error_message "Failed to load file $handling_file"
    exit 1
  }
  MAIN_VERSION=$(_get_version_from_file "$main_branch_file") || {
    _show_error_message "Failed to get main version from '$handling_file'!"
    _show_try_grep_command_message
    _show_error_message "Also make sure that origin/$remote_branch has the same structure as your local version file."
    make_sure_message="If your origin/$remote_branch branch has different version storage logic make sure that it "\
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

function _get_suggesting_version_using_git() {
  read_local_version || exit 1
  read_main_version || exit 1
  _load_local_conf_file || exit 1
  [ "$ARGUMENT_QUIET" = 'true' ] || _show_function_title 'suggesting relevant version'
  largest_version=$(_get_largest_version "$MAIN_VERSION" "$LOCAL_VERSION") || {
    _show_error_message "Failed to select larger version between '$MAIN_VERSION' and '$LOCAL_VERSION'!"
    exit 1
  }
  if [ "$largest_version" = '=' ]; then
    fair_largest_version="$MAIN_VERSION"
  else
    fair_largest_version="$largest_version"
  fi

  # checking is version increasing allowed or not
  is_version_increasing_allowed='true'
  if { [ "$ARGUMENT_DONT_CHECK_GIT_DIFF" != 'true' ] && [ "$IS_INCREMENT_REQUIRED_ONLY_ON_CHANGES" = 'true' ]; } ||
      [ "$ARGUMENT_CHECK_GIT_DIFF" = 'true' ]; then
    main_branch_path="HEAD..origin/$MAIN_BRANCH_NAME"

    # checking is version increasing allowed or not
    module_location="$MODULE_ROOT_PATH"
    if [ "$MODULE_ROOT_PATH" = '' ]; then
      module_location="."
    fi
    is_version_increasing_allowed=$(_is_git_diff_in_location "$module_location")
    comment_if_allowed=""
    _show_git_diff_result "$is_version_increasing_allowed" "$main_branch_path" "$module_location" "$comment_if_allowed"

    # checking is there differences leading to minor updates
    if [ "$MINOR_CHANGING_LOCATIONS" != '' ]; then
      is_increasing_minor=$(_is_git_diff_in_location "$MINOR_CHANGING_LOCATIONS")
      [ "$is_increasing_minor" = 'true' ] && _update_increasing_version_part 'minor'
      comment_if_allowed="This changes require minor version update."
      _show_git_diff_result "$is_increasing_minor" "$main_branch_path" "$MINOR_CHANGING_LOCATIONS" "$comment_if_allowed"
    fi

    # checking is there differences leading to major updates
    if [ "$MAJOR_CHANGING_LOCATIONS" != '' ]; then
      is_increasing_major=$(_is_git_diff_in_location "$MAJOR_CHANGING_LOCATIONS")
      [ "$is_increasing_major" = 'true' ] && _update_increasing_version_part 'major'
      comment_if_allowed="This changes require major version update."
      _show_git_diff_result "$is_increasing_major" "$main_branch_path" "$MAJOR_CHANGING_LOCATIONS" "$comment_if_allowed"
    fi
  fi

  if [ "$SPECIFIED_VERSION" = '' ]; then
    # if used -vp=.. param
    incremented_main_version=$(_get_incremented_version_if_allowed "$MAIN_VERSION" "$is_version_increasing_allowed")
    if [ "$fair_largest_version" = "$MAIN_VERSION" ]; then
      SUGGESTING_VERSION="$incremented_main_version"
    else
      largest_version=$(_get_largest_version "$incremented_main_version" "$LOCAL_VERSION") || {
        _show_error_message "Failed to select larger version between '$incremented_main_version' and '$LOCAL_VERSION'!"
        exit 1
      }
      if [ "$largest_version" = '=' ]; then
        SUGGESTING_VERSION="$incremented_main_version"
      else
        SUGGESTING_VERSION="$largest_version"
      fi
    fi
  else
    # if used -v=.. param
    largest_version=$(_get_largest_version "$fair_largest_version" "$SPECIFIED_VERSION") || {
      _show_error_message "Failed to select larger version between '$fair_largest_version' and '$SPECIFIED_VERSION'!"
      exit 1
    }
    if [ "$largest_version" = '=' ]; then
      if [ "$fair_largest_version" = "$LOCAL_VERSION" ]; then
        SUGGESTING_VERSION=$LOCAL_VERSION
      else
        SUGGESTING_VERSION=$(_get_incremented_version_if_allowed "$MAIN_VERSION" "$is_version_increasing_allowed")
      fi
    elif [ "$largest_version" = "$MAIN_VERSION" ]; then
      SUGGESTING_VERSION=$(_get_incremented_version_if_allowed "$MAIN_VERSION" "$is_version_increasing_allowed")
    elif [ "$largest_version" = "$SPECIFIED_VERSION" ]; then
      SUGGESTING_VERSION=$SPECIFIED_VERSION
    else
      SUGGESTING_VERSION=$LOCAL_VERSION
    fi
  fi
}

function _get_suggesting_version_without_git() {
  [ "$ARGUMENT_QUIET" = 'true' ] || echo "Using vuh without git!"
  read_local_version || exit 1
  [ "$ARGUMENT_QUIET" = 'true' ] || _show_function_title 'suggesting relevant version'
  if [ "$SPECIFIED_VERSION" = '' ]; then
    # if used -vp=.. param
    SUGGESTING_VERSION=$(_get_incremented_version_if_allowed "$LOCAL_VERSION" "true")
  else
    # if used -v=.. param
    SUGGESTING_VERSION=$(_get_largest_version "$LOCAL_VERSION" "$SPECIFIED_VERSION") || {
      _show_error_message "Failed to select larger version between '$LOCAL_VERSION' and '$SPECIFIED_VERSION'!"
      exit 1
    }
  fi
}

function get_suggesting_version() {
  if [ "$ARGUMENT_DONT_USE_GIT" = 'true' ]; then
    _get_suggesting_version_without_git || exit 1
  else
    _get_suggesting_version_using_git || exit 1
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

function get_project_modules() {
  [ "$ARGUMENT_QUIET" = 'false' ] && _show_function_title 'getting project modules'
  _load_local_conf_file || exit 1
  if [ "$PROJECT_MODULES" = "" ]; then
    _show_error_message "PROJECT_MODULES wasn't specified in configuration file (.vuh)."
    _show_error_message "It may mean that this project has only one module and it's not pretending to be a monorepo."
    exit 1
  else
    [ "$ARGUMENT_QUIET" = 'false' ] && echo "current project has next modules: $PROJECT_MODULES"
    [ "$ARGUMENT_QUIET" = 'true' ] && echo "$PROJECT_MODULES"
  fi
}

function show_module_root_path() {
  [ "$ARGUMENT_QUIET" = 'false' ] && _show_function_title 'showing module root path'
  _load_local_conf_file || exit 1
  if [ "$SPECIFIED_PROJECT_MODULE" = "" ]; then
    _show_error_message "Project module should be specified in this command (see 'vuh -h' for more info)!"
    exit 1
  fi
  [ "$ARGUMENT_QUIET" = 'false' ] && echo "$SPECIFIED_PROJECT_MODULE module located in: '$MODULE_ROOT_PATH'"
  [ "$ARGUMENT_QUIET" = 'true' ] && echo "$MODULE_ROOT_PATH"
}

function update_version() {
  new_version=$1
  [ "$ARGUMENT_QUIET" = 'false' ] && _show_function_title 'updating local version'
  _load_local_conf_file || exit 1
  version_file=$(<"$ROOT_REPO_DIR/$VERSION_FILE") || {
    _show_error_message "Failed to load file $ROOT_REPO_DIR/$VERSION_FILE!"
    exit 1
  }
  if [ "$LOCAL_VERSION" != "$new_version" ]; then
    old_version_line=$(_get_version_line_from_file "$version_file")
    version_prefix=$(sed -r "s/($TEXT_BEFORE_VERSION_CODE).*/\1/" <<< "$old_version_line") || exit 1
    version_and_postfix=${old_version_line##*"$version_prefix"} || exit 1
    if [[ "$TEXT_AFTER_VERSION_CODE" != '' ]]; then
      version_postfix=$(sed -r "s/.*($TEXT_AFTER_VERSION_CODE)/\1/" <<< "$version_and_postfix") || exit 1
    fi
    new_version_line="$version_prefix$new_version$version_postfix"
    echo "${version_file/$old_version_line/$new_version_line}" > "$ROOT_REPO_DIR/$VERSION_FILE"
    after_successful_version_update "$LOCAL_VERSION" "$new_version"
    [ "$ARGUMENT_QUIET" = 'false' ] && _show_updated_message "local version updated: $LOCAL_VERSION -> $new_version"
    [ "$ARGUMENT_QUIET" = 'true' ] && echo "$new_version"
  else
    after_successful_version_update "$LOCAL_VERSION" "$new_version"
    [ "$ARGUMENT_QUIET" = 'false' ] && echo "your local version already up to date: $LOCAL_VERSION"
    [ "$ARGUMENT_QUIET" = 'true' ] && echo "$LOCAL_VERSION"
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


CUR_DIR="$(pwd)"

_unset_conf_variables

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h|--help)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--help'
    STANDALONE_COMMAND='true'
    shift ;;
  -v|--version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--version'
    STANDALONE_COMMAND='true'
    shift ;;
  --configuration)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--configuration'
    STANDALONE_COMMAND='true'
    shift ;;
  --update)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--update'
    STANDALONE_COMMAND='true'
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
  mrp|module-root-path)
    _exit_if_using_multiple_commands "$1"
    COMMAND='module-root-path'
    shift ;;
  pm|project-modules)
    _exit_if_using_multiple_commands "$1"
    COMMAND='project-modules'
    shift ;;
  uv|update-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='update-version'
    shift ;;
  -v=*)
    _check_arg "$1"
    _show_cant_use_both_arguments '-v' '-vp' "$SPECIFIED_INCREASING_VERSION_PART" 'patch'
    SPECIFIED_VERSION=${1#*=}
    shift ;;
  -vp=*)
    _check_arg "$1"
    _show_cant_use_both_arguments '-v' '-vp' "$SPECIFIED_VERSION" ''
    SPECIFIED_INCREASING_VERSION_PART=${1#*=}
    _update_increasing_version_part "$SPECIFIED_INCREASING_VERSION_PART"
    shift ;;
  -pm=*)
    _check_arg "$1"
    SPECIFIED_PROJECT_MODULE=${1#*=}
    if [ "$SPECIFIED_PROJECT_MODULE" = "ALL" ]; then  # TODO || [ if ',' in PM ]
      SPECIFIED_MULTIPLE_PROJECT_MODULES='true'
    fi
    shift ;;
  -q|--quiet)
    _check_arg "$1"
    ARGUMENT_QUIET='true'
    shift ;;
  --check-git-diff)
    _check_arg "$1"
    _show_cant_use_both_arguments '--check-git-diff' '--dont-check-git-diff' "$ARGUMENT_DONT_CHECK_GIT_DIFF" 'false'
    _show_cant_use_both_arguments '--check-git-diff' '--dont-use-git' "$ARGUMENT_DONT_USE_GIT" 'false'
    ARGUMENT_CHECK_GIT_DIFF='true'
    shift ;;
  --dont-check-git-diff)
    _check_arg "$1"
    _show_cant_use_both_arguments '--dont-check-git-diff' '--check-git-diff' "$ARGUMENT_CHECK_GIT_DIFF" 'false'
    _show_cant_use_both_arguments '--dont-check-git-diff' '--dont-use-git' "$ARGUMENT_DONT_USE_GIT" 'false'
    ARGUMENT_DONT_CHECK_GIT_DIFF='true'
    shift ;;
  --offline|--airplane-mode)
    _check_arg "$1"
    ARGUMENT_OFFLINE='true'
    shift ;;
  --dont-use-git)
    _check_arg "$1"
    _show_cant_use_both_arguments '--dont-use-git' '--check-git-diff' "$ARGUMENT_CHECK_GIT_DIFF" 'false'
    _show_cant_use_both_arguments '--dont-use-git' '--dont-check-git-diff' "$ARGUMENT_DONT_CHECK_GIT_DIFF" 'false'
    if [ "$COMMAND" = 'main-version' ]; then
      _show_invalid_usage_error_message "You can't use --dont-use-git parameter with 'mv' or 'main-version' command!"
      exit 1
    fi
    ARGUMENT_DONT_USE_GIT='true'
    shift ;;
  -mb=*)
    _check_arg "$1"
    SPECIFIED_MAIN_BRANCH=${1#*=}
    shift ;;
  --config-dir=*)
    _check_arg "$1"
    SPECIFIED_CONFIG_DIR=${1#*=}
    shift ;;
  -*)
    _show_invalid_usage_error_message "Unknown option '$1'!"
    exit 1 ;;
  *)
    _show_invalid_usage_error_message "Unknown command '$1'!"
    exit 1 ;;
  esac
done

if [[ "$STANDALONE_COMMAND" = 'false' ]] &&
    [[ "$ARGUMENT_QUIET" != 'true' ]] && [[ "$ARGUMENT_OFFLINE" != 'true' ]]; then
  tmp_specified_project_module="$SPECIFIED_PROJECT_MODULE"
  SPECIFIED_PROJECT_MODULE=''
  _regular_check_available_updates
  SPECIFIED_PROJECT_MODULE="$tmp_specified_project_module"
fi

if [[ "$STANDALONE_COMMAND" = 'false' ]]; then
  [ "$SPECIFIED_MULTIPLE_PROJECT_MODULES" = 'true' ] && _handle_multiple_modules_call
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
project-modules)
  get_project_modules
  exit 0
  ;;
module-root-path)
  show_module_root_path
  exit 0
  ;;
update-version)
  get_suggesting_version
  update_version "$SUGGESTING_VERSION"
  exit 0
  ;;
esac
