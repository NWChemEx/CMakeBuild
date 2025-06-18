################################################################################
#
# Macros for defining new targets.
#
# General definitions so they aren't defined for each function:
#     name      : The name of the target
#     flags     : These are compile-time flags to pass to the compiler
#     includes  : The directories containing include files for the target
#     libraries : The libraries the target needs to link against
#
################################################################################

include(CTest)
enable_testing()

enable_language(C CXX Fortran)

if(${CMSB_PROJECTS}_HAS_CUDA)
    include(CheckLanguage)
    check_language(CUDA)
    if(CMAKE_CUDA_COMPILER)
        enable_language(CUDA)
        set(CMAKE_CUDA_ARCHITECTURES ${GPU_ARCH} CACHE STRING "CUDA ARCH" FORCE)
        if(CMAKE_CUDA_COMPILER_ID STREQUAL "Clang")
          set(CMAKE_CUDA_FLAGS "-DUSE_CUDA")
        else()
          set(CMAKE_CUDA_FLAGS "--maxrregcount ${CUDA_MAXREGCOUNT} --use_fast_math -DUSE_CUDA")
        endif()
    endif()
endif()
if(${CMSB_PROJECTS}_HAS_HIP)
  set(GPU_TARGETS "${GPU_ARCH}" CACHE STRING "GPU targets to compile for")
  enable_language(HIP)
endif()

include(UtilityMacros)
include(DependencyMacros)
include(AssertMacros)
include(OptionMacros)

#Little trick so we always know this directory even when we are in a function
set(DIR_OF_TARGET_MACROS ${CMAKE_CURRENT_LIST_DIR})

function(cmsb_set_up_target __name __flags __lflags __install)
    set(__headers_copy ${${__includes}})
    make_full_paths(__headers_copy)
    foreach(__depend ${CMSB_DEPENDENCIES})
        cmsb_find_dependency(${__depend})
        target_link_libraries(${__name} PRIVATE ${__depend}_External)
        get_property(_tmp TARGET ${__depend}_External
                PROPERTY INTERFACE_LINK_LIBRARIES)
        list(APPEND CMAKE_INSTALL_RPATH ${_tmp})
        list(APPEND _tll ${_tmp})
        get_property(_tmp1 TARGET ${__depend}_External
                PROPERTY INTERFACE_INCLUDE_DIRECTORIES)     
        list(APPEND _tid ${_tmp1})
        get_property(_tmp2 TARGET ${__depend}_External
                PROPERTY INTERFACE_COMPILE_DEFINITIONS)     
        list(APPEND _tcd ${_tmp2})
        get_property(_tmp3 TARGET ${__depend}_External
                PROPERTY INTERFACE_COMPILE_OPTIONS)     
        list(APPEND _tco ${_tmp3})                      
    endforeach()
    target_link_libraries(${__name} PRIVATE "${_tll}")
    if(TAMM_EXTRA_LIBS)
        target_link_libraries(${__name} PRIVATE "${TAMM_EXTRA_LIBS}")
    endif()
    is_valid(_tco __has_defs)
    if(__has_defs)
        target_compile_options(${__name} PRIVATE ${${__flags}} ${_tco})
    else()
        target_compile_options(${__name} PRIVATE ${${__flags}})
    endif()
    is_valid(_tcd __has_defs)
    if(__has_defs)
        target_compile_definitions(${__name} PRIVATE "${_tcd}")
    endif()
    target_include_directories(${__name} PRIVATE ${CMSB_INCLUDE_DIR})
    target_include_directories(${__name} PRIVATE ${_tid})
    set_property(TARGET ${__name} PROPERTY CXX_STANDARD ${CMAKE_CXX_STANDARD})
    set_property(TARGET ${__name} PROPERTY LINK_FLAGS "${${__lflags}}") 
    set_property(TARGET ${__name} PROPERTY LINKER_LANGUAGE CXX)
    if(${CMSB_PROJECTS}_HAS_HIP)
      list (APPEND CMAKE_PREFIX_PATH ${ROCM_ROOT} ${ROCM_ROOT}/hip ${ROCM_ROOT}/hipblas)
      set(CMAKE_HIP_ARCHITECTURES ${GPU_ARCH} CACHE STRING "HIP ARCH" FORCE)
      set(GPU_TARGETS ${GPU_ARCH} CACHE STRING "GPU targets to compile for")
      enable_language(HIP)
      find_package(hip REQUIRED)
      find_package(rocblas REQUIRED)
      find_package(rocm_smi REQUIRED)
      set(_GPU_BLAS roc::rocblas hip::device rocm_smi64)
      target_link_libraries(${__name} PUBLIC ${_GPU_BLAS})
    elseif(${CMSB_PROJECTS}_HAS_CUDA)
      find_package(CUDAToolkit REQUIRED COMPONENTS cublas)
      if(NOT LINK_STATIC_GPU_LIBS)
        target_link_libraries(${__name} PUBLIC CUDA::cudart CUDA::cublas CUDA::nvml)
      else()
        target_link_libraries(${__name} PUBLIC CUDA::cudart_static CUDA::cublas_static CUDA::nvml)
      endif()
      target_include_directories(${__name} PUBLIC ${CUDAToolkit_INCLUDE_DIRS})
    elseif(${CMSB_PROJECTS}_HAS_DPCPP)
      set(MKL_INTERFACE ilp64)
      if(BLAS_INT4)
        set(MKL_INTERFACE lp64)
      endif()
      if(USE_ONEMATH_HIP)
        set(ENABLE_ROCBLAS_BACKEND ON)
        set(HIP_TARGETS ${GPU_ARCH} CACHE STRING "AMD targets to compile for")
        if (NOT TARGET ONEMATH::SYCL::SYCL)
          find_package(oneMath CONFIG REQUIRED PATHS ${ONEMATH_PREFIX} NO_DEFAULT_PATH)
        endif()
        target_link_libraries(${__name} PUBLIC ONEMATH::SYCL::SYCL ONEMATH::onemath ONEMATH::onemath_blas_rocblas)
      elseif(USE_ONEMATH_CUDA)
        if (NOT TARGET ONEMATH::SYCL::SYCL)
          find_package(oneMath CONFIG REQUIRED PATHS ${ONEMATH_PREFIX} NO_DEFAULT_PATH)
        endif()
        target_link_libraries(${__name} PUBLIC ONEMATH::SYCL::SYCL ONEMATH::onemath ONEMATH::onemath_blas_cublas)
      else()
        if(LINK_STATIC_GPU_LIBS)
          set(MKL_LINK "static")
        endif()
        find_package(MKL CONFIG REQUIRED PATHS ${LINALG_PREFIX} NO_DEFAULT_PATH)
        target_link_libraries(${__name} PUBLIC MKL::MKL_SYCL::BLAS)
      endif()      
    endif()
