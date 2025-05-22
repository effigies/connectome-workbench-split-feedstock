#!/usr/bin/env bash

mkdir build
cd build

if [[ "$target_platform" == linux-* ]]; then
    export CXXFLAGS="$CXXFLAGS -lGL -lGLU"
    CMAKE="cmake"
elif [[ "$target_platform" == osx-* ]]; then
    CMAKE="arch -x86_64 cmake"
else
    echo "Unsupported platform: $target_platform"
    exit 1
fi

if [[ "$build_variant" == "qt6" ]]; then
    export WORKBENCH_USE_QT5=FALSE
    export WORKBENCH_USE_QT6=TRUE
elif [[ "$build_variant" == "qt5" ]]; then
    export WORKBENCH_USE_QT5=TRUE
    export WORKBENCH_USE_QT6=FALSE
else
    echo "Unknown build variant: $build_variant"
    exit 1
fi

$CMAKE $CMAKE_ARGS -GNinja \
    -DWORKBENCH_USE_QT5:BOOL=$WORKBENCH_USE_QT5 \
    -DWORKBENCH_USE_QT6:BOOL=$WORKBENCH_USE_QT6 \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DWORKBENCH_MESA_DIR:STRING=$PREFIX \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:STRING=$PREFIX \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    ../src

$CMAKE --build .

ctest --extra-verbose --output-on-failure .

cmake --install .
