#!/bin/sh

#  archive_ios.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 12/09/2022.
#

SCHEME="Tasktive"

bundle exec fastlane gym --scheme $SCHEME
