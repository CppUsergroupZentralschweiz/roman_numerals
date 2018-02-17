if(NOT Catch_FIND_VERSION)
    message(FATAL_ERROR "A version number for Catch2 must be specified.")
elseif(Catch_FIND_REQUIRED)
    message(FATAL_ERROR "This module assumes Catch2 is not required.")
elseif(Catch_FIND_VERSION_EXACT)
    message(FATAL_ERROR "Exact version numbers are not supported, only minimum.")
endif()

function(_get_catch_version)
    string(REGEX MATCH "catch2-v([0-9]+)\\.([0-9]+)\\.([0-9]+)" version_line ${CATCH_INCLUDE_DIR})
    if(version_line MATCHES "catch2-v([0-9]+)\\.([0-9]+)\\.([0-9]+)")
        set(CATCH_VERSION "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}")
        message(STATUS "Found Catch2 with version ${CATCH_VERSION}")
    endif()
endfunction()

function(catch_add_tests executable extra_args)
    if(NOT ARGN)
        message(FATAL_ERROR "Missing ARGN: Read the documentation for CATCH_ADD_TESTS")
    endif()
    foreach(source ${ARGN})
        file(READ "${source}" contents)
        string(REGEX MATCHALL "TEST_CASE *\\( *\"([ A-Za-z_0-9]+)\" *, *\"\\[[ A-Za-z_0-9]*\\]\" *\\)" found_tests ${contents})
        foreach(hit ${found_tests})
            string(REGEX REPLACE "TEST_CASE *\\( *\"([ A-Za-z_0-9]+)\".*" "\\1" test_name ${hit})
            string(REPLACE " " "_" test_name_underscore ${test_name})
            add_test(${test_name_underscore} ${executable} ${extra_args})
        endforeach()

        # Test alternative
        string(REGEX MATCHALL "SCENARIO *\\( *\"([ A-Za-z_0-9]+)\" *, *\"\\[[ A-Za-z_0-9]*\\]\" *\\)" found_tests ${contents})
        foreach(hit ${found_tests})
            string(REGEX REPLACE "SCENARIO *\\( *\"([ A-Za-z_0-9]+)\".*" "\\1" test_name ${hit})
            string(REPLACE " " "_" test_name_underscore ${test_name})
            add_test(${test_name_underscore} ${executable} ${extra_args})
        endforeach()
    endforeach()
endfunction()


find_path(CATCH_INCLUDE_DIR NAMES catch.hpp PATH_SUFFIXES catch)
if(CATCH_INCLUDE_DIR)
    _get_catch_version()
endif()

# Download if Catch wasn't found or if it's outdated
if(NOT CATCH_VERSION OR CATCH_VERSION VERSION_LESS ${Catch_FIND_VERSION})
    include(ExternalProject)

    if(NOT TARGET catch)
        ExternalProject_Add(catch
            URL https://github.com/catchorg/Catch2/archive/v${Catch_FIND_VERSION}.tar.gz
            PREFIX ${CMAKE_BINARY_DIR}/catch2-v${Catch_FIND_VERSION}
            TIMEOUT 10
            UPDATE_COMMAND ""
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ""
            INSTALL_COMMAND ""
            LOG_DOWNLOAD ON
            )
    endif(NOT TARGET catch)

    ExternalProject_Get_Property(catch source_dir)
    set(CATCH_INCLUDE_DIR ${source_dir}/single_include CACHE INTERNAL "Path to include folder for Catch")
    file(MAKE_DIRECTORY ${CATCH_INCLUDE_DIR})
    mark_as_advanced(CATCH_INCLUDE_DIR)
endif()

if(NOT TARGET Catch::catch)
    add_library(Catch::catch INTERFACE IMPORTED)
    add_dependencies(Catch::catch catch)
    if(EXISTS "${CATCH_INCLUDE_DIR}")
        set_target_properties(Catch::catch PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${CATCH_INCLUDE_DIR}"
            )
    endif()
    set_target_properties(Catch::catch PROPERTIES
        INTERFACE_COMPILE_FEATURES cxx_noexcept
        INTERFACE_COMPILE_FEATURES cxx_std_11
        )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CATCH DEFAULT_MSG CATCH_INCLUDE_DIR)
