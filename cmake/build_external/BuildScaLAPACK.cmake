# This file will build the Reference ScaLAPACK distribution over 
# an existing BLAS and LAPACK installation.

include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

enable_language(C Fortran)
foreach(depend BLAS LAPACK)
    find_or_build_dependency(${depend})
    package_dependency(${depend} DEPENDENCY_PATHS)
endforeach()


set(ScaLAPACK_URL https://github.com/Reference-ScaLAPACK/scalapack.git)

if(CMAKE_Fortran_COMPILER_ID STREQUAL "Cray")
    message(STATUS "Detected Cray Fortran compiler!")
endif()

# set(ScaLAPACK_C_FLAGS "-Wno-unused-variable -O3")
set(ScaLAPACK_C_FLAGS "${CMAKE_C_FLAGS_INIT}")
set(ScaLAPACK_F_FLAGS "${CMAKE_Fortran_FLAGS_INIT}")

if(NOT BLAS_INT4)
    set(ScaLAPACK_BUILD_INDEX64 "-DInt=long")
    set(ScaLAPACK_C_FLAGS "-DInt=long ${ScaLAPACK_C_FLAGS}")
    if( CMAKE_Fortran_COMPILER_ID MATCHES "GNU" OR CMAKE_Fortran_COMPILER_ID MATCHES "Flang" )
        set( _FFD8 "-fdefault-integer-8" )
    elseif( CMAKE_Fortran_COMPILER_ID MATCHES "PGI" )
        set( _FFD8 "-i8" )
    endif()
    set(ScaLAPACK_F_FLAGS "${_FFD8} ${ScaLAPACK_F_FLAGS}")
endif()

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(ScaLAPACK_External
                SOURCE_DIR ${DEPS_LOCAL_PATH}/scalapack
                CMAKE_ARGS
                    ${DEPENDENCY_CMAKE_OPTIONS}
                   -DSCALAPACK_BUILD_TESTS=OFF
                   -DUSE_OPTIMIZED_LAPACK_BLAS=ON
                   #-DBUILD_SHARED_LIBS=OFF
                   -DCMAKE_C_FLAGS=${ScaLAPACK_C_FLAGS}
                   -DCMAKE_Fortran_FLAGS=${SCALAPACK_F_FLAGS}
                #    -DBLAS_LIBRARIES=${BLAS_LIBRARIES}
                #    -DLAPACK_LIBRARIES=${LAPACK_LIBRARIES}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
        CMAKE_CACHE_ARGS ${DEPENDENCY_PATHS} ${CORE_CMAKE_LISTS} ${CORE_CMAKE_STRINGS}
        )
else()
ExternalProject_Add(ScaLAPACK_External
                GIT_REPOSITORY ${ScaLAPACK_URL}
                GIT_TAG ${SL_GIT_TAG}
                UPDATE_DISCONNECTED 1
                CMAKE_ARGS
                    ${DEPENDENCY_CMAKE_OPTIONS}
                   -DSCALAPACK_BUILD_TESTS=OFF
                   -DUSE_OPTIMIZED_LAPACK_BLAS=ON
                   #-DBUILD_SHARED_LIBS=OFF
                   -DCMAKE_C_FLAGS=${ScaLAPACK_C_FLAGS}
                   -DCMAKE_Fortran_FLAGS=${SCALAPACK_F_FLAGS}
                #    -DBLAS_LIBRARIES=${BLAS_LIBRARIES}
                #    -DLAPACK_LIBRARIES=${LAPACK_LIBRARIES}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
        CMAKE_CACHE_ARGS ${DEPENDENCY_PATHS} ${CORE_CMAKE_LISTS} ${CORE_CMAKE_STRINGS}
        )
endif()

add_dependencies(ScaLAPACK_External LAPACK_External BLAS_External)