endfunction()

function(cmsb_add_executable __name __srcs __flags __lflags)
    set(__flags __CMSB_PROJECT_CXX_FLAGS)
    set(__srcs_copy ${${__srcs}})
    make_full_paths(__srcs_copy)
    add_executable(${__name} ${__srcs_copy})
    cmsb_set_up_target(${__name}
                           "${__flags}"
                           "${__lflags}"
                           bin/${__name})
    install(TARGETS ${__name} DESTINATION bin/${__name})
endfunction()

function(cmsb_add_library __name __srcs __headers __flags __lflags)
    set(__srcs_copy ${${__srcs}})
    make_full_paths(__srcs_copy)
    is_valid(__srcs_copy HAS_LIBRARY)
    if(HAS_LIBRARY)
        add_library(${__name} ${__srcs_copy})
        cmsb_set_up_target(${__name}
                "${__flags}"
                "${__lflags}"
                lib/${__name})
        install(TARGETS ${__name}
                ARCHIVE DESTINATION lib
                LIBRARY DESTINATION lib/${__name}/${__install}
                RUNTIME DESTINATION lib/${__name}/${__install})
    endif()
    set(CMSB_LIBRARY_NAME ${__name})
    set(CMSB_LIBRARY_HEADERS ${${__headers}})
    get_filename_component(__CONFIG_FILE ${DIR_OF_TARGET_MACROS} DIRECTORY)
    configure_file("${__CONFIG_FILE}/CMSBTargetConfig.cmake.in"
                    ${__name}-config.cmake @ONLY)
    install(FILES ${CMAKE_BINARY_DIR}/${__name}-config.cmake
            DESTINATION share/cmake/${__name})
    foreach(__header_i ${${__headers}})
        #We want to preserve structure so get directory (if it exists)
        get_filename_component(__header_i_dir ${__header_i} DIRECTORY)
        install(FILES ${__header_i}
                DESTINATION include/${__name}/${__header_i_dir})
    endforeach()
endfunction()

