# Pin dependency versions

set(CMSB_HDF5_VERSION hdf5_1.14.4.3)
set(CMSB_DOCTEST_VERSION 2.4.9)
set(CMSB_ELPA_VERSION 2024.03.001)

set(TAMM_GIT_TAG main) #2024-10-27
if(ENABLE_DEV_MODE OR USE_TAMM_DEV)
    set(TAMM_GIT_TAG develop)
endif()

# numactl
set(NUMACTL_GIT_TAG v2.0.18)

# Eigen3
set(EIGEN_GIT_TAG e887196d9d67e48c69168257d599371abf1c3b31) #Mar 17, 2023
if(ENABLE_DEV_MODE)
  set(EIGEN_GIT_TAG master)
endif()

# spdlog
set(SPDLOG_GIT_TAG v1.14.1)

# BLIS
set(BLIS_GIT_TAG 415893066e966159799d96166cadcf9bb5535b1c)


# OpenBLAS
set(OpenBLAS_GIT_TAG 0.3.27)

# LAPACK
set(LAPACK_GIT_TAG 8b468db25c0c5a25d8e0020c7e2134e14cfd33d0)
if(ENABLE_DEV_MODE)
  set(LAPACK_GIT_TAG master)
endif()

# ScaLAPACK
set(SL_GIT_TAG 0234af94c6578c53ac4c19f2925eb6e5c4ad6f0f)
if(ENABLE_DEV_MODE)
  set(SL_GIT_TAG master)
endif()

# NJSON
set(NJSON_GIT_TAG 3.11.3) #Do not use commit hash for NJSON
set(CMSB_NJSON_VERSION ${NJSON_GIT_TAG})

# GSL
set(MSGSL_GIT_TAG 3ba80d5dd465828909e1ee756b8c437d5e820ccc)
if(ENABLE_DEV_MODE)
  set(MSGSL_GIT_TAG main)
endif()

# Global Arrays
set(GA_GIT_TAG b2c538eee2cdd3982e2d5d0a4c5f97846f49a6b8)
if(ENABLE_DEV_MODE)
    set(GA_GIT_TAG develop)
endif()

# HPTT
set(HPTT_GIT_TAG eff1bdd79734ddc4993dd4df1d0cdbd40758b9cb)
if(ENABLE_DEV_MODE)
    set(HPTT_GIT_TAG master)
endif()

# Librett
set(LIBRETT_GIT_TAG 0d6d629ef728d414c4c3c99a44b97ae1224e6dea)
if(ENABLE_DEV_MODE)
  set(LIBRETT_GIT_TAG master)
endif()

# Libint
set(CMSB_LIBINT_VERSION 2.9.0)

# LibEcpInt
set(ECPINT_GIT_TAG ee6d75a969bb92535a9ecf2ba4b564a75b7ef84b)
if(ENABLE_DEV_MODE)
  set(ECPINT_GIT_TAG master)
endif()

# GauXC
set(GXC_GIT_TAG 7ea1c8c00ea39625ea0a9beb6fbf7f202c46afb7)
if(ENABLE_DEV_MODE)
    set(GXC_GIT_TAG master)
endif()

# Unused
set(PYBIND_GIT_TAG master)
if(ENABLE_DEV_MODE)
  set(PYBIND_GIT_TAG master)
endif()

set(MACIS_GIT_TAG master)
if(ENABLE_DEV_MODE)
  set(MACIS_GIT_TAG master)
endif()
