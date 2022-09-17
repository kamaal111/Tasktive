#!/bin/sh

#  pre_compile.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 15/07/2022.
#  

 if which swiftlint >/dev/null; then
     swiftlint lint --quiet $@ | sed 's/error: /warning: /g'
 else
     echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
 fi
