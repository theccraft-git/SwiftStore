#!/usr/bin/env bash
set -euo pipefail

if ! command -v swift >/dev/null 2>&1; then
  echo "swift not found. Install Swift toolchain or use macOS with Xcode."
  exit 1
fi

echo "Building..."
swift build
echo "Testing..."
swift test
