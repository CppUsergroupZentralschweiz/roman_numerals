#include "decode.h"

#include "roman_validator/validator.h"

#include <map>
#include <algorithm>
#include <ciso646>

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
} // namespace

uint32_t from_roman(const std::string& roman) {
    auto arabic = 0u;
    auto prev = 0u;
    if (not roman_is_valid(roman)) {
        throw std::invalid_argument{"Invalid string provided"};
    }

    std::for_each(roman.crbegin(), roman.crend(), [&](const auto& ch) {
        const auto inc = to_arabic_mapping.at(ch);
        arabic += inc < prev ? -inc : inc;
        prev = inc;
    });

    return arabic;
}

} // namespace roman_numerals
