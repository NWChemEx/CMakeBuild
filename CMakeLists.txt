cmake_minimum_required(VERSION 3.26.0)
project(CMakeBuild VERSION 0.0.0 LANGUAGES C CXX Fortran)

include( FetchContent )
set(LAM_GIT_TAG 290e2e080418e15fc35c80daad23e78c220fd6b4)
if(ENABLE_DEV_MODE)
  set(LAM_GIT_TAG main)
endif()

if(ENABLE_OFFLINE_BUILD)
FetchContent_Declare(linalg-cmake-modules
  URL ${DEPS_LOCAL_PATH}/linalg-cmake-modules
)
else()
FetchContent_Declare(linalg-cmake-modules
  GIT_REPOSITORY https://github.com/wavefunction91/linalg-cmake-modules.git
  GIT_TAG ${LAM_GIT_TAG}
)
endif()

FetchContent_MakeAvailable( linalg-cmake-modules )
set(CMSB_LAM_PATH ${linalg-cmake-modules_SOURCE_DIR})

include(${CMAKE_CURRENT_LIST_DIR}/cmake/macros/BuildCMSBModule.cmake)

if(NOT DEFINED BUILD_TESTS)
  set(BUILD_TESTS OFF)
endif()
set(BUILD_METHODS OFF)

build_cmsb_module(${CMAKE_CURRENT_LIST_DIR})
