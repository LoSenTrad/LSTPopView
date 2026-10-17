#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# Use `bundle exec ./prepare.sh` after `bundle install` so both commands share
# the pinned Ruby dependencies. Alternatively supply a Ruby environment that
# already has the same CocoaPods and xcodeproj gems installed.
ruby ./generate-project.rb
pod install
