#!/bin/bash

# Clean problematic directories
rm -rf device/linaro/hikey
rm -rf device/linaro/hikey-common
rm -rf device/amlogic/yukawa
rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86
rm -rf out/soong
rm -rf out/target/product/udon/vendor

# Rom source repo
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b main https://github.com/ICECOLD90191/local_manifests.git .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
#/opt/crave/resync.sh
repo forall -c "git reset --hard"
repo forall -c "git clean -fdx"
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags
echo "============================"

# Export build environment variables (MOVED BEFORE envsetup)
export BUILD_USERNAME=ICECOLD
export BUILD_HOSTNAME=crave
export TZ="Asia/India"

# Clean again after repo sync
rm -rf device/linaro/hikey
rm -rf device/linaro/hikey-common
rm -rf device/amlogic/yukawa

# Set up build environment
. build/envsetup.sh

# Lunch
lunch lineage_udon-bp1a-userdebug

m installclean

# Build rom
m bacon
