
#!/bin/bash
rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86

# Rom source repo
repo init --git-lfs --no-clone-bundle -u https://git@github.com/LineageOS/android.git -b refs/changes/42/436442/31
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

# Export
export BUILD_USERNAME=ICECOLD
export BUILD_HOSTNAME=crave
export TZ="Asia/India"
echo "======= Export Done ======"

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
