
#
# This file will build BLIS which is the default BLAS library we use.
#

enable_language(C Fortran)

include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

is_valid_and_true(BLAS_ARCH __blas_arch_set)
if (NOT __blas_arch_set)
    message(STATUS "BLAS_ARCH not set, will auto-detect")
    set(__BLAS_ARCH "auto")
else()
    message(STATUS "BLAS_ARCH set to ${BLAS_ARCH}")
    set(__BLAS_ARCH ${BLAS_ARCH})
endif()

string_concat(CMAKE_C_FLAGS_RELEASE "" " " BLIS_FLAGS)

if(CMAKE_POSITION_INDEPENDENT_CODE)
    set(FPIC_LIST "-fPIC")
    string_concat(FPIC_LIST "" " " BLIS_FLAGS)
endif()

# set(BLIS_TAR https://github.com/flame/blis/archive/refs/tags/0.9.0.tar.gz)

is_valid_and_true(BLIS_TAG __lt_set)
if(__lt_set)
  set(BLIS_GIT_TAG ${BLIS_TAG})
endif()

set(BLIS_OPT_FLAGS "${BLIS_FLAGS}")

set(BLIS_W_OPENMP no)
if(USE_OPENMP)
  set(BLIS_W_OPENMP openmp)
endif()

set(BLIS_INT_FLAGS -i 64 -b 64 -t ${BLIS_W_OPENMP} --disable-blas)# --enable-cblas

if(BLAS_INT4)
    set(BLIS_INT_FLAGS -i 32 -b 32 -t ${BLIS_W_OPENMP} --disable-blas)# --enable-cblas
endif()

set(BLIS_MISC_OPTIONS --without-memkind --enable-scalapack-compat)

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(BLIS_External
        URL ${DEPS_LOCAL_PATH}/blis
        CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}
                                      CXX=${CMAKE_CXX_COMPILER}
                                      CC=${CMAKE_C_COMPILER}
                                      CFLAGS=${BLIS_OPT_FLAGS}
                                      ${BLIS_INT_FLAGS}
                                      ${BLIS_MISC_OPTIONS}
                                      ${__BLAS_ARCH}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
        BUILD_IN_SOURCE 1
)
else()
ExternalProject_Add(BLIS_External
        GIT_REPOSITORY https://github.com/flame/blis.git
        GIT_TAG ${BLIS_GIT_TAG}
        UPDATE_DISCONNECTED 1
        CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}
                                      CXX=${CMAKE_CXX_COMPILER}
                                      CC=${CMAKE_C_COMPILER}
                                      CFLAGS=${BLIS_OPT_FLAGS}
                                      ${BLIS_INT_FLAGS}
                                      ${BLIS_MISC_OPTIONS}
                                      ${__BLAS_ARCH}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
        BUILD_IN_SOURCE 1
)
endif()
