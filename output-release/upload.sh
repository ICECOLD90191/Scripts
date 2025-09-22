#!/bin/bash
# Upload specific ROM build files to GitHub Release
# Only uploads: ROM zip, recovery.img, vendor_boot.img, boot.img

# Usage:
# bash upload_rom.sh

# GitHub release details
RELEASETAG="lineage-22.2-20250922"
DEVICE="udon"
REPONAME="ICECOLD90191/Outputs"
RELEASETITLE="LineageOS 22.2 UDON-INITIAL"

# GitHub token file
TOKEN_FILE="token.txt"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "Error: $TOKEN_FILE not found! Please create it with your GitHub PAT."
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "gh CLI not found. Installing..."
    curl -sS https://webi.sh/gh | sh
    source ~/.config/envman/PATH.env
fi

# Authenticate gh
gh auth login --with-token < "$TOKEN_FILE"

# Upload size limit (default 2GB)
: ${GH_UPLOAD_LIMIT:=2147483648}
echo "Upload limit set to $GH_UPLOAD_LIMIT bytes"

# Select the ROM zip
ROM_ZIP="lineage-22.2-20250922-udon.zip"
if [[ -f "$ROM_ZIP" && $(stat -c%s "$ROM_ZIP") -le $GH_UPLOAD_LIMIT ]]; then
    ZIP_FILES="$ROM_ZIP"
    echo "Selected ROM zip: $ROM_ZIP"
else
    echo "ROM zip not found or exceeds upload limit!"
    exit 1
fi


# Create release (if it doesn’t exist)
gh release create "$RELEASETAG" --repo "$REPONAME" --title "$RELEASETITLE" --generate-notes

# Upload files
gh release upload "$RELEASETAG" --repo "$REPONAME" $ZIP_FILES 

echo "Upload complete!"
