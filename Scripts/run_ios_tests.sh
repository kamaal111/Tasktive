#!/bin/sh

#  run_ios_tests.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 27/08/2022.
#

PROJECT="Tasktive.xcodeproj"

iOS_destinations=(
  "platform=iOS Simulator,name=iPhone 13 Pro Max"
)

iOS_test_schemes=(
  "Tasktive"
)

xcode_test() {
    set -o pipefail && xcodebuild test -project "$PROJECT" -scheme "$1" -destination "$2" | bundle exec xcpretty || exit 1
}

test_all_destinations() {
  time {
      for destination in "${iOS_destinations[@]}"
      do
        for scheme in "${iOS_test_schemes[@]}"
        do
        echo "testing $scheme on $destination"
        xcode_test "$scheme" "$destination"
        done
    done
  }
}

test_all_destinations
