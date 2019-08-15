mkdir cmake-build
cd cmake-build
# rem BUILD TYPES: Release/Debug/RelWithDebInfo/MinSizeRel
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release
cpack
cd ..
