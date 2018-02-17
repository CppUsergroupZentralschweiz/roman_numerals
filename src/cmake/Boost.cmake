if(NOT DISABLE_BOOST_DOWNLOAD)

    include(ExternalProject)

    if(WIN32)
        set(SCRIPT_SUFFIX .bat)
        set(EXE_SUFFIX .exe)
    else(WIN32)
        set(SCRIPT_SUFFIX .sh)
        set(EXE_SUFFIX "")
    endif(WIN32)

    if(NOT BOOST_VERSION)
        if(${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 3.9)
            set(BOOST_VER_STRING "1.66.0")
        elseif(${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} LESS 3.9)
            set(BOOST_VER_STRING "1.61.0")
        else()
            set(BOOST_VER_STRING "1.65.0")
        endif()

        set(BOOST_VERSION ${BOOST_VER_STRING} CACHE STRING "Define Boost version")
    endif(NOT BOOST_VERSION)

    string(REPLACE "." "_" Boost_Version_Underscore ${BOOST_VERSION})

    set(boost_INSTALL ${CMAKE_CURRENT_LIST_DIR}/../third_party/boost)
    set(boost_INCLUDE_DIR ${boost_INSTALL}/include)
    set(boost_LIB_DIR ${boost_INSTALL}/lib)

    foreach(library ${Boost_Components})
        if("${library}" MATCHES "unit_test_framework")
            set(BOOST_LIBRARIES ${BOOST_LIBRARIES} --with-test)
        else()
            set(BOOST_LIBRARIES ${BOOST_LIBRARIES} --with-${library})
        endif()
    endforeach(library)

    set(BOOST_THREADING multi)

    set(BOOST_LAYOUT tagged)

    set(BOOST_TOOLSET)
    set(BOOST_TOOLSET_BUILD)

    if(USE_STATIC_BOOST)
        set(BOOST_LINK "static")
    else(USE_STATIC_BOOST)
        set(BOOST_LINK "shared,static")
    endif(USE_STATIC_BOOST)

    if(MSVC12)
        set(BOOST_TOOLSET_BUILD "toolset=msvc-12.0")
    elseif(MSVC14)
        set(BOOST_TOOLSET_BUILD "toolset=msvc-14.0")
    endif(MSVC12)

    # Use the same compiler for building boost as for your own project
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
        set(BOOST_TOOLSET_BUILD "toolset=clang")
        set(BOOST_CXX_FLAGS "cxxflags='-Wno-c99-extensions -stdlib=libc++ -std=c++11'")
        set(BOOST_LINK_FLAGS "linkflags='-stdlib=libc++'")
    elseif(MSVC)
        set(BOOST_TOOLSET "msvc")
        set(BOOST_LAYOUT versioned)
    endif(CMAKE_COMPILER_IS_GNUCXX AND WIN32)

    if(CMAKE_CL_64)
        set(BOOST_TOOLSET_ADDRESSMODEL "address-model=64")
    endif(CMAKE_CL_64)

    if(NOT TARGET boost_external)
        ExternalProject_Add(boost_external
            URL http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${Boost_Version_Underscore}.tar.bz2
            PREFIX boost
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

        if(MSVC)
            string(REPLACE "_0" "" Boost_Version_Shorten ${Boost_Version_Underscore})
            ExternalProject_Add_Step(boost_external MoveHeaders
                COMMAND ${CMAKE_COMMAND} -E copy_directory ${boost_INCLUDE_DIR}/boost-${Boost_Version_Shorten}/boost ${EXT_INSTALL_INCLUDE_DIR}/boost
                COMMAND ${CMAKE_COMMAND} -E remove_directory ${boost_INCLUDE_DIR}/boost-${Boost_Version_Shorten}
                COMMENT "Move boost headers..."
                DEPENDEES install
                )
        endif(MSVC)

        if(MINGW)
            ExternalProject_Add_Step(boost_external FixBoostProjectConfig
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
    endif()

    if(USE_STATIC_BOOST)
        set(boost_LIBRARY_SUFFIX .a)
    else(USE_STATIC_BOOST)
        set(boost_LIBRARY_SUFFIX .so)
    endif(USE_STATIC_BOOST)

    set(boost_NAME_SUFFIX_RELEASE "")
    set(boost_NAME_SUFFIX_DEBUG "")

    if(Boost_USE_MULTITHREADED)
        set(boost_NAME_SUFFIX_RELEASE "-mt")
        set(boost_NAME_SUFFIX_DEBUG "-mt")
    endif(Boost_USE_MULTITHREADED)

    if(Boost_USE_STATIC_RUNTIME)
        set(boost_NAME_SUFFIX_RELEASE "${boost_NAME_SUFFIX_RELEASE}-s")
        set(boost_NAME_SUFFIX_DEBUG "${boost_NAME_SUFFIX_RELEASE}-sd")
    else(Boost_USE_STATIC_RUNTIME)
        set(boost_NAME_SUFFIX_DEBUG "${boost_NAME_SUFFIX_DEBUG}-d")
    endif(Boost_USE_STATIC_RUNTIME)

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
                "${boost_LIB_DIR}/libboost_${library}${boost_NAME_SUFFIX_RELEASE}${boost_LIBRARY_SUFFIX}")

            set_property(TARGET Boost::${library} APPEND PROPERTY
                IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(Boost::${library} PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
                IMPORTED_LOCATION_RELEASE
                "${boost_LIB_DIR}/libboost_${library}${boost_NAME_SUFFIX_RELEASE}${boost_LIBRARY_SUFFIX}")

            set_property(TARGET Boost::${library} APPEND PROPERTY
                IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(Boost::${library} PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
                IMPORTED_LOCATION_DEBUG
                "${boost_LIB_DIR}/libboost_${library}${boost_NAME_SUFFIX_DEBUG}${boost_LIBRARY_SUFFIX}")

            add_dependencies(Boost::${library} boost_external)
            list(APPEND Boost_LIBRARIES Boost::${library})
        endif()
    endforeach(library)

    set(Boost_FOUND TRUE)
endif(NOT DISABLE_BOOST_DOWNLOAD)