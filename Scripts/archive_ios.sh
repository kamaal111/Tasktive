#!/bin/sh

#  archive_ios.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 12/09/2022.
#

SCHEME="Tasktive"
WORKSPACE="Tasktive.xcworkspace"
PROJECT_NAME="Tasktivity"
ARCHIVE_PATH="Archive/$PROJECT_NAME.xcarchive"

bundle exec fastlane gym --scheme $SCHEME

# mkdir -p Archive

# xcodebuild -workspace $WORKSPACE -scheme $SCHEME archive -configuration release -sdk iphoneos -archivePath $ARCHIVE_PATH

# xcodebuild -exportArchive -archivePath $ARCHIVE_PATH -exportPath "Archive/$PROJECT_NAME.ipa" -exportOptionsPlist fastlane/ExportOptions.plist
