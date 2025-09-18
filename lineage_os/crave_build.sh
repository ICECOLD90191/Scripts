#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting LineageOS build process...${NC}"

# Clean problematic directories
echo -e "${YELLOW}Cleaning problematic directories...${NC}"
rm -rf device/linaro/hikey
rm -rf device/linaro/hikey-common
rm -rf device/amlogic/yukawa
rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86

# Rom source repo
echo -e "${GREEN}Initializing repo...${NC}"
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs
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
echo -e "${GREEN}Syncing repositories...${NC}"
#/opt/crave/resync.sh
repo forall -c "git reset --hard"
repo forall -c "git clean -fdx"
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags
echo "============================"

# Export build environment variables (MOVED BEFORE envsetup)
echo -e "${GREEN}Setting up build environment...${NC}"
export BUILD_USERNAME=ICECOLD
export BUILD_HOSTNAME=crave
export TZ="Asia/India"

# DOLBY CONFLICT FIXES - Must be set before envsetup
export TARGET_SUPPORTS_32_BIT_APPS=false
export BOARD_VNDK_VERSION=33
export TARGET_ARCH_VARIANT=armv8-a
export TARGET_PREFER_32_BIT=false
export BOARD_USES_DOLBY=true
export TARGET_COPY_OUT_VENDOR=vendor

# Performance optimizations
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export CCACHE_MAXSIZE=50G

echo "======= Environment Setup Done ======"

# Clean again after repo sync
rm -rf device/linaro/hikey
rm -rf device/linaro/hikey-common
rm -rf device/amlogic/yukawa

# Set up build environment
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_udon-bp1a-userdebug
echo -e "${GREEN}Lunch completed for udon${NC}"

# Install clean
echo -e "${YELLOW}Cleaning previous build...${NC}"
m installclean

# Build rom
echo -e "${GREEN}Starting ROM build at $(date)...${NC}"
time m bacon

# Check build result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo -e "${GREEN}ROM location: out/target/product/udon/lineage-*.zip${NC}"
    ls -lah out/target/product/udon/lineage-*.zip 2>/dev/null || echo "ZIP file check failed"
else
    echo -e "${RED}❌ Build failed!${NC}"
    echo -e "${RED}Check the error messages above${NC}"
    exit 1
fi