function(cmsb_add_pymodule __name __srcs __headers __flags __lflags __init)
    set(__flags __CMSB_PROJECT_CXX_FLAGS)
    cmsb_add_library(${__name} ${__srcs} ${__headers} ${__flags}
            ${__lflags})
    SET_TARGET_PROPERTIES(${__name} PROPERTIES PREFIX "")
    install(FILES ${__init}
            DESTINATION lib/${__name})
endfunction()

function(cmsb_add_test __name __test_file __flags)
    set(__file_copy ${__test_file})
    make_full_paths(__file_copy)
    add_executable(${__name} ${__file_copy})
    cmsb_set_up_target(${__name} ${__flags} "" "tests")
    install(TARGETS ${__name} DESTINATION tests)
    add_test(NAME ${__name} COMMAND ${CMAKE_BINARY_DIR}/${__name})
    target_include_directories(${__name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
    install(FILES ${CMAKE_BINARY_DIR}/CTestTestfile.cmake DESTINATION tests)
endfunction()

function(add_cxx_unit_test __name)
    set(__flags __CMSB_PROJECT_CXX_FLAGS)
    cmsb_add_test(${__name} ${__name}.cpp ${__flags})
    set_tests_properties(${__name} PROPERTIES LABELS "UnitTest")
endfunction()

function(cmsb_set_up_gpu_target __name __testgpulib __flags __lflags __install)
    set(__headers_copy ${${__includes}})
    make_full_paths(__headers_copy)
    foreach(__depend ${CMSB_DEPENDENCIES})
        cmsb_find_dependency(${__depend})
        target_link_libraries(${__name} PRIVATE ${__depend}_External)
        get_property(_tmp_libs TARGET ${__depend}_External
                PROPERTY INTERFACE_LINK_LIBRARIES)
        list(APPEND CMAKE_INSTALL_RPATH ${_tmp_libs})
        list(APPEND _all_tmp_libs ${_tmp_libs})
    endforeach()

    target_link_libraries(${__name} PRIVATE "${__testgpulib}" "${_all_tmp_libs}")
    if(TAMM_EXTRA_LIBS)
        target_link_libraries(${__name} PRIVATE "${TAMM_EXTRA_LIBS}")
    endif()
    target_compile_options(${__name} PRIVATE "${${__flags}}")
    target_include_directories(${__name} PRIVATE ${CMSB_INCLUDE_DIR} ${CUDAToolkit_INCLUDE_DIRS})
    set_property(TARGET ${__name} PROPERTY CXX_STANDARD ${CMAKE_CXX_STANDARD})
    set_property(TARGET ${__name} PROPERTY LINK_FLAGS "${${__lflags}}") 
    # set_property(TARGET ${__name} PROPERTY CUDA_SEPARABLE_COMPILATION ON)
    set_property(TARGET ${__name} PROPERTY LINKER_LANGUAGE CXX)
    if(${CMSB_PROJECTS}_HAS_HIP)
      list (APPEND CMAKE_PREFIX_PATH ${ROCM_ROOT} ${ROCM_ROOT}/hip ${ROCM_ROOT}/hipblas)
      set(CMAKE_HIP_ARCHITECTURES ${GPU_ARCH} CACHE STRING "HIP ARCH" FORCE)
      set(GPU_TARGETS ${GPU_ARCH} CACHE STRING "GPU targets to compile for")
      enable_language(HIP)
      find_package(hip REQUIRED)
      find_package(rocblas REQUIRED)
      find_package(rocm_smi REQUIRED)
      set(_GPU_BLAS roc::rocblas hip::device rocm_smi64)
      target_link_libraries(${__name} PUBLIC ${_GPU_BLAS})
    elseif(${CMSB_PROJECTS}_HAS_CUDA)
      target_compile_options( ${__name}
      PRIVATE
        $<$<COMPILE_LANGUAGE:CUDA>: -Xptxas -v > 
      )
      find_package(CUDAToolkit REQUIRED COMPONENTS cublas)
      if(NOT LINK_STATIC_GPU_LIBS)
        target_link_libraries(${__name} PUBLIC CUDA::cudart CUDA::cublas CUDA::nvml)
      else()
        target_link_libraries(${__name} PUBLIC CUDA::cudart_static CUDA::cublas_static CUDA::nvml)
      endif()
      target_include_directories(${__name} PUBLIC ${CUDAToolkit_INCLUDE_DIRS})
    elseif(${CMSB_PROJECTS}_HAS_DPCPP)
      set(MKL_INTERFACE ilp64)
      if(BLAS_INT4)
        set(MKL_INTERFACE lp64)
      endif()
      if(USE_ONEMATH_HIP)
        set(ENABLE_ROCBLAS_BACKEND ON)
        set(HIP_TARGETS ${GPU_ARCH} CACHE STRING "AMD targets to compile for")
        if (NOT TARGET ONEMATH::SYCL::SYCL)
          find_package(oneMath CONFIG REQUIRED PATHS ${ONEMATH_PREFIX} NO_DEFAULT_PATH)
        endif()
        target_link_libraries(${__name} PUBLIC ONEMATH::SYCL::SYCL ONEMATH::onemath ONEMATH::onemath_blas_rocblas)
      elseif(USE_ONEMATH_CUDA)
        if (NOT TARGET ONEMATH::SYCL::SYCL)
          find_package(oneMath CONFIG REQUIRED PATHS ${ONEMATH_PREFIX} NO_DEFAULT_PATH)
        endif()
        target_link_libraries(${__name} PUBLIC ONEMATH::SYCL::SYCL ONEMATH::onemath ONEMATH::onemath_blas_cublas)
      else()
        if(LINK_STATIC_GPU_LIBS)
          set(MKL_LINK "static")
        endif()
        find_package(MKL CONFIG REQUIRED PATHS ${LINALG_PREFIX} NO_DEFAULT_PATH)
        target_link_libraries(${__name} PUBLIC MKL::MKL_SYCL::BLAS)
      endif()
    endif()
endfunction()

function(add_mpi_gpu_unit_test __name __gpusrcs __np __testargs)
    set(__flags __CMSB_PROJECT_CXX_FLAGS)
    string(TOUPPER ${__name} __NAME)
    string(SUBSTRING ${__NAME} 0 5 _test_prefix)
    set(_dest_install_folder "methods")
    if(_test_prefix STREQUAL "TEST_")
        set(_dest_install_folder "tests")
    endif()

    list(APPEND CMAKE_INSTALL_RPATH ${CMAKE_CURRENT_BINARY_DIR})

    set(__test_file ${__name}.cpp)
    set(__file_copy ${__test_file})
    make_full_paths(__file_copy)
    

    set(__testgpulib "cmsb_gpulib_${__name}")

    add_library(${__testgpulib} ${__gpusrcs})
    if(${CMSB_PROJECTS}_HAS_CUDA)
    target_compile_options( ${__testgpulib}
    PRIVATE
      $<$<COMPILE_LANGUAGE:CUDA>: -Xptxas -v > 
    )
    endif()
    cmsb_set_up_target(${__testgpulib} "" "" ${_dest_install_folder})

    # set_property(TARGET ${__testgpulib} PROPERTY CUDA_SEPARABLE_COMPILATION ON)

    add_executable(${__name} ${__file_copy})
    #set_property(TARGET ${__name} PROPERTY LINKER_LANGUAGE CXX)
    #set_source_files_properties(${sources} PROPERTIES LANGUAGE "CUDA")

    cmsb_set_up_gpu_target(${__name} ${__testgpulib} ${__flags} "" ${_dest_install_folder})
    install(TARGETS ${__name} DESTINATION ${_dest_install_folder})
    set(__cmsb_job_cmd ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${__np})
    if(JOB_LAUNCH_CMD)
      set(__cmsb_job_cmd ${JOB_LAUNCH_CMD})
      if(JOB_LAUNCH_ARGS)
        separate_arguments(JOB_LAUNCH_ARGS)
        set(__cmsb_job_cmd ${__cmsb_job_cmd} ${JOB_LAUNCH_ARGS})
      else()
        set(__cmsb_job_cmd ${__cmsb_job_cmd} ${MPIEXEC_NUMPROC_FLAG} ${__np})
      endif()
    endif()
    separate_arguments(__testargs)
    add_test(NAME ${__name} COMMAND ${__cmsb_job_cmd} ${CMAKE_BINARY_DIR}/${__name} ${__testargs})
    target_include_directories(${__name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
    install(FILES ${CMAKE_BINARY_DIR}/CTestTestfile.cmake DESTINATION ${_dest_install_folder})
    set_tests_properties(${__name} PROPERTIES LABELS "MPICUDAUnitTest")
endfunction()

function(add_mpi_unit_test __name __np __testargs)
    set(__flags __CMSB_PROJECT_CXX_FLAGS)
    string(TOUPPER ${__name} __NAME)
    string(SUBSTRING ${__NAME} 0 5 _test_prefix)
    set(_dest_install_folder "methods")
    if(_test_prefix STREQUAL "TEST_")
        set(_dest_install_folder "tests")
    endif()

    set(__test_file ${__name}.cpp)
    set(__file_copy ${__test_file})
    make_full_paths(__file_copy)
    add_executable(${__name} ${__file_copy})
    cmsb_set_up_target(${__name} ${__flags} "" ${_dest_install_folder})
    install(TARGETS ${__name} DESTINATION ${_dest_install_folder})
    set(__cmsb_job_cmd ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${__np})
    if(JOB_LAUNCH_CMD)
      set(__cmsb_job_cmd ${JOB_LAUNCH_CMD})
      if(JOB_LAUNCH_ARGS)
        separate_arguments(JOB_LAUNCH_ARGS)
        set(__cmsb_job_cmd ${__cmsb_job_cmd} ${JOB_LAUNCH_ARGS})
      else()
        set(__cmsb_job_cmd ${__cmsb_job_cmd} ${MPIEXEC_NUMPROC_FLAG} ${__np})
      endif()
    endif()
    separate_arguments(__testargs)
    add_test(NAME ${__name} COMMAND ${__cmsb_job_cmd} ${CMAKE_BINARY_DIR}/${__name} ${__testargs})
    target_include_directories(${__name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
    install(FILES ${CMAKE_BINARY_DIR}/CTestTestfile.cmake DESTINATION ${_dest_install_folder})
    set_tests_properties(${__name} PROPERTIES LABELS "MPIUnitTest")
endfunction()

function(add_python_unit_test __name)
    foreach(__depend ${CMSB_DEPENDENCIES})
        cmsb_find_dependency(${__depend})
        get_property(_tmp_libs TARGET ${__depend}_External
                PROPERTY INTERFACE_LINK_LIBRARIES)
        foreach(__lib ${_tmp_libs})
            get_filename_component(_lib_path ${__lib} DIRECTORY)
            set(LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:${_lib_path}")
        endforeach()
    endforeach()
    set(env_vars)
    add_test(NAME Py${__name} COMMAND python3 ${__name}.py)
    set_tests_properties(Py${__name} PROPERTIES ENVIRONMENT
       "LD_LIBRARY_PATH=${LD_LIBRARY_PATH};PYTHONPATH=${STAGE_INSTALL_DIR}/lib")
    install(FILES ${__name}.py DESTINATION tests)
endfunction()

function(add_cmake_macro_test __name)
    install(FILES ${__name}.cmake DESTINATION tests)
    list(GET CMAKE_MODULE_PATH 0 _stage_dir)
    set(_macro_dir "${_stage_dir}/share/cmake/CMakeBuild/macros")
    add_test(NAME ${__name}
             COMMAND ${CMAKE_COMMAND} -DCMAKE_MODULE_PATH=${_macro_dir}
                                      -P ${__name}.cmake)
    install(FILES ${CMAKE_BINARY_DIR}/CTestTestfile.cmake DESTINATION tests)
endfunction()

function(add_cmsb_test __name)
    include(ExternalProject)
    bundle_cmake_args(CMAKE_CORE_OPTIONS CMAKE_CXX_COMPILER CMAKE_C_COMPILER
            CMAKE_Fortran_COMPILER CMAKE_INSTALL_PREFIX)

    ExternalProject_Add(${__name}
        PREFIX ${__name}
        DOWNLOAD_DIR ${__name}
        BINARY_DIR ${__name}/build
        SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/${__name}
        CMAKE_ARGS ${CMAKE_CORE_OPTIONS}
        BUILD_ALWAYS 1
        CMAKE_CACHE_ARGS -DCMAKE_PREFIX_PATH:LIST=${CMAKE_PREFIX_PATH}
                         -DCMAKE_MODULE_PATH:LIST=${CMAKE_MODULE_PATH}
        INSTALL_COMMAND ""
    )
    set(working_dir ${CMAKE_BINARY_DIR}/${__name}/build/test_stage/${CMAKE_INSTALL_PREFIX})
    add_test(NAME ${__name}
             COMMAND ${working_dir}/tests/${__name})
    install(FILES ${CMAKE_BINARY_DIR}/CTestTestfile.cmake DESTINATION tests)
endfunction()
