#!/bin/bash

#  import_provisioning_profile.bash
#  Tasktive
#
#  Created by Kamaal M Farah on 11/09/2022.
#  

set -euo pipefail

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
echo "$PROVISIONING_PROFILE_DATA" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision

ls ~/Library/MobileDevice/Provisioning\ Profiles

echo "Provisioning profile created"
