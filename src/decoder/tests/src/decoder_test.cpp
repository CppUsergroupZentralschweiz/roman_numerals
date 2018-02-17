#include "roman_decoder/decode.h"
#include <catch.hpp>

namespace {

TEST_CASE("A roman numbers decoder can decode I - III to 1 - 3", "") {
    REQUIRE(roman_numerals::from_roman("I") == 1);
    REQUIRE(roman_numerals::from_roman("II") == 2);
    REQUIRE(roman_numerals::from_roman("III") == 3);
}

TEST_CASE("A roman numbers decoder can decode X, XX, XXX to 10, 20, 30", "") {
    REQUIRE(roman_numerals::from_roman("X") == 10);
    REQUIRE(roman_numerals::from_roman("XX") == 20);
    REQUIRE(roman_numerals::from_roman("XXX") == 30);
}

TEST_CASE("A roman numbers decoder can decode XIII to 13, XXII to 22 and XXXI to 31", "") {
    REQUIRE(roman_numerals::from_roman("XIII") == 13);
    REQUIRE(roman_numerals::from_roman("XXII") == 22);
    REQUIRE(roman_numerals::from_roman("XXXI") == 31);
}

TEST_CASE("A roman numbers decoder can decode C, CC and CCC to 100, 200, 300", "") {
    REQUIRE(roman_numerals::from_roman("C") == 100);
    REQUIRE(roman_numerals::from_roman("CC") == 200);
    REQUIRE(roman_numerals::from_roman("CCC") == 300);
}

TEST_CASE("A roman numbers decoder can decode M, MM, MMM and MMMM to 000, 2000, 3000 and 4000", "") {
    REQUIRE(roman_numerals::from_roman("M") == 1000);
    REQUIRE(roman_numerals::from_roman("MM") == 2000);
    REQUIRE(roman_numerals::from_roman("MMM") == 3000);
    REQUIRE(roman_numerals::from_roman("MMMM") == 4000);
}

TEST_CASE("A roman numbers decoder can decode V as 5", "") {
    REQUIRE(roman_numerals::from_roman("V") == 5);
}

TEST_CASE("A roman numbers decoder can decode L as 50", "") {
    REQUIRE(roman_numerals::from_roman("L") == 50);
}

TEST_CASE("A roman numbers decoder can decode D as 500", "") {
    REQUIRE(roman_numerals::from_roman("D") == 500);
}

TEST_CASE("A roman numbers decoder can decode IV as 4", "") {
    REQUIRE(roman_numerals::from_roman("IV") == 4);
}

TEST_CASE("A roman numbers decoder can decode IX as 9", "") {
    REQUIRE(roman_numerals::from_roman("IX") == 9);
}

TEST_CASE("A roman numbers decoder can decode XL as 40", "") {
    REQUIRE(roman_numerals::from_roman("XL") == 40);
}

TEST_CASE("A roman numbers decoder can decode XC as 90", "") {
    REQUIRE(roman_numerals::from_roman("XC") == 90);
}

TEST_CASE("A roman numbers decoder can decode CD as 400", "") {
    REQUIRE(roman_numerals::from_roman("CD") == 400);
}

TEST_CASE("A roman numbers decoder can decode CM as 900", "") {
    REQUIRE(roman_numerals::from_roman("CM") == 900);
}

TEST_CASE("A roman numbers decoder can decode MDCLXVI as 1666", "") {
    REQUIRE(roman_numerals::from_roman("MDCLXVI") == 1666);
}

TEST_CASE("A roman numbers decoder can decode MCMXC as 1990", "") {
    REQUIRE(roman_numerals::from_roman("MCMXC") == 1990);
}

TEST_CASE("A roman numbers decoder decodes empty string to 0", "") {
    REQUIRE(roman_numerals::from_roman("") == 0);
}

TEST_CASE("A roman numbers decoder throws invalid_argument exception for invalid string", "") {
    REQUIRE_THROWS_AS(roman_numerals::from_roman("ABC"), std::invalid_argument);
}

TEST_CASE("M, C, and X cannot be equalled or exceeded by smaller denominations.", "") {
    CHECK_THROWS_AS(roman_numerals::from_roman("IIIIIIIIII"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("CCCCCCCCCC"), std::invalid_argument);
}

TEST_CASE("D, L, and V can each only appear once", "") {
    CHECK_THROWS_AS(roman_numerals::from_roman("VV"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("VIV"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("DCD"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("CDD"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("XLL"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("LXL"), std::invalid_argument);
}

TEST_CASE("I can only be placed before V and X.", "") {
    CHECK_THROWS_AS(roman_numerals::from_roman("IL"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("IC"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("ID"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("IM"), std::invalid_argument);
}

TEST_CASE("X can only be placed before L and C", "") {
    CHECK_THROWS_AS(roman_numerals::from_roman("XD"), std::invalid_argument);
    CHECK_THROWS_AS(roman_numerals::from_roman("XM"), std::invalid_argument);
}

} //namespace
