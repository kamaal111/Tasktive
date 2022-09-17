#!/bin/sh

#  release_build_ios.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 15/09/2022.
#  

PROJECT="Tasktive.xcodeproj"
DESTINATION="platform=iOS Simulator,name=iPhone 14 Pro Max"
SCHEME="Tasktive"

set -o pipefail && xcodebuild -configuration Release -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" || exit 1
