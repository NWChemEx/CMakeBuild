# Pin dependency versions

set(CMSB_HDF5_VERSION hdf5_1.14.4.3) #skip upto 1.14.6
set(CMSB_DOCTEST_VERSION 2.4.11)
set(CMSB_ELPA_VERSION 2025.01.002)

set(TAMM_GIT_TAG 2025-05-01)
if(ENABLE_DEV_MODE OR USE_TAMM_DEV)
    set(TAMM_GIT_TAG main)
endif()

# numactl
set(NUMACTL_GIT_TAG v2.0.19)

# Eigen3
set(EIGEN_GIT_TAG 2265a5e025601d501903c772799ce29fb73c8efa) #April 23, 2025
if(ENABLE_DEV_MODE)
  set(EIGEN_GIT_TAG master)
endif()

# spdlog
set(SPDLOG_GIT_TAG v1.15.2)

# BLIS
set(BLIS_GIT_TAG 5d9e110a2aa58b6e5d131db9131bae0143f22f9f) #April 7, 2025


# OpenBLAS
set(OpenBLAS_GIT_TAG 0.3.29)

# LAPACK
set(LAPACK_GIT_TAG 72df25ba80b18d423bdbfdb153ee68c7e922360a)
if(ENABLE_DEV_MODE)
  set(LAPACK_GIT_TAG master)
endif()

# ScaLAPACK
set(SL_GIT_TAG 0e8767285b7a201c7b1ff34d2c2bb009534145df) #April 8, 2025
if(ENABLE_DEV_MODE)
  set(SL_GIT_TAG master)
endif()

# NJSON
set(NJSON_GIT_TAG 3.12.0) #Do not use commit hash for NJSON
set(CMSB_NJSON_VERSION ${NJSON_GIT_TAG})

# GSL
set(MSGSL_GIT_TAG 3325bbd33d24d1f8f5a0f69e782c92ad5a39a68e) #4.2.0
if(ENABLE_DEV_MODE)
  set(MSGSL_GIT_TAG main)
endif()

# Global Arrays
set(GA_GIT_TAG 97964278ae7dca1df373139038b4d5f34b71147c) #June 7,2025
if(ENABLE_DEV_MODE)
    set(GA_GIT_TAG develop)
endif()

# HPTT
set(HPTT_GIT_TAG eff1bdd79734ddc4993dd4df1d0cdbd40758b9cb)
if(ENABLE_DEV_MODE)
    set(HPTT_GIT_TAG master)
endif()

# Librett
set(LIBRETT_GIT_TAG 7e69731d3864304bba8ac4a1c5c4b243f36e5747) #June 25, 2025
if(ENABLE_DEV_MODE)
  set(LIBRETT_GIT_TAG master)
endif()

# Libint
set(CMSB_LIBINT_VERSION 2.11.0) #2.9.0 is min

# LibEcpInt
set(ECPINT_GIT_TAG ee6d75a969bb92535a9ecf2ba4b564a75b7ef84b)
if(ENABLE_DEV_MODE)
  set(ECPINT_GIT_TAG master)
endif()

# GauXC
set(GXC_GIT_TAG 5c85f6b95fa4132eb2ef08e1ed419247a2fe8d48) #May 1, 2025
if(ENABLE_DEV_MODE)
    set(GXC_GIT_TAG master)
endif()

#NWQ-Sim
set(NWQSIM_GIT_TAG main)
if(ENABLE_DEV_MODE)
  set(NWQSIM_GIT_TAG main)
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
