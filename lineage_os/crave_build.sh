#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting LineageOS 22.2 build with ultimate NFC fix...${NC}"

# Clean problematic directories
echo -e "${YELLOW}Cleaning problematic directories...${NC}"
rm -rf out/
rm -rf .repo/repo/
rm -rf device/linaro/hikey
rm -rf device/linaro/hikey-common
rm -rf device/amlogic/yukawa
rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86
rm -rf out/soong
rm -rf out/target/product/udon/vendor

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
echo -e "${GREEN}Syncing repositories...${NC}"
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags
echo "============================"

#disable fsgen 
rm -rf build/soong
git clone -b lineage-22.2 https://github.com/ICECOLD90191/android_build_soong.git build/soong

# Export build environment variables
echo -e "${GREEN}Setting up build environment...${NC}"
export BUILD_USERNAME=ICECOLD
export BUILD_HOSTNAME=crave
export TZ="Asia/India"

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
echo -e "${GREEN}Setting up build environment...${NC}"
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
echo -e "${GREEN}Running lunch command...${NC}"
lunch lineage_udon-ap4a-userdebug
echo -e "${GREEN}Lunch completed successfully${NC}"

# Install clean
echo -e "${YELLOW}Cleaning previous build artifacts...${NC}"
m installclean

# Create the ultimate NFC conflict fix script
echo -e "${GREEN}Creating ultimate NFC conflict resolution system...${NC}"
cat > ultimate_nfc_fix.sh << 'EOF'
#!/bin/bash

echo "$(date): Starting ultimate NFC conflict resolution monitor..."

# Function to fix the file immediately when it appears
fix_nfc_file() {
    local context_file="out/soong/.intermediates/system/sepolicy/contexts/vendor_service_contexts/android_common/udon/vendor_service_contexts"
    
    if [ -f "$context_file" ]; then
        # Check if conflict exists
        local conflicts=$(grep -c "vendor\.nxp\.nxpnfc_aidl\.INxpNfc/default" "$context_file" 2>/dev/null || echo "0")
        
        if [ "$conflicts" -gt 1 ]; then
            echo "$(date): *** CONFLICT DETECTED *** Found $conflicts NFC entries"
            
            # Show what we found
            echo "Current conflicting entries:"
            grep "vendor\.nxp\.nxpnfc_aidl\.INxpNfc/default" "$context_file" || echo "None found"
            
            # Make backup
            cp "$context_file" "$context_file.backup.$(date +%s)"
            
            # Remove ONLY the hal_nfc_service entry, keep vendor_hal_nxpnfc_service
            sed -i '/vendor\.nxp\.nxpnfc_aidl\.INxpNfc\/default.*u:object_r:hal_nfc_service:s0/d' "$context_file"
            
            echo "$(date): *** FIXED *** Removed hal_nfc_service entry"
            echo "Remaining entries after fix:"
            grep "vendor\.nxp\.nxpnfc_aidl\.INxpNfc/default" "$context_file" || echo "No NFC entries remaining"
            
        elif [ "$conflicts" -eq 1 ]; then
            echo "$(date): NFC service found - no conflicts detected"
        fi
    fi
}

# Monitor continuously with maximum frequency
iteration=0
while true; do
    fix_nfc_file
    
    # Progress indicator every 30 seconds
    if [ $((iteration % 30)) -eq 0 ]; then
        echo "$(date): NFC monitor active (iteration $iteration)"
    fi
    
    iteration=$((iteration + 1))
    sleep 1
done
EOF

chmod +x ultimate_nfc_fix.sh

# Function to cleanup on exit
cleanup() {
    echo -e "${YELLOW}Cleaning up background processes...${NC}"
    if [ ! -z "$ULTIMATE_PID" ] && kill -0 $ULTIMATE_PID 2>/dev/null; then
        echo "Stopping NFC conflict monitor (PID: $ULTIMATE_PID)..."
        kill $ULTIMATE_PID 2>/dev/null
        sleep 2
        kill -9 $ULTIMATE_PID 2>/dev/null
    fi
    echo -e "${GREEN}Cleanup completed${NC}"
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

# Start the ultimate monitor in background
echo -e "${GREEN}Starting ultimate NFC conflict monitor...${NC}"
./ultimate_nfc_fix.sh &
ULTIMATE_PID=$!

echo -e "${GREEN}NFC monitor started successfully (PID: $ULTIMATE_PID)${NC}"
echo -e "${YELLOW}Monitor will automatically fix NFC conflicts during build...${NC}"

# Wait a moment for monitor to initialize
sleep 3

# Start the build with full logging
echo -e "${GREEN}Starting ROM build at $(date)...${NC}"
echo -e "${YELLOW}Build progress will be logged to build_log.txt${NC}"

# Run build with comprehensive logging
time m bacon 2>&1 | tee build_log.txt

# Check build result
BUILD_EXIT_CODE=${PIPESTATUS[0]}

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ BUILD COMPLETED SUCCESSFULLY!${NC}"
    echo -e "${GREEN}ROM location: out/target/product/udon/lineage-*.zip${NC}"
    ls -lah out/target/product/udon/lineage-*.zip 2>/dev/null || echo "ZIP file check failed"
    echo -e "${GREEN}Build completed at $(date)${NC}"
else
    echo -e "${RED}❌ BUILD FAILED!${NC}"
    echo -e "${RED}Exit code: $BUILD_EXIT_CODE${NC}"
    echo -e "${YELLOW}Check build_log.txt and the error messages above${NC}"
    echo -e "${YELLOW}Last 50 lines of build log:${NC}"
    tail -50 build_log.txt | grep -E "FAILED:|error:|Error:" || echo "No obvious errors in tail"
fi

# The cleanup function will automatically run due to trap
