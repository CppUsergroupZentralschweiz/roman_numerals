# Roman numeral validator cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)

# Set a project name in case only this library is built
if(NOT PROJECT_NAME)
    project(roman_numeral_validator_lib VERSION 0.0.1 LANGUAGES CXX)
endif(NOT PROJECT_NAME)

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)

include(clang)

# Build library
add_library(roman_validator_lib STATIC
    src/validator.cpp
    )

# define alias
add_library(roman::validator_lib ALIAS roman_validator_lib)

target_include_directories(roman_validator_lib
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    )

if(NOT MSVC)
    target_compile_options(roman_validator_lib
        PRIVATE
        -pedantic
        -Wall
        -Wextra
        -Werror
        -Wno-c++98-compat
        -Wno-exit-time-destructors
        -Wno-global-constructors
        $<$<BOOL:${CMAKE_COMPILER_IS_CLANGCXX}>:-Weverything>
        )
endif(NOT MSVC)

target_compile_options(roman_validator_lib
    PRIVATE
    $<$<BOOL:${MSVC}>:/analyze;/W4>
    )

target_compile_features(roman_validator_lib
    PRIVATE
    cxx_auto_type
    )

if(CLANG_TIDY_EXE AND NOT CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(roman_validator_lib
        PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
        )
endif()

# Coverage instrumentation
include(CodeCoverage)
if(Coverage_FOUND)
    enable_coverage(roman_validator_lib)
endif(Coverage_FOUND)

# tests
enable_testing(true)

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
