include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(PCBUtilityMaths_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(PCBUtilityMaths_setup_options)
  option(PCBUtilityMaths_ENABLE_HARDENING "Enable hardening" ON)
  option(PCBUtilityMaths_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    PCBUtilityMaths_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    PCBUtilityMaths_ENABLE_HARDENING
    OFF)

  PCBUtilityMaths_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR PCBUtilityMaths_PACKAGING_MAINTAINER_MODE)
    option(PCBUtilityMaths_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(PCBUtilityMaths_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(PCBUtilityMaths_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(PCBUtilityMaths_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(PCBUtilityMaths_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(PCBUtilityMaths_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(PCBUtilityMaths_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(PCBUtilityMaths_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(PCBUtilityMaths_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(PCBUtilityMaths_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(PCBUtilityMaths_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(PCBUtilityMaths_ENABLE_PCH "Enable precompiled headers" OFF)
    option(PCBUtilityMaths_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(PCBUtilityMaths_ENABLE_IPO "Enable IPO/LTO" ON)
    option(PCBUtilityMaths_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(PCBUtilityMaths_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(PCBUtilityMaths_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(PCBUtilityMaths_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(PCBUtilityMaths_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(PCBUtilityMaths_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(PCBUtilityMaths_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(PCBUtilityMaths_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(PCBUtilityMaths_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(PCBUtilityMaths_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(PCBUtilityMaths_ENABLE_PCH "Enable precompiled headers" OFF)
    option(PCBUtilityMaths_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      PCBUtilityMaths_ENABLE_IPO
      PCBUtilityMaths_WARNINGS_AS_ERRORS
      PCBUtilityMaths_ENABLE_USER_LINKER
      PCBUtilityMaths_ENABLE_SANITIZER_ADDRESS
      PCBUtilityMaths_ENABLE_SANITIZER_LEAK
      PCBUtilityMaths_ENABLE_SANITIZER_UNDEFINED
      PCBUtilityMaths_ENABLE_SANITIZER_THREAD
      PCBUtilityMaths_ENABLE_SANITIZER_MEMORY
      PCBUtilityMaths_ENABLE_UNITY_BUILD
      PCBUtilityMaths_ENABLE_CLANG_TIDY
      PCBUtilityMaths_ENABLE_CPPCHECK
      PCBUtilityMaths_ENABLE_COVERAGE
      PCBUtilityMaths_ENABLE_PCH
      PCBUtilityMaths_ENABLE_CACHE)
  endif()

  PCBUtilityMaths_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (PCBUtilityMaths_ENABLE_SANITIZER_ADDRESS OR PCBUtilityMaths_ENABLE_SANITIZER_THREAD OR PCBUtilityMaths_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(PCBUtilityMaths_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(PCBUtilityMaths_global_options)
  if(PCBUtilityMaths_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    PCBUtilityMaths_enable_ipo()
  endif()

  PCBUtilityMaths_supports_sanitizers()

  if(PCBUtilityMaths_ENABLE_HARDENING AND PCBUtilityMaths_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR PCBUtilityMaths_ENABLE_SANITIZER_UNDEFINED
       OR PCBUtilityMaths_ENABLE_SANITIZER_ADDRESS
       OR PCBUtilityMaths_ENABLE_SANITIZER_THREAD
       OR PCBUtilityMaths_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${PCBUtilityMaths_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${PCBUtilityMaths_ENABLE_SANITIZER_UNDEFINED}")
    PCBUtilityMaths_enable_hardening(PCBUtilityMaths_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(PCBUtilityMaths_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(PCBUtilityMaths_warnings INTERFACE)
  add_library(PCBUtilityMaths_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  PCBUtilityMaths_set_project_warnings(
    PCBUtilityMaths_warnings
    ${PCBUtilityMaths_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(PCBUtilityMaths_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(PCBUtilityMaths_options)
  endif()

  include(cmake/Sanitizers.cmake)
  PCBUtilityMaths_enable_sanitizers(
    PCBUtilityMaths_options
    ${PCBUtilityMaths_ENABLE_SANITIZER_ADDRESS}
    ${PCBUtilityMaths_ENABLE_SANITIZER_LEAK}
    ${PCBUtilityMaths_ENABLE_SANITIZER_UNDEFINED}
    ${PCBUtilityMaths_ENABLE_SANITIZER_THREAD}
    ${PCBUtilityMaths_ENABLE_SANITIZER_MEMORY})

  set_target_properties(PCBUtilityMaths_options PROPERTIES UNITY_BUILD ${PCBUtilityMaths_ENABLE_UNITY_BUILD})

  if(PCBUtilityMaths_ENABLE_PCH)
    target_precompile_headers(
      PCBUtilityMaths_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(PCBUtilityMaths_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    PCBUtilityMaths_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(PCBUtilityMaths_ENABLE_CLANG_TIDY)
    PCBUtilityMaths_enable_clang_tidy(PCBUtilityMaths_options ${PCBUtilityMaths_WARNINGS_AS_ERRORS})
  endif()

  if(PCBUtilityMaths_ENABLE_CPPCHECK)
    PCBUtilityMaths_enable_cppcheck(${PCBUtilityMaths_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(PCBUtilityMaths_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    PCBUtilityMaths_enable_coverage(PCBUtilityMaths_options)
  endif()

  if(PCBUtilityMaths_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(PCBUtilityMaths_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(PCBUtilityMaths_ENABLE_HARDENING AND NOT PCBUtilityMaths_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR PCBUtilityMaths_ENABLE_SANITIZER_UNDEFINED
       OR PCBUtilityMaths_ENABLE_SANITIZER_ADDRESS
       OR PCBUtilityMaths_ENABLE_SANITIZER_THREAD
       OR PCBUtilityMaths_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    PCBUtilityMaths_enable_hardening(PCBUtilityMaths_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
