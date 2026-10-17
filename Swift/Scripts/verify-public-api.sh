#!/bin/bash
set -euo pipefail

# Compile a real Swift 6 library, then consume it without @testable. Keeping the
# SDKROOT explicit also avoids inheriting a macOS SDK from a developer shell.
repo_root=$(cd "$(dirname "$0")/../.." && pwd)
sdk=$(xcrun --sdk iphonesimulator --show-sdk-path)
arch=$(uname -m)
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/lstpop-public-api.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT
export SDKROOT="$sdk"

xcrun --sdk iphonesimulator swiftc \
  -emit-module -emit-library -module-name LSTPopViewSwift \
  -target "$arch-apple-ios15.0-simulator" -sdk "$sdk" \
  -swift-version 6 -strict-concurrency=complete -warnings-as-errors \
  -emit-module-path "$build_dir/LSTPopViewSwift.swiftmodule" \
  -o "$build_dir/libLSTPopViewSwift.dylib" \
  "$repo_root"/Swift/Sources/LSTPopViewSwift/*.swift

xcrun --sdk iphonesimulator swiftc \
  -typecheck -target "$arch-apple-ios15.0-simulator" -sdk "$sdk" \
  -swift-version 6 -strict-concurrency=complete -warnings-as-errors \
  -I "$build_dir" "$repo_root/Swift/Tests/PublicAPIConsumer/Consumer.swift"

echo 'PASS: Swift 6 strict library compilation/linking and external public API consumer.'
