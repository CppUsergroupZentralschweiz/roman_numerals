#include "roman_validator/roman_numeral_validator.h"
#include <catch.hpp>

// see https://projecteuler.net/about=roman_numerals

namespace {

TEST_CASE("Digits I, V, X, L, C, D, M are allowed", "") {
    CHECK(roman_numerals::roman_is_valid("I"));
    CHECK(roman_numerals::roman_is_valid("V"));
    CHECK(roman_numerals::roman_is_valid("X"));
    CHECK(roman_numerals::roman_is_valid("L"));
    CHECK(roman_numerals::roman_is_valid("C"));
    CHECK(roman_numerals::roman_is_valid("D"));
    CHECK(roman_numerals::roman_is_valid("M"));
}

TEST_CASE("Digits other than I, V, X, L, C, D, M are not allowed", "") {
    CHECK_FALSE(roman_numerals::roman_is_valid("A"));
    CHECK_FALSE(roman_numerals::roman_is_valid("1"));
}

TEST_CASE("M, C, and X cannot be equalled or exceeded by smaller denominations", "") {
    CHECK(roman_numerals::roman_is_valid("IIIIIIIII")); // 9
    CHECK_FALSE(roman_numerals::roman_is_valid("IIIIIIIIII")); // 10 (X)
    CHECK_FALSE(roman_numerals::roman_is_valid("VIIIII")); // 10 (X)

    CHECK(roman_numerals::roman_is_valid("XXXXXXXXX")); // 90
    CHECK_FALSE(roman_numerals::roman_is_valid("XXXXXXXXXX")); // 100 (C)
    CHECK_FALSE(roman_numerals::roman_is_valid("LXXXXX")); // 100 (C)
    CHECK_FALSE(roman_numerals::roman_is_valid("LXXXXXIII")); // 103 (C)

    CHECK(roman_numerals::roman_is_valid("CCCCCCCCC")); // 900
    CHECK_FALSE(roman_numerals::roman_is_valid("CCCCCCCCCC")); // 1000 (M)
    CHECK_FALSE(roman_numerals::roman_is_valid("DCCCCC")); // 1000 (M)
}

TEST_CASE("MCM is valid", "") {
    REQUIRE(roman_numerals::roman_is_valid("MCM"));
}


TEST_CASE("D, L, and V can each only appear once", "") {
    CHECK_FALSE(roman_numerals::roman_is_valid("DD"));
    CHECK_FALSE(roman_numerals::roman_is_valid("LL"));
    CHECK_FALSE(roman_numerals::roman_is_valid("VV"));
}

TEST_CASE("Empty string is always valid", "") {
    REQUIRE(roman_numerals::roman_is_valid(""));
}

TEST_CASE("MDCLXVI and MCMXC are valid", "") {
    CHECK(roman_numerals::roman_is_valid("MDCLXVI"));
    CHECK(roman_numerals::roman_is_valid("MCMXC"));
}


TEST_CASE("I can be placed before V and X but not L, C, D or M", "") {
    CHECK(roman_numerals::roman_is_valid("IV"));
    CHECK(roman_numerals::roman_is_valid("IX"));
    CHECK_FALSE(roman_numerals::roman_is_valid("IL"));
    CHECK_FALSE(roman_numerals::roman_is_valid("IC"));
    CHECK_FALSE(roman_numerals::roman_is_valid("ID"));
    CHECK_FALSE(roman_numerals::roman_is_valid("IM"));
}

TEST_CASE("X can be placed before L and C but not D or M", "") {
    CHECK(roman_numerals::roman_is_valid("XL"));
    CHECK(roman_numerals::roman_is_valid("XC"));
    CHECK_FALSE(roman_numerals::roman_is_valid("XD"));
    CHECK_FALSE(roman_numerals::roman_is_valid("XM"));
}

TEST_CASE("C can be placed before D and M", "") {
    CHECK(roman_numerals::roman_is_valid("CD"));
    CHECK(roman_numerals::roman_is_valid("CM"));
}


} //namespace
