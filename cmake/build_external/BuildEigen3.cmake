include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

is_valid_and_true(EIGEN_TAG __et_set)
if(__et_set)
  set(EIGEN_GIT_TAG ${EIGEN_TAG})
endif()

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(Eigen3_External
    SOURCE_DIR ${DEPS_LOCAL_PATH}/eigen
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} 
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
    )
else()
ExternalProject_Add(Eigen3_External
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_TAG ${EIGEN_GIT_TAG}
    UPDATE_DISCONNECTED 1
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} 
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
    )
endif()
