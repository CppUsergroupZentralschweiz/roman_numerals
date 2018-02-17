#include "roman_encoder/encode.h"
#include <catch.hpp>

namespace {


using Catch::Matchers::Equals;


TEST_CASE("A roman numbers encoder can encode numbers 1 to 3 as I, II, III", "") {
    REQUIRE_THAT(roman_numerals::to_roman(1), Equals("I"));
    REQUIRE_THAT(roman_numerals::to_roman(2), Equals("II"));
    REQUIRE_THAT(roman_numerals::to_roman(3), Equals("III"));
}

TEST_CASE("A roman numbers encoder can encode numbers 10, 20 and 30 as X, XX, XXX", "") {
    REQUIRE_THAT(roman_numerals::to_roman(10), Equals("X"));
    REQUIRE_THAT(roman_numerals::to_roman(20), Equals("XX"));
    REQUIRE_THAT(roman_numerals::to_roman(30), Equals("XXX"));
}

TEST_CASE("A roman numbers encoder can encode numbers 100, 200 and 300 as C, CC, CCC", "") {
    REQUIRE_THAT(roman_numerals::to_roman(100), Equals("C"));
    REQUIRE_THAT(roman_numerals::to_roman(200), Equals("CC"));
    REQUIRE_THAT(roman_numerals::to_roman(300), Equals("CCC"));
}

TEST_CASE("A roman numbers encoder can encode numbers 1000, 2000, 3000 and 4000 as M, MM, MMM, MMMM", "") {
    REQUIRE_THAT(roman_numerals::to_roman(1000), Equals("M"));
    REQUIRE_THAT(roman_numerals::to_roman(2000), Equals("MM"));
    REQUIRE_THAT(roman_numerals::to_roman(3000), Equals("MMM"));
    REQUIRE_THAT(roman_numerals::to_roman(4000), Equals("MMMM"));
}

TEST_CASE("A roman numbers encoder can encode 5 as V", "") {
    REQUIRE_THAT(roman_numerals::to_roman(5), Equals("V"));
}

TEST_CASE("A roman numbers encoder can encode 50 as L", "") {
    REQUIRE_THAT(roman_numerals::to_roman(50), Equals("L"));
}

TEST_CASE("A roman numbers encoder can encode 500 as D", "") {
    REQUIRE_THAT(roman_numerals::to_roman(500), Equals("D"));
}

TEST_CASE("A roman numbers encoder can encode 4 as IV", "") {
    REQUIRE_THAT(roman_numerals::to_roman(4), Equals("IV"));
}

TEST_CASE("A roman numbers encoder can encode 9 as IX", "") {
    REQUIRE_THAT(roman_numerals::to_roman(9), Equals("IX"));
}

TEST_CASE("A roman numbers encoder can encode 40 as XL", "") {
    REQUIRE_THAT(roman_numerals::to_roman(40), Equals("XL"));
}

TEST_CASE("A roman numbers encoder can encode 90 as XC", "") {
    REQUIRE_THAT(roman_numerals::to_roman(90), Equals("XC"));
}

TEST_CASE("A roman numbers encoder can encode 400 as CD", "") {
    REQUIRE_THAT(roman_numerals::to_roman(400), Equals("CD"));
}

TEST_CASE("A roman numbers encoder can encode 90 as CM", "") {
    REQUIRE_THAT(roman_numerals::to_roman(900), Equals("CM"));
}

TEST_CASE("A roman numbers encoder can encode 1666 as MDCLXVI", "") {
    REQUIRE_THAT(roman_numerals::to_roman(1666), Equals("MDCLXVI"));
}

TEST_CASE("A roman numbers encoder can encode 1990 as MCMXC", "") {
    REQUIRE_THAT(roman_numerals::to_roman(1990), Equals("MCMXC"));
}

TEST_CASE("A roman numbers encoder can encode 0 as nothing", "") {
    REQUIRE_THAT(roman_numerals::to_roman(0), Equals(""));
}

} //namespace
