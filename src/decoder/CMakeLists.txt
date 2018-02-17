# Roman Decoder cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)


if(NOT PROJECT_NAME)
    project(roman_decoder_lib VERSION 0.0.1 LANGUAGES CXX C)
endif(NOT PROJECT_NAME)
# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)

include(clang)

# Build library
# TODO uncomment the EXCLUDE_FROM_ALL if your library is only used internally

add_library(roman_decoder_lib STATIC
    #  EXCLUDE_FROM_ALL
    ""
    )

# define alias
add_library(roman::decoder_lib ALIAS roman_decoder_lib)

# add source files
target_sources(roman_decoder_lib
    PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src/decode.cpp"
    )

target_include_directories(roman_decoder_lib
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    include/roman_decoder
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    )

target_link_libraries(roman_decoder_lib
    PRIVATE
    roman::validator_lib
    )

if(NOT ${MSVC})
    target_compile_options(roman_decoder_lib
        PRIVATE
        -pedantic
        -Wall
        -Wextra
        -Werror
        $<$<BOOL:${CMAKE_COMPILER_IS_CLANGCXX}>:-Weverything>
        )
endif(NOT ${MSVC})

target_compile_options(roman_decoder_lib
    PRIVATE
    $<$<BOOL:${MSVC}>:/analyze>
    )

target_compile_definitions(roman_decoder_lib
    PUBLIC
    "$<$<BOOL:${MSVC}>:_WIN32_WINNT=0x0601;>"
    )


if(CPPCHECK_EXE AND ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 3.9)
    set_target_properties(
        roman_decoder_lib
        PROPERTIES
        CXX_CPPCHECK "${CPPCHECK_PROPERTIES}"
    )
endif()

if(CLANG_TIDY_EXE AND NOT CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(
        roman_decoder_lib
        PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
    )
endif()


# Define some common C++11/14/17 features
# TODO uncomment the C++11/14/17 features you use
target_compile_features(roman_decoder_lib
    PRIVATE
    cxx_std_14
    )


if(CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)
    if(${COVERAGE_XML} OR ${COVERAGE_HTML})
        enable_coverage(roman_decoder_lib)
    endif(${COVERAGE_XML} OR ${COVERAGE_HTML})
endif(CMAKE_BUILD_TYPE MATCHES Debug)

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
