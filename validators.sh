#!/bin/bash

# Validation helpers for grid diamond tile generation
# Each validator returns 0 (pass) or 1 (fail)

[[ -z "${_VALIDATORS_SOURCED}" ]] || return 0
_VALIDATORS_SOURCED=1

# Checks that every argument passed is non-empty.
# Globals: none
# Args: variable arguments to check
# Output: none
# Returns: 0 if all args non-empty, 1 if any empty or no args
validators::is_set() {
    [[ $# -eq 0 ]] && return 1
    for var in "$@"; do
        [[ -n "$var" ]] || return 1
    done
}

# Check all arguments match ^-?[0-9]+$ (optional minus sign, digits only).
# Globals: none
# Args: variable arguments to validate
# Output: none
# Returns: 0 if all args are integers, 1 otherwise
validators::is_integer() {
    validators::is_set "$@" || return 1
    for val in "$@"; do
        [[ "${val}" =~ ^-?[0-9]+$ ]] || return 1
    done
}

# Check if $1 is within bounds. With 1 arg: [0, grid_size-1] (defaults to 8). With 2 args: equal check.
# With 3 args: [$2, $3] inclusive.
# Globals: grid_size (optional; defaults to 8 if not set)
# Args: $1=value; $2=lower_bound (optional); $3=upper_bound (optional)
# Output: error message to stderr on invalid arg count
# Returns: 0 if in bounds, 1 otherwise
validators::is_in_bounds() {
    validators::is_set "$@" || return 1
    validators::is_integer "$@" || return 1
    local tval lbound ubound
    local grid_size="${grid_size:-8}"

    case $# in
        1)
            tval="$1"
            lbound=0
            ubound=$((grid_size - 1))
            ;;
        2)
            tval="$1"
            lbound="$2"
            ubound="$2"
            ;;
        3)
            tval="$1"
            lbound="$2"
            ubound="$3"
            ;;
        *)
            echo "error: expected 1, 2, or 3 arguments; got $#" >&2
            return 1
            ;;
    esac

    ! (( tval < lbound || tval > ubound ))
}

# Check if length of $1 equals $2.
# Globals: none
# Args: $1=string to measure; $2=expected_length
# Output: none
# Returns: 0 if lengths match, 1 otherwise
validators::is_length() {
    [[ $# -eq 2 ]] || return 1
    validators::is_integer "$2" || return 1
    local tstring="$1"
    local tval="$2"
    validators::is_equal "${#tstring}" "$tval"
}

# Check if $1 equals $2 (both must be integers).
# Globals: none
# Args: $1=value1; $2=value2
# Output: none
# Returns: 0 if equal, 1 otherwise
validators::is_equal() {
    validators::is_set "$@" || return 1
    validators::is_integer "$@" || return 1
    local i="$1"
    local j="$2"
    (( i == j ))
}
