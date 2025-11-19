#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Clean problematic directories
rm -rf out/
rm -rf .repo/repo/
rm -rf device/linaro/hikey
rm -rf device/linaro/hikey-common
rm -rf device/amlogic/yukawa
rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86
rm -rf out/soong
rm -rf out/soong/.intermediates
rm -rf out/soong/.bootstrap
rm -rf out/soong/build.ninja
rm -rf out/target/product/udon/vendor
rm -rf hardware/pixelworks
rm -rf device/oneplus/udon
# Rom source repo
echo -e "${GREEN}Initializing repo...${NC}"
repo init -u https://github.com/LineageOS/android.git -b lineage-23.0 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
echo -e "${GREEN}Cloning local manifests...${NC}"
git clone -b main https://github.com/ICECOLD90191/local_manifests.git .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags

# Export build environment variables
export BUILD_USERNAME=ICECOLD
export BUILD_HOSTNAME=crave
export TZ="Asia/India"

# Performance optimizations
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export CCACHE_MAXSIZE=50G

# Clean again after repo sync
rm -rf device/linaro/hikey
rm -rf device/linaro/hikey-common
rm -rf device/amlogic/yukawa


# Set up build environment
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_udon-bp2a-userdebug
echo "============="

# Install clean
m installclean

# Build rom
m bacon
