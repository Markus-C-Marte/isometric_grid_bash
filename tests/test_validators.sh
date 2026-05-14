#!/bin/bash

source ../validators.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOTAL=0
PASSED=0
FAILED=0

test_func() {
    local name="$1"
    local cmd="$2"
    local expected="$3"

    TOTAL=$((TOTAL + 1))
    eval "$cmd" 2>/dev/null
    local exit_code=$?

    if [[ $exit_code -eq $expected ]]; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $name (expected $expected, got $exit_code)"
        FAILED=$((FAILED + 1))
    fi
}

run_tests() {
    local suite_name="$1"
    echo -e "\n${YELLOW}${suite_name}${NC}"
    shift

    while (( $# >= 3 )); do
        test_func "$1" "$2" "$3"
        shift 3
    done
}

echo "========================================"
echo "Testing validators.sh Library"
echo "========================================"

run_tests "validators::is_set" \
    "single non-empty string" "validators::is_set 'hello'" 0 \
    "multiple non-empty strings" "validators::is_set 'hello' 'world' '123'" 0 \
    "single empty string" "validators::is_set ''" 1 \
    "one empty among many" "validators::is_set 'hello' '' 'world'" 1 \
    "no arguments" "validators::is_set" 1

run_tests "validators::is_integer" \
    "single positive integer" "validators::is_integer 42" 0 \
    "single negative integer" "validators::is_integer -42" 0 \
    "zero" "validators::is_integer 0" 0 \
    "multiple integers" "validators::is_integer 1 2 3 -4 0" 0 \
    "non-integer string" "validators::is_integer abc" 1 \
    "decimal number" "validators::is_integer 3.14" 1 \
    "empty string" "validators::is_integer ''" 1

run_tests "validators::is_in_bounds" \
    "value 0 (default 0-7)" "validators::is_in_bounds 0" 0 \
    "value 7 (default 0-7)" "validators::is_in_bounds 7" 0 \
    "value -1 (below bounds)" "validators::is_in_bounds -1" 1 \
    "value 8 (above bounds)" "validators::is_in_bounds 8" 1 \
    "value within range" "validators::is_in_bounds 5 0 10" 0 \
    "value at lower bound" "validators::is_in_bounds 0 0 10" 0 \
    "value at upper bound" "validators::is_in_bounds 10 0 10" 0 \
    "value below lower bound" "validators::is_in_bounds -1 0 10" 1 \
    "value above upper bound" "validators::is_in_bounds 11 0 10" 1 \
    "equal check mode" "validators::is_in_bounds 5 5" 0 \
    "not equal" "validators::is_in_bounds 5 3" 1

run_tests "validators::is_equal" \
    "5 == 5" "validators::is_equal 5 5" 0 \
    "0 == 0" "validators::is_equal 0 0" 0 \
    "-3 == -3" "validators::is_equal -3 -3" 0 \
    "5 != 3" "validators::is_equal 5 3" 1 \
    "0 != 5" "validators::is_equal 0 5" 1 \
    "one empty argument" "validators::is_equal 5 ''" 1 \
    "non-integer first arg" "validators::is_equal abc 5" 1 \
    "no arguments" "validators::is_equal" 1

run_tests "validators::is_length" \
    "string 'hello' length 5" "validators::is_length 'hello' 5" 0 \
    "string 'hi' length 2" "validators::is_length 'hi' 2" 0 \
    "empty string length 0" "validators::is_length '' 0" 0 \
    "string 'hello' length 3 (fail)" "validators::is_length 'hello' 3" 1 \
    "string 'test' length 4" "validators::is_length 'test' 4" 0 \
    "no arguments" "validators::is_length" 1

echo
echo "========================================"
echo "Test Results:"
echo -e "  Total:  $TOTAL"
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo "========================================"

[[ $FAILED -eq 0 ]] && echo -e "${GREEN}All tests passed!${NC}" && exit 0 || echo -e "${RED}Some tests failed.${NC}" && exit 1
