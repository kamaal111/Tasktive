#!/bin/sh

#  build_release.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 15/09/2022.
#  

PROJECT="Tasktive.xcodeproj"

if [[ ! -n $SCHEME ]]
then
    echo $SCHEME
    echo "No scheme provided"
    exit 1
fi

if [[ ! -n $DESTINATION ]]
then
    if [[ $SCHEME == "Tasktive" ]]
    then
        DESTINATION="platform=iOS Simulator,name=iPhone 14 Pro Max"
    elif [[ $SCHEME == "TasktiveMac" ]]
    then
        DESTINATION="platform=macOS"
    else
        echo "Invalid scheme provided"
        exit 1
    fi
fi

set -o pipefail && xcodebuild -configuration Release -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" || exit 1
