#!/bin/bash

cd ../
BUILD_FILE_NAME="build.pkr.hcl"

for build_file in $(find ./ -name $BUILD_FILE_NAME); do
    BUILD_DIR=${build_file%${BUILD_FILE_NAME}}
    echo "Building $BUILD_DIR"

    cd $BUILD_DIR

    BUILD_OUTPUT=$(./build.sh)
    RESULT=$?

    if [[ $RESULT == 1 ]]; then
        echo "There was an error: "
        echo $BUILD_OUTPUT
    else
        echo "Build Successful..."
    fi

    cd ../
    echo
done
