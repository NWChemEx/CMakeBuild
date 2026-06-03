
enable_language(C Fortran)

include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

find_or_build_dependency(BLAS)
package_dependency(BLAS DEPENDENCY_PATHS)

set(LAPACK_URL https://github.com/Reference-LAPACK/lapack.git)

if(CMAKE_Fortran_COMPILER_ID STREQUAL "Cray")
    message(STATUS "Detected Cray Fortran compiler!")
endif()

set(LAPACK_BUILD_INDEX64 "-DBUILD_INDEX64=ON")
if(BLAS_INT4)
    set(LAPACK_BUILD_INDEX64 "-DBUILD_INDEX64=OFF")
endif()

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(LAPACK_External
        SOURCE_DIR ${DEPS_LOCAL_PATH}/lapack
        CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS}
                   -DUSE_OPTIMIZED_BLAS=ON
                   -DBLAS_LIBRARIES=${BLAS_LIBRARIES}
                   -DBUILD_TESTING=OFF
                   -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS_INIT}
                   -DCMAKE_Fortran_FLAGS=${CMAKE_Fortran_FLAGS_INIT}
                   -DLAPACKE=OFF -DTEST_FORTRAN_COMPILER=OFF
                   ${LAPACK_BUILD_INDEX64}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
        CMAKE_CACHE_ARGS ${DEPENDENCY_PATHS} ${CORE_CMAKE_LISTS} ${CORE_CMAKE_STRINGS}
        )
else()
ExternalProject_Add(LAPACK_External
        GIT_REPOSITORY ${LAPACK_URL}
        GIT_TAG ${LAPACK_GIT_TAG}
        UPDATE_DISCONNECTED 1
        CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS}
                   -DUSE_OPTIMIZED_BLAS=ON
                   -DBLAS_LIBRARIES=${BLAS_LIBRARIES}
                   -DBUILD_TESTING=OFF
                   -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS_INIT}
                   -DCMAKE_Fortran_FLAGS=${CMAKE_Fortran_FLAGS_INIT}
                   -DLAPACKE=OFF -DTEST_FORTRAN_COMPILER=OFF
                   ${LAPACK_BUILD_INDEX64}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
        CMAKE_CACHE_ARGS ${DEPENDENCY_PATHS} ${CORE_CMAKE_LISTS} ${CORE_CMAKE_STRINGS}
        )
endif()

add_dependencies(LAPACK_External BLAS_External)