if(NOT DISABLE_BOOST_DOWNLOAD)

    include(ExternalProject)

    if(WIN32)
        set(SCRIPT_SUFFIX ".bat")
        set(EXE_SUFFIX ".exe")
        set(ARCHIVE_SUFFIX ".zip")
    else(WIN32)
        set(SCRIPT_SUFFIX ".sh")
        set(EXE_SUFFIX "")
        set(ARCHIVE_SUFFIX ".tar.bz2")
    endif(WIN32)

    if(NOT BOOST_VERSION)
        if(${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} VERSION_LESS 3.9)
            set(BOOST_VER_STRING "1.63.0")
        else()
            set(BOOST_VER_STRING "1.65.1")
        endif()

        set(BOOST_VERSION ${BOOST_VER_STRING} CACHE STRING "Define Boost version (at least 1.63.0)")
    endif(NOT BOOST_VERSION)

    string(REPLACE "." "_" Boost_Version_Underscore ${BOOST_VERSION})


    foreach(library ${Boost_Components})
        if("${library}" MATCHES "unit_test_framework")
            set(BOOST_LIBRARIES ${BOOST_LIBRARIES} --with-test)
        else()
            set(BOOST_LIBRARIES ${BOOST_LIBRARIES} --with-${library})
        endif()
    endforeach(library)

    set(BOOST_THREADING multi)
    set(BOOST_TOOLSET)
    set(BOOST_TOOLSET_BUILD)

    if(USE_STATIC_BOOST)
        set(BOOST_LINK "static")
    else(USE_STATIC_BOOST)
        set(BOOST_LINK "shared,static")
    endif(USE_STATIC_BOOST)

    set(Boost_lib_name_suffix "")

    if(CMAKE_COMPILER_IS_GNUCXX AND WIN32)
        set(BOOST_TOOLSET "mingw")
        set(BOOST_TOOLSET_BUILD "toolset=gcc")
        set(BOOST_CXX_FLAGS "-std=c++11")
        set(BOOST_LINK_FLAGS "")
    elseif(CMAKE_COMPILER_IS_GNUCXX)
        set(BOOST_TOOLSET "gcc")
        set(BOOST_TOOLSET_BUILD "toolset=gcc")
        set(BOOST_CXX_FLAGS "cxxflags='-std=c++11'")
        set(BOOST_LINK_FLAGS "")
    elseif(CMAKE_COMPILER_IS_CLANGCXX)
        set(BOOST_TOOLSET "clang")
        set(BOOST_TOOLSET_BUILD "toolset=clang-${CMAKE_CXX_COMPILER_VERSION}")
        set(BOOST_CXX_FLAGS "cxxflags='-Wno-c99-extensions -std=c++11'")
        set(BOOST_LINK_FLAGS "")
    elseif(MSVC)
        set(BOOST_TOOLSET "msvc")
        if(${MSVC_VERSION} EQUAL "1800")
            set(BOOST_TOOLSET_BUILD "toolset=msvc-12.0")
        elseif(${MSVC_VERSION} EQUAL "1900")
            set(BOOST_TOOLSET_BUILD "toolset=msvc-14.0")
        elseif(${MSVC_VERSION} VERSION_GREATER "1910")
            set(BOOST_TOOLSET_BUILD "toolset=msvc-14.1")
        endif(${MSVC_VERSION} EQUAL "1800")

        set(Boost_lib_dir_suffix "32")
        if(CMAKE_CL_64)
            set(BOOST_TOOLSET_ADDRESSMODEL "address-model=64")
            set(Boost_lib_dir_suffix "64")
        endif(CMAKE_CL_64)
    endif(CMAKE_COMPILER_IS_GNUCXX AND WIN32)


    set(boost_INSTALL ${CMAKE_CURRENT_LIST_DIR}/../third_party/boost)
    set(boost_INCLUDE_DIR ${boost_INSTALL}/include)
    set(boost_LIB_DIR ${boost_INSTALL}/lib${Boost_lib_dir_suffix})

    set(BOOST_LAYOUT versioned)

    if(NOT TARGET boost_external)
        externalproject_add(boost_external
            URL https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${Boost_Version_Underscore}${ARCHIVE_SUFFIX}
            #    URL https://github.com/boostorg/boost/archive/boost-${BOOST_VERSION}.tar.gz
            PREFIX boost
            PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/../scripts/config_toolset.bat <SOURCE_DIR>/tools/build/src/engine/config_toolset.bat
            INSTALL_DIR ${boost_INSTALL}
            LOG_DOWNLOAD ON
            LOG_CONFIGURE ON
            LOG_BUILD ON
            UPDATE_COMMAND ""
            CONFIGURE_COMMAND
            <SOURCE_DIR>/bootstrap${SCRIPT_SUFFIX} --with-toolset=${BOOST_TOOLSET} --prefix=<INSTALL_DIR>
            COMMAND <SOURCE_DIR>/b2 clean
            BUILD_COMMAND
            <SOURCE_DIR>/b2${EXE_SUFFIX} install --prefix=<INSTALL_DIR>
            ${BOOST_LIBRARIES}
            -j8
            --build-type=complete
            --layout=${BOOST_LAYOUT}
            link=${BOOST_LINK}
            threading=${BOOST_THREADING}
            ${BOOST_CXX_FLAGS}
            ${BOOST_LINK_FLAGS}
            ${BOOST_TOOLSET_BUILD}
            ${BOOST_TOOLSET_ADDRESSMODEL}
            BUILD_IN_SOURCE 1
            INSTALL_COMMAND ""
            )

        if("${BOOST_LAYOUT}" STREQUAL "versioned")
            string(REPLACE "_0" "" Boost_Version_Shorten ${Boost_Version_Underscore})
            externalproject_add_step(boost_external MoveHeaders
                COMMAND ${CMAKE_COMMAND} -E copy_directory ${boost_INCLUDE_DIR}/boost-${Boost_Version_Shorten}/boost ${boost_INCLUDE_DIR}/boost
                COMMAND ${CMAKE_COMMAND} -E remove_directory ${boost_INCLUDE_DIR}/boost-${Boost_Version_Shorten}
                COMMENT "Move boost headers..."
                DEPENDEES install
                )
        endif("${BOOST_LAYOUT}" STREQUAL "versioned")

        if(NOT (${boost_INSTALL}/lib STREQUAL ${boost_LIB_DIR}))
            externalproject_add_step(boost_external MoveLibs
                COMMAND ${CMAKE_COMMAND} -E copy_directory ${boost_INSTALL}/lib ${boost_LIB_DIR}
                COMMAND ${CMAKE_COMMAND} -E remove_directory ${boost_INSTALL}/lib
                COMMENT "Move boost libs..."
                DEPENDEES install
                )
        endif(NOT (${boost_INSTALL}/lib STREQUAL ${boost_LIB_DIR}))

        if(MINGW)
            externalproject_add_step(boost_external FixBoostProjectConfig
                COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/../scripts/fix_boost_project-config_for_mingw.bat <BINARY_DIR>
                COMMAND ${CMAKE_COMMAND} -E chdir <BINARY_DIR> fix_boost_project-config_for_mingw.bat project-config.jam
                COMMENT "Fix boost project-config.jam file for MinGW..."
                DEPENDEES configure
                DEPENDERS build
                )
        endif(MINGW)
    endif(NOT TARGET boost_external)

    if(WIN32)
        set(Boost_USE_MULTITHREADED ON)
        set(Boost_USE_STATIC_RUNTIME OFF)
    endif(WIN32)

    set(Boost_INCLUDE_DIR ${boost_INCLUDE_DIR})
    # Hack to make it works, otherwise INTERFACE_INCLUDE_DIRECTORIES will not be propagated
    file(MAKE_DIRECTORY ${Boost_INCLUDE_DIR})

    set(Boost_INCLUDE_DIRS ${boost_INCLUDE_DIR})
    set(BOOST_ROOT ${boost_INSTALL} CACHE INTERNAL "Path to include folder for Boost")

    # For header-only libraries
    if(NOT TARGET Boost::boost)
        add_library(Boost::boost INTERFACE IMPORTED)
        if(EXISTS ${Boost_INCLUDE_DIRS})
            set_target_properties(Boost::boost PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIRS}")
        endif()
        add_dependencies(Boost::boost boost_external)
    endif(NOT TARGET Boost::boost)

    if(NOT TARGET Boost::diagnostic_definitions)
        add_library(Boost::diagnostic_definitions INTERFACE IMPORTED)
        add_library(Boost::disable_autolinking INTERFACE IMPORTED)
        add_library(Boost::dynamic_linking INTERFACE IMPORTED)
    endif()

    if(WIN32)
        set(Boost_LIB_DIAGNOSTIC_DEFINITIONS "-DBOOST_LIB_DIAGNOSTIC")
        set_target_properties(Boost::diagnostic_definitions PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "BOOST_LIB_DIAGNOSTIC")
        set_target_properties(Boost::disable_autolinking PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "BOOST_ALL_NO_LIB")
        set_target_properties(Boost::dynamic_linking PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK")
    endif(WIN32)

    #
    # Runs compiler with "-dumpversion" and parses major/minor
    # version with a regex.
    #
    function(_boost_compiler_dumpversion _OUTPUT_VERSION)
        string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1\\2"
            _boost_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})

        set(${_OUTPUT_VERSION} ${_boost_COMPILER_VERSION} PARENT_SCOPE)
    endfunction()

    #======================
    # Systematically build up the Boost ABI tag for the 'tagged' and 'versioned' layouts
    # see https://github.com/Kitware/CMake/blob/master/Modules/FindBoost.cmake

    # Guesses Boost's compiler prefix used in built library names
    # Returns the guess by setting the variable pointed to by _ret
    function(_boost_guess_compiler_prefix _ret)
        if("x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xClang")
            _boost_compiler_dumpversion(_boost_COMPILER_VERSION)
            set(_boost_COMPILER "-clang${_boost_COMPILER_VERSION}")
        elseif("x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xIntel")
            if(WIN32)
                set(_boost_COMPILER "-iw")
            else()
                set(_boost_COMPILER "-il")
            endif()
        elseif(GHSMULTI)
            set(_boost_COMPILER "-ghs")
        elseif("x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xMSVC")
            if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.10)
                set(_boost_COMPILER "-vc141")
            elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19)
                set(_boost_COMPILER "-vc140")
            elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 18)
                set(_boost_COMPILER "-vc120")
            endif()
        elseif(BORLAND)
            set(_boost_COMPILER "-bcb")
        elseif(CMAKE_CXX_COMPILER_ID STREQUAL "SunPro")
            set(_boost_COMPILER "-sw")
        elseif(CMAKE_CXX_COMPILER_ID STREQUAL "XL")
            set(_boost_COMPILER "-xlc")
        elseif(MINGW)
            _boost_compiler_dumpversion(_boost_COMPILER_VERSION)
            set(_boost_COMPILER "-mgw${_boost_COMPILER_VERSION}")
        elseif(UNIX)
            if(CMAKE_COMPILER_IS_GNUCXX)
                _boost_compiler_dumpversion(_boost_COMPILER_VERSION)
                # Determine which version of GCC we have.
                if(APPLE)
                    # In Boost 1.36.0 and newer, the mangled compiler name used
                    # on Mac OS X/Darwin is "xgcc".
                    set(_boost_COMPILER "-xgcc${_boost_COMPILER_VERSION}")
                else()
                    #set(_boost_COMPILER "-gcc${_boost_COMPILER_VERSION}")
                    set(_boost_COMPILER "-gcc")
                endif()
            endif()
        else()
            set(_boost_COMPILER "")
        endif()
        set(${_ret} ${_boost_COMPILER} PARENT_SCOPE)
    endfunction()

    if(("${BOOST_LAYOUT}" STREQUAL "versioned") OR ("${BOOST_LAYOUT}" STREQUAL "tagged"))
        set(_boost_RELEASE_ABI_TAG "-")
        set(_boost_DEBUG_ABI_TAG "-")
        # Key       Use this library when:
        #  s        linking statically to the C++ standard library and
        #           compiler runtime support libraries.
        if(Boost_USE_STATIC_RUNTIME)
            set(_boost_RELEASE_ABI_TAG "${_boost_RELEASE_ABI_TAG}s")
            set(_boost_DEBUG_ABI_TAG "${_boost_DEBUG_ABI_TAG}s")
        endif()
        #  g        using debug versions of the standard and runtime
        #           support libraries
        if(WIN32 AND Boost_USE_DEBUG_RUNTIME)
            if("x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xMSVC"
                OR "x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xClang"
                OR "x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xIntel")
                string(APPEND _boost_DEBUG_ABI_TAG "g")
            endif()
        endif()
        #  y        using special debug build of python
        if(Boost_USE_DEBUG_PYTHON)
            string(APPEND _boost_DEBUG_ABI_TAG "y")
        endif()
        #  d        using a debug version of your code
        string(APPEND _boost_DEBUG_ABI_TAG "d")
        #  p        using the STLport standard library rather than the
        #           default one supplied with your compiler
        if(Boost_USE_STLPORT)
            string(APPEND _boost_RELEASE_ABI_TAG "p")
            string(APPEND _boost_DEBUG_ABI_TAG "p")
        endif()
        #  n        using the STLport deprecated "native iostreams" feature
        #           removed from the documentation in 1.43.0 but still present in
        #           boost/config/auto_link.hpp
        if(Boost_USE_STLPORT_DEPRECATED_NATIVE_IOSTREAMS)
            string(APPEND _boost_RELEASE_ABI_TAG "n")
            string(APPEND _boost_DEBUG_ABI_TAG "n")
        endif()

        #  -x86     Architecture and address model tag
        #           First character is the architecture, then word-size, either 32 or 64
        #           Only used in 'versioned' layout, added in Boost 1.66.0
        set(_boost_ARCHITECTURE_TAG "")
        # {CMAKE_CXX_COMPILER_ARCHITECTURE_ID} is not currently set for all compilers
        if(NOT "x${CMAKE_CXX_COMPILER_ARCHITECTURE_ID}" STREQUAL "x" AND NOT Boost_VERSION VERSION_LESS 106600)
            string(APPEND _boost_ARCHITECTURE_TAG "-")
            # This needs to be kept in-sync with the section of CMakePlatformId.h.in
            # inside 'defined(_WIN32) && defined(_MSC_VER)'
            if(${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} STREQUAL "IA64")
                string(APPEND _boost_ARCHITECTURE_TAG "i")
            elseif(${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} STREQUAL "X86"
                OR ${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} STREQUAL "x64")
                string(APPEND _boost_ARCHITECTURE_TAG "x")
            elseif(${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} MATCHES "^ARM")
                string(APPEND _boost_ARCHITECTURE_TAG "a")
            elseif(${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} STREQUAL "MIPS")
                string(APPEND _boost_ARCHITECTURE_TAG "m")
            endif()

            if(CMAKE_SIZEOF_VOID_P EQUAL 8)
                string(APPEND _boost_ARCHITECTURE_TAG "64")
            else()
                string(APPEND _boost_ARCHITECTURE_TAG "32")
            endif()
        endif()

        set(_boost_MULTITHREADED "-mt")
        if(NOT Boost_USE_MULTITHREADED)
            set(_boost_MULTITHREADED "")
        endif()

        _boost_guess_compiler_prefix(boost_COMPILER)
    endif(("${BOOST_LAYOUT}" STREQUAL "versioned") OR ("${BOOST_LAYOUT}" STREQUAL "tagged"))

    if(("${BOOST_LAYOUT}" STREQUAL "versioned"))
        set(_boost_Version "-${Boost_Version_Underscore}")
    endif(("${BOOST_LAYOUT}" STREQUAL "versioned"))


    if(USE_STATIC_BOOST)
        if(MSVC)
            set(boost_LIBRARY_SUFFIX .lib)
        else()
            set(boost_LIBRARY_SUFFIX .a)
        endif(MSVC)
    else(USE_STATIC_BOOST)
        if(MSVC)
            set(boost_LIBRARY_SUFFIX .dll)
        else()
            set(boost_LIBRARY_SUFFIX .so)
        endif(MSVC)

    endif(USE_STATIC_BOOST)

    set(Boost_LIBRARIES "")

    foreach(library ${Boost_Components})
        if(NOT TARGET Boost::${library})
            message(STATUS "Import target Boost::${library}")
            if(USE_STATIC_BOOST)
                add_library(Boost::${library} STATIC IMPORTED)
            else()
                add_library(Boost::${library} UNKNOWN IMPORTED)
            endif()
            if(EXISTS "${Boost_INCLUDE_DIRS}")
                set_target_properties(Boost::${library} PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIRS}")
            endif()

            set_target_properties(Boost::${library} PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
                IMPORTED_LOCATION
                "${boost_LIB_DIR}/libboost_${library}${boost_COMPILER}${_boost_MULTITHREADED}${_boost_RELEASE_ABI_TAG}${_boost_ARCHITECTURE_TAG}${_boost_Version}${boost_LIBRARY_SUFFIX}")

            set_property(TARGET Boost::${library} APPEND PROPERTY
                IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(Boost::${library} PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
                IMPORTED_LOCATION_RELEASE
                "${boost_LIB_DIR}/libboost_${library}${boost_COMPILER}${_boost_MULTITHREADED}${_boost_RELEASE_ABI_TAG}${_boost_ARCHITECTURE_TAG}${_boost_Version}${boost_LIBRARY_SUFFIX}")
            set_property(TARGET Boost::${library} APPEND PROPERTY
                IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(Boost::${library} PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
                IMPORTED_LOCATION_DEBUG
                "${boost_LIB_DIR}/libboost_${library}${boost_COMPILER}${_boost_MULTITHREADED}${_boost_DEBUG_ABI_TAG}${_boost_ARCHITECTURE_TAG}${_boost_Version}${boost_LIBRARY_SUFFIX}")

            add_dependencies(Boost::${library} boost_external)
            list(APPEND Boost_LIBRARIES Boost::${library})
        endif()
    endforeach(library)

    set(Boost_FOUND TRUE)
endif(NOT DISABLE_BOOST_DOWNLOAD)