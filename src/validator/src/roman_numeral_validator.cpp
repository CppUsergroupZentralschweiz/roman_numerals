#include "roman_numeral_validator.h"

#include <map>
#include <algorithm>
#include <vector>

namespace roman_numerals {

namespace {

const std::map<char, uint32_t> to_arabic_mapping =
        {
                {'M', 1000},
                {'D', 500},
                {'C', 100},
                {'L', 50},
                {'X', 10},
                {'V', 5},
                {'I', 1}
        };

const std::vector<char> five_x_digits = {{'D', 'L', 'V'}};

bool check_DLV_occurs_maximal_once(const std::string& roman) {
    for (const auto& digit : five_x_digits) {
        if (std::count(roman.begin(), roman.end(), digit) > 1) {
            return false;
        }
    }
    return true;
}

bool check_digits(const std::string& roman) {
    for (const auto& numeral: roman) {
        if (to_arabic_mapping.count(numeral) == 0) {
            return false;
        };
    }
    return true;
}

bool check_consecutive_equals(const std::string& roman) {
    char prev_numeral = '\0';
    auto count_consecutive_equals = 1u;
    for (const auto& numeral: roman) {
        if (numeral == prev_numeral) {
            ++count_consecutive_equals;
            if (count_consecutive_equals == 10) {
                return false;
            }
        } else {
            count_consecutive_equals = 1;
        }
        prev_numeral = numeral;
    }
    return true;
}

bool check_sum_smaller_denominations(const std::string& roman) {
    auto prev = 0u;
    auto roman_reverse = roman;
    auto arabic = 0;
    std::reverse(roman_reverse.begin(), roman_reverse.end());
    auto next_decimal = to_arabic_mapping.at(roman_reverse.at(0)) * 10;
    for (const auto& numeral: roman_reverse) {
        const int32_t inc = to_arabic_mapping.at(numeral);
        if (inc >= next_decimal) {
            arabic = 0;
            next_decimal = inc % next_decimal == 0 ? inc * 10 : inc + inc;
        }
        arabic += inc < prev ? -inc : inc;
        if (arabic >= next_decimal) {
            return false;
        }
        prev = inc;
    }
    return true;
}


bool check_ordering(const std::string& roman) {
    auto prev = 0u;
    auto roman_reverse = roman;
    std::reverse(roman_reverse.begin(), roman_reverse.end());
    for (const auto& numeral: roman_reverse) {
        const auto inc = to_arabic_mapping.at(numeral);
        if ((inc < prev) && ((prev - inc) > (10 * inc))) {
            return false;
        }
        prev = inc;
    }
    return true;
}
}

bool roman_is_valid(const std::string& roman) {

    if (roman.empty()) {
        return true;
    }
    return (check_DLV_occurs_maximal_once(roman) &&
            check_digits(roman) &&
            check_consecutive_equals(roman) &&
            check_sum_smaller_denominations(roman) &&
            check_ordering(roman));
}

} // namespace roman_numerals
