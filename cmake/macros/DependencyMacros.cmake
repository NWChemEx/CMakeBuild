################################################################################
#
# These are macros for finding dependencies.
#
################################################################################

include(DebuggingMacros)
include(UtilityMacros)
include(AssertMacros)
include(OptionMacros)

enable_language(C)

set(DEP_ABUILD "GauXC" "Eigen3" "LibInt2" "HPTT" "HDF5" "numactl" "ELPA" "GlobalArrays" "NWQSim" "TAMM") # "BLIS" "AntlrCppRuntime"
set(DEP_ABUILD_MISC "MACIS" "MSGSL" "NJSON" "DOCTEST" "SPDLOG" "EcpInt" "Librett")
if("${LINALG_VENDOR}" STREQUAL "BLIS" OR "${LINALG_VENDOR}" STREQUAL "OpenBLAS")
    list(APPEND DEP_ABUILD "BLAS" "LAPACK")
elseif("${LINALG_VENDOR}" STREQUAL "IBMESSL")
    list(APPEND DEP_ABUILD "LAPACK")
endif()
list(APPEND DEP_ABUILD ${DEP_ABUILD_MISC})

set(PROPERTY_NAMES INCLUDE_DIRECTORIES LINK_LIBRARIES COMPILE_OPTIONS COMPILE_DEFINITIONS)

function(dependency_to_variables __name _INCLUDE_DIRECTORIES
                                        _LINK_LIBRARIES
                                        _COMPILE_OPTIONS
                                        _COMPILE_DEFINITIONS)

    string(TOUPPER ${__name} __NAME)
    foreach(__var ${PROPERTY_NAMES})
        get_property(__value TARGET ${__name}_External
                             PROPERTY INTERFACE_${__var})
        list( REMOVE_DUPLICATES __value )

        set( __value_list ${__value})
        if (NOT "${__name}" IN_LIST DEP_ABUILD)
            set( __value_list )
            foreach( __val ${__value} )
                if( TARGET ${__val} )
                get_true_target_property( __tmp ${__val} INTERFACE_${__var} )
                is_valid(__tmp _tmp_set)
                if(_tmp_set)
                    list(APPEND __value_list ${__tmp} )
                else()
                    list(APPEND __value_list ${__val} )
                endif()
                else()
                list(APPEND __value_list ${__val} )
                endif()
            endforeach()
        endif()

        set(input_var ${_${__var}}) # Name of the variable user gave us
        list(APPEND ${input_var} ${__value_list})
        set(${input_var} ${${input_var}} PARENT_SCOPE)
    endforeach()
endfunction()

function(package_dependency __depend __lists)
    string(TOUPPER ${__depend} __DEPEND)
    dependency_to_variables(${__depend} ${__DEPEND}_INCLUDE_DIRS
                                        ${__DEPEND}_LIBRARIES
                                        ${__DEPEND}_COMPILE_OPTIONS
                                        ${__DEPEND}_COMPILE_DEFINITIONS)
    bundle_cmake_list(${__lists} ${__DEPEND}_INCLUDE_DIRS
                                 ${__DEPEND}_LIBRARIES
                                 ${__DEPEND}_COMPILE_OPTIONS
                                 ${__DEPEND}_COMPILE_DEFINITIONS)
    set(${__lists} ${${__lists}} PARENT_SCOPE)
endfunction()

function(are_we_building __name __value)
    if(NOT TARGET ${__name}_External)
        set(${__value} TRUE PARENT_SCOPE)
    else()
        package_dependency(${__name} __temp)
        is_valid(__temp ${__value})
        if(${__value})
            set(${__value} FALSE PARENT_SCOPE)
        else()
            set(${__value} TRUE PARENT_SCOPE)
        endif()
    endif()
endfunction()

function(print_dependency __name)
    message("Target: ${__name}")
    foreach(_prop ${PROPERTY_NAMES} LINK_FLAGS)
        get_property(__value TARGET ${__name} PROPERTY INTERFACE_${_prop})
        is_valid(__value __has_prop)
        if(__has_prop)
            message("  ${_prop} : ${__value}")
        endif()
    endforeach()
endfunction()

