#include "roman_numerals_version.h"
#include "roman_encoder/encode.h"
#include "roman_decoder/decode.h"

#ifdef USE_BOOST
#include <boost/program_options.hpp>
#include <string>
#else

#include <getopt.h>

#endif


#include <iostream>

int main(int argc, char** argv) {

    std::string roman_number{};
    uint32_t arabic_number = 5000u;

#ifndef USE_BOOST
    int opt;
    while ((opt = getopt(argc, argv, "hvr:a:")) != EOF) {
        switch (opt) {
            case 'v':
                std::cout << "version: "
                          << roman_numerals::version_major
                          << "."
                          << roman_numerals::version_minor
                          << "."
                          << roman_numerals::version_patch
                          << std::endl;
                return 0;
            case 'r':
                roman_number = optarg;
                break;
            case 'a':
                arabic_number = std::stoi(optarg);
                break;
            case 'h':
            case '?':
            default:
                std::cout << "usuage is \n "
                        "  -h [ --help ]         produce help message\n"
                        "  -v             show version\n"
                        "  -r [ --roman ] arg    roman numeral\n"
                        "  -a [ --arabic ] arg   arabic numeral\n";
                return 0;
        }
    }
#else
    namespace po = boost::program_options;

    using po::options_description;
    using po::parse_command_line;

    options_description option_description{"Allowed options"};
    option_description.add_options()
            ("help,h", "produce help message")
            ("version", "show version")
            ("roman,r", po::value<std::string>(&roman_number), "roman numeral")
            ("arabic,a", po::value<uint32_t>(&arabic_number), "arabic numeral");

    po::variables_map variable_map;
    po::store(parse_command_line(argc, argv, option_description),
              variable_map);
    po::notify(variable_map);

    if (variable_map.count("help") > 0) {
        std::cout << option_description << "\n";
        return 0;
    }

    if (variable_map.count("version") > 0) {
        std::cout << "version: "
                  << roman_numerals::version_major
                  << "."
                  << roman_numerals::version_minor
                  << "."
                  << roman_numerals::version_patch
                  << std::endl;
        return 0;
    }

    if (variable_map.count("roman") == 0 && variable_map.count("arabic") == 0) {
        std::cout << "Specify at least one of roman or arabic roman=" << roman_number << "\n";
        std::cout << option_description << std::endl;
        return 1;
    }
#endif
    try {
        if ((not roman_number.empty()) && (arabic_number <= 4000u)) {
            const auto arabic_result = roman_numerals::from_roman(roman_number);
            std::cout << "'" << roman_number << "' is " << (arabic_result == arabic_number ? "" : "not ")
                      << std::to_string(arabic_number) << " (is " << arabic_result << ")\n";
        } else if (not roman_number.empty()) {

            const auto arabic_result = roman_numerals::from_roman(roman_number);
            std::cout << "'" << roman_number << "' is " << std::to_string(arabic_result) << "\n";
        } else if (arabic_number <= 4000u) {
            std::cout << std::to_string(arabic_number) << " is '" << roman_numerals::to_roman(arabic_number) << "'\n";
        }

    } catch (const std::exception& ex) {
        std::cerr << ex.what() << std::endl;
        return 1;
    }

    return 0;
}
