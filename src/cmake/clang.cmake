
# Check for clang compiler
if(CMAKE_CXX_COMPILER MATCHES ".*clang")
    set(CMAKE_COMPILER_IS_CLANGCXX TRUE)
    set(CLANG_VERSION ${CMAKE_CXX_COMPILER_VERSION})
    message(STATUS "Clang found")
else()
    set(CMAKE_COMPILER_IS_CLANGCXX FALSE)

endif()

find_program(
    CLANG_TIDY_EXE
    NAMES "clang-tidy"
    DOC "Path to clang-tidy executable"
)

# From http://clang.llvm.org/extra/clang-tidy/#using-clang-tidy
#
# clang-tidy has its own checks and can also run Clang static analyzer checks. Each check has a name and the checks to run can be chosen using the -checks= option, which specifies a comma-separated list of positive and negative (prefixed with -) globs. Positive globs add subsets of checks, negative globs remove them. For example,
#     $> clang-tidy test.cpp -checks=-*,clang-analyzer-*,-clang-analyzer-cplusplus*
# will disable all default checks (-*) and enable all clang-analyzer-* checks except for clang-analyzer-cplusplus* ones.
#
# There are currently the following groups of checks:
#
# Name prefix           Description
# android-	            Checks related to Android.
# boost-	            Checks related to Boost library.
# bugprone-	            Checks that target bugprone code constructs.
# cert-	                Checks related to CERT Secure Coding Guidelines.
# cppcoreguidelines-	Checks related to C++ Core Guidelines.
# clang-analyzer-	    Clang Static Analyzer checks.
# fuchsia-	            Checks related to Fuchsia coding conventions.
# google-	            Checks related to Google coding conventions.
# hicpp-	            Checks related to High Integrity C++ Coding Standard.
# llvm-	                Checks related to the LLVM coding conventions.
# misc-	                Checks that we didn’t have a better category for.
# modernize-	        Checks that advocate usage of modern (currently “modern” means “C++11”) language constructs.
# mpi-	                Checks related to MPI (Message Passing Interface).
# objc-	                Checks related to Objective-C coding conventions.
# performance-	        Checks that target performance-related issues.
# readability-	        Checks that target readability-related issues that don’t relate to any particular coding style.

if(NOT CLANG_TIDY_EXE)
    message(STATUS "clang-tidy not found.")
else()
    message(STATUS "clang-tidy found: ${CLANG_TIDY_EXE}")
    set(CLANG_TIDY_PROPERTIES "${CLANG_TIDY_EXE}"
        "-checks=-*,bugprone-*,cert-*,cppcoreguidelines-*,clang-analyzer-*,hicpp-*,misc-*,modernize-*,performance-*,readability-*")
endif()