function(cmsb_find_dependency __name)

    string( TOUPPER ${__name} __name_upper )
    string( TOLOWER ${__name} __name_lower )

    if( ${__name_upper}_LIBRARIES AND NOT ${__name_lower}_LIBRARIES )
      set( ${__name_lower}_LIBRARIES ${${__name_upper}_LIBRARIES} )
    endif()

    set(_dep_name ${__name})
    if(${__name} STREQUAL "DOCTEST")
      set(_dep_name doctest)
    elseif(${__name} STREQUAL "Librett")
      set(_dep_name librett)
    elseif(${__name} STREQUAL "NJSON")
      set(_dep_name nlohmann_json)
    elseif(${__name} STREQUAL "SPDLOG")
      set(_dep_name spdlog)
    elseif(${__name} STREQUAL "MSGSL")
      set(_dep_name Microsoft.GSL)
    elseif(${__name} STREQUAL "MACIS")
      set(_dep_name macis)
    elseif(${__name} STREQUAL "EcpInt")
      set(_dep_name ecpint)
    endif()
    if(${__name} IN_LIST DEP_ABUILD_MISC)
      set(__dep_target_name ${_dep_name}::${_dep_name})
      if(${__name} STREQUAL "MSGSL")
        set(__dep_target_name Microsoft.GSL::GSL)
      elseif(${__name} STREQUAL "EcpInt")
        set(__dep_target_name ECPINT::ecpint)
      endif()
    endif()

    if(TARGET ${__name}_External)
        debug_message("${__name} already handled.")
    else()
        #This will be messy for packages relying on Config files if we haven't
        #built them yet
        is_valid_and_true(BUILD_${__name} __dont_look_for)
        if(__dont_look_for)
            message(STATUS "Per user's request building bundled ${__name}")
        elseif(CMSB_DEBUG_CMAKE)
            if(${__name} IN_LIST DEP_ABUILD)
                set(DEP_STAGE_DIR ${STAGE_DIR}${CMAKE_INSTALL_PREFIX})
                set(DEP_PATHS ${DEP_STAGE_DIR} ${CMAKE_INSTALL_PREFIX}
                              ${${__name}_ROOT})
                # set(${__name}_DIR ${DEP_PATHS})
                find_package(${_dep_name} CONFIG
                             HINTS ${DEP_PATHS}
                            #  PATHS ${DEP_PATHS}
                             NO_DEFAULT_PATH
                            )
                # find_package(${__name} QUIET)
                if(NOT ${_dep_name}_FOUND)
                  find_package(${_dep_name} CONFIG
                    HINTS ${CMAKE_PREFIX_PATH} NO_DEFAULT_PATH)
                endif()
                if(NOT ${_dep_name}_FOUND)
                  is_valid(HDF5_ROOT __h5root)
                  if(${__name} STREQUAL "ELPA") 
                    find_package(ELPA)
                  elseif(${__name} STREQUAL "HDF5" AND __h5root)
                    # set(HDF5_PREFER_PARALLEL ON)
                    find_library( _HDF5_LIBRARIES
                        NAMES hdf5
                        HINTS ${${__name}_ROOT}
                        PATHS ${${__name}_ROOT}
                        PATH_SUFFIXES lib lib64
                        NO_DEFAULT_PATH
                    )
                    find_path( _HDF5_INCLUDE_DIR
                        NAMES hdf5.h
                        HINTS ${${__name}_ROOT}
                        PATHS ${${__name}_ROOT}
                        PATH_SUFFIXES include
                        NO_DEFAULT_PATH
                    )
                    find_package_handle_standard_args( HDF5
                        REQUIRED_VARS _HDF5_LIBRARIES _HDF5_INCLUDE_DIR
                        HANDLE_COMPONENTS
                    )
                    if(HDF5_FOUND)
                        message(STATUS "HDF5 found!")
                        set(HDF5_INCLUDE_DIR ${_HDF5_INCLUDE_DIR})
                        if( _HDF5_LIBRARIES AND NOT TARGET hdf5-static )
                          add_library( hdf5-static INTERFACE IMPORTED )
                          set_target_properties( hdf5-static PROPERTIES
                            INTERFACE_INCLUDE_DIRECTORIES "${_HDF5_INCLUDE_DIR}"
                            INTERFACE_LINK_LIBRARIES      "${_HDF5_LIBRARIES}"
                          )
                        endif()
                    endif()
                  elseif(${__name} STREQUAL "numactl")
                    find_package(numactl)
                  endif()
                endif()
            else()
                find_package(${__name})
            endif()
        else()
            find_package(${__name} QUIET)
        endif()
        string(TOUPPER ${__name} __NAME)
        is_valid_and_true(${__NAME}_FOUND _upper)
        is_valid_and_true(${__name}_FOUND _lower)
        if(_upper OR _lower OR TARGET ${__dep_target_name})
            set(_tname ${__name}_External)
            add_library(${_tname} INTERFACE)
            #By convention CMake variables are supposed to be all caps,
            #but some projects instead use the same name
            foreach(name_var ${__name}) #${__NAME}
                if(${__NAME} STREQUAL "INTELSYCL")
                    set(name_var INTEL_SYCL)
                elseif(${__NAME} STREQUAL "EIGEN3")
                    set(name_var ${__NAME})
                    target_include_directories(${_tname} SYSTEM INTERFACE
                            ${CMAKE_INSTALL_PREFIX}/include/eigen3)
                endif()

                if(${__NAME} STREQUAL "MPI")
                  set(MPI_LIBRARIES ${MPI_C_LIBRARIES})
                  set(MPI_INCLUDE_DIRS ${MPI_C_INCLUDE_DIRS})
                endif()

                #CMake's lack of consistent naming makes a loop ineffective here
                is_valid(${name_var}_INCLUDE_DIRS __has_includes)
                if(__has_includes)
                    target_include_directories(${_tname} SYSTEM INTERFACE
                            ${${name_var}_INCLUDE_DIRS})
                endif()

                if(${__NAME} STREQUAL "LIBINT2")
                    set(${name_var}_LIBRARIES Libint2::cxx)
                    get_property(_li_cd TARGET Libint2::cxx
                        PROPERTY INTERFACE_COMPILE_DEFINITIONS)
                    set(${name_var}_COMPILE_DEFINITIONS "${_li_cd}")

                elseif(${__NAME} STREQUAL "HDF5")
                    set(${name_var}_LIBRARIES hdf5-static)
                    target_include_directories(${_tname} SYSTEM INTERFACE
                            ${${name_var}_INCLUDE_DIR})

                elseif(${__NAME} STREQUAL "NUMACTL")
                    set(${name_var}_LIBRARIES numactl-cmsb)
                    target_include_directories(${_tname} SYSTEM INTERFACE
                        ${${__NAME}_INCLUDE_DIRS})

                elseif(${__NAME} STREQUAL "ELPA")
                    set(${name_var}_LIBRARIES elpa_cmsb)
                    target_include_directories(${_tname} SYSTEM INTERFACE
                        ${${name_var}_INCLUDE_DIRS})                        

                elseif(${__name} IN_LIST DEP_ABUILD_MISC OR 
                       ${__NAME} IN_LIST DEP_ABUILD_MISC)
                    set(${name_var}_LIBRARIES ${__dep_target_name})
                endif()

                # if(${__NAME} STREQUAL "MSGSL")
                #     set(${name_var}_LIBRARIES Microsoft.GSL::GSL)
                # endif()

                is_valid(${name_var}_LIBRARIES __has_libs)
                if(__has_libs)
                    target_link_libraries(${_tname} INTERFACE
                            ${${name_var}_LIBRARIES})
                endif()

                # is_valid(${name_var}_DEFINITIONS __has_defs)
                # if(__has_defs)
                #     target_compile_definitions(${_tname} INTERFACE
                #             ${${name_var}_DEFINITIONS})
                # endif()

                is_valid(${name_var}_COMPILE_OPTIONS __has_defs)
                if(__has_defs)
                    target_compile_options(${_tname} INTERFACE
                                ${${name_var}_COMPILE_OPTIONS})
                endif()

                is_valid(${name_var}_COMPILE_DEFINITIONS __has_defs)
                if(__has_defs)
                    target_compile_definitions(${_tname} INTERFACE
                                ${${name_var}_COMPILE_DEFINITIONS})
                endif()
                is_valid(${name_var}_LINK_FLAGS __has_lflags)
                #if(__has_lflags)
                #    target_link_libraries(${_tname} INTERFACE
                #                          ${${__NAME}_LINK_FLAGS})
                #endif()
            endforeach()
            if(CMSB_DEBUG_CMAKE)
                print_dependency(${_tname})
            endif()
        endif()
    endif()
