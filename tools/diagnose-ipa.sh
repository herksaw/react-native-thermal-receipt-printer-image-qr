#!/bin/bash

# Path to your IPA file
IPA_PATH="$1"

if [ ! -f "$IPA_PATH" ]; then
  echo "Usage: $0 /path/to/YourApp.ipa"
  exit 1
fi

# Create temp folder
TMP_DIR=$(mktemp -d)
echo "Unzipping IPA to $TMP_DIR"
unzip -q "$IPA_PATH" -d "$TMP_DIR"

# Locate .app inside IPA
APP_PATH=$(find "$TMP_DIR" -name "*.app" -type d | head -n 1)
if [ -z "$APP_PATH" ]; then
  echo "Unable to locate .app inside IPA"
  exit 2
fi

echo "Found app bundle at: $APP_PATH"

# Check embedded frameworks
FRAMEWORKS_PATH="$APP_PATH/Frameworks"
if [ ! -d "$FRAMEWORKS_PATH" ]; then
  echo "No embedded frameworks found."
else
  echo "=== Embedded Frameworks ==="
  find "$FRAMEWORKS_PATH" -name "*.framework" -type d | while read FRAMEWORK; do
    echo ""
    echo "Framework: $FRAMEWORK"
    BINARY=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
    BINARY_PATH="$FRAMEWORK/$BINARY"

    if [ -f "$BINARY_PATH" ]; then
      echo "- Binary: $BINARY_PATH"
      echo "- Architectures:"
      lipo -info "$BINARY_PATH"
      echo "- Codesign:"
      codesign --verify --deep --strict --verbose=4 "$FRAMEWORK" 2>&1
    else
      echo "⚠ Binary not found inside framework!"
    fi

    # Check Headers folder
    if [ -d "$FRAMEWORK/Headers" ]; then
      echo "- Headers folder exists"
    else
      echo "⚠ Headers folder missing!"
    fi

    # Check plist type
    PKG_TYPE=$(defaults read "$FRAMEWORK/Info.plist" CFBundlePackageType)
    echo "- Package type: $PKG_TYPE"
  done
fi

# Check main app binary
APP_BINARY=$(defaults read "$APP_PATH/Info.plist" CFBundleExecutable)
APP_BINARY_PATH="$APP_PATH/$APP_BINARY"

if [ -f "$APP_BINARY_PATH" ]; then
  echo ""
  echo "=== Main App Binary ==="
  echo "- Binary: $APP_BINARY_PATH"
  echo "- Architectures:"
  lipo -info "$APP_BINARY_PATH"
  echo "- Codesign:"
  codesign --verify --deep --strict --verbose=4 "$APP_BINARY_PATH" 2>&1
else
  echo "⚠ Main binary not found!"
fi

# Clean up
rm -rf "$TMP_DIR"
echo ""
echo "Diagnostics complete."
