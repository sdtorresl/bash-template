#!/usr/bin/env bash

# Title:        The name of your script
# Description:  A description of your script
# Author:       Sergio Torres (sdtorresl@innovaciones.co)
# Version:      0.1
# Usage:
#   ./template.sh --help

# Default variables
: "${LOG_LEVEL:=5}"

function help () {
    echo """
Usage: ./template.sh [OPTIONS]
A brief description

Prerequisites:
  - Some prerequisites

Arguments:
  -l|-level     Set log level (Default 5)
                    1 Alert
                    2 Critical
                    3 Error
                    4 Warning
                    5 Info
                    6 Notice
                    7 Debug
  -h|--help     Print this help
"""
    exit 0
}

function log () {
    local log_level="${1}"
    shift

    # shellcheck disable=SC2034
    local color_debug="\x1b[35m"
    # shellcheck disable=SC2034
    local color_info="\x1b[34m"
    # shellcheck disable=SC2034
    local color_notice="\x1b[32m"
    # shellcheck disable=SC2034
    local color_warning="\x1b[33m"
    # shellcheck disable=SC2034
    local color_error="\x1b[31m"
    # shellcheck disable=SC2034
    local color_critical="\x1b[1;31m"
    # shellcheck disable=SC2034
    local color_alert="\x1b[1;33;41m"
    # shellcheck disable=SC2034
    local color_emergency="\x1b[1;4;5;33;41m"

    local colorvar="color_${log_level}"

    local color="${!colorvar:-${color_error}}"
    local color_reset="\x1b[0m"

    if [[ "${NO_COLOR:-}" = "true" ]] || ( [[ "${TERM:-}" != "xterm"* ]] && [[ "${TERM:-}" != "screen"* ]] ) || [[ ! -t 2 ]]; then
        if [[ "${NO_COLOR:-}" != "false" ]]; then
            # Don't use colors on pipes or non-recognized terminals
            color=""; color_reset=""
        fi
    fi

    # all remaining arguments are to be printed
    local log_line=""

    while IFS=$'\n' read -r log_line; do
       echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%s]" "${log_level^^}")${color_reset} ${log_line}" 1>&2
    done <<< "${@:-}"
}

function emergency () { log emergency "${@}"; exit 1; }
function alert ()     { [[ "${LOG_LEVEL}" -ge 1 ]] && log alert "${@}"; true; }
function critical ()  { [[ "${LOG_LEVEL}" -ge 2 ]] && log critical "${@}"; true; }
function error ()     { [[ "${LOG_LEVEL}" -ge 3 ]] && log error "${@}"; true; }
function warning ()   { [[ "${LOG_LEVEL}" -ge 4 ]] && log warning "${@}"; true; }
function notice ()    { [[ "${LOG_LEVEL}" -ge 5 ]] && log notice "${@}"; true; }
function info ()      { [[ "${LOG_LEVEL}" -ge 6 ]] && log info "${@}"; true; }
function debug ()     { [[ "${LOG_LEVEL}" -ge 7 ]] && log debug "${@}"; true; }

function main () {
    notice "Program started"
}

POSITIONAL=()
while [[ $# > 0 ]]; do
    case "$1" in
        -l|--level)
            LOG_LEVEL=$2
            shift 2
        ;;
        -h|--help)
            help
        ;;
        *) # Unknown args
            help
        POSITIONAL+=("$1")
        shift
        ;;
    esac
done

set -- "${POSITIONAL[@]}" # restore positional params

# Run main program
main
