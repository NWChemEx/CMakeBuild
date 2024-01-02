
#
# This file will build BLIS which is the default BLAS library we use.
#

enable_language(C Fortran)

is_valid_and_true(BLIS_CONFIG __set)
if (NOT __set)
    message(STATUS "BLIS_CONFIG not set, will auto-detect")
    set(BLIS_CONFIG_HW "auto")
else()
    message(STATUS "BLIS_CONFIG set to ${BLIS_CONFIG}")
    set(BLIS_CONFIG_HW ${BLIS_CONFIG})
endif()

string_concat(CMAKE_C_FLAGS_RELEASE "" " " BLIS_FLAGS)

if(CMAKE_POSITION_INDEPENDENT_CODE)
    set(FPIC_LIST "-fPIC")
    string_concat(FPIC_LIST "" " " BLIS_FLAGS)
endif()

set(BLIS_TAR https://github.com/flame/blis/archive/refs/tags/0.9.0.tar.gz)
set(BLIS_GIT_TAG 6f412204004666abac266409a203cb635efbabf3)

if(USE_SCALAPACK)
  #The next commit breaks scalapack builds
  set(BLIS_GIT_TAG 6f412204004666abac266409a203cb635efbabf3)
endif()

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

set(BLIS_MISC_OPTIONS --without-memkind)

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(BLIS_External
        URL ${DEPS_LOCAL_PATH}/blis
        CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}
                                      CXX=${CMAKE_CXX_COMPILER}
                                      CC=${CMAKE_C_COMPILER}
                                      CFLAGS=${BLIS_OPT_FLAGS}
                                      ${BLIS_INT_FLAGS}
                                      ${BLIS_MISC_OPTIONS}
                                      ${BLIS_CONFIG_HW}
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
                                      ${BLIS_CONFIG_HW}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
        BUILD_IN_SOURCE 1
)
endif()
