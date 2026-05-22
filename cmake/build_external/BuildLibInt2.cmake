
# This file will build LibInt

include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

find_or_build_dependency(Eigen3)
package_dependency(Eigen3 DEPENDENCY_PATHS)
set(TEST_LIBINT FALSE)
if(${PROJECT_NAME} STREQUAL "TestBuildLibInt")
    set(TEST_LIBINT TRUE)
endif()

set(LIBINT_URL https://github.com/evaleev/libint)
set(LIBINT_TAR ${LIBINT_URL}/releases/download/v${CMSB_LIBINT_VERSION})
set(LIBINT_TAR ${LIBINT_TAR}/libint-${CMSB_LIBINT_VERSION})
if(TEST_LIBINT)
    #Grab the small version of libint for testing purposes
    set(LIBINT_TAR ${LIBINT_TAR}-test-mpqc4.tgz)
else()
    set(LIBINT_TAR ${LIBINT_TAR}.tgz)
endif()

# append platform-specific optimization options for non-Debug builds
set(LIBINT_EXTRA_FLAGS "-Wno-unused-variable")
set(CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} ${LIBINT_EXTRA_FLAGS}")

set(LIBINT_TAR_URL https://github.com/ExaChem/exachem-support.git)
set(LI_GIT_TAG main)

if(ENABLE_OFFLINE_BUILD)
  set(LIBINT_TAR ${DEPS_LOCAL_PATH}/libint-${CMSB_LIBINT_VERSION}.tgz)
endif()

# set (LI_SRC_SDIR libint-${CMSB_LIBINT_VERSION})
# if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
#   set(LI_SRC_SDIR ".")
# endif()
set(LI_SRC_SDIR ".")

ExternalProject_Add(LibInt2_External
    GIT_REPOSITORY ${LIBINT_TAR_URL}
    GIT_TAG ${LI_GIT_TAG}
    UPDATE_DISCONNECTED 1
    PATCH_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
              ${CMAKE_COMMAND} -E tar xJf <SOURCE_DIR>/libint/libint-${CMSB_LIBINT_VERSION}.tar.xz   
    SOURCE_SUBDIR ${LI_SRC_SDIR}/libint-${CMSB_LIBINT_VERSION}
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DCMAKE_CXX_FLAGS_INIT=${CXX_FLAGS_INIT} -DLIBINT_USE_BUNDLED_BOOST=ON
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS}
    ${CORE_CMAKE_STRINGS}
    )

add_dependencies(LibInt2_External Eigen3_External)

