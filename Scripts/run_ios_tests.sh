#!/bin/sh

#  run_ios_tests.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 27/08/2022.
#

PROJECT="Tasktive.xcodeproj"
DESTINATION="platform=iOS Simulator,name=iPhone 14 Pro Max"
SCHEME="TasktiveTests"

set -o pipefail && xcodebuild test -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" || exit 1
