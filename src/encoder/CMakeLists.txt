# Roman Encoder cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)

# Set a project name in case only this library is built
if(NOT PROJECT_NAME)
    project(roman_encoder_lib VERSION 0.0.1 LANGUAGES CXX)
endif(NOT PROJECT_NAME)

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)

include(clang)

# Build library
add_library(roman_encoder_lib STATIC
    src/encode.cpp
    )

# define alias
add_library(roman::encoder_lib ALIAS roman_encoder_lib)

target_include_directories(roman_encoder_lib
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    )

if(NOT MSVC)
    target_compile_options(roman_encoder_lib
        PRIVATE
        -pedantic
        -Wall
        -Wextra
        -Werror
        -Wno-c++98-compat
        $<$<BOOL:${CMAKE_COMPILER_IS_CLANGCXX}>:-Weverything>
        )
endif(NOT MSVC)

target_compile_options(roman_encoder_lib
    PRIVATE
    $<$<BOOL:${MSVC}>:/analyze;/W4>
    )

if(CLANG_TIDY_EXE AND NOT CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(
        roman_encoder_lib
        PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
    )
endif()


target_compile_features(roman_encoder_lib
    PRIVATE
    cxx_auto_type
    cxx_std_14
    )

# Coverage instrumentation
include(CodeCoverage)
if(Coverage_FOUND)
    enable_coverage(roman_encoder_lib)
endif(Coverage_FOUND)


# tests
enable_testing(true)

add_subdirectory(tests)

#Install targets
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/../..)

install(TARGETS roman_encoder_lib
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib/static
    COMPONENT library
    )

install(DIRECTORY include/roman_encoder DESTINATION include)

install(TARGETS roman_encoder_lib EXPORT encoder_lib DESTINATION lib)
install(EXPORT encoder_lib NAMESPACE roman:: DESTINATION lib)
