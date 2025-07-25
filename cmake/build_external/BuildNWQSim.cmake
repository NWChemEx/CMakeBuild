include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

if(${CMSB_PROJECTS}_HAS_CUDA)
    set(NWQSIM_GPU_ARCH "-DCUDA_ARCH=${GPU_ARCH}")
elseif(${CMSB_PROJECTS}_HAS_HIP)
    set(NWQSIM_GPU_ARCH "-DHIP_ARCH=${GPU_ARCH}")
endif()

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(NWQSim_External
    URL ${DEPS_LOCAL_PATH}/NWQ-Sim
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} ${NWQSIM_GPU_ARCH}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS}
                     ${CORE_CMAKE_STRINGS}
)
else()
ExternalProject_Add(NWQSim_External
    GIT_REPOSITORY https://github.com/pnnl/NWQ-Sim
    GIT_TAG dev/exachem_integration
    # GIT_TAG ${NWQSIM_GIT_TAG}
    UPDATE_DISCONNECTED 1
    UPDATE_COMMAND
    ${CMAKE_COMMAND} -E echo "Updating NWQSim submodules..." &&
    git -C <SOURCE_DIR> submodule update --init --recursive
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} ${NWQSIM_GPU_ARCH}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS}
                     ${CORE_CMAKE_STRINGS}
)
endif()

