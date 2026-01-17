#!/bin/bash

rm -rf .repo/local_manifests/

# Rom source repo
repo init -u https://github.com/LineageOS/android.git -b lineage-23.0 --git-lfs --depth=1
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b main https://github.com/ICECOLD90191/local_manifests.git .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
repo sync -c --no-tags --no-clone-bundle -j$(nproc --all) --force-sync

echo "============================"

# Export build environment variables
export BUILD_USERNAME=ICECOLD
export BUILD_HOSTNAME=GARUDA
export TZ="Asia/India"

# Clean again after repo sync

# Set up build environment
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_udon-bp2a-eng
echo "============="

# Build rom
m bacon
