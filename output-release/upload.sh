#!/bin/bash
# Upload only the ROM zip to GitHub Release
# Ignores all images

# GitHub release details
RELEASETAG="lineage-22.2-20250922"
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

# Find ROM zip in current folder
ROM_ZIP=$(ls lineage-22.2-*.zip 2>/dev/null | head -n 1)

if [[ -z "$ROM_ZIP" ]]; then
    echo "ROM zip not found in current directory!"
    exit 1
fi

echo "Selected ROM zip: $ROM_ZIP"

# Create release (if it doesn’t exist)
gh release create "$RELEASETAG" --repo "$REPONAME" --title "$RELEASETITLE" --generate-notes

# Upload only the ROM zip
gh release upload "$RELEASETAG" --repo "$REPONAME" "$ROM_ZIP"

echo "Upload complete!"
