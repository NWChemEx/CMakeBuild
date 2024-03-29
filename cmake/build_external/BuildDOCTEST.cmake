if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(DOCTEST_External
    URL ${DEPS_LOCAL_PATH}/v2.4.9.tar.gz
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DDOCTEST_WITH_TESTS=OFF
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    )
else()
ExternalProject_Add(DOCTEST_External
    URL https://github.com/doctest/doctest/archive/refs/tags/v2.4.9.tar.gz
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DDOCTEST_WITH_TESTS=OFF
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    )
endif()

