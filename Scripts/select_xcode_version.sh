#!/bin/sh

#  select_xcode_version.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 11/09/2022.
#  

echo "listing available Xcode versions:"
ls -d /Applications/Xcode*

sudo xcode-select --switch /Applications/$XCODE_APP_NAME/Contents/Developer
