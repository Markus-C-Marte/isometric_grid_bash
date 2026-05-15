#!/bin/bash
# Library for building grid-based fixtures using grid_size

[[ -z "${_GRID_FIXTURES_LOADED}" ]] || return 0
readonly _GRID_FIXTURES_LOADED=1
source ./validators.sh
    
grid_fixtures::init() {
  # Assign grid_size to 8 or $1
  local holder=${1:-8}
  readonly grid_size="${holder}"
  # quit if odd
  ((  grid_size % 2 == 1 )) && { printf "Error, gridsize: %d ! should be even\n" "${grid_size}" >&2; return 1; }
  # make half 
  readonly half=$(( grid_size / 2 ))
  # declare l and r pos arrays
  # declare -p r_Pos &>/dev/null || declare -a r_Pos
  # declare -p l_Pos &>/dev/null || declare -a l_Pos
  # fill them
  grid_fixtures::fill_r_Pos
  # make line global
  grid_fixtures::make_line
} 

grid_fixtures::fill_r_Pos() {
  # Fills the r_Pos array with a symmetric pyramid pattern
  # Calls fill_l_Pos for each index to populate l_Pos
  # Globals: grid_size (required), r_Pos (modified), l_Pos (modified)
  # Args: none
  # Outputs: none

  for ((i = 0; i < grid_size; i++)); do
    if (( i < half )); then
      r_Pos[i]=$((half + i))
    else
      r_Pos[i]=$((half + (grid_size - i - 1)))
    fi
    grid_fixtures::_fill_l_Pos "$i"
  done
  readonly r_Pos
  readonly l_Pos
}

grid_fixtures::_fill_l_Pos() {
  # Fills l_Pos[i] based on r_Pos[i]
  # Globals: grid_size (required), r_Pos (required), l_Pos (modified)
  # Args: i (array index)
  # Outputs: none

  local i=$1
  l_Pos[i]=$(( (grid_size - 1) - r_Pos[i] ))
}

grid_fixtures::make_line() {
  # Creates variable 'line' containing grid_size spaces
  # Globals: grid_size (required), line (modified)
  # Args: none
  # Outputs: none

  printf -v line '%*s' "$grid_size"
  readonly line
}
