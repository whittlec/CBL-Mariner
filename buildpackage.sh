#!/bin/bash

check_args() {
    if [ -z "$1" ]; then
        echo "Provide spec folder name (SPECS, SPECS-EXTENDED, etc...)"
        exit 1
    fi
    SPEC_FOLDER_NAME=$1
    if [ -z "$2" ]; then
        echo "Provide name of package to build (vim, cpuid, etc...)"
        exit 1
    fi
    PKGNAME=$2
}

check_args "$@"

set -x
ROOT_FOLDER=$(git rev-parse --show-toplevel)
echo Building package $PKGNAME in $ROOT_FOLDER

# Setup SPECS-build folder with requested package spec
sudo make clean-input-srpms clean-expand-specs
rm -rf $ROOT_FOLDER/SPECS-build
mkdir -pv $ROOT_FOLDER/SPECS-build
cp -vr $ROOT_FOLDER/$SPEC_FOLDER_NAME/$PKGNAME $ROOT_FOLDER/SPECS-build

# Build the package
sudo make build-packages PACKAGE_BUILD_LIST="$PKGNAME" PACKAGE_REBUILD_LIST="$PKGNAME" REFRESH_WORKER_CHROOT=n SPECS_DIR=$ROOT_FOLDER/SPECS-build SOURCE_URL=https://cblmarinerstorage.blob.core.windows.net/sources/core REBUILD_TOOLS=y USE_CCACHE=y

exit 0

# Build all packages
sudo make clean-input-srpms clean-expand-specs
time sudo make build-packages REFRESH_WORKER_CHROOT=n SOURCE_URL=https://cblmarinerstorage.blob.core.windows.net/sources/core REBUILD_TOOLS=y USE_CCACHE=y

# Build input srpms
time sudo make input-srpms SOURCE_URL=https://cblmarinerstorage.blob.core.windows.net/sources/core REBUILD_TOOLS=y REFRESH_WORKER_CHROOT=n