endfunction()

function(find_or_build_dependency __name)
        cmsb_find_dependency(${__name})
        if(NOT TARGET ${__name}_External)
            is_valid(BUILD_${__name} __is_set)
            if(__is_set AND NOT BUILD_${__name})
                message(FATAL_ERROR "Could not locate ${__name} and user has "
                        "requested we do not build one.")
            endif()
            debug_message("Unable to locate ${__name}.  Building one instead.")
            include(Build${__name})
        endif()
endfunction()

function(makify_dependency __depend __incs __libs)
    string(TOUPPER ${__depend} __DEPEND)
    dependency_to_variables(${__depend} ${__DEPEND}_INCLUDE_DIRS
                                        ${__DEPEND}_LIBRARIES
                                        ${__DEPEND}_COMPILE_OPTIONS
                                        ${__DEPEND}_COMPILE_DEFINITIONS)
    string_concat(${__DEPEND}_INCLUDE_DIRS "-I" " " ${__incs})
    foreach(__lib ${${__DEPEND}_LIBRARIES})
        # Remove the actual library from the path
        get_filename_component(_lib_path ${__lib} DIRECTORY)
        # Get only library name with extension
        get_filename_component(_name_lib ${__lib} NAME_WE)
        if(NOT _lib_path STREQUAL "")
            # Strip the lib prefix
            string(SUBSTRING ${_name_lib} 3 -1 _name_lib)
            set(${__libs} "${${__libs}} -L${_lib_path} -l${_name_lib}")
        endif()
    endforeach()
    set(${__incs} ${${__incs}} PARENT_SCOPE)
    set(${__libs} ${${__libs}} PARENT_SCOPE)
endfunction()
