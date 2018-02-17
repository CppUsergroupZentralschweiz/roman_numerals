# Roman Encoder test cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)

option(COVERAGE_XML "Enable binary instrumentation to collect test coverage information in the DEBUG configuration (XML output)" TRUE)
option(COVERAGE_HTML "Enable binary instrumentation to collect test coverage information in the DEBUG configuration (HTML output)" TRUE)


# Enable unit-testing.
enable_testing(true)

if(NOT RUNTIME_OUTPUT_DIRECTORY)
    set(RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../../bin)
    file(MAKE_DIRECTORY
        ${RUNTIME_OUTPUT_DIRECTORY}
        )
endif()

set(TEST_RUNTIME_OUTPUT_DIRECTORY ${RUNTIME_OUTPUT_DIRECTORY}/tests)

file(MAKE_DIRECTORY
    ${TEST_RUNTIME_OUTPUT_DIRECTORY}
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

include(clang)

find_package(Catch 2.0.1)

#########################################################################
# Create test executables for every testclass (no coverage measurement) #
#########################################################################

function(register_catchtest TEST_FILE)
    get_filename_component(TEST_NAME ${TEST_FILE} NAME)
    message(STATUS "Adding Catch test " ${TEST_NAME})
    add_executable(${TEST_NAME}
        EXCLUDE_FROM_ALL
        ${TEST_FILE}.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
        )

    target_link_libraries(${TEST_NAME}
        PRIVATE
        Catch::catch
        roman::encoder_lib ${ARGN}
        )

    catch_add_tests(${TEST_NAME} "" ${TEST_FILE}.cpp)
    set(CATCHTEST_SOURCES ${CATCHTEST_SOURCES} ${TEST_FILE}.cpp PARENT_SCOPE)
endfunction()

# TODO add here all your tests (source file name without extension)
# The following tests are all the same tests but with different syntax, i.e
# - Classic Test
# - BDD Style Test
register_catchtest(src/encoder_test)


######################################
# Create a single test executable.   #
######################################

add_executable(encoder_unittests
    ${CATCHTEST_SOURCES}
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
    )

add_executable(encoder_tests::unit ALIAS encoder_unittests)

set_target_properties(encoder_unittests
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_OUTPUT_DIRECTORY}"
    )

add_test(encoder_unittest encoder_unittests)

set_target_properties(encoder_unittests
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_OUTPUT_DIRECTORY}"
    )

target_link_libraries(encoder_unittests
    PRIVATE
    Catch::catch
    roman::encoder_lib
    "$<$<BOOL:${UNIX}>:-Xlinker '--no-as-needed'>"
    )

if(NOT ${MSVC})
    target_compile_options(encoder_unittests
        PRIVATE
        -pedantic
        -Wall
        -Wextra
        -Werror
        $<$<BOOL:${CMAKE_COMPILER_IS_CLANGCXX}>:-Weverything>
        )
endif(NOT ${MSVC})

target_compile_options(encoder_unittests
    PRIVATE
    $<$<BOOL:${MSVC}>:/analyze>
    )

if(CLANG_TIDY_EXE AND NOT CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(
        encoder_unittests
        PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
    )
endif()

add_dependencies(encoder_unittests catch)

# Target: run tests
add_custom_target(run_encoder_unittests
    ALL # run the test always for target all
    encoder_tests::unit --order rand
    DEPENDS encoder_tests::unit
    )

# Target: run tests with junit output
add_custom_target(run_encoder_unittests_junit
    encoder_tests::unit -r junit;-o ${TESTS_REPORT_DIR}/unit-tests.xml
    DEPENDS encoder_tests::unit
    )

if(CMAKE_BUILD_TYPE MATCHES Debug)
    include(CodeCoverage)
    if(COVERAGE_XML)
        setup_target_for_coverage_cobertura(
            NAME coverage_encoder_unittests_cobertura
            EXECUTABLE encoder_tests::unit
            OUTPUTNAME ${COVERAGE_REPORT_DIR}/encoder_unittests
        )

        if(NOT TARGET coverage_encoder)
            add_custom_target(coverage_encoder)
        endif(NOT TARGET coverage_encoder)

        add_dependencies(coverage_encoder coverage_encoder_unittests_cobertura)
    endif(COVERAGE_XML)

    if(COVERAGE_HTML)
        setup_target_for_coverage(
            NAME coverage_encoder_unittests
            EXECUTABLE encoder_tests::unit
            OUTPUTNAME ${COVERAGE_REPORT_DIR}/encoder_unittests
        )
        if(NOT TARGET coverage_encoder)
            add_custom_target(coverage_encoder)
        endif(NOT TARGET coverage_encoder)
        add_dependencies(coverage_encoder coverage_encoder_unittests)
    endif(COVERAGE_HTML)
endif(CMAKE_BUILD_TYPE MATCHES Debug)
