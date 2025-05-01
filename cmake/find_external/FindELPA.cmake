# - Try to find ELPA
#
#  In order to aid find_package the user may set ELPA_ROOT to the root of
#  the installed ELPA.
#
#  Once done this will define
#  ELPA_FOUND - System has ELPA
#  ELPA_INCLUDE_DIR - The ELPA include directories
#  ELPA_LIBRARY - The libraries needed to use ELPA
#  ELPA_COMPILE_DEFINITIONS - ELPA compile definitions

# include(DependencyMacros)

set(ELPA_HINTS ${STAGE_DIR}${CMAKE_INSTALL_PREFIX} ${CMAKE_INSTALL_PREFIX})

set( elpa_LIBRARY_NAME libelpa.a elpa )
if(BUILD_SHARED_LIBS)
  set( elpa_LIBRARY_NAME elpa )
endif()

find_path(ELPA_INCLUDE_DIR elpa/elpa.h
            HINTS ${ELPA_HINTS}
            PATHS ${ELPA_ROOT}
            PATH_SUFFIXES include include/elpa-2025.01.001
            NO_DEFAULT_PATH
          )

find_library(ELPA_LIBRARY 
             NAMES ${elpa_LIBRARY_NAME}
             HINTS ${ELPA_HINTS}
             PATHS ${ELPA_ROOT}
             PATH_SUFFIXES lib lib32 lib64
             NO_DEFAULT_PATH
        )

set(ELPA_LIBRARIES ${ELPA_LIBRARY})
set(ELPA_INCLUDE_DIRS ${ELPA_INCLUDE_DIR})
set(ELPA_COMPILE_DEFINITIONS "TAMM_USE_ELPA")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ELPA 
                              REQUIRED_VARS ELPA_LIBRARIES ELPA_INCLUDE_DIRS ELPA_COMPILE_DEFINITIONS
                              HANDLE_COMPONENTS)

set(ELPA_FOUND ${ELPA_FOUND})

if(ELPA_FOUND)
  if(${CMSB_PROJECTS}_HAS_CUDA)
    find_package(CUDAToolkit REQUIRED COMPONENTS cublas)
    if(NOT LINK_STATIC_GPU_LIBS)
      list(APPEND ELPA_LIBRARIES CUDA::cudart CUDA::cublas CUDA::cublasLt CUDA::cusolver)
    else()
      list(APPEND ELPA_LIBRARIES CUDA::cudart_static CUDA::cublas_static CUDA::cublasLt_static CUDA::cusolver_static)
    endif()
  endif()
  message(STATUS "ELPA_LIBRARIES = ${ELPA_LIBRARIES}")
  if( ELPA_LIBRARIES AND NOT TARGET elpa_cmsb )
      add_library( elpa_cmsb INTERFACE IMPORTED )
      set_target_properties( elpa_cmsb PROPERTIES
          INTERFACE_INCLUDE_DIRECTORIES "${ELPA_INCLUDE_DIRS}"
          INTERFACE_LINK_LIBRARIES      "${ELPA_LIBRARIES}"
          INTERFACE_COMPILE_DEFINITIONS "${ELPA_COMPILE_DEFINITIONS}"
      )
  endif()
endif()



