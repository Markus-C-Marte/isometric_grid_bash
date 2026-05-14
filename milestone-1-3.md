# Milestone 1 — Print a Single Diamond Tile

## Goal
Get one diamond tile printing correctly in the terminal.
No dynamic math. No user input. Just hardcoded values and two functions.

---

## Hardcoded Values

`grid_size` is the single source of truth. Everything else is derived from it.

```bash
grid_size=8                   # total width and height of the tile in characters
                              # NOTE: current formula assumes even grid_size.
                              # odd grid_size would produce a non-integer hw/hh
                              # and would need a different approach (see odd grid note below)

grid_width=$grid_size         # width of the tile in characters
grid_height=$grid_size        # height of the tile in characters (equal for uniform diamond)

hw=$(( grid_width / 2 ))      # half-width  = 4  (even-only formula: integer division)
hh=$(( grid_height / 2 ))     # half-height = 4  (same as hw for uniform diamond)

l_Pos=( 3 2 1 0 0 1 2 3 )    # left char position per row  — must have exactly grid_width elements
r_Pos=( 4 5 6 7 7 6 5 4 )    # right char position per row — must have exactly grid_width elements
                              # complement rule: l_Pos[i] + r_Pos[i] = grid_width - 1 (= 7)
                              # NOTE: this complement rule holds cleanly for even grids.
                              # for odd grids, the center row would have l and r meeting
                              # at the same index — a single point, not a gap — which
                              # may require special-casing that row in print_map
```

---

## Validation Helpers

Small reusable functions that each handle one concern. Return exit code 0 (pass) or 1 (fail). Designed to be called inline as guards.

### `is_set`
Checks that every argument passed is non-empty. Fails on the first unset value.
```bash
is_set() {
    for var in "$@"; do
        [[ -n "$var" ]] || return 1
    done
}
```
**Usage:**
```bash
# scalars
is_set "$grid_size" "$grid_width" "$grid_height" "$hw" "$hh" || return 1
# arrays need a different check — is_set can't see inside them
# also verify array sizes match grid_width
[[ ${#l_Pos[@]} -eq $grid_width && ${#r_Pos[@]} -eq $grid_width ]] || return 1
```

---

### `is_integer` *(stubbed)*
```bash
# TODO: check $1 matches ^-?[0-9]+$
```

---

### `is_in_bounds` *(stubbed)*
```bash
# TODO: check $1 is within [$2, $3]
# $2 defaults to 0 if not provided
# $3 defaults to grid_width - 1 if not provided
# negatives blocked by default lower bound of 0 — not explicitly forbidden
```

---

### `is_length` *(stubbed)*
```bash
# TODO: check length of $1 equals $2
# NOTE: ${#1} won't work directly on positional params
# assign to local first: local str="$1"; then check ${#str}
```

---

## Functions Needed

### 1. `replace_character`
Slots a single character into a position in a line string.

**Args:** `$line` `$index` `$char`

**Returns:** the modified line via `echo`

**Body:**
```bash
echo "${line:0:$index}${char}${line:$(( index + 1 ))}"
```

---

### Validation — `replace_character` *(stubbed)*
```bash
# TODO: validate $# == 3
# TODO: validate ${#line} == grid_width            — use is_length
# TODO: validate $index is an integer              — use is_integer
# TODO: validate $index is in [0, grid_width - 1]  — use is_in_bounds
# TODO: validate ${#char} == 1                     — use is_length
```

---

### 2. `print_map`
Loops through every row, builds the line, and echoes it.

**Args:** none (uses globals `grid_width`, `grid_height`, `l_Pos`, `r_Pos`, `hh`)

**Loop bound:** `grid_height` — not derived from the array

**Char swap:** `/` and `\` for the top half, swapped to `\` and `/` at the halfway point (`i == hh`)
- NOTE: for even grids, `hh` lands exactly between two rows — the swap happens cleanly.
  For odd grids, there is a true center row where l and r would meet at one point.
  The swap condition `i == hh` may need special handling for that center row.

**Body outline:**
```bash
print_map() {
    local lchr='/'
    local rchr='\\'
    local base_line="        "  # grid_width spaces — blank canvas for each row

    for (( i=0; i<grid_height; i++ )); do
        if (( i == hh )); then
            # TODO: swap lchr and rchr here
        fi

        local line="$base_line"
        line=$(replace_character "$line" "${l_Pos[$i]}" "$lchr")
        line=$(replace_character "$line" "${r_Pos[$i]}" "$rchr")
        echo "$line"
    done
}
```

---

### Validation — `print_map` *(stubbed)*
```bash
# TODO: validate grid_width, grid_height, hh are set   — use is_set
# TODO: validate l_Pos and r_Pos are sized to grid_width
#         [[ ${#l_Pos[@]} -eq $grid_width && ${#r_Pos[@]} -eq $grid_width ]] || return 1
```

---

## Expected Output (hw=4)

```
   /\
  /  \
 /    \
/      \
\      /
 \    /
  \  /
   \/
```

---

## Notes
- `base_line` is a local inside `print_map` — it's constructed fresh each call and not needed elsewhere
- Validation for all functions will be filled in during the testing phase
