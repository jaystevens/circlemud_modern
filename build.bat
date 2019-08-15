@echo off
mkdir cmake-build
cd cmake-build
rem BUILD TYPES: Release/Debug/RelWithDebInfo/MinSizeRel
cmake -G "Visual Studio 16 2019" -A x64 -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release
cpack
cd ..
@echo on
