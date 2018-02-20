# Roman numeral validator cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)


if (NOT PROJECT_NAME)
    project(roman_numeral_validator_lib VERSION 0.0.1 LANGUAGES CXX C)
endif (NOT PROJECT_NAME)
# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)

include(clang)

# Build library
# TODO uncomment the EXCLUDE_FROM_ALL if your library is only used internally

add_library(roman_validator_lib STATIC
        #  EXCLUDE_FROM_ALL
        src/roman_numeral_validator.cpp
        )

# define alias
add_library(roman::validator_lib ALIAS roman_validator_lib)

target_include_directories(roman_validator_lib
        PRIVATE
        include/roman_validator
        PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
        )

if (NOT ${MSVC})
    target_compile_options(roman_validator_lib
            PRIVATE
            -pedantic
            -Wall
            -Wextra
            -Werror
            $<$<BOOL:${CMAKE_COMPILER_IS_CLANGCXX}>:-Weverything>
            )
endif (NOT ${MSVC})

target_compile_options(roman_validator_lib
        PUBLIC
        $<$<BOOL:${MSVC}>:/Za>
        PRIVATE
        $<$<BOOL:${MSVC}>:/analyze;/Wall>
        )

target_compile_definitions(roman_validator_lib
        PUBLIC
        #     $<$<BOOL:${WIN32}>:WINVER=0x0A00;_WIN32_WINNT=0x0A00>
        )

if (CLANG_TIDY_EXE AND NOT CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(roman_validator_lib
            PROPERTIES
            CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
            )
endif ()

find_program(GCOV_PATH gcov)

if (GCOV_PATH AND NOT MSVC)
    include(CodeCoverage)
    enable_coverage(roman_validator_lib)
endif (GCOV_PATH AND NOT MSVC)

add_subdirectory(tests)

#Install targets
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/../..)

install(TARGETS roman_validator_lib
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib/static
        COMPONENT library
        )

install(DIRECTORY include/roman_validator DESTINATION include)

install(TARGETS roman_validator_lib EXPORT validator DESTINATION lib)
install(EXPORT validator NAMESPACE roman:: DESTINATION lib)
