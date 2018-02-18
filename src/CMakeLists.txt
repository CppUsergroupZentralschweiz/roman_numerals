# Roman number en-/decoder

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)

# project name
# TODO fill in your project name and version
project(roman_numerals VERSION 0.0.1 LANGUAGES CXX C)

option(DISABLE_BOOST_DOWNLOAD "Disable download of boost" FALSE)

# set default built type to Debug
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif (NOT CMAKE_BUILD_TYPE)

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

set(RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/../bin)

file(MAKE_DIRECTORY
        ${RUNTIME_OUTPUT_DIRECTORY}
        )

include(clang)

# Enable unit-testing.
enable_testing(true)

add_subdirectory(encoder)
add_subdirectory(decoder)
add_subdirectory(validator)
add_subdirectory(app)

# Add some custom target

# Targets for code anyalysis
# set report output paths
if (NOT REPORT_DIR)
    set(REPORT_DIR ${PROJECT_SOURCE_DIR}/../reports CACHE PATH "Reports directory")
endif (NOT REPORT_DIR)

# create report and documentation output directories
file(MAKE_DIRECTORY
        ${REPORT_DIR}
        )

add_custom_target(clean-reports
        ${CMAKE_COMMAND} -E remove_directory ${REPORT_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${REPORT_DIR}
        COMMENT "Delete all reports." VERBATIM
        )

# Packaging

install(FILES
        ${PROJECT_SOURCE_DIR}/../README.md
        ${PROJECT_SOURCE_DIR}/../LICENSE
        DESTINATION doc
        COMPONENT doc
        )

# project name used for installation
set(APPLICATION_NAME ${PROJECT_DOC_NAME})

include(CMakeInstallation.cmake)

add_custom_target(install_${PROJECT_NAME}
        $(MAKE) install
        DEPENDS ${PROJECT_NAME}
        COMMENT "Installing ${PROJECT_NAME}"
        )

add_custom_target(package_${PROJECT_NAME}
        $(MAKE) package
        DEPENDS ${PROJECT_NAME}
        COMMENT "Packaging ${PROJECT_NAME}"
        )
