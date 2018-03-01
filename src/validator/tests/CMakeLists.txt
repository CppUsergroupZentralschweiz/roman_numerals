# Roman Encoder test cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)

# Options for difining coverage output
option(COVERAGE_XML "Enable binary instrumentation to collect test coverage information in the DEBUG configuration (XML output)" TRUE)
option(COVERAGE_HTML "Enable binary instrumentation to collect test coverage information in the DEBUG configuration (HTML output)" FALSE)

include(clang)

find_package(Catch 2.1.2)

######################################
# Create a single test executable.   #
######################################
add_executable(validator_unittests
    src/main.cpp
    src/validator_test.cpp
    )
add_executable(validator_tests::unit ALIAS validator_unittests)

catch_add_tests($<TARGET_FILE:validator_unittests> "" ${CMAKE_CURRENT_SOURCE_DIR}/src/validator_test.cpp)
# add_test(NAME validator_unittest COMMAND $<TARGET_FILE:validator_unittests>)


if(NOT RUNTIME_OUTPUT_DIRECTORY)
    set(RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../../bin)
    file(MAKE_DIRECTORY
        ${RUNTIME_OUTPUT_DIRECTORY}
        )
endif(NOT RUNTIME_OUTPUT_DIRECTORY)

if(NOT TEST_RUNTIME_OUTPUT_DIRECTORY)
    set(TEST_RUNTIME_OUTPUT_DIRECTORY ${RUNTIME_OUTPUT_DIRECTORY}/tests)

    file(MAKE_DIRECTORY
        ${TEST_RUNTIME_OUTPUT_DIRECTORY}
        )
endif(NOT TEST_RUNTIME_OUTPUT_DIRECTORY)

set_target_properties(validator_unittests
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_OUTPUT_DIRECTORY}"
    )

set_target_properties(validator_unittests
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_OUTPUT_DIRECTORY}"
    )

target_link_libraries(validator_unittests
    PRIVATE
    Catch::catch
    roman::validator_lib
    "$<$<BOOL:${UNIX}>:-Xlinker '--no-as-needed'>"
    )

if(NOT MSVC)
    target_compile_options(validator_unittests
        PRIVATE
        -pedantic
        -Wall
        -Wextra
        -Werror
        $<$<BOOL:${CMAKE_COMPILER_IS_CLANGCXX}>:-Weverything>
        )
endif(NOT MSVC)

target_compile_options(validator_unittests
    PRIVATE
    $<$<BOOL:${MSVC}>:/analyze;/Za>
    )

if(CLANG_TIDY_EXE AND NOT CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(
        validator_unittests
        PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
    )
endif()

# Target: run tests
add_custom_target(run_validator_unittests
    ALL # run the test always for target all
    validator_tests::unit --order rand
    )

# set report and documentation output paths
if(NOT REPORT_DIR)
    set(REPORT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../reports CACHE PATH "Reports directory")
endif(NOT REPORT_DIR)

if(NOT COVERAGE_REPORT_DIR)
    set(COVERAGE_REPORT_DIR ${REPORT_DIR}/coverage CACHE PATH "Coverage reports output directory")
endif(NOT COVERAGE_REPORT_DIR)

if(NOT TESTS_REPORT_DIR)
    set(TESTS_REPORT_DIR ${REPORT_DIR}/tests CACHE PATH "Testresult output directory")
endif(NOT TESTS_REPORT_DIR)

# create report and documentation output directories
file(MAKE_DIRECTORY
    ${REPORT_DIR}
    ${COVERAGE_REPORT_DIR}
    ${TESTS_REPORT_DIR}
    )


# Target: run tests with junit output
add_custom_target(run_validator_unittests_junit
    decoder_tests::unit -r junit;-o ${TESTS_REPORT_DIR}/unit-tests.xml
    )

# Coverage
find_program(GCOV_PATH gcov)

if(GCOV_PATH AND NOT MSVC AND CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)
    if(COVERAGE_XML)
        setup_target_for_coverage_cobertura(
            NAME coverage_validator_unittests_cobertura
            EXECUTABLE validator_tests::unit
            OUTPUTNAME ${COVERAGE_REPORT_DIR}/validator_unittests
        )

        if(NOT TARGET coverage_validator)
            add_custom_target(coverage_validator)
        endif(NOT TARGET coverage_validator)

        add_dependencies(coverage_validator coverage_validator_unittests_cobertura)
    endif(COVERAGE_XML)

    if(COVERAGE_HTML)
        setup_target_for_coverage(
            NAME coverage_validator_unittests
            EXECUTABLE validator_tests::unit
            OUTPUTNAME ${COVERAGE_REPORT_DIR}/validator_unittests
        )
        if(NOT TARGET coverage_decoder)
            add_custom_target(coverage_decoder)
        endif(NOT TARGET coverage_decoder)
        add_dependencies(coverage_decoder coverage_decoder_unittests)
    endif(COVERAGE_HTML)
endif(GCOV_PATH AND NOT MSVC AND CMAKE_BUILD_TYPE MATCHES Debug)
