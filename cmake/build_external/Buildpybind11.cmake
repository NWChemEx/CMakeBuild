include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(pybind11_External
    URL ${DEPS_LOCAL_PATH}/pybind11
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS}
               -DPYBIND11_TEST=OFF
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS}
                     ${CORE_CMAKE_STRINGS}
)
else()
ExternalProject_Add(pybind11_External
    GIT_REPOSITORY https://github.com/pybind/pybind11
    GIT_TAG ${PYBIND_GIT_TAG}
    UPDATE_DISCONNECTED 1
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS}
               -DPYBIND11_TEST=OFF
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS}
                     ${CORE_CMAKE_STRINGS}    
)
endif()

