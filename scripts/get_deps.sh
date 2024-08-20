#!/bin/bash

export cdir=`pwd`

echo "Replace L20-21 in TAMM/CMakeLists.txt with: URL $cdir/CMakeBuild"
git clone https://github.com/NWChemEx-Project/CMakeBuild.git
cd CMakeBuild

cd $cdir

git clone https://github.com/wavefunction91/linalg-cmake-modules.git

git clone https://github.com/flame/blis.git
cd blis
git checkout 415893066e966159799d96166cadcf9bb5535b1c

cd $cdir

wget https://github.com/OpenMathLib/OpenBLAS/releases/download/v0.3.27/OpenBLAS-0.3.27.tar.gz

wget https://github.com/doctest/doctest/archive/refs/tags/v2.4.9.tar.gz

git clone https://gitlab.com/libeigen/eigen.git
cd eigen
git checkout e887196d9d67e48c69168257d599371abf1c3b31

cd $cdir

git clone https://github.com/GlobalArrays/ga.git
cd ga
git checkout develop

cd $cdir
wget https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_1.14.4.3.tar.gz

git clone https://github.com/ajaypanyala/hptt.git
cd hptt
git checkout eff1bdd79734ddc4993dd4df1d0cdbd40758b9cb

cd $cdir
wget https://github.com/evaleev/libint/releases/download/v2.9.0/libint-2.9.0.tgz

git clone https://github.com/victor-anisimov/Librett.git
cd Librett
git checkout 8273ac6989cb412a08fdb59bfc9783d93f2aa372

git clone https://github.com/Microsoft/GSL.git
cd GSL
git checkout 3ba80d5dd465828909e1ee756b8c437d5e820ccc

cd $cdir

git clone https://github.com/nlohmann/json.git
cd json
git checkout 3.11.3

cd $cdir

git clone git clone https://github.com/gabime/spdlog
cd spdlog
git checkout v1.14.1

cd $cdir

git clone https://github.com/Reference-LAPACK/lapack.git
cd lapack
git checkout 8b468db25c0c5a25d8e0020c7e2134e14cfd33d0

cd $cdir
git clone https://github.com/Reference-ScaLAPACK/scalapack.git
cd scalapack
git checkout 0234af94c6578c53ac4c19f2925eb6e5c4ad6f0f

cd $cdir

git clone https://bitbucket.org/icl/blaspp.git
cd blaspp 
git checkout v2024.05.31

cd $cdir
git clone https://bitbucket.org/icl/lapackpp.git
cd lapackpp
git checkout v2024.05.31

cd $cdir
git clone https://github.com/wavefunction91/scalapackpp
cd scalapackpp
git checkout 6397f52cf11c0dfd82a79698ee198a2fce515d81
cd $cdir

git clone https://github.com/robashaw/libecpint.git
cd libecpint
git checkout ee6d75a969bb92535a9ecf2ba4b564a75b7ef84b

cd $cdir
