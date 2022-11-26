#!/bin/bash

#  import_signing_certificate.bash
#  Tasktive
#
#  Created by Kamaal M Farah on 11/09/2022.
#  

set -euo pipefail

security create-keychain -p "$KEYCHAIN_PASSPHRASE" build.keychain
security list-keychains -s build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "$KEYCHAIN_PASSPHRASE" build.keychain
security set-keychain-settings

security import <(echo $SIGNING_CERTIFICATE_P12_DATA | base64 --decode) \
                -f pkcs12 \
                -k build.keychain \
                -P $SIGNING_CERTIFICATE_PASSWORD \
                -T /usr/bin/codesign

security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSPHRASE" build.keychain
