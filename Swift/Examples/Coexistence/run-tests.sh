#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ $# -ne 1 ]]; then
  echo 'Usage: ./run-tests.sh <available iOS Simulator UDID>' >&2
  echo 'List devices with: xcrun simctl list devices available' >&2
  exit 64
fi
if [[ ! -d CoexistenceApp.xcworkspace ]]; then
  echo 'Generate the project and integrate the real OC dependencies first: bundle exec ./prepare.sh' >&2
  exit 66
fi

mkdir -p TestResults
result="TestResults/Coexistence-$(date -u +%Y%m%dT%H%M%SZ).xcresult"
xcodebuild test \
  -workspace CoexistenceApp.xcworkspace \
  -scheme CoexistenceApp \
  -destination "platform=iOS Simulator,id=$1" \
  -derivedDataPath DerivedData \
  -resultBundlePath "$result" \
  -parallel-testing-enabled NO \
  -only-testing:CoexistenceTests \
  CODE_SIGNING_ALLOWED=NO

echo "Result bundle: $PWD/$result"
