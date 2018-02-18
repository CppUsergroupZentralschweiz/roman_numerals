# Roman En-/Decoder app cmake file

# required minimum version of cmake
cmake_minimum_required(VERSION 3.6 FATAL_ERROR)

if (NOT PROJECT_NAME)
    project(roman_numerals VERSION 0.0.1 LANGUAGES CXX C)
endif (NOT PROJECT_NAME)

if (NOT RUNTIME_OUTPUT_DIRECTORY)
    set(RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../bin)
    file(MAKE_DIRECTORY
            ${RUNTIME_OUTPUT_DIRECTORY}
            )
endif ()

# set the path to the additional cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)

include(clang)

# configure a header file to pass the version number to the source code
configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/roman_numerals_version.h.in"
        "${CMAKE_CURRENT_SOURCE_DIR}/include/roman_numerals_version.h"
)

add_executable(${PROJECT_NAME}
        ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
        )

add_executable(${PROJECT_NAME}::exe ALIAS ${PROJECT_NAME})

set_target_properties(${PROJECT_NAME}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${RUNTIME_OUTPUT_DIRECTORY}"
        )

target_compile_features(${PROJECT_NAME}
        PRIVATE
        cxx_generalized_initializers
        )

target_link_libraries(${PROJECT_NAME}
        PRIVATE
        roman::encoder_lib
        roman::decoder_lib
        "$<$<BOOL:${UNIX}>:-Xlinker '--no-as-needed'>"
        )

target_include_directories(${PROJECT_NAME}
        PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        )

if (NOT ${MSVC})
    target_compile_options(${PROJECT_NAME}
            PRIVATE
            -pedantic
            -Wall
            -Wextra
            -Werror
            $<$<BOOL:${CMAKE_COMPILER_IS_CLANGCXX}>:-Weverything>
            )
endif (NOT ${MSVC})

target_compile_options(${PROJECT_NAME}
        PRIVATE
        $<$<BOOL:${UNIX}>:-fPIC>
        $<$<BOOL:${MSVC}>:/analyze;/Za>
        )

#
# with Boost
#
option(USE_STATIC_BOOST "Statically link Boost" ${WIN32})

if (NOT BOOST_VERSION)
    if (${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 3.9)
        set(BOOST_VER_STRING "1.66.0")
    elseif (${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} LESS 3.9)
        set(BOOST_VER_STRING "1.61.0")
    else ()
        set(BOOST_VER_STRING "1.65.0")
    endif ()

    set(BOOST_VERSION ${BOOST_VER_STRING} CACHE STRING "Define Boost version")
endif (NOT BOOST_VERSION)


target_compile_definitions(${PROJECT_NAME}
        PRIVATE
        $<$<NOT:$<BOOL:USE_STATIC_BOOST>>:BOOST_ALL_DYN_LINK>
        )

if (USE_STATIC_BOOST)
    set(Boost_USE_STATIC_LIBS ON)
endif (USE_STATIC_BOOST)


set(Boost_Components ${Boost_Components} program_options)

set(BOOST_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/boost)
set(Boost_ADDITIONAL_VERSIONS ${BOOST_VERSION})

find_package(Boost ${BOOST_VERSION} COMPONENTS ${Boost_Components})

if (NOT Boost_FOUND)
    include(Boost)
endif (NOT Boost_FOUND)

target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Boost::boost
        Boost::program_options
        )

if (CLANG_TIDY_EXE)
    set_target_properties(
            ${PROJECT_NAME}
            PROPERTIES
            CXX_CLANG_TIDY "${CLANG_TIDY_PROPERTIES}"
    )
endif ()

#Install targets

install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION bin
        COMPONENT main
        )
