# Roman Encoder cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)


if (NOT PROJECT_NAME)
    project(roman_encoder_lib VERSION 0.0.1 LANGUAGES CXX C)
endif (NOT PROJECT_NAME)
# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)

include(clang)

# Build library
# TODO uncomment the EXCLUDE_FROM_ALL if your library is only used internally

add_library(roman_encoder_lib STATIC
        #  EXCLUDE_FROM_ALL
        src/encode.cpp
        )

# define alias
add_library(roman::encoder_lib ALIAS roman_encoder_lib)

target_include_directories(roman_encoder_lib
        PRIVATE
        include/roman_encoder
        PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
        )

if (NOT ${MSVC})
    target_compile_options(roman_encoder_lib
            PRIVATE
            -pedantic
            -Wall
            -Wextra
            -Werror
            $<$<BOOL:${CMAKE_COMPILER_IS_CLANGCXX}>:-Weverything>
            )
endif (NOT ${MSVC})

target_compile_options(roman_encoder_lib
        PRIVATE
        $<$<BOOL:${MSVC}>:/analyze;/Za>
        )

target_compile_definitions(roman_encoder_lib
        PUBLIC
        "$<$<BOOL:${MSVC}>:WINVER=0x0A00;_WIN32_WINNT=0x0A00;>"
        )

if (CPPCHECK_EXE AND ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 3.9)
    set_target_properties(
            roman_encoder_lib
            PROPERTIES
            CXX_CPPCHECK "${CPPCHECK_PROPERTIES}"
    )
endif ()

if (CLANG_TIDY_EXE AND NOT CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(
            roman_encoder_lib
            PROPERTIES
            CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
    )
endif ()


target_compile_features(roman_encoder_lib
        PRIVATE
        cxx_std_14
        )


if (CMAKE_BUILD_TYPE MATCHES Debug AND NOT ${MSVC})
    include(CodeCoverage)
    if (${COVERAGE_XML} OR ${COVERAGE_HTML})
        enable_coverage(roman_encoder_lib)
    endif (${COVERAGE_XML} OR ${COVERAGE_HTML})
endif (CMAKE_BUILD_TYPE MATCHES Debug AND NOT ${MSVC})

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
