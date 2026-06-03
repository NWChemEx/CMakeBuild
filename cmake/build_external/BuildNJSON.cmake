include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(NJSON_External
    SOURCE_DIR ${DEPS_LOCAL_PATH}/json
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DJSON_BuildTests=OFF
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    )
else()
ExternalProject_Add(NJSON_External
    # GIT_REPOSITORY https://github.com/nlohmann/json.git
    # GIT_TAG v${NJSON_GIT_TAG}
    # GIT_SHALLOW 1
    # UPDATE_DISCONNECTED 1    
    URL https://github.com/nlohmann/json/archive/refs/tags/v${CMSB_NJSON_VERSION}.tar.gz
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DJSON_BuildTests=OFF
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    )
endif()
