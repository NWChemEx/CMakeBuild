#!/bin/bash

set -eu
set -x

export cdir=`pwd`

# echo "Replace L20-21 in TAMM/CMakeLists.txt with: URL $cdir/CMakeBuild"
git clone https://github.com/NWChemEx-Project/CMakeBuild.git
cd CMakeBuild

cd $cdir

git clone https://github.com/wavefunction91/linalg-cmake-modules.git

git clone https://github.com/flame/blis.git
cd blis
git checkout 5d9e110a2aa58b6e5d131db9131bae0143f22f9f

cd $cdir

wget https://github.com/OpenMathLib/OpenBLAS/releases/download/v0.3.30/OpenBLAS-0.3.30.tar.gz

wget https://github.com/doctest/doctest/archive/refs/tags/v2.4.11.tar.gz

wget https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/2025.01.002/elpa-2025.01.002.tar.gz

git clone https://gitlab.com/libeigen/eigen.git
cd eigen
git checkout 2265a5e025601d501903c772799ce29fb73c8efa

cd $cdir

git clone https://github.com/GlobalArrays/ga.git
cd ga
git checkout a0af63f9235bde86e88ae14e9a78178bba3fb1b0

cd $cdir
wget https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_1.14.4.3.tar.gz

git clone https://github.com/ajaypanyala/hptt.git
cd hptt
git checkout eff1bdd79734ddc4993dd4df1d0cdbd40758b9cb

cd $cdir
wget https://github.com/evaleev/libint/releases/download/v2.11.2/libint-2.11.2.tgz

git clone https://github.com/victor-anisimov/Librett.git
cd Librett
git checkout 7e69731d3864304bba8ac4a1c5c4b243f36e5747

cd $cdir

git clone https://github.com/Microsoft/GSL.git
cd GSL
git checkout 3325bbd33d24d1f8f5a0f69e782c92ad5a39a68e

cd $cdir

git clone https://github.com/nlohmann/json.git
cd json
git checkout v3.12.0

cd $cdir

git clone https://github.com/gabime/spdlog
cd spdlog
git checkout v1.15.2

cd $cdir

git clone https://github.com/Reference-LAPACK/lapack.git
cd lapack
git checkout 67f9279da4d004b3e998d6fb63ef75c4fbbf7355

cd $cdir
git clone https://github.com/Reference-ScaLAPACK/scalapack.git
cd scalapack
git checkout 46d1837e0f6f20aed6c94dcc5033b60844c7a3c8

cd $cdir

git clone https://github.com/icl-utk-edu/blaspp
cd blaspp 
git checkout v2025.05.28

cd $cdir
git clone https://github.com/icl-utk-edu/lapackpp.git
cd lapackpp
git checkout v2025.05.28

cd $cdir
git clone https://github.com/wavefunction91/scalapackpp
cd scalapackpp
git checkout 6397f52cf11c0dfd82a79698ee198a2fce515d81
cd $cdir

git clone https://github.com/robashaw/libecpint.git
cd libecpint
git checkout ee6d75a969bb92535a9ecf2ba4b564a75b7ef84b

cd $cdir

git clone https://github.com/pybind/pybind11.git
cd pybind11
git checkout v3.0.3

cd $cdir

git clone https://github.com/pnnl/NWQ-Sim.git
cd NWQ-Sim
git checkout 1a4f3c49fd7277649b37eb623bd2f4622cb32cdb

cd $cdir
