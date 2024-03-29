

set(TAMM_GIT_TAG main)
if(ENABLE_DEV_MODE OR USE_TAMM_DEV)
    set(TAMM_GIT_TAG develop)
endif()

ExternalProject_Add(TAMM_External
    GIT_REPOSITORY https://github.com/NWChemEx-Project/TAMM
    GIT_TAG ${TAMM_GIT_TAG}
    UPDATE_DISCONNECTED 1
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS} ${CORE_CMAKE_STRINGS}
)

