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
repo forall -c "git reset --hard"
repo forall -c "git clean -fdx"
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags
echo "============================"

# Export build environment variables
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

# Install clean
m installclean

# Create the NFC conflict fix script
cat > fix_nfc_conflict.sh << 'EOF'
#!/bin/bash
while true; do
    CONTEXT_FILE="out/soong/.intermediates/system/sepolicy/contexts/vendor_service_contexts/android_common/udon/vendor_service_contexts"
    if [ -f "$CONTEXT_FILE" ]; then
        # Remove the conflicting hal_nfc_service entry, keep vendor_hal_nxpnfc_service
        if grep -q "vendor\.nxp\.nxpnfc_aidl\.INxpNfc/default.*hal_nfc_service:s0" "$CONTEXT_FILE"; then
            sed -i '/vendor\.nxp\.nxpnfc_aidl\.INxpNfc\/default.*hal_nfc_service:s0/d' "$CONTEXT_FILE"
            echo "$(date): Fixed NFC conflict in vendor_service_contexts"
        fi
    fi
    sleep 5
done
EOF

chmod +x fix_nfc_conflict.sh

# Start the fix script in background
echo "Starting NFC conflict monitor..."
./fix_nfc_conflict.sh &
FIX_PID=$!

# Function to cleanup on exit
cleanup() {
    echo "Stopping NFC conflict monitor..."
    kill $FIX_PID 2>/dev/null
    exit
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

# Build rom
echo "Starting build..."
m bacon

# The cleanup function will automatically kill the background script
