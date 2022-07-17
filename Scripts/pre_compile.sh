#!/bin/sh

#  pre_compile.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 15/07/2022.
#  

#if which swiftformat >/dev/null; then
#   swiftformat .
#else
#    echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
#fi

if which swiftlint >/dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
