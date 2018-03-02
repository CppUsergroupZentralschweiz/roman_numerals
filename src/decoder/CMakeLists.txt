# Roman Decoder cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)

# Set a project name in case only this library is built
if(NOT PROJECT_NAME)
    project(roman_decoder_lib VERSION 0.0.1 LANGUAGES CXX)
endif(NOT PROJECT_NAME)

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)

include(clang)

# Build library
add_library(roman_decoder_lib STATIC
    src/decode.cpp
    )

# define alias
add_library(roman::decoder_lib ALIAS roman_decoder_lib)

target_include_directories(roman_decoder_lib
    PRIVATE
    include/roman_decoder
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    )

target_link_libraries(roman_decoder_lib
    PRIVATE
    roman::validator_lib
    )

if(NOT MSVC)
    target_compile_options(roman_decoder_lib
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

target_compile_options(roman_decoder_lib
    PRIVATE
    $<$<BOOL:${MSVC}>:/analyze;/W4>
    )

target_compile_features(roman_decoder_lib
    PRIVATE
    cxx_auto_type
    cxx_std_14
    )

if(CLANG_TIDY_EXE AND NOT CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(
        roman_decoder_lib
        PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
    )
endif()

# Coverage instrumentation
include(CodeCoverage)
if(Coverage_FOUND)
    enable_coverage(roman_decoder_lib)
endif(Coverage_FOUND)

# tests
enable_testing(true)

add_subdirectory(tests)

#Install targets
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/../..)

install(TARGETS roman_decoder_lib
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib/static
    COMPONENT library
    )

install(DIRECTORY include/roman_decoder DESTINATION include)

install(TARGETS roman_decoder_lib EXPORT decoder_lib DESTINATION lib)
install(EXPORT decoder_lib NAMESPACE roman:: DESTINATION lib)
