
#!/bin/bash

rm -rf .repo/local_manifests/

# Rom source repo
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b main https://github.com/Mayuresh2543/local_manifests.git .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

rm -rf packages/apps/Updater
git clone https://github.com/Mayuresh2543/lineage_packages_apps_Updater.git --depth=1 packages/apps/Updater
rm -rf packages/apps/Trebuchet
git clone https://github.com/Mayuresh2543/lineage_packages_apps_Trebuchet.git --depth=1 packages/apps/Trebuchet
rm -rf build/release
git clone https://github.com/mayuresh2543/android_build_release.git --depth=1 build/release
echo "Custom sources synced"

# Export
export BUILD_USERNAME=mayuresh
export BUILD_HOSTNAME=crave
export TZ="Asia/India"
echo "======= Export Done ======"

# Set up build environment
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_stone-bp1a-userdebug
echo "============="

# Install clean
m installclean

# Build rom
m bacon
