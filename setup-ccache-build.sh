#!/bin/bash

set -x
ROOT_FOLDER=$(git rev-parse --show-toplevel)
SPEC_FOLDER_NAME=SPECS

# Cleanup
sudo make clean-input-srpms clean-expand-specs
rm -rf $ROOT_FOLDER/SPECS-build
mkdir -pv $ROOT_FOLDER/SPECS-build

# Setup 2.0-stable toolchain
wget https://raw.githubusercontent.com/microsoft/CBL-Mariner/2.0-stable/toolkit/resources/manifests/package/toolchain_x86_64.txt -O $ROOT_FOLDER/toolkit/resources/manifests/package/toolchain_x86_64.txt
wget https://raw.githubusercontent.com/microsoft/CBL-Mariner/2.0-stable/toolkit/resources/manifests/package/pkggen_core_x86_64.txt -O $ROOT_FOLDER/toolkit/resources/manifests/package/pkggen_core_x86_64.txt
sudo make toolchain REBUILD_TOOLCHAIN=n
sudo make copy-toolchain-rpms

# Build and configure newer macros package in toolchain
PKGNAME2=mariner-rpm-macros
cp -vr $ROOT_FOLDER/$SPEC_FOLDER_NAME/$PKGNAME2 $ROOT_FOLDER/SPECS-build
sudo make build-packages PACKAGE_BUILD_LIST="$PKGNAME2" PACKAGE_REBUILD_LIST="$PKGNAME2" RUN_CHECK=n REFRESH_WORKER_CHROOT=n SPECS_DIR=$ROOT_FOLDER/SPECS-build SOURCE_URL=https://cblmarinerstorage.blob.core.windows.net/sources/core REBUILD_TOOLS=y SRPM_FILE_SIGNATURE_HANDLING=update USE_CCACHE=n
sudo cp -v ../out/RPMS/noarch/mariner-rpm-macros-2.0-20.cm2.noarch.rpm ../build/rpm_cache/cache/noarch/
sudo cp -v ../out/RPMS/noarch/mariner-check-macros-2.0-20.cm2.noarch.rpm ../build/rpm_cache/cache/noarch/
sed -i "s/2.0-19/2.0-20/g" resources/manifests/package/*.txt

# Build ccache
PKGNAME2=ccache
sudo make clean-input-srpms clean-expand-specs
rm -rf $ROOT_FOLDER/SPECS-build
mkdir -pv $ROOT_FOLDER/SPECS-build
cp -vr $ROOT_FOLDER/$SPEC_FOLDER_NAME/$PKGNAME2 $ROOT_FOLDER/SPECS-build
sudo make build-packages PACKAGE_BUILD_LIST="$PKGNAME2" PACKAGE_REBUILD_LIST="$PKGNAME2" RUN_CHECK=n REFRESH_WORKER_CHROOT=n SPECS_DIR=$ROOT_FOLDER/SPECS-build SOURCE_URL=https://cblmarinerstorage.blob.core.windows.net/sources/core REBUILD_TOOLS=y SRPM_FILE_SIGNATURE_HANDLING=update USE_CCACHE=n

# Configure ccache
mkdir -pv $ROOT_FOLDER/ccache/
sudo rm -vf $ROOT_FOLDER/ccache/ccache.conf
echo "max_size = 100G" > ccache.conf 
sudo mv -v ccache.conf $ROOT_FOLDER/ccache/
